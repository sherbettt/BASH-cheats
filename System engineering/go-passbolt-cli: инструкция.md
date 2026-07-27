# Полная инструкция по go-passbolt-cli

## 1. Настройка

```bash
# Настраивается единожды:
passbolt configure \
  --serverAddress https://passwd.runtel.ru \
  --userPrivateKeyFile /home/kkorablin/Загрузки/passbolt-recovery-kit_kiko.txt
```

## 2. Правильные команды для просмотра

### Просмотр всего (без фильтров)

```bash
# Все ресурсы (пароли)
passbolt list resources
passbolt list resources | (head -3; tail -n +4 | sort -t '|' -k 2,2 -k 3,3) | head -12

# Все папки
passbolt list folders
passbolt list folders | (head -4; tail -n +5 | sort -t '|' -k 2,2 -k 3,3)

# Все пользователи
passbolt list users

# Все группы
passbolt list groups
```

### Поиск и фильтрация

**Важно:** Фильтры работают ТОЛЬКО с оператором `==` (точное совпадение)!

```bash
# Поиск по точному имени
passbolt list resources --filter 'name == "kats"'

# Поиск по точному URI (обязательно в кавычках!)
passbolt list resources --filter 'uri == "10.100.210.2"'

# Поиск по папке (по ID папки)
passbolt list resources --filter 'folder_parent_id == "9d589e93-b8bf-4950-9185-c3485e09bc33"'

# Поиск по имени пользователя
passbolt list resources --filter 'username == "root"'

# Комбинированный фильтр (И)
passbolt list resources --filter 'name == "kats" && username == "root"'

# Комбинированный фильтр (ИЛИ)
passbolt list resources --filter 'name == "kats" || name == "lk-a7ru"'

# Проверка на NULL (корневые папки)
passbolt list folders --filter 'folder_parent_id == null'
```

### Получение конкретного объекта

```bash
# Получить ресурс (пароль) по ID
passbolt get resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9

# Получить папку по ID
passbolt get folder --id 9d589e93-b8bf-4950-9185-c3485e09bc33

# Получить пользователя по ID
passbolt get user --id 955ab5fe-7638-46d3-8027-aea3bb13d993

# Получить группу по ID
passbolt get group --id 0adf657d-9d93-40a8-bd16-7958c75b8eb8
```

### Просмотр пароля (секрета)

**Единственный рабочий способ** - использовать JSON вывод с флагом `-j` или `--json`:

```bash
# Получить пароль (короткий флаг -j)
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq '.password'

# Или с полным флагом --json
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 --json | jq '.password'

# Посмотреть всю информацию о ресурсе
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq '.'
```

**Пример вывода:**
```json
{
  "folder_parent_id": "9d589e93-b8bf-4950-9185-c3485e09bc33",
  "name": "kats",
  "username": "root",
  "uri": "10.100.210.2",
  "password": "<PASSWR>",
  "description": "Imported (date: 2026-07-24T12:01:45Z)",
  "metadata": {
    "description": "Imported (date: 2026-07-24T12:01:45Z)",
    "name": "kats",
    "uri": "10.100.210.2",
    "username": "root"
  },
  "secret": {
    "description": "Imported (date: 2026-07-24T12:01:45Z)",
    "password": "<PASSWR>"
  },
  "deleted": false,
  "expired": false
}
```

### Просмотр прав доступа (Permissions)

```bash
# Получить права доступа для ресурса
passbolt get resource permission --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 -j | jq '.'

# Или через get resource с JSON
passbolt get resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 -j | jq '.permissions'
```

## 3. Создание данных

### Создать ресурс (пароль)

```bash
passbolt create resource \
  --name="server_name" \
  --uri="10.100.210.2" \
  --username="admin" \
  --password="your_password" \
  --description="Описание сервера" \
  --folder-parent-id="9d589e93-b8bf-4950-9185-c3485e09bc33"
```

### Создать папку

```bash
# В корне
passbolt create folder --name="new_folder"

# В другой папке
passbolt create folder --name="sub_folder" --parent-id="9d589e93-b8bf-4950-9185-c3485e09bc33"
```

### Создать группу

```bash
passbolt create group \
  --name="devops" \
  --users='["k@runtel.ru", "a@runtel.ru"]'
```

## 4. Обновление данных

### Обновить ресурс

```bash
# Обновить пароль
passbolt update resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 --password="new_password"

# Обновить имя
passbolt update resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 --name="new_name"

# Обновить описание
passbolt update resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 --description="new description"

# Переместить в другую папку
passbolt update resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 --folder-parent-id="new_folder_id"
```

### Обновить папку

```bash
passbolt update folder --id 9d589e93-b8bf-4950-9185-c3485e09bc33 --name="new_name"
```

### Обновить группу (добавить/удалить пользователей)

```bash
# Добавить пользователя
passbolt update group --id 0adf657d-9d93-40a8-bd16-7958c75b8eb8 --add-user="k@runtel.ru"

# Удалить пользователя
passbolt update group --id 0adf657d-9d93-40a8-bd16-7958c75b8eb8 --remove-user="k@runtel.ru"
```

## 5. Управление доступом (Share)

```bash
# Поделиться ресурсом с пользователем
passbolt share resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 \
  --user="k@runtel.ru" \
  --permission="read"

# Поделиться ресурсом с группой
passbolt share resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 \
  --group="developers" \
  --permission="update"

# Поделиться папкой
passbolt share folder --id 9d589e93-b8bf-4950-9185-c3485e09bc33 \
  --user="k@runtel.ru" \
  --permission="owner"

# Уровни доступа: read, update, owner, admin
```

## 6. Удаление данных

```bash
# Удалить ресурс
passbolt delete resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9

# Удалить папку
passbolt delete folder --id 9d589e93-b8bf-4950-9185-c3485e09bc33

# Удалить группу
passbolt delete group --id 0adf657d-9d93-40a8-bd16-7958c75b8eb8
```

## 7. Экспорт данных

```bash
# Экспорт всех ресурсов в JSON
passbolt export resources > all_resources.json

# Экспорт в CSV (если поддерживается)
passbolt export resources --format csv > all_resources.csv
```

**Примечание:** Флаг `--secret` для export может не работать. Используйте `get resource --json` для получения паролей.

## 8. Работа с JSON и jq

```bash
# Получить пароль для конкретного ресурса
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq -r '.password'

# Получить все поля ресурса
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq '.'

# Получить только имя и пароль
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq '{name, password}'
```

## 9. Полезные скрипты

### Скрипт для просмотра всех паролей в папке

```bash
#!/bin/bash
# save as show_folder_passwords.sh
FOLDER_ID="9d589e93-b8bf-4950-9185-c3485e09bc33"

echo "=== Пароли из папки ssh_users ==="
echo "----------------------------------------"

passbolt list resources --filter "folder_parent_id == \"$FOLDER_ID\"" | \
  awk 'NR>1 {print $1, $4, $5}' | \
  while read id name uri; do
    password=$(passbolt get resource --id $id -j 2>/dev/null | jq -r '.password')
    echo "$name | $uri | $password"
  done
```

### Функция для быстрого получения пароля

Добавьте в `~/.bashrc`:

```bash
# Быстрое получение пароля по имени
pass-get() {
    if [ -z "$1" ]; then
        echo "Использование: pass-get <имя_ресурса> [username]"
        return 1
    fi
    
    if [ -n "$2" ]; then
        id=$(passbolt list resources --filter "name == \"$1\" && username == \"$2\"" 2>/dev/null | awk 'NR==2 {print $1}')
    else
        id=$(passbolt list resources --filter "name == \"$1\"" 2>/dev/null | awk 'NR==2 {print $1}')
    fi
    
    if [ -z "$id" ]; then
        echo "Ресурс '$1' не найден"
        return 1
    fi
    
    passbolt get resource --id $id -j 2>/dev/null | jq -r '.password'
}

# Показать все версии ресурса
pass-list() {
    if [ -z "$1" ]; then
        echo "Использование: pass-list <имя_ресурса>"
        return 1
    fi
    
    passbolt list resources --filter "name == \"$1\"" 2>/dev/null | awk 'NR>1 {print $4, $5, $1}'
}
```

Использование:
```bash
source ~/.bashrc

# Получить пароль для kats/root
pass-get kats root

# Получить пароль для первого найденного kats
pass-get kats

# Показать все версии kats
pass-list kats
```

## 10. Частые ошибки и их решение

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `unknown flag: --limit` | Флаг не существует | Уберите `--limit` |
| `unknown flag: --output` | Неправильный флаг | Используйте `-j` или `--json` |
| `unknown flag: --secret` | Флаг не существует | Используйте `-j \| jq '.password'` |
| `unknown flag: --show-secret` | Флаг не существует | Используйте `-j \| jq '.password'` |
| `Error: required flag(s) "id" not set` | Не передали ID | Добавьте `--id <UUID>` |
| `API error (code 404)` | Объект не найден | Проверьте ID (ресурс vs папка) |
| `gopenpgp: error in unlocking key` | Проблема с ключом | Введите пароль заново |
| Фильтры не работают | Используете `=~` или `contains` | Используйте только `==` |

## 11. Шпаргалка по полям JSON

При использовании `-j` или `--json` вывод содержит:

```json
{
  "id": "b9d9592b-0b0c-4ce4-a057-71f58d880a86",
  "name": "kats",
  "username": "root",
  "uri": "10.100.210.2",
  "password": "<PASSWR>",    // ← ПАРОЛЬ ЗДЕСЬ!
  "description": "Imported (date: ...)",
  "folder_parent_id": "9d589e93-b8bf-4950-9185-c3485e09bc33",
  "metadata": { ... },
  "secret": {
    "password": "<PASSWR>"   // ← И ЗДЕСЬ ТОЖЕ!
  },
  "deleted": false,
  "expired": false
}
```

**Пароль находится в двух местах:**
- `password` - основной пароль
- `secret.password` - дублирование

## 12. Важные отличия от других CLI

1. **Нет** `--limit` - выводит все сразу
2. **Нет** `--output json` - используйте `-j` или `--json`
3. **Нет** `--secret` или `--show-secret` для `get resource`
4. **Пароль получается через JSON** - `-j | jq '.password'`
5. **Нет** `contains()` и `=~` - только точное сравнение `==`
6. **get resource** - обязательно с `--id`

## 13. Отладка

Если что-то не работает - используйте `--debug`:

```bash
passbolt --debug get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j
```

