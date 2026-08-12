# Runtel PBX v2 EAPI MRG: создание systemd unit

## 1. Подготовка окружения

### Клонирование проекта (если не сделано)
```bash
cd /home
git clone https://gitlab.runtel.org/runtel/runtel_pbx_v2_eapi_mrg.git
cd /home/runtel_pbx_v2_eapi_mrg
```

### Проверка Python
```bash
python3.11 --version
# Python 3.11.2
```

## 2. Создание виртуального окружения

```bash
cd /home/runtel_pbx_v2_eapi_mrg
rm -rf .venv  # если был старый
python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

Если `requirements.txt` неполный, используйте полный список:

```bash
pip install aiocron==2.1 \
    aiodns==4.0.4 \
    aiohappyeyeballs==2.7.1 \
    aiohttp==3.14.3 \
    aiohttp-middlewares==2.4.0 \
    aiosignal==1.4.0 \
    aiosmtplib==5.1.2 \
    async-timeout==4.0.3 \
    asyncpg==0.31.0 \
    attrs==26.1.0 \
    cffi==2.1.1 \
    cronsim==2.7 \
    frozenlist==1.8.0 \
    greenlet==3.5.5 \
    idna==3.18 \
    Jinja2==3.1.6 \
    lxml==6.1.1 \
    MarkupSafe==3.0.3 \
    multidict==6.7.1 \
    propcache==0.5.2 \
    psycopg2-binary==2.9.12 \
    pycares==5.0.1 \
    pycparser==3.0 \
    pycryptodome==3.23.0 \
    python-dateutil==2.9.0.post0 \
    pytz==2026.3.post1 \
    PyYAML==6.0.3 \
    redis==8.1.0 \
    runtel_cache_engine==0.0.41 \
    runtel_eapi==0.0.34 \
    runtel_logger==0.0.14 \
    runtel_sql_engine==0.2.11 \
    schematics==2.1.1 \
    six==1.17.0 \
    SQLAlchemy==2.0.51 \
    trafaret==2.1.1 \
    trafaret-config==2.0.2 \
    typing_extensions==4.16.0 \
    tzlocal==5.4.4 \
    ujson==5.13.0 \
    yarl==1.24.5
```

## 3. Настройка конфигурации

### Создание симлинка на конфиг
```bash
# Проверяем, что конфиг существует
ls -la /etc/runtel/eapi_mrg.yaml

# Создаем симлинк
ln -sf /etc/runtel/eapi_mrg.yaml /etc/runtel/main_plugin.yaml

# Проверяем
ls -la /etc/runtel/main_plugin.yaml
# Должно быть: main_plugin.yaml -> /etc/runtel/eapi_mrg.yaml
```

### Проверка конфига
```bash
.venv/bin/python -c "import yaml; print(yaml.safe_load(open('/etc/runtel/eapi_mrg.yaml'))['system'])"
# Должен вывести: {'worker_count': 1, 'log_level': 10, ...}
```


## 5. Создание systemd сервиса

```bash
nano /etc/systemd/system/runtel-eapi.service
```

Содержимое:

```ini
[Unit]
Description=Runtel Pbx V2 Eapi Mrg service
After=network.target postgresql.target
Wants=network.target

[Service]
Type=simple

#WorkingDirectory=/home/runtel_pbx_v2_eapi_mrg
#Environment="PATH=/home/runtel_pbx_v2_eapi_mrg/.venv/bin:/usr/local/bin:/usr/bin:/bin"
#Environment="PYTHONPATH=/home/runtel_pbx_v2_eapi_mrg"
#Environment="PYTHON_EXECUTABLE=/home/runtel_pbx_v2_eapi_mrg/.venv/bin/python3"
Environment="VIRTUAL_ENV=/home/runtel_pbx_v2_eapi_mrg/.venv/"
ExecStart=/home/runtel_pbx_v2_eapi_mrg/.venv/bin/python3 /home/runtel_pbx_v2_eapi_mrg/start_eapi.py

User=root
Group=root
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
TimeoutStopSec=15
SyslogIdentifier=runtel-pbx-v2-eapi-mrg
KillMode=mixed

[Install]
WantedBy=multi-user.target
```

## 6. Запуск сервиса

```bash
# Перезагружаем systemd
systemctl daemon-reload

# Включаем автозапуск
systemctl enable runtel-eapi.service

# Запускаем сервис
systemctl start runtel-eapi.service

# Проверяем статус
systemctl status runtel-eapi.service -l --no-pager
```

## 7. Проверка работы

```bash
# Проверяем порты
ss -tlnp | grep -E "9902|9903"

# Проверяем через curl
curl -v http://192.168.87.71:9902/
# Должен быть ответ (404 или другой)

# Смотрим логи
journalctl -u runtel-pbx-v2-eapi-mrg -f
```

## 8. Команды управления сервисом

```bash
# Статус
systemctl status runtel-eapi.service

# Запуск
systemctl start runtel-eapi.service

# Остановка
systemctl stop runtel-eapi.service

# Перезапуск
systemctl restart runtel-eapi.service

# Логи (в реальном времени)
journalctl -u runtel-pbx-v2-eapi-mrg -f

# Логи (последние 50 строк)
journalctl -u runtel-pbx-v2-eapi-mrg -n 50

# Отключить автозапуск
systemctl disable runtel-eapi.service
```

## 9. Проверка автозапуска

```bash
systemctl is-enabled runtel-eapi.service
# Должен вернуть: enabled

systemctl is-active runtel-eapi.service
# Должен вернуть: active
```

## 10. Файлы проекта

### Основные файлы
- `start_eapi.py` - точка входа
- `plugin.py` - основной плагин (исправлен)
- `config/eapi.yaml` - конфиг (симлинк из /etc/runtel/)
- `.venv/` - виртуальное окружение

### Конфигурационные файлы
- `/etc/runtel/eapi_mrg.yaml` - основной конфиг
- `/etc/runtel/main_plugin.yaml` - симлинк на eapi_mrg.yaml
- `/etc/systemd/system/runtel-eapi.service` - systemd сервис

## 11. Устранение неполадок

### Если сервис не запускается
```bash
# Проверяем логи
journalctl -u runtel-pbx-v2-eapi-mrg -n 50 -p err

# Проверяем конфиг
ls -la /etc/runtel/main_plugin.yaml

# Проверяем venv
ls -la /home/runtel_pbx_v2_eapi_mrg/.venv/bin/python3

# Проверяем права
chmod +x /home/runtel_pbx_v2_eapi_mrg/start_eapi.py
```

### Если воркер не находит модули
```bash
# Проверяем, что все пакеты установлены
source .venv/bin/activate
pip list | grep runtel
# Должны быть: runtel_eapi, runtel_logger, runtel_sql_engine, runtel_cache_engine

# Проверяем импорт
python -c "import runtel_eapi; print('OK')"
```

