# Настройка Teleport для доступа к Jenkins, Jira, GitLab и создание бота (Machine ID)

## Введение

В этой статье описан опыт настройки Teleport Community (Enterprise) для централизованного доступа к внутренним веб-приложениям: Jenkins, Jira, GitLab. Также рассмотрено создание бота (Machine ID) для автоматизации. Основной фокус — на проблемах редиректов, возникающих из-за особенностей каждого приложения, и способах их решения.

---

## 1. Архитектура и предварительные требования

- **Teleport сервер (jumpserver)**: IP `192.168.87.238`, домен `teleport.runtel.org`
- **Jenkins**: IP `192.168.87.11`, порт `8080`, работает с префиксом `/web/app/jenkins`
- **Jira**: IP `192.168.46.4`, порт `8080` (или `8082`)
- **GitLab**: IP `192.168.46.5` (условно), домен `gitlab.runtel.org`
- **Grafana**: IP `192.168.87.209`, порт `3000`

Все приложения должны быть доступны с сервера Teleport по указанным внутренним адресам.

---

## 2. Общая философия: почему одни приложения работают «из коробки», а другие нет

Проблема редиректов возникает из-за того, как каждое приложение генерирует абсолютные ссылки:

| Приложение | Поведение за прокси | Причина |
|------------|---------------------|---------|
| **Jenkins** | ✅ Работает без смены Base URL | Использует относительные ссылки и доверяет заголовку `X-Forwarded-Host` |
| **GitLab** | ❌ Редиректит на `external_url` | Жёстко привязан к своему `external_url`, игнорирует заголовки |
| **Jira** | ❌ Редиректит на `Base URL` | Аналогично GitLab, требуется смена Base URL |
| **Grafana** | ✅ Работает через `root_url` | Поддерживает настройку `root_url` в конфиге |

**Вывод:** Для Jenkins и Grafana достаточно настроить Teleport и добавить правильные заголовки. Для Jira и GitLab необходимо изменить их внутренний базовый URL.

---

## 3. Настройка приложений в Teleport

### 3.1. Единый подход через `app_service` в `teleport.yaml`

Все приложения добавляются в секцию `app_service` основного конфига. Это самый надёжный способ.

```yaml
app_service:
  enabled: yes
  apps:
    - name: jenkins
      uri: http://192.168.87.11:8080/web/app/jenkins
      public_addr: jenkins.teleport.runtel.org
      rewrite:
        headers:
          - name: "Remote-User"
            value: "{client_cert_subject}"
          - name: "X-Forwarded-User"
            value: "{client_cert_subject}"
          - name: "X-Forwarded-For"
            value: "{client_ip}"
          - name: "X-Forwarded-Host"
            value: "jenkins.runtel.ru"
          - name: "X-Forwarded-Proto"
            value: "https"

    - name: jira
      uri: http://192.168.46.4:8080
      public_addr: jira.teleport.runtel.org
      rewrite:
        headers:
          - name: "X-Forwarded-For"
            value: "{client_ip}"
          - name: "X-Forwarded-Host"
            value: "jira.teleport.runtel.ru"
          - name: "X-Forwarded-Proto"
            value: "https"

    - name: gitlab
      uri: https://gitlab.runtel.org
      public_addr: gitlab.teleport.runtel.org
      rewrite:
        headers:
          - name: "X-Forwarded-For"
            value: "{client_ip}"
          - name: "X-Forwarded-Host"
            value: "gitlab.runtel.org"
          - name: "X-Forwarded-Proto"
            value: "https"

    - name: grafana
      uri: http://192.168.87.209:3000
      public_addr: grafana.teleport.runtel.org
```

### 3.2. Добавление DNS-записей (или /etc/hosts)

На сервере Teleport (jumpserver) необходимо добавить записи для всех `public_addr`, чтобы Teleport мог резолвить их в свои внутренние IP:

```bash
echo "192.168.87.238 jenkins.teleport.runtel.org" >> /etc/hosts
echo "192.168.87.238 jira.teleport.runtel.org" >> /etc/hosts
echo "192.168.87.238 gitlab.teleport.runtel.org" >> /etc/hosts
echo "192.168.87.238 grafana.teleport.runtel.org" >> /etc/hosts
```

На рабочей машине пользователя также нужно добавить эти записи, либо настроить реальный DNS.

---

## 4. Настройка самих приложений для работы за прокси

### 4.1. Jenkins (гибкий, не требует смены Base URL)

В `/etc/default/jenkins` добавлен параметр `--prefix`:

```bash
JENKINS_ARGS="--webroot=/var/cache/jenkins/war --httpPort=8080 --httpListenAddress=0.0.0.0 --prefix=/web/app/jenkins"
```

В `jenkins.service.d/proxy.conf` добавлены настройки прокси и доверия к заголовкам:

```ini
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.forwarded.proto.trusted=192.168.87.238 -Dhudson.security.Realm=jenkins.security.HeaderAuthenticationRealm"
```

**Почему нет редиректа:** Jenkins использует относительные ссылки в UI и доверяет заголовку `X-Forwarded-Host`.

---

### 4.2. GitLab (жёсткий, требуется смена `external_url`)

В `/etc/gitlab/gitlab.rb`:

```ruby
external_url 'https://gitlab.teleport.runtel.org'
gitlab_rails['trusted_proxies'] = ['192.168.87.238']
nginx['real_ip_header'] = 'X-Forwarded-For'
nginx['real_ip_recursive'] = 'on'
```

**Почему редирект:** GitLab игнорирует заголовки и жёстко привязан к `external_url`. Без его смены будет бесконечный редирект.

---

### 4.3. Jira (аналогично GitLab)

В `/var/atlassian/jira/atlassian-jira/WEB-INF/classes/jira-application.properties`:

```properties
jira.baseurl=https://jira.teleport.runtel.org
```

Также в `server.xml` Tomcat добавляются `proxyName` и `proxyPort`.

**Почему редирект:** Jira использует `Base URL` для генерации всех абсолютных ссылок.

---

### 4.4. Grafana (гибкая, достаточно `root_url`)

В `/etc/grafana/grafana.ini`:

```ini
[server]
root_url = https://grafana.teleport.runtel.org
```

**Почему нет редиректа:** Grafana поддерживает настройку `root_url` и корректно работает за прокси.

---

## 5. Создание бота (Machine ID) для Jenkins

Бот позволяет Jenkins'у получать короткоживущие сертификаты для доступа к другим серверам через Teleport.

### 5.1. На сервере Teleport: создание бота

```bash
tctl bots add jenkins-bot --roles=jenkins-bot
```

Сохранить полученный токен.

### 5.2. На сервере Jenkins: установка и настройка `tbot`

```bash
# Скачать и установить tbot
cd /tmp
curl -O https://cdn.teleport.dev/teleport-v18.7.3-linux-amd64-bin.tar.gz
tar -xzf teleport-v18.7.3-linux-amd64-bin.tar.gz
cd teleport
sudo ./install
```

Создать конфиг `/etc/tbot.yaml`:

```yaml
version: v2
proxy_server: "teleport.runtel.org:443"
onboarding:
  token: "<токен_бота>"
storage:
  type: directory
  path: /var/lib/teleport/bot
destinations:
  - type: directory
    path: /opt/machine-id
```

Создать systemd-сервис (вручную, если команда `tbot install` недоступна):

```ini
[Unit]
Description=Teleport Machine ID Service (tbot)
After=network.target

[Service]
Type=simple
User=teleport
Group=teleport
ExecStart=/usr/local/bin/tbot start --config=/etc/tbot.yaml --join-method=token --token=<токен_бота>
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Запустить:

```bash
sudo systemctl daemon-reload
sudo systemctl enable tbot --now
```

### 5.3. Использование сертификатов в Jenkins Pipeline

```groovy
sh '''
    ssh -i /opt/machine-id/key \
        -o CertificateFile=/opt/machine-id/key-cert.pub \
        -o GlobalKnownHostsFile=/opt/machine-id/sshcacerts \
        -o StrictHostKeyChecking=no \
        user@target-server "command"
'''
```

---

## 6. Проблемы редиректов: причины и решения

| Приложение | Наличие редиректа | Решение |
|------------|-------------------|---------|
| **Jenkins** | Нет | Настроить `--prefix` и заголовки в Teleport |
| **GitLab** | Да (без смены `external_url`) | Сменить `external_url` на адрес Teleport |
| **Jira** | Да (без смены `Base URL`) | Сменить `Base URL` на адрес Teleport |
| **Grafana** | Нет | Указать `root_url` в конфиге |

### 6.1. Почему Jenkins не редиректит?

Jenkins использует **относительные ссылки** в веб-интерфейсе. При заходе через `https://jenkins.teleport.runtel.org` он генерирует ссылки вида `/job/...`, которые браузер интерпретирует относительно текущего `Host`. Абсолютные ссылки Jenkins использует только для внешних уведомлений (почта). Поэтому его не нужно перенастраивать.

### 6.2. Почему GitLab и Jira редиректят?

Оба приложения генерируют **абсолютные ссылки** на основе своего внутреннего `external_url` (GitLab) или `Base URL` (Jira). При заходе с другого домена они делают редирект на «свой» канонический адрес.

### 6.3. Как определить, будет ли приложение редиректить?

Проверь в исходном коде или документации:
- Использует ли приложение **абсолютные ссылки** в UI?
- Можно ли переопределить `Host` через заголовок `X-Forwarded-Host`?
- Есть ли встроенная поддержка прокси (настройка `root_url`, `--prefix`, `proxyName`)?

---

## 7. Полезные команды для диагностики

```bash
# Проверка конфигурации Teleport
tctl get apps

# Проверка, что Teleport видит приложение
curl -v https://teleport.runtel.org/web/launch/<app_name> --insecure

# Проверка доступности приложения с jumpserver
curl -v http://<ip_app>:<port>

# Логи Teleport
sudo journalctl -u teleport -f

# Логи приложений (Jenkins, GitLab, Jira, Grafana)
sudo journalctl -u jenkins -f
sudo gitlab-ctl tail
sudo journalctl -u grafana-server -f
```

---

## 8. Итоги и рекомендации

1. **Teleport** — отличный инструмент для централизованного доступа, но поведение приложений за прокси зависит от их архитектуры.
2. **Jenkins** и **Grafana** — «гибкие»: достаточно настроить заголовки и префиксы.
3. **GitLab** и **Jira** — «жёсткие»: необходимо изменить их базовый URL на адрес Teleport.
4. **Бот (Machine ID)** позволяет Jenkins получать сертификаты для безопасного доступа к другим серверам без хранения паролей.
5. Всегда проверяй доступность приложения с сервера Teleport (curl) перед добавлением в Teleport.

### Финальная архитектура:

```
Пользователь → Teleport (единый вход) → Jenkins / Jira / GitLab / Grafana
```

Все сервисы доступны через единый интерфейс, с единой аутентификацией (Keycloak) и аудитом.

---

**Примечание:** Если приложение не поддерживает работу за прокси, всегда можно использовать `tsh apps login` или SSH-туннель.



