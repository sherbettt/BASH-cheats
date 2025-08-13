## Создание /etc/systemd/system/csync2.service юнита


Разберём подробно каждую строку создаваемого systemd юнита `csync2.service`:

### [Unit] секция:
```
[Unit]
Description=csync2 cluster synchronization
After=network.target
```
- `[Unit]` - начало секции с общими метаданными и зависимостями
- `Description=csync2 cluster synchronization` - человекочитаемое описание сервиса
- `After=network.target` - сервис должен запускаться только после того, как поднята сетевая подсистема (network.target)

### [Service] секция:
```
[Service]
Type=simple
ExecStart=/usr/sbin/csync2 -D /var/lib/csync2 -ii -v
Restart=on-failure
RestartSec=5s
```
- `[Service]` - начало секции с параметрами сервиса
- `Type=simple` - тип сервиса (simple означает, что процесс является основным процессом сервиса)
- `ExecStart=/usr/sbin/csync2 -D /var/lib/csync2 -ii -v` - команда для запуска:
  - `/usr/sbin/csync2` - основной исполняемый файл csync2
  - `-D /var/lib/csync2` - указывает рабочую директорию
  - `-ii` - включает автоматическое добавление новых узлов в кластер
  - `-v` - verbose режим (подробный вывод)
- `Restart=on-failure` - политика перезапуска (перезапускать при неудачном завершении)
- `RestartSec=5s` - пауза 5 секунд перед перезапуском

### [Install] секция:
```
[Install]
WantedBy=multi-user.target
```
- `[Install]` - начало секции с параметрами установки
- `WantedBy=multi-user.target` - указывает, что сервис должен быть запущен при достижении multi-user уровня (стандартный уровень для многопользовательской системы без графического интерфейса)

### Параметры запуска Ansible:
- `ansible gateways` - применяется к группе хостов gateways
- `-m copy` - использует модуль copy для копирования файла
- `dest=/etc/systemd/system/csync2.service` - целевой путь для файла сервиса
- `content='...'` - содержимое файла (как показано выше)
- `-b` - become (повышение привилегий, обычно через sudo)
- `--diff` - показывает различия при изменении файлов

Этот юнит создаёт управляемый systemd сервис для csync2, который:
1. Запускается после сети
2. Работает в foreground (simple)
3. Автоматически перезапускается при падении
4. Активируется на стандартном multi-user уровне
