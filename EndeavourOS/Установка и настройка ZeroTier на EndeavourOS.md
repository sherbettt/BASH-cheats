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
