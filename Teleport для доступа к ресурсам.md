# Настройка Teleport для доступа к Jenkins, Jira, GitLab, Grafana и создание бота (Machine ID)

## Введение

В этой статье описан реальный опыт настройки **Teleport Enterprise** для централизованного доступа к внутренним веб-приложениям: Jenkins, Jira, GitLab, Grafana. Также рассмотрено создание бота (Machine ID) для автоматизации. Основной фокус — на проблемах редиректов, возникающих из-за особенностей каждого приложения, и способах их решения.

---

## Используемая инфраструктура

| Компонент | IP-адрес | Порт | Внутренний адрес | Адрес в Teleport |
|-----------|----------|------|------------------|------------------|
| **Teleport (jumpserver)** | 192.168.87.238 | 443 | — | teleport.runtel.org |
| **Jenkins** | 192.168.87.11 | 8080 | http://192.168.87.11:8080/web/app/jenkins | jenkins.teleport.runtel.org |
| **Jira** | 192.168.46.4 | 8080 | http://192.168.46.4:8080 | jira.teleport.runtel.org |
| **GitLab** | 192.168.46.4 | 443 (HTTPS) | https://gitlab.runtel.org | gitlab.teleport.runtel.org |
| **Grafana** | 192.168.87.209 | 3000 | http://192.168.87.209:3000 | grafana.teleport.runtel.org |

**Важно:** Все приложения доступны с сервера Teleport по указанным внутренним адресам (проверено через `curl`).

---

## 1. Почему одни приложения работают «из коробки», а другие — нет?

В ходе настройки мы столкнулись с разным поведением приложений за прокси:

| Приложение | Поведение | Причина |
|------------|-----------|---------|
| **Jenkins** | ✅ Работает без смены Base URL | Использует относительные ссылки и доверяет заголовку `X-Forwarded-Host` |
| **Grafana** | ✅ Работает через `root_url` | Поддерживает настройку `root_url` в конфиге |
| **GitLab** | ❌ Редиректит на `external_url` | Жёстко привязан к своему `external_url`, игнорирует заголовки |
| **Jira** | ❌ Редиректит на `Base URL` | Аналогично GitLab, требуется смена Base URL |

**Вывод:** Jenkins и Grafana — гибкие, их достаточно настроить через заголовки или параметры. GitLab и Jira — жёсткие, требуют изменения внутреннего базового URL.

---

## 2. Настройка Teleport

### 2.1. Основной конфиг `/etc/teleport.yaml`

Teleport настроен как единый proxy + auth. В секцию `app_service` добавлены все приложения:

```yaml
version: v3
teleport:
  auth_token: /var/lib/teleport/token # auth_token generated in the previous step.
  ca_pin: ###### # ca_pin generated in the previous step.
  nodename: teleport.runtel.org
  advertise_ip: 192.168.87.238
  cache:
    type: in-memory
  log:
    output: stderr
    severity: DEBUG
  data_dir: /var/lib/teleport
  storage:
    type: dir
    path: /var/lib/teleport/backend
  auth_server: 192.168.87.238:3025 # HAProxy IP address or the DNS name pointing to port 3025

auth_service:
  enabled: yes
  license_file: /var/lib/teleport/license.pem
  keep_alive_interval: 1m
  keep_alive_count_max: 3
  listen_addr: 192.168.87.238:3025
  public_addr: 192.168.87.238:3025
  proxy_listener_mode: multiplex
  authentication:
    type: local
    require_session_mfa: false
#    second_factor: off
  cluster_name: teleport-runtel


windows_desktop_service:
  enabled: yes
  listen_addr: 192.168.87.238:3389
  static_hosts:
  - name: win10
    ad: false
    addr: 192.168.87.114
    labels:
      datacenter: teleport-runtel

ssh_service:
  enabled: no

proxy_service:
#  license_file: /var/lib/teleport/license.pem
  enabled: yes
  listen_addr: 0.0.0.0:3023
  tunnel_listen_addr: 0.0.0.0:3080
  web_listen_addr: 0.0.0.0:443
  public_addr: teleport.runtel.org:443
  ssh_public_addr: teleport.runtel.org:3023
  tunnel_public_addr: teleport.runtel.org:443
  https_keypairs:
#    - cert_file: /etc/wc_runtelorg.crt #cert file generated for the domain name of public_addr 
#      key_file: /etc/wc_runtelorg.key #key file generated for the domain name of public_addr
    - cert_file: /etc/runtelorg.crt #cert file generated for the domain name of public_addr 
      key_file: /etc/runtelorg.key #key file generated for the domain name of public_addr


# секция добавлена в рамках добавления входа на ресурсы через теккущий севрер Teleport
app_service:
  enabled: yes
  apps:
    - name: jenkins
      uri: http://192.168.87.11:8080
      public_addr: jenkins.teleport.runtel.org

    - name: jira
      uri: http://192.168.46.4:8080
      public_addr: jira.teleport.runtel.org

    - name: gitlab
      uri: https://gitlab.runtel.org
      public_addr: gitlab.teleport.runtel.org

    - name: grafana
      uri: http://192.168.87.209:3000
      public_addr: grafana.teleport.runtel.org
```

### 2.2. Дополнительные файлы конфигурации в `/etc/teleport.d/`

Для более гибкой настройки заголовков мы использовали отдельные файлы:

#### **`jenkins-app.yaml`**
```yaml
kind: app
version: v3
metadata:
  name: jenkins
spec:
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
```

#### **`jira-app.yaml`**
```yaml
kind: app
version: v3
metadata:
  name: jira
spec:
  uri: http://192.168.46.4:8080
  public_addr: jira.teleport.runtel.org
  rewrite:
    headers:
      - name: "X-Forwarded-For"
        value: "{client_ip}"
      - name: "X-Forwarded-Host"
        value: "jira.runtel.ru"
      - name: "X-Forwarded-Proto"
        value: "https"
```

#### **`gitlab-app.yaml`**
```yaml
kind: app
version: v3
metadata:
  name: gitlab
spec:
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
```

#### **`grafana-app.yaml`**
```yaml
kind: app
version: v3
metadata:
  name: grafana
spec:
  uri: http://192.168.87.209:3000
  public_addr: grafana.teleport.runtel.org
  rewrite:
    headers:
      - name: "Origin"
        value: "https://grafana.teleport.runtel.org"
      - name: "Host"
        value: "grafana.teleport.runtel.org"
```

### 2.3. Применение конфигурации

```bash
# создать конфиг для Grafana в  Teleport
tctl create -f /etc/teleport.d/grafana-app.yaml

sudo systemctl restart teleport
tctl get apps   # проверка, что все приложения появились
```
```bash
# удалить конфиг
tctl rm app/grafana

# проверить конфиг
tctl get app/grafana

# проверить конфиги
tctl get apps
```


### 2.4. ***ОПЦИОНАЛЬНО!*** DNS (файл `/etc/hosts`)

На сервере Teleport (jumpserver) добавлены записи:

```
192.168.87.238 teleport.runtel.org
192.168.87.238 teleport-proxy
192.168.87.209 grafana.teleport.runtel.org
```

***Не обязательно!*** На рабочей машине пользователя также добавлены записи для всех `public_addr`:

```
192.168.87.238 jenkins.teleport.runtel.org
192.168.87.238 jira.teleport.runtel.org
192.168.87.238 gitlab.teleport.runtel.org
192.168.87.238 grafana.teleport.runtel.org
```

---

## 3. Настройка приложений для работы за прокси

### 3.1. Jenkins (гибкий, без смены Base URL)

**Сервер:** `jenkins-updated` (192.168.87.11)

Jenkins настроен с префиксом `/web/app/jenkins`, чтобы правильно обрабатывать пути через Teleport.

#### **`/etc/default/jenkins`:**
```bash
#JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT"
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=0.0.0.0 --prefix=/web/app/jenkins"

# или
JENKINS_ARGS="--webroot=/var/cache/jenkins/war --httpPort=8080 --httpListenAddress=0.0.0.0 --prefix=/web/app/jenkins"
```

#### **Systemd override `/etc/systemd/system/jenkins.service.d/proxy.conf`:**
```ini
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.forwarded.proto.trusted=192.168.87.238 -Dhudson.security.Realm=jenkins.security.HeaderAuthenticationRealm"
```

#### **Дополнительно в Jenkins:**
- Включена опция **"Use Root URL from request"** в настройках безопасности (OIC плагин)
- Увеличен `sessionTimeout` до 1440 минут (24 часа)
- Установлен плагин "Remote Authentication" для приёма заголовка `Remote-User` от Teleport

**Почему Jenkins не редиректит:** Он использует относительные ссылки в UI (`/job/...`) и доверяет заголовку `X-Forwarded-Host`.

---

### 3.2. Grafana (гибкая, через `root_url`)

**Сервер:** `loki-grafana` (192.168.87.209)

#### **`/etc/grafana/grafana.ini`:**
```ini
[server]
root_url = https://grafana.teleport.runtel.org

[auth]
# Отключаем проверку Referer для работы через прокси
disable_login_form = false
```

**Почему Grafana не редиректит:** Она поддерживает настройку `root_url`, которая указывает внешний адрес. Teleport передаёт правильные заголовки `Origin` и `Host`.

---

### 3.3. GitLab (жёсткий, требуется смена `external_url`)

**Сервер:** `gitlab` (192.168.46.4)

GitLab игнорирует заголовки и жёстко привязан к своему `external_url`. Без его смены при заходе через `gitlab.teleport.runtel.org` происходил бы редирект на `gitlab.runtel.org`.

#### **`/etc/gitlab/gitlab.rb`:**
```bash
sed -n '30,37p;193,206p' /etc/gitlab/gitlab.rb | ccze -A
```
```ruby
##! address from AWS. For more details, see: 
##! https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html 
external_url 'https://gitlab.runtel.org' 

# gitlab_rails['trusted_proxies] = [] 

# Добавляем доверие к Teleport 
gitlab_rails['trusted_proxies] = ['192.168.87.238'] 
nginx['real_ip_header] = 'X-Forwarded-For' 
nginx['real_ip_recursive] = 'on' 

# Говорим GitLab, что он может отвечать на оба адреса 
#nginx['listen_addresses'] = ['*'] 
#nginx['server_names'] = ['gitlab.runtel.org', 'gitlab.teleport.runtel.org'] 

# Добавляем поддержку второго домена через кастомную конфигурацию nginx 
#nginx['custom_gitlab_server_config'] = "server_name gitlab.runtel.org gitlab.teleport.runtel.org;\n" 
```

#### **Применение изменений:**
```bash
sudo gitlab-ctl reconfigure
```

**Результат:** GitLab теперь доступен только через `gitlab.teleport.runtel.org`, прямой доступ на `gitlab.runtel.org` приводит к редиректу (что и требуется).

---

### 3.4. Jira (жёсткая, требуется смена Base URL)

**Сервер:** `jira` (192.168.46.4, порт 8080)

Аналогично GitLab, Jira использует свой `Base URL` для генерации абсолютных ссылок.

#### **Конфигурация (`jira-application.properties`):**
```properties
jira.baseurl=https://jira.teleport.runtel.org
```

#### **Tomcat `server.xml`:**
```xml
<Connector port="8080" protocol="HTTP/1.1"
           proxyName="jira.teleport.runtel.org"
           proxyPort="443"
           scheme="https"/>
```

**Результат:** Jira теперь работает через Teleport без редиректов.

---

## 4. Создание бота (Machine ID) для Jenkins

Бот позволяет Jenkins'у получать короткоживущие сертификаты для доступа к другим серверам через Teleport.

### 4.1. На сервере Teleport: создание бота и роли

#### **Роль для бота (`jenkins-bot.yaml`):**
```yaml
kind: "role"
version: "v3"
metadata:
  name: "jenkins-bot"
spec:
  allow:
    logins: ["root", "kkorablin", "ipetrov", "cgnezdilov"]
    node_labels:
      "env": "ci"
```

```bash
tctl create -f /etc/teleport.d/jenkins-bot.yaml
```

#### **Создание бота:**
```bash
tctl bots add jenkins-bot --roles=jenkins-bot
```
**Сохранить токен:** `d4c885b1c76dd21a4150812d26521f9a` (пример)

### 4.2. На сервере Jenkins: установка и настройка `tbot`

#### **Установка бинарников Teleport:**
```bash
cd /tmp
curl -O https://cdn.teleport.dev/teleport-v18.7.3-linux-amd64-bin.tar.gz
tar -xzf teleport-v18.7.3-linux-amd64-bin.tar.gz
cd teleport
sudo ./install
```

#### **Конфигурация `/etc/tbot.yaml`:**
```yaml
version: v2
proxy_server: "teleport.runtel.org:443"
onboarding:
  token: "d4c885b1c76dd21a4150812d26521f9a"
storage:
  type: directory
  path: /opt/machine-id
```

#### **Systemd-сервис `/etc/systemd/system/tbot.service`:**
```ini
[Unit]
Description=Teleport Machine ID Service (tbot)
After=network.target

[Service]
Type=simple
User=teleport
Group=teleport
ExecStart=/usr/local/bin/tbot start --config=/etc/tbot.yaml --join-method=token --token=d4c885b1c76dd21a4150812d26521f9a
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

#### **Запуск:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable tbot --now
```

### 4.3. Использование сертификатов в Jenkins Pipeline

```groovy
sh '''
    ssh -i /opt/machine-id/key \
        -o CertificateFile=/opt/machine-id/key-cert.pub \
        -o GlobalKnownHostsFile=/opt/machine-id/sshcacerts \
        -o StrictHostKeyChecking=no \
        kkorablin@192.168.87.238 "hostname"
'''
```

---

## 5. Проблемы редиректов: причины и решения

| Приложение | Наличие редиректа | Решение |
|------------|-------------------|---------|
| **Jenkins** | Нет | Настроен `--prefix` и заголовки `X-Forwarded-Host` |
| **Grafana** | Нет | Указан `root_url` в конфиге |
| **GitLab** | Да (без смены `external_url`) | Смена `external_url` на адрес Teleport |
| **Jira** | Да (без смены `Base URL`) | Смена `Base URL` на адрес Teleport |

### 5.1. Почему Jenkins и Grafana не редиректят?

**Jenkins** использует **относительные ссылки** в веб-интерфейсе. При заходе через `https://jenkins.teleport.runtel.org` он генерирует ссылки вида `/job/...`, которые браузер интерпретирует относительно текущего `Host`. Абсолютные ссылки Jenkins использует только для внешних уведомлений (почта).

**Grafana** поддерживает настройку `root_url`, которая указывает внешний адрес. Teleport передаёт заголовки `Origin` и `Host`, и Grafana корректно их обрабатывает.

### 5.2. Почему GitLab и Jira редиректят?

Оба приложения генерируют **абсолютные ссылки** на основе своего внутреннего `external_url` (GitLab) или `Base URL` (Jira). При заходе с другого домена они делают редирект на «свой» канонический адрес. Это архитектурное решение разработчиков, связанное с безопасностью.

### 5.3. Как определить, будет ли приложение редиректить?

- Использует ли приложение **абсолютные ссылки** в UI?
- Можно ли переопределить `Host` через заголовок `X-Forwarded-Host`?
- Есть ли встроенная поддержка прокси (настройка `root_url`, `--prefix`, `proxyName`)?

---

## 6. Полезные команды для диагностики

```bash
# Проверка конфигурации Teleport
tctl get apps

# Проверка доступности приложения с jumpserver
curl -v http://192.168.87.11:8080/web/app/jenkins
curl -v http://192.168.46.4:8080
curl -k https://gitlab.runtel.org
curl -v http://192.168.87.209:3000

# Логи Teleport
sudo journalctl -u teleport -f

# Логи приложений
sudo journalctl -u jenkins -f
sudo gitlab-ctl tail
sudo journalctl -u grafana-server -f
```

---

## 7. Итоги и рекомендации

1. **Teleport** — отличный инструмент для централизованного доступа, но поведение приложений за прокси зависит от их архитектуры.
2. **Jenkins** и **Grafana** — гибкие: достаточно настроить заголовки и префиксы.
3. **GitLab** и **Jira** — жёсткие: необходимо изменить их базовый URL на адрес Teleport.
4. **Бот (Machine ID)** позволяет Jenkins получать сертификаты для безопасного доступа к другим серверам без хранения паролей.
5. Всегда проверяй доступность приложения с сервера Teleport (curl) перед добавлением в Teleport.
6. Для диагностики редиректов используй `curl -v` и смотри заголовок `Location`.

---

## Финальная архитектура

```
Пользователь
    │
    ▼
Teleport UI (teleport.runtel.org)
    │
    ├── Jenkins (jenkins.teleport.runtel.org)
    ├── Jira (jira.teleport.runtel.org)
    ├── GitLab (gitlab.teleport.runtel.org)
    └── Grafana (grafana.teleport.runtel.org)
```

Все сервисы доступны через единый интерфейс, с единой аутентификацией (Keycloak) и аудитом.

---

**Примечание:** Если приложение не поддерживает работу за прокси, всегда можно использовать `tsh apps login` или SSH-туннель (`ssh -L`).

