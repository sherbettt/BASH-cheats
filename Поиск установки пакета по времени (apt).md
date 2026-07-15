# Поиск установки пакета по времени в Debian (apt)

Предполдожим, имеется пакет:
```bash
root@pbx-qa ~
07:45:39 # apt policy runtel-iface-v2 | head -20

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

runtel-iface-v2:
  Установлен: 2.22.9-9-235-deb12
  Кандидат:   2.22.11-1-233-deb12
  Таблица версий:
     2.22.11-1-233-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-237-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-236-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-234-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-228-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-227-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-223-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-222-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages

root@pbx-qa ~
07:46:21 # dpkg -l runtel-iface-v2
Желаемый=неизвестно[u]/установить[i]/удалить[r]/вычистить[p]/зафиксировать[h]
| Состояние=не[n]/установлен[i]/настроен[c]/распакован[U]/частично настроен[F]/
            частично установлен[H]/trig-aWait/Trig-pend
|/ Ошибка?=(нет)/требуется переустановка[R] (верхний регистр
в полях состояния и ошибки указывает на ненормальную ситуацию)
||/ Имя             Версия             Архитектура  Описание
+++-===============-==================-============-=================================
ii  runtel-iface-v2 2.22.9-9-235-deb12 amd64        runtel iface v2 package
```

**Требуется узнать историю изменения установки версиий данного пакета по времени.**



<br/>

-------------------------
## 1. **История APT (самый надежный способ)**

APT ведет подробный лог всех действий:

```bash
grep "runtel-iface-v2" /var/log/apt/history.log
```

И посмотрите более старые логи (они ротируются):

```bash
zgrep "runtel-iface-v2" /var/log/apt/history.log*.gz
```

Это покажет **дату и время** каждого действия с пакетом (установка, обновление, удаление).

---

## 2. **История DPKG (более детальная)**

```bash
grep "runtel-iface-v2" /var/log/dpkg.log
```

И старые логи:

```bash
zgrep "runtel-iface-v2" /var/log/dpkg.log*.gz
```

В выводе будет что-то вроде:
```
2026-01-15 10:30:45 status installed runtel-iface-v2 2.22.9-9-235-deb12
2025-12-01 14:20:10 upgrade runtel-iface-v2 2.22.8-xxx 2.22.9-9-235-deb12
```

---

## 3. **Информация о времени установки файлов**

Можно посмотреть, когда были созданы/изменены файлы пакета:

```bash
ls -la /opt/runtel/bin/iface
stat /opt/runtel/bin/iface
```

Или для всех файлов пакета:

```bash
dpkg -L runtel-iface-v2 | xargs ls -la --time-style=full 2>/dev/null | grep -v "^d"
```

---

## 4. **Статус пакета в базе dpkg**

Показать, когда пакет был установлен (только дата, не время):

```bash
dpkg-query -s runtel-iface-v2 | grep Installed
```

---

## 5. **Проверить, были ли установлены другие версии ранее**

Посмотреть все версии, которые когда-либо были установлены:

```bash
grep "status installed runtel-iface-v2" /var/log/dpkg.log* | sort
```

---

## **Краткий ответ на ваш вопрос:**

Выполните эту команду, чтобы увидеть полную историю:

```bash
zgrep -E "(install|upgrade|remove|purge).*runtel-iface-v2" /var/log/dpkg.log* | sort
```

Это покажет все действия с пакетом, включая дату, время и версии.

