# Поиск истории установки пакета по времени в Debian (apt/dpkg)

## Проблема

Имеется установленный пакет, например:
```bash
root@pbx-qa ~
07:45:39 # apt policy runtel-iface-v2 | head -20

runtel-iface-v2:
  Установлен: 2.22.9-9-235-deb12
  Кандидат:   2.22.11-1-233-deb12
  Таблица версий:
     2.22.11-1-233-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     2.22.10-1-237-deb12 500
        500 http://repo.runtel.ru bookworm/dev amd64 Packages
     ...

root@pbx-qa ~
07:46:21 # dpkg -l runtel-iface-v2
ii  runtel-iface-v2 2.22.9-9-235-deb12 amd64        runtel iface v2 package
```

**Требуется узнать полную историю изменения версий данного пакета с привязкой ко времени.**

---

## 1. **История APT** (информация о командах)

APT хранит историю выполненных команд в `/var/log/apt/history.log`:

```bash
# Просмотр текущего лога
grep "runtel-iface-v2" /var/log/apt/history.log

# Просмотр всех сжатых и несжатых логов
zgrep "runtel-iface-v2" /var/log/apt/history.log*

# Только действия с пакетом (установка/обновление/удаление)
zgrep -E "(Install|Upgrade|Remove|Purge).*runtel-iface-v2" /var/log/apt/history.log*

# Показать команды, которые затрагивали пакет
zgrep "Commandline:.*runtel-iface-v2" /var/log/apt/history.log*
```

**Пример вывода:**
```
2026-07-01 13:51:33 upgrade runtel-iface-v2:amd64 2.22.9-9-212-deb12 2.22.9-9-214-deb12
2026-07-14 13:38:11 downgrade runtel-iface-v2:amd64 2.22.11-1-233-deb12 2.22.10-1-236-deb12
```

---

## 2. **История DPKG** (детальная информация о каждом пакете)

DPKG логирует каждое действие с пакетами в `/var/log/dpkg.log`:

### 2.1. Просмотр текущих логов

```bash
# Все записи о пакете
grep "runtel-iface-v2" /var/log/dpkg.log

# Только установка/обновление/понижение версии
grep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log

# Только финальный статус "installed"
grep "status installed runtel-iface-v2" /var/log/dpkg.log

# Все статусы пакета (включая промежуточные)
grep "status.*runtel-iface-v2" /var/log/dpkg.log
```

### 2.2. Просмотр сжатых (ротированных) логов

Логи DPKG ротируются и сжимаются в `.gz` архивы. Для поиска по ним используйте `zgrep`:

```bash
# Все записи из всех логов (включая сжатые)
zgrep "runtel-iface-v2" /var/log/dpkg.log*

# Только изменения версий (установка, обновление, понижение)
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | sort

# Все статусы "installed" из всех логов
zgrep "status installed runtel-iface-v2" /var/log/dpkg.log* | sort

# Полная история с сортировкой по времени
zgrep -E "(install|upgrade|downgrade|remove|purge).*runtel-iface-v2" /var/log/dpkg.log* | sort
```

### 2.3. Форматированный вывод для удобства

```bash
# Компактный вывод: дата, время, действие, версии
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  awk '{print $1, $2, $4, $5, $6, $7, $8}' | column -t

# Только дата и версии (без промежуточных статусов)
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  grep -v "status" | awk '{print $1, $2, $4, $5, $6, $7, $8}' | column -t
```

---

## 3. **Дополнительные способы определения времени**

### 3.1. По времени изменения файлов пакета

```bash
# Время изменения основного исполняемого файла
ls -la /opt/runtel/bin/iface
stat /opt/runtel/bin/iface

# Все файлы пакета с временем
dpkg -L runtel-iface-v2 | xargs ls -la --time-style=full 2>/dev/null | grep -v "^d"

# Самый старый и самый новый файл в пакете
dpkg -L runtel-iface-v2 | xargs stat -c '%y %n' 2>/dev/null | sort
```

### 3.2. Информация из базы dpkg

```bash
# Дата установки (только дата, без времени)
dpkg-query -s runtel-iface-v2 | grep Installed

# Подробная информация о пакете
dpkg-query -s runtel-iface-v2
```

### 3.3. По журналу systemd (если пакет запускает службу)

```bash
# Время последнего запуска службы
systemctl show runtel-iface-v2 --property=ActiveEnterTimestamp

# Журнал службы
journalctl -u runtel-iface-v2 --since "2026-05-01"
```

---

## 4. **Практические примеры**

### 4.1. Узнать, когда пакет был установлен впервые

```bash
# Самая первая запись об установке
zgrep "install.*runtel-iface-v2" /var/log/dpkg.log* | head -1

# Или с форматированием
zgrep "install.*runtel-iface-v2" /var/log/dpkg.log* | head -1 | awk '{print $1, $2, $4, $5}'
```

### 4.2. Узнать, когда была установлена текущая версия

```bash
# Найти момент, когда текущая версия стала "installed"
zgrep "status installed runtel-iface-v2.*2.22.9-9-235-deb12" /var/log/dpkg.log*

# Или найти upgrade/downgrade на эту версию
zgrep -E "(upgrade|downgrade).*runtel-iface-v2.*2.22.9-9-235-deb12" /var/log/dpkg.log*
```

### 4.3. Получить полную историю в читаемом виде

```bash
# С цветным выводом (если установлен ccze)
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  sort | ccze -A

# Без ccze, но с форматированием
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  sort | awk '{printf "%s %s %-10s %-20s -> %-20s\n", $1, $2, $4, $6, $8}'
```

### 4.4. Сравнить историю нескольких пакетов

```bash
# История для группы пакетов
for pkg in runtel-iface-v2 runtel-core-v2 runtel-web-v2; do
  echo "=== $pkg ==="
  zgrep -E "(install|upgrade|downgrade).*$pkg" /var/log/dpkg.log* | tail -5
  echo
done
```

### 4.5. Найти все откаты (downgrade) пакета

```bash
zgrep "downgrade.*runtel-iface-v2" /var/log/dpkg.log*
```

---

## 5. **Особенности работы с логами**

### 5.1. Структура логов dpkg

Лог-файлы dpkg содержат следующие типы записей:

| Тип записи | Описание | Пример |
|-----------|----------|--------|
| `install` | Установка пакета | `install runtel-iface-v2:amd64 <none> 2.22.5-15-18-deb12` |
| `upgrade` | Обновление версии | `upgrade runtel-iface-v2:amd64 2.22.9-9-212-deb12 2.22.9-9-214-deb12` |
| `downgrade` | Откат версии | `downgrade runtel-iface-v2:amd64 2.22.11-1-233-deb12 2.22.10-1-236-deb12` |
| `remove` | Удаление | `remove runtel-iface-v2:amd64 2.22.9-9-235-deb12` |
| `purge` | Полное удаление с конфигами | `purge runtel-iface-v2:amd64 2.22.9-9-235-deb12` |
| `status` | Промежуточный статус | `status installed runtel-iface-v2:amd64 2.22.9-9-235-deb12` |
| `configure` | Настройка пакета | `configure runtel-iface-v2:amd64 2.22.9-9-235-deb12 <none>` |

### 5.2. Ротация логов

Логи в Debian ротируются:
- `/var/log/dpkg.log` — текущий лог
- `/var/log/dpkg.log.1` — предыдущий (еще не сжат)
- `/var/log/dpkg.log.2.gz` — сжатый архив (gzip)
- `/var/log/dpkg.log.3.gz` — и т.д.

**Важно:** Всегда используйте `zgrep` вместо `grep` для поиска по `/var/log/dpkg.log*`, чтобы не пропустить сжатые файлы.

### 5.3. Почему `grep` и `zgrep` показывают разное?

```bash
# grep — читает только несжатые файлы
grep "runtel-iface-v2" /var/log/dpkg.log*   # читает .log, .log.1

# zgrep — читает все файлы (и сжатые, и нет)
zgrep "runtel-iface-v2" /var/log/dpkg.log*  # читает .log, .log.1, .log.2.gz, ...
```

---

## 6. **Полезные однострочники**

```bash
# Полная история с сортировкой по времени (самая полная команда)
zgrep -E "(install|upgrade|downgrade|remove|purge).*runtel-iface-v2" /var/log/dpkg.log* | sort

# Только основные события (без промежуточных статусов)
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | grep -v "status" | sort

# История с человекочитаемым форматом
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  grep -v "status" | sort | \
  awk '{printf "%-10s %-8s %-30s -> %-30s\n", $1" "$2, $4, $6, $8}'

# Количество установок/обновлений пакета
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  grep -v "status" | wc -l

# Список всех версий, которые когда-либо были установлены
zgrep "status installed runtel-iface-v2" /var/log/dpkg.log* | \
  awk '{print $8}' | sort -u

# История только за последние N дней (например, 30)
zgrep -E "(install|upgrade|downgrade).*runtel-iface-v2" /var/log/dpkg.log* | \
  awk -v d="2026-06-01" '$1 >= d' | sort

# Поиск по конкретной версии
zgrep "runtel-iface-v2.*2.22.9-9-235-deb12" /var/log/dpkg.log*
```

---

## 7. **Заключение**

Для получения полной истории пакета в Debian рекомендуется использовать:

```bash
zgrep -E "(install|upgrade|downgrade|remove|purge).*<имя_пакета>" /var/log/dpkg.log* | sort
```

Эта команда:
- Читает все логи (включая сжатые)
- Показывает все действия с пакетом
- Сортирует по времени (старые → новые)
- Дает полную картину изменений версий
