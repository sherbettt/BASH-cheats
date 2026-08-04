# Инструкция: Настройка Semaphore для Ansible Playbook

## Проблема
При запуске Ansible playbook в Semaphore возникала ошибка подключения к серверу:
```
Invalid/incorrect password: no such identity: /tmp/semaphore/project_4/.ssh/id_rsa: No such file or directory
```

## Решение

### 1. Создание директории для SSH-ключа в проекте Semaphore

```bash
# Создаем директорию .ssh в проекте
mkdir -p /tmp/semaphore/project_4/.ssh/

# Копируем SSH-ключ из домашней директории
cp /root/.ssh/id_rsa /tmp/semaphore/project_4/.ssh/

# Устанавливаем правильные права
chmod 600 /tmp/semaphore/project_4/.ssh/id_rsa
chown -R root:root /tmp/semaphore/project_4/.ssh
```

### 2. Настройка ansible.cfg

Обновляем файл `ansible.cfg` , добавив ***private_key_file*** в репозитории:

```ini
[defaults]
host_key_checking = False
timeout = 10
private_key_file = /tmp/semaphore/project_4/.ssh/id_rsa

display_failed_stderr = yes
stdout_callback = debug

callbacks_enabled = profile_tasks, timer

[ssh_connection]
pipelining = True
```

**Важно:** Убедиться, что параметр `private_key_file` указан только один раз!

### 3. Настройка инвентаря в Semaphore

В UI Semaphore создаем/обновляем статический инвентарь:

**Путь:** `Project 4` → `Inventory` → `inventory_qa`

```ini
[qa]
pbx-qa-clone ansible_host=192.168.87.201

[all:vars]
ansible_user=root
ansible_port=22
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```

### 4. Подключение SSH-ключа через секреты Semaphore (альтернативный способ)

Если не хотите хранить ключ в файловой системе:

1. **Добавить секрет:**
   - `Settings` → `Secrets` → `Add Secret`
   - Имя: `qa_ssh_key`
   - Значение: содержимое приватного ключа (`/root/.ssh/id_rsa`)

2. **Обновить инвентарь:**
```ini
[qa]
pbx-qa-clone ansible_host=192.168.87.201

[all:vars]
ansible_user=root
ansible_ssh_private_key_file=/tmp/semaphore/secrets/qa_ssh_key
ansible_port=22
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3

# опционально можно и сюда всключить
ansible_ssh_private_key_file=/tmp/semaphore/project_4/.ssh/id_rsa
```

3. **В настройках задачи подключить секрет:**
   - В задаче `Update QA servers` → `Secrets` → добавить `qa_ssh_key`

### 5. Настройка задачи в Semaphore

**Путь:** `Project 4` → `Tasks` → `Update QA servers`

- **Inventory:** `inventory_qa`
- **Playbook:** `playbook-updown.yml`
- **Parameters:** 
  - Для обновления: `--tags upgrade_back,upgrade_front`
  - Для даунгрейда: `--tags downgrade_back,downgrade_front --extra-vars "back_version=2.22.9-9-235-deb12 front_version=2.22.9-2265-deb12"`

### 6. Проверка работоспособности

```bash
# Проверка SSH подключения из Semaphore
ssh -i /tmp/semaphore/project_4/.ssh/id_rsa -o StrictHostKeyChecking=no root@192.168.87.201 "echo OK"

# Проверка через ansible
ansible -i inventory.yml pbx-qa-clone -m ping
```

## Устранение типичных ошибок

### Ошибка: duplicate option 'private_key_file'
**Причина:** В `ansible.cfg` дважды указан параметр `private_key_file`

**Решение:** Оставить только одну строку с `private_key_file`

### Ошибка: Could not find the requested service runtel-web-v2
**Причина:** Служба `runtel-web-v2` не существует на сервере

**Решение:** Это не критично, плейбук игнорирует ошибку благодаря `ignore_errors: yes`

### Ошибка: bad boolean config value for GIT_TERMINAL_PROMPT
**Причина:** В настройках Git присутствуют лишние символы

**Решение:** Очистить инвентарь от кириллических комментариев

## Команды для запуска

```bash
# Обновление BACKEND+FRONTEND
ansible-playbook playbook-updown.yml --tags upgrade_back,upgrade_front

# Даунгрейд BACKEND+FRONTEND
ansible-playbook playbook-updown.yml --tags downgrade_back,downgrade_front --extra-vars "back_version=2.22.9-9-235-deb12 front_version=2.22.9-2265-deb12"

# Только просмотр состояния
ansible-playbook playbook-updown.yml --tags always
```

## Итог

После выполнения всех шагов, Semaphore успешно:
1. Клонирует репозиторий
2. Подключается к серверу по SSH
3. Выполняет обновление/даунгрейд пакетов Runtel
4. Перезапускает службы

