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

# Все папки
passbolt list folders

# Все пользователи
passbolt list users

# Все группы
passbolt list groups
```

### Поиск и фильтрация (правильный синтаксис)

**Важно:** Фильтры работают ТОЛЬКО с оператором `==` (точное совпадение)!

```bash
# Поиск по точному имени
passbolt list resources --filter 'name == "kats"'

# Поиск по точному URI
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

### Просмотр пароля

```bash
# Получить пароль (секрет) - ДРУГОЙ флаг!
passbolt get resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 --secret

# Или с полной информацией
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 --json

passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq '.secret'
```

### Просмотр прав доступа (Permissions)

```bash
# Получить ресурс с правами доступа
passbolt get resource --id 6af23369-4ac5-4c90-81b2-2f5f04595db9 --include-permissions

# Получить папку с правами
passbolt get folder --id 9d589e93-b8bf-4950-9185-c3485e09bc33 --include-permissions
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

# Экспорт с паролями
passbolt export resources --secret > all_with_passwords.json

# Экспорт в CSV
passbolt export resources --format csv > all_resources.csv
```

## 8. Работа с JSON и jq (продвинутый уровень)

```bash
# Получить список всех имен ресурсов
passbolt list resources --output json | jq '.[].name'

# Получить ID ресурса по имени и имени пользователя
passbolt list resources --output json | \
  jq -r '.[] | select(.name=="kats" and .username=="root") | .id'

# Найти дубликаты по URI
passbolt list resources --output json | \
  jq -r '.[] | {uri: .uri, name: .name, username: .username}' | \
  jq -s 'group_by(.uri) | map(select(length > 1))'

# Получить все ресурсы в папке с паролями
passbolt list resources --filter 'folder_parent_id == "9d589e93-b8bf-4950-9185-c3485e09bc33"' --output json | \
  jq '.[] | {name, username, uri, password: .secret}'
```

## 9. Частые ошибки и их решение

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `unknown flag: --limit` | Флаг не существует | Уберите `--limit` |
| `unknown flag: --show-secret` | Неправильный флаг | Используйте `--secret` |
| `--show-password` | Неправильный флаг | Используйте `--secret` |
| `Error: required flag(s) "id" not set` | Не передали ID | Добавьте `--id <UUID>` |
| `API error (code 404)` | Объект не найден | Проверьте ID (ресурс vs папка) |
| `gopenpgp: error in unlocking key` | Проблема с ключом | Запросите пароль заново или перезапустите |
| Фильтры не работают | Используете `=~` или `contains` | Используйте только `==` |

## 10. Примеры из вашей системы

### Найти все дубликаты (по URI)

```bash
# Найти все ресурсы с одинаковым URI
passbolt list resources --output json | \
  jq -r '.[] | {uri: .uri, name: .name, username: .username}' | \
  jq -s 'group_by(.uri) | map(select(length > 1)) | .[] | {uri: .[0].uri, count: length, entries: .}'
```

### Получить пароль для конкретного ресурса

```bash
# 1. Найти ID
passbolt list resources --filter 'name == "kats" && username == "root"'
# ID: b9d9592b-0b0c-4ce4-a057-71f58d880a86

# 2. Получить пароль
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 --secret
```

### Показать все ресурсы с правами доступа

```bash
passbolt list resources --output json | \
  jq '.[] | {name, username, uri, permissions: .permissions}'
```

### Посмотреть структуру папок

```bash
passbolt list folders --output json | \
  jq '.[] | {name, id, parent: .folder_parent_id}'
```

### Добавить пользователя в группу developers

```bash
passbolt update group --id 0adf657d-9d93-40a8-bd16-7958c75b8eb8 --add-user="k@runtel.ru"
```

### Создать ресурс из файла

```bash
# Если у вас есть файл с паролями в формате CSV
passbolt import resources --file passwords.csv --format csv
```

## 11. Шпаргалка по полям объекта

### Ресурс (пароль):
- `id` - UUID
- `name` - название
- `username` - имя пользователя
- `uri` - URL/IP
- `description` - описание
- `secret` - пароль (требуется --secret)
- `folder_parent_id` - ID папки (null если в корне)
- `created` - дата создания
- `modified` - дата изменения

### Папка:
- `id` - UUID
- `name` - название
- `folder_parent_id` - ID родительской папки (null если корневая)

### Пользователь:
- `id` - UUID
- `username` - email
- `first_name` - имя
- `last_name` - фамилия
- `role` - роль (admin, user)

### Группа:
- `id` - UUID
- `name` - название группы
- `users` - список пользователей (требуется --include-users)

## 12. Полезные комбинации

```bash
# Получить все пароли из папки ssh_users
passbolt list resources \
  --filter 'folder_parent_id == "9d589e93-b8bf-4950-9185-c3485e09bc33"' \
  --output json | jq '.[] | {name, username, uri, password: .secret}'

# Найти все ресурсы, созданные сегодня
passbolt list resources --output json | \
  jq '.[] | select(.created | startswith("2026-07-24"))'

# Очистить дубликаты (оставить только root)
for name in kats lk-a7ru lk-cher; do
  # Найти ID для odmen и tcpdump, удалить
  passbolt list resources --filter "name == \"$name\" && username != \"root\"" --output json | \
    jq -r '.[].id' | while read id; do
      echo "Deleting $id ($name)"
      passbolt delete resource --id $id
    done
done
```

---

## Важно: ключевые отличия от других CLI

1. **Нет** `--limit` - выводит все сразу
2. **Нет** `--show-password` - используйте `--secret`
3. **Нет** `contains()` и `=~` - только точное сравнение `==`
4. **get resource** - обязательно с `--id`
5. ID папки и ресурса - разные вещи, не путайте!

Если что-то не работает - используйте `--debug` для детального вывода:
```bash
passbolt --debug list resources
```

