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

### **Вывод**  
Timeshift позволяет удобно управлять резервными копиями через терминал. Основные команды:  
- `--create` – создание снепшота,  
- `--restore` – восстановление,  
- `--list` – просмотр списка,  
- `--delete` – удаление.  

Для автоматизации можно использовать `--setup-cron`.  

