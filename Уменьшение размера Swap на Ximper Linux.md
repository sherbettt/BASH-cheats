# Инструкция: Уменьшение размера Swap на Ximper Linux (ALT Linux)

**В случае, если вы устанавливали Ximper по умолчанию, автоматически, то следует уменьшить Swap**

**Исходная ситуация:** Swap-раздел 8.4 ГБ, не используется, нужно уменьшить до 2 ГБ

---

## 1. Диагностика текущего состояния

### 1.1. Проверка использования памяти и swap
```bash
free -h
```
**Результат:** Swap: 8.4GiB, Used: 0B

### 1.2. Определение типа swap
```bash
sudo swapon --show
```
или
```bash
sudo cat /proc/swaps
```
**Результат:** `/dev/nvme0n1p2 partition 8,4G 0B -2` — **swap-раздел**

### 1.3. Проверка файловой системы корневого раздела
```bash
df -T /
findmnt -no FSTYPE /
```
**Результат:** btrfs — **Btrfs имеет особенности работы с swap-файлами**

---

## 2. Отключение старого swap-раздела

### 2.1. Отключение swap-раздела
```bash
sudo swapoff /dev/nvme0n1p2
```

### 2.2. Редактирование /etc/fstab (отключение автозагрузки)
```bash
sudo nano /etc/fstab
```
**Найти строку с swap-разделом:**
```
UUID=527c5922-137b-485e-842b-17bbe290c5a6	swap	swap	defaults	0	0
```
**Заменить на (закомментировать):**
```
#UUID=527c5922-137b-485e-842b-17bbe290c5a6	swap	swap	defaults	0	0
```

**Проверка:**
```bash
cat -n /etc/fstab
```

---

## 3. Создание swap-файла 2 ГБ на Btrfs

**Важно:** На файловой системе Btrfs требуется специальная подготовка из-за механизма Copy-on-Write (CoW)

### 3.1. Удаление старого swap-файла (если существовал)
```bash
sudo swapoff /swapfile 2>/dev/null
sudo rm /swapfile
```

### 3.2. Создание файла с отключенным CoW
```bash
sudo truncate -s 0 /swapfile
sudo chattr +C /swapfile
```

### 3.3. Выделение места
```bash
sudo fallocate -l 2G /swapfile
```
**Альтернативный метод (если fallocate не работает):**
```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
```

### 3.4. Установка прав доступа
```bash
sudo chmod 600 /swapfile
```

### 3.5. Форматирование как swap
```bash
sudo mkswap /swapfile
```
**Результат:** `UUID=97efbe6e-aae3-4bc7-b1a2-f23a993242d0`

### 3.6. Включение swap-файла
```bash
sudo swapon /swapfile
```

---

## 4. Настройка автоматического включения при загрузке

### 4.1. Добавление записи в /etc/fstab
```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**Проверка:**
```bash
tail -n 1 /etc/fstab
```
**Результат:** `/swapfile none swap sw 0 0`

---

## 5. Проверка результатов

### 5.1. Проверка активного swap
```bash
sudo swapon --show
```
**Результат:**
```
NAME      TYPE SIZE USED PRIO
/swapfile file   2G   0B   -2
```

### 5.2. Проверка использования памяти
```bash
free -h
```
**Результат:**
```
Mem:  14Gi   6,4Gi   3,6Gi   157Mi   5,5Gi   8,6Gi
Swap: 2,0Gi   0B      2,0Gi
```

### 5.3. Финальная проверка /etc/fstab
```bash
cat -n /etc/fstab
```
**Результат (строка 8):**
```
     8	/swapfile none swap sw 0 0
```

### 5.4. Отключение старого раздела (если еще активен)
```bash
sudo swapoff /dev/nvme0n1p2 2>/dev/null
```

---

## 6. Оптимизация использования swap (рекомендуется)

### 6.1. Уменьшение "swappiness" (активности использования swap)
```bash
# Временное изменение (до перезагрузки)
sudo sysctl vm.swappiness=10

# Постоянное изменение
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```

**Пояснение:** Значение 10 означает, что swap будет использоваться только при крайней необходимости (обычно значение 60).

---

## 7. Особенности и возможные проблемы

### 7.1. Btrfs и swap-файлы
На Btrfs swap-файлы требуют:
- Отключения Copy-on-Write (`chattr +C`)
- Поддержки ядром (Linux 5.0+)
- **Обязательного использования** `chattr +C` **ДО** выделения места

### 7.2. Ошибка "Недопустимый аргумент"
Возникала при попытке `swapon` без `chattr +C`. Решение — последовательность:
```bash
truncate → chattr +C → fallocate → chmod → mkswap → swapon
```

### 7.3. Старый swap-раздел
Остался на диске, но не используется:
- **Не мешает** работе системы
- Занимает 8.4 ГБ на диске
- **Для полного удаления** требуется загрузка с LiveUSB и использование GParted

---



