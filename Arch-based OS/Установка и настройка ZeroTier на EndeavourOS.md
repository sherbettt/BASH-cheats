# Инструкция: Установка и настройка ZeroTier на EndeavourOS

## Система
- **ОС:** EndeavourOS (Arch-based)
- **Версия ZeroTier:** 1.16.0-2

---
### читай: 
  - ***https://github.com/zerotier/ZeroTierOne/blob/dev/doc/zerotier-cli.1.md***
  - ***https://www.mankier.com/1/zerotier-cli***

---

## Шаг 1: Установка пакетов

```bash
sudo pacman -S zerotier-one zerotier-gui-git
```

Пакет находится в официальных репозиториях Arch/EndeavourOS.

---

## Шаг 2: Запуск и включение службы

```bash
sudo systemctl enable --now zerotier-one.service
```

Проверка статуса:
```bash
sudo systemctl status zerotier-one.service
```

Ожидаемый результат: `Active: active (running)`

---

## Шаг 3: Получение Node ID

```bash
sudo zerotier-cli status
```

**Вывод:**
```
200 info 5aa3d1df20 1.16.0 ONLINE
```

**Node ID:** `5aa3d1df20` — понадобится для авторизации в веб-панели.

---

## Шаг 4: Подключение к сети

```bash
sudo zerotier-cli join b103a835d258b06a
```

**Вывод:**
```
200 join OK
```

---

## Шаг 5: Авторизация устройства

1. Открыть https://my.zerotier.com
2. Найти сеть `b103a835d258b06a`
3. В разделе **Members** найти Node ID `5aa3d1df20`
4. ✅ Поставить галочку **Auth** (Authorize)

---

## Шаг 6: Проверка подключения

```bash
sudo zerotier-cli listnetworks
```

**Вывод до авторизации:**
```
200 listnetworks b103a835d258b06a ... REQUESTING_CONFIGURATION ... -
```

**Вывод после авторизации:**
```
200 listnetworks b103a835d258b06a K1rpi4i-net 6a:ea:fb:03:ea:88 OK PRIVATE ztqti7bbny 10.147.20.153/24
```

Проверка интерфейса:
```bash
ip addr show ztqti7bbny
```

**Результат:** интерфейс `ztqti7bbny` получает IP `10.147.20.153/24`

---

## Итоговая конфигурация

| Параметр | Значение |
|----------|----------|
| Node ID | `5aa3d1df20` |
| Сеть | `b103a835d258b06a` (K1rpi4i-net) |
| ZeroTier IP | `10.147.20.153/24` |
| Статус | `OK` |

---

## Полезные команды

| Команда | Описание |
|---------|----------|
| `sudo zerotier-cli status` | Статус службы и Node ID |
| `sudo zerotier-cli listnetworks` | Список сетей и их статус |
| `sudo zerotier-cli listpeers` | Список подключённых узлов |
| `sudo zerotier-cli leave <nwid>` | Покинуть сеть |
| `sudo zerotier-cli join <nwid>` | Присоединиться к сети |

---

## Установка завершена

Устройство доступно в ZeroTier сети по адресу **10.147.20.153**.

---

## ⚠️ Важное дополнение: Решение проблемы с TUN/TAP устройством

### Проблема
При запуске zerotier-one возникает ошибка:
```
ERROR: unable to configure virtual network port: could not open TUN/TAP device: No such file or directory
```
ZeroTier подключается к сети (join OK), но виртуальный интерфейс `zt...` не создаётся, команда `ip a` не показывает интерфейс ZeroTier.

### Причина
Отсутствует или не загружен модуль ядра `tun`. Проверка:
```bash
lsmod | grep tun      # пустой вывод — модуль не загружен
sudo modprobe tun     # ошибка: Module tun not found in directory /lib/modules/версия-ядра
```

Это происходит, если после обновления ядра не были установлены или обновлены соответствующие модули.

### Диагностика
```bash
# Проверить существование устройства
ls -la /dev/net/tun     # должно быть: crw-rw-rw- 1 root root 10, 200

# Проверить загрузку модуля
lsmod | grep tun

# Проверить версию ядра
uname -r
```

### Решение

#### 1. Переустановить пакет ядра (если модуль не найден)
```bash
sudo pacman -S linux
```

#### 2. Перезагрузить систему (обязательно!)
```bash
sudo reboot
```

#### 3. После перезагрузки проверить модуль
```bash
lsmod | grep tun
```
**Ожидаемый вывод:**
```
tun                    73728  2
```

#### 4. Убедиться, что устройство доступно
```bash
ls -la /dev/net/tun
# Должно быть: crw-rw-rw- 1 root root 10, 200
```

#### 5. Перезапустить ZeroTier
```bash
sudo systemctl restart zerotier-one
```

#### 6. Проверить появление интерфейса
```bash
ip a | grep zt
```
**Ожидаемый вывод:**
```
4: ztqti7bbny: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    inet 10.147.20.153/24 ...
```

### Альтернативное решение (без перезагрузки — временно)
```bash
# Принудительное создание TUN устройства
sudo mkdir -p /dev/net
sudo mknod /dev/net/tun c 10 200
sudo chmod 666 /dev/net/tun

# Попытка принудительной загрузки модуля (если файл существует)
sudo insmod /usr/lib/modules/$(uname -r)/kernel/drivers/net/tun.ko.xz
```

⚠️ **Важно:** Перезагрузка после установки модулей ядра является обязательной для корректной работы.

### Проверка успешного решения
```bash
# Статус сервиса без ошибок
sudo systemctl status zerotier-one | grep -i error
# Не должно быть сообщений об ошибке TUN/TAP

# Просмотр списка сетей — интерфейс и IP присутствуют
sudo zerotier-cli listnetworks

# Проверка пиров (должны отображаться другие узлы сети)
sudo zerotier-cli peers
```

### Типичная последовательность действий при проблеме TUN/TAP:
1. Установка ZeroTier: `sudo pacman -S zerotier-one`
2. Запуск сервиса: `sudo systemctl enable --now zerotier-one`
3. Обнаружение ошибки TUN/TAP в статусе сервиса
4. Проверка модуля: `lsmod | grep tun` (пусто)
5. Переустановка ядра: `sudo pacman -S linux`
6. Перезагрузка: `sudo reboot`
7. Проверка модуля: `lsmod | grep tun` (есть)
8. Подключение к сети: `sudo zerotier-cli join <network-id>`
9. Авторизация устройства в веб-панели ZeroTier Central
10. Получение IP и работа сети

---

## Установка завершена (с учётом решения проблемы TUN/TAP)

Устройство доступно в ZeroTier сети по адресу **10.147.20.153**. Виртуальный интерфейс `ztqti7bbny` успешно создан, модуль `tun` загружен, сеть функционирует штатно.
