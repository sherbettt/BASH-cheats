# Шпаргалка по файловым дескрипторам, inode и ulimit в Linux

##  Inode (Index Node)

### Что такое inode?
**Inode** - это структура данных в файловой системе, содержащая метаинформацию о файле (кроме имени).

### Команды для работы с inode

```bash
# Показать inode файлов
ls -i filename.txt

# Показать inode с детальной информацией
ls -li filename.txt

# Показать inode всех файлов в директории
ls -ai

# Найти файл по inode
find /path -inum 1234567

# Показать информацию о файловой системе (доступные inode)
df -i
```

### Ключевая информация в inode:
- Права доступа
- Владелец и группа
- Размер файла
- Временные метки
- Ссылки на блоки данных


##  Файловые дескрипторы (File Descriptors)

### Что такое файловый дескриптор?
**FD** - числовой идентификатор, который ядро возвращает процессу при открытии файла/сокета.

### Команды для работы с файловыми дескрипторами

```bash
# Показать FD текущего shell-процесса
ls -l /proc/$$/fd/

# Показать FD конкретного процесса
ls -l /proc/<PID>/fd/

# Показать все открытые файлы в системе
lsof

# Показать открытые файлы процессом
lsof -p <PID>

# Показать процессы, использующие файл
lsof /path/to/file

# Создать FD вручную в bash
exec 3>file.txt    # FD 3 для записи
exec 4<file.txt    # FD 4 для чтения
echo "test" >&3    # запись через FD 3
```

### Стандартные файловые дескрипторы:
- **0** - stdin (стандартный ввод)
- **1** - stdout (стандартный вывод)  
- **2** - stderr (стандартный ошибка)



##  Ulimit - управление лимитами ресурсов

### Основные команды ulimit

```bash
# Показать все текущие лимиты
ulimit -a

# Показать лимит файловых дескрипторов
ulimit -n

# Установить лимит FD
ulimit -n 4096

# Показать hard limit
ulimit -H -n

# Показать soft limit  
ulimit -S -n

# Установить лимит процессов на пользователя
ulimit -u 1000
```

### Часто используемые опции:
```bash
-a  # Все лимиты
-n  # Количество открытых файлов
-u  # Максимум процессов
-t  # Максимум CPU time (секунды)
-v  # Максимум виртуальной памяти
-f  # Максимум размера файлов
```



##  Взаимосвязь понятий

### Цепочка доступа к файлу:
```
Процесс открывает файл 
    ↓
Ядро возвращает файловый дескриптор (FD)
    ↓
FD ссылается на системную таблицу файлов
    ↓
Системная таблица ссылается на inode
    ↓
Inode указывает на данные на диске
```

### Аналогия:
- **Inode** = Паспорт файла (постоянный)
- **File Descriptor** = Читательский билет (временный)
- **Ulimit** = Охранник, ограничивающий количество билетов



##  Практические примеры

### Диагностика проблем
```bash
# Проверить использование FD процессом
ls -l /proc/<PID>/fd/ | wc -l

# Найти утечки FD
lsof -p <PID> | wc -l

# Проверить доступные inode в ФС
df -i

# Увеличить лимит FD для веб-сервера
ulimit -n 65536
```

### Постоянная настройка лимитов
```bash
# Добавить в ~/.bashrc
ulimit -n 8192

# Или в /etc/security/limits.conf
# * soft nofile 8192
# * hard nofile 65536
```



##  Полезные советы

1. **При "Too many open files"** - увеличьте `ulimit -n`
2. **При "No space left on device"** - проверьте `df -i` (могли кончиться inode)
3. **Для серверных приложений** всегда настраивайте адекватные лимиты
4. **FD освобождаются автоматически** при завершении процесса
5. **Inode создаются при создании ФС** и их количество ограничено

--------------------------------------

#  Inode в Linux: лимиты и управление

##  Количество inode в системе

### 1. **Факторы, влияющие на количество inode:**

```bash
# Проверить общее количество inode в файловой системе
df -i
# Файловая система    Inodes IUsed IFree IUse% Mounted on
# /dev/sda1          5242880 15000 5227880    1% /

# Детальная информация о ФС
tune2fs -l /dev/sda1 | grep -i inode
```

### 2. **Лимиты по умолчанию:**

| Файловая система | Inode на 1GB | Максимум inode |
|------------------|--------------|----------------|
| ext4             | ~16,000      | ~4 миллиарда   |
| xfs              | ~18,000      | ~2^64          |
| btrfs            | Динамические | Практически неограничено |

### 3. **Как рассчитывается количество inode:**

```bash
# При создании ФС задается соотношение:
mkfs.ext4 -i 16384 /dev/sda1  # 1 inode на 16KB данных
# или
mkfs.ext4 -N 1000000 /dev/sda1  # явно указать количество inode
```



##  Симптомы заполнения inode

### Признаки проблемы:
```bash
# 1. Ошибки при создании файлов
touch new_file.txt
# touch: cannot touch 'new_file.txt': No space left on device

# 2. Но df -h показывает свободное место
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   30G   20G  60% /

# 3. Проверяем inode
df -i
# Filesystem     Inodes IUsed IFree IUse% Mounted on
# /dev/sda1      5242880 5242880 0    100% /
```



##  Диагностика и поиск проблем

### 1. **Найти директории с наибольшим количеством файлов:**
```bash
# Показать топ-10 директорий по количеству файлов
find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -rn | head -10

# Или более точный метод:
find /path/to/check -xdev -printf '%h\n' | sort | uniq -c | sort -rn | head -20
```

### 2. **Поиск множества маленьких файлов:**
```bash
# Найти директории с большим количеством файлов
for dir in /*; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -type f 2>/dev/null | wc -l)
        echo "$count - $dir"
    fi
done | sort -rn

# Поиск в конкретной директории
find /var -type f 2>/dev/null | wc -l
```

### 3. **Проверить конкретные места:**
```bash
# Проверить /tmp
ls -f /tmp | wc -l

# Проверить почтовые очереди
find /var/spool/postfix -type f | wc -l

# Проверить логи
find /var/log -type f | wc -l

# Проверить сессии PHP
find /var/lib/php/sessions -type f | wc -l
```



##  Очистка занятых inode

### 1. **Очистка временных файлов:**
```bash
# Очистка /tmp
sudo find /tmp -type f -atime +7 -delete

# Очистка кэша пакетов
sudo apt-get clean
# или для yum
sudo yum clean all
```

### 2. **Очистка логов:**
```bash
# Ротация логов
sudo logrotate -f /etc/logrotate.conf

# Очистка старых логов
sudo find /var/log -name "*.log.*" -type f -mtime +30 -delete
sudo find /var/log -name "*.gz" -type f -mtime +30 -delete
```

### 3. **Очистка почтовых очередей:**
```bash
# Проверить почтовую очередь
sudo mailq

# Очистить всю очередь
sudo postsuper -d ALL

# Или выборочно
sudo find /var/spool/postfix -type f -delete
```

### 4. **Очистка сессий:**
```bash
# PHP сессии
sudo find /var/lib/php/sessions -type f -mtime +1 -delete

# Системные сессии
sudo find /tmp -name "sess_*" -type f -mtime +1 -delete
```



##  Экстренные меры

### Если система не позволяет удалять файлы:
```bash
# Перезагрузка в single mode
sudo systemctl rescue

# Принудительная очистка
# ВАЖНО: Будьте осторожны с этими командами!

# Удаление по шаблону
sudo find /path -name "*.tmp" -delete

# Очистка пустых файлов
sudo find /path -type f -size 0 -delete
```



##  Профилактика и настройка

### 1. **Мониторинг inode для проверки всех ФС:**
```bash
#!/bin/bash

THRESHOLD=90
ALERT_TRIGGERED=0

echo "=== INODE USAGE REPORT ==="
date

# Проверяем все файловые системы кроме временных
df -i | grep -E '^/dev/' | while read line; do
    USAGE=$(echo $line | awk '{gsub(/%/,"",$5); print $5}')
    FILESYSTEM=$(echo $line | awk '{print $1}')
    MOUNT_POINT=$(echo $line | awk '{print $6}')
    
    if [[ "$USAGE" =~ ^[0-9]+$ ]] && [ "$USAGE" -gt "$THRESHOLD" ]; then
        echo "🚨 ALERT: $FILESYSTEM on $MOUNT_POINT is at ${USAGE}% inode usage"
        ALERT_TRIGGERED=1
    else
        echo "✅ OK: $FILESYSTEM on $MOUNT_POINT - ${USAGE}%"
    fi
done

if [ "$ALERT_TRIGGERED" -eq 1 ]; then
    echo ""
    echo "=== RECOMMENDED ACTIONS ==="
    echo "1. Check for many small files: find /path -type f | wc -l"
    echo "2. Clean temporary files"
    echo "3. Check log files rotation"
fi
```

### 2. **Создание ФС с правильным количеством inode:**
```bash
# Для ФС с множеством маленьких файлов
mkfs.ext4 -i 4096 -I 512 /dev/sdb1  # больше inode

# Для ФС с большими файлами
mkfs.ext4 -i 65536 /dev/sdb1  # меньше inode
```

### 3. **Перенос данных на ФС с динамическими inode:**
```bash
# Использовать btrfs или xfs для динамического выделения inode
mkfs.btrfs /dev/sdb1
# или
mkfs.xfs /dev/sdb1
```



##  Статистика и мониторинг

### Полезные команды для мониторинга:
```bash
# Ежедневная проверка inode
watch -n 3600 'df -i'

# Скрипт для мониторинга
#!/bin/bash
echo "=== Inode Usage ==="
df -i
echo ""
echo "=== Top directories by file count ==="
find / -xdev -type f 2>/dev/null | cut -d "/" -f 2,3 | sort | uniq -c | sort -rn | head -10
```



##  Профилактические меры

1. **Регулярно мониторьте** `df -i`
2. **Настройте оповещения** при достижении 80% использования
3. **Используйте ФС с динамическими inode** (btrfs, xfs) для workload'ов с множеством маленьких файлов
4. **Регулярно чистите** временные файлы и кэши
5. **Настройте logrotate** для автоматического управления логами

**Важно:** После очистки inode может потребоваться перезагрузка некоторых сервисов для полного освобождения ресурсов!
