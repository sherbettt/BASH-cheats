# Настройка блокировки входа в EndeavourOS (GNOME) — шпаргалка

## Быстрая настройка

```bash
# Открыть конфиг
sudo mcedit /etc/security/faillock.conf

# Добавить строки (или раскомментировать):
deny = 12
unlock_time = 60
fail_interval = 60

# Сохранить и выйти: F2, F10
```

---

## Все команды для работы с блокировкой

### Основные команды

| Команда | Что делает |
|---------|------------|
| `faillock` | Показать всех заблокированных пользователей |
| `faillock --user username` | Показать статус блокировки конкретного пользователя |
| `sudo faillock --reset` | Разблокировать текущего пользователя |
| `sudo faillock --user username --reset` | Разблокировать конкретного пользователя |
| `sudo faillock --reset --user all` | Разблокировать всех пользователей |

### Диагностика

| Команда | Что делает |
|---------|------------|
| `journalctl --since today \| grep faillock` | Показать логи блокировок за сегодня |
| `journalctl -f \| grep -i pam` | Следить за логами PAM в реальном времени |
| `ls -la /var/run/faillock/` | Посмотреть файлы блокировок (временные) |
| `cat /var/run/faillock/$(whoami)` | Прочитать файл блокировки текущего пользователя |

---

## Параметры faillock.conf (все возможные)

```ini
# Количество неудачных попыток до блокировки
deny = 3

# Интервал подсчета ошибок (секунды)
fail_interval = 900

# Время блокировки (секунды)
unlock_time = 600

# Время блокировки root-пользователя (если не указано, root не блокируется)
root_unlock_time = 600

# Директория хранения данных блокировок
dir = /var/run/faillock

# Блокировать root (отключает защиту)
even_deny_root

# Не показывать сообщения о блокировке
silent

# Не увеличивать счетчик для root
no_root_faillock

# Очищать счетчик после успешного входа
reset_on_success

# Показывать количество оставшихся попыток
audit
```

---

## Быстрые однострочники

```bash
# Узнать, сколько попыток осталось (нужно ввести неправильный пароль, чтобы увидеть)
# Система покажет сообщение типа: "Authentication failed. 2 attempts left."

# Сбросить блокировку без перезагрузки
sudo rm -f /var/run/faillock/$(whoami)

# Альтернативный сброс через faillock
sudo faillock --user $(whoami) --reset

# Посмотреть время блокировки
grep unlock_time /etc/security/faillock.conf

# Посмотреть количество попыток
grep deny /etc/security/faillock.conf

# Проверить, есть ли файл конфигурации
ls -la /etc/security/faillock.conf

# Создать конфиг с нуля с настройками "5 попыток, блокировка 30 секунд"
echo -e "deny = 5\nunlock_time = 30\nfail_interval = 30" | sudo tee /etc/security/faillock.conf
```

---

## Команды для экстренной разблокировки

### Если вы заблокировались в GNOME:

1. **Переключитесь на другой терминал:**
   ```
   Ctrl + Alt + F2
   ```
   (F2, F3, F4, F5, F6 — доступно несколько виртуальных терминалов)

2. **Войдите в систему:**
   ```
   login: root
   Password: ваш_пароль
   ```

3. **Сбросьте блокировку:**
   ```bash
   sudo faillock --reset

   # Принудительная разблокировка пользователя
   sudo faillock --user <user_name> --reset

   # Очистка всех блокировок
   sudo faillock --reset --user all
   ```

4. **Вернитесь в GNOME:**
   ```
   Ctrl + Alt + F1
   ```
   (или F7, зависит от системы)

---

## Где искать проблемы

```bash
# Посмотреть ошибки PAM
sudo journalctl -xe | grep -i pam | tail -20

# Посмотреть все логи блокировок
sudo journalctl -u systemd-logind | grep -i lock

# Проверить синтаксис конфигурации PAM
sudo pam_tally2 -u username 2>/dev/null || echo "pam_tally2 не используется, используется faillock"
```

---

## Важные заметки

| Что | Где |
|-----|-----|
| Конфигурация faillock | `/etc/security/faillock.conf` |
| Временные файлы блокировок | `/var/run/faillock/` |
| Логи входа в систему | `journalctl -u gdm` (для GNOME) |
| Настройки PAM | `/etc/pam.d/system-auth` (не редактировать вручную!) |

---

## Самые частые команды (шпаргалка)

```bash
# Показать текущие настройки
cat /etc/security/faillock.conf | grep -v "^#"

# Разблокировать себя
sudo faillock --reset

# Узнать имя пользователя
whoami

# Разблокировать по имени
sudo faillock --user kkorablin --reset

# Сделать 10 попыток вместо 3
echo "deny = 10" | sudo tee -a /etc/security/faillock.conf

# Сделать блокировку 2 минуты
echo "unlock_time = 120" | sudo tee -a /etc/security/faillock.conf

# Проверить, активна ли блокировка сейчас
faillock

# Перезапустить GDM (если что-то пошло не так) — ВНИМАНИЕ: закроет все сессии!
sudo systemctl restart gdm
```

---

## Изменения вступают в силу сразу

После изменения `/etc/security/faillock.conf` команды `faillock` сразу начнут использовать новые настройки. Перезагрузка не требуется.

```bash
# Проверка, что настройки применились
sudo faillock --reset  # сбрасывает счетчик
# Теперь сделайте 3 ошибки при вводе пароля и проверьте время блокировки
```

