### **Основные консольные команды Timeshift**  

#### **1. Установка Timeshift**  
```bash
sudo apt install timeshift  # Для Debian/Ubuntu
sudo pacman -S timeshift    # Для Arch Linux
sudo dnf install timeshift  # Для Fedora
```

#### **2. Запуск Timeshift**  
```bash
sudo timeshift --launch    # Запуск с графическим интерфейсом
sudo timeshift --list      # Просмотр существующих снепшотов
```

#### **3. Создание снепшота**  
```bash
sudo timeshift --create    # Создание нового снепшота (интерактивный режим)
sudo timeshift --create --comments "Резервная копия перед обновлением"  # С комментарием
sudo timeshift --create --tags D  # С тегом (D – daily, W – weekly, M – monthly, O – on-demand)
```

#### **4. Восстановление системы из снепшота**  
```bash
sudo timeshift --restore   # Запуск восстановления (интерактивно)
sudo timeshift --restore --snapshot '2024-01-01_12-00-00' --target /dev/sda1  # Указание конкретного снепшота и раздела
```

#### **5. Удаление снепшотов**  
```bash
sudo timeshift --delete --snapshot '2024-01-01_12-00-00'  # Удаление конкретного снепшота
sudo timeshift --delete-all      # Удаление всех снепшотов (осторожно!)
```

#### **6. Настройка расписания (cron)**  
```bash
sudo timeshift --setup-cron  # Автоматическое создание снепшотов по расписанию
```

#### **7. Просмотр информации о снепшотах**  
```bash
sudo timeshift --list-snapshots  # Список всех снепшотов
sudo timeshift --info --snapshot '2024-01-01_12-00-00'  # Подробная информация о снепшоте
```

#### **8. Проверка состояния**  
```bash
sudo timeshift --check  # Проверка необходимости создания нового снепшота
```

#### **9. Изменение настроек (через конфиг)**  
```bash
sudo nano /etc/timeshift/timeshift.json  # Ручное редактирование конфигурации
```

#### **10. Просмотр у-в и создание снепшота**
```bash
sudo timeshift --list-devices  # выбираем /dev/md0
sudo timeshift --create --snapshot-device /dev/md0 --comments "before editting NFS share folder"
# просмотр снепшотов
sudo timeshift --list
sudo ls /run/timeshift/*/backup/timeshift/snapshots/
```
каталог `/run/timeshift/` является временным и существует только во время работы Timeshift. Когда вы пытаетесь проверить его содержимое через `ls`, он уже демонтирован. Вот как правильно проверить ваши снапшоты:
```bash
sudo timeshift --list\

# Найдите UUID устройства
sudo blkid /dev/md0

# Ищите снапшоты по UUID; это будет /stg/8tb/timeshift/snapshots/
sudo find / -path "*/timeshift/snapshots" -type d 2>/dev/null
```

#### **11. Как смонтировать снапшот для проверки (если нужно)**
```bash
# Создаём точку монтирования
sudo mkdir -p /mnt/snapshot

# Монтируем снапшот
sudo mount --bind /stg/8tb/timeshift/snapshots/2025-08-07_10-58-42/localhost/ /mnt/snapshot/

# Проверяем содержимое
ls -alhF /mnt/snapshot/

# После работы размонтируем
sudo umount /mnt/snapshot
```


### **Вывод**  
Timeshift позволяет удобно управлять резервными копиями через терминал. Основные команды:  
- `--create` – создание снепшота,  
- `--restore` – восстановление,  
- `--list` – просмотр списка,  
- `--delete` – удаление.  

Для автоматизации можно использовать `--setup-cron`.  

