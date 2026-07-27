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
passbolt list folders | grep "c21d953c-ed52-4797-a9f2-ea494e6b23d4"
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

<details>
<summary> Пример проверки </summary>

```bash
# корневая папка Support level1 private folder
passbolt list folders | grep "833541ff-b8a3-49d6-9ac2-70d268ba7f5d"
Enter Password:
833541ff-b8a3-49d6-9ac2-70d268ba7f5d |                                      | Support level1 private folder
f94e6a18-4876-443a-bee1-03be0b8eee5c | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Артур Лагутин
d2e46392-8e37-43a3-b9eb-d8ac7fc7492f | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Богдан Косухин
9de8c8f8-9174-478a-ad3e-e608f06f62fc | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Вячеслав Ярцев
6543d9bd-0d30-4e04-be87-5c0783ed0951 | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Дмитрий Хопин
347788d5-6bb2-43b1-bdaf-eb1da39bfefe | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Иван Ковалёв
a4e86d9a-d123-4042-9f98-fa722f20179c | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Кирилл Кораблин
1d539c4a-155f-4fce-b59e-47568828fbd0 | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Кирилл Полыга
2aba19a3-3c82-4e08-88d9-23fcb324b0a0 | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Николай Нестеров
7babf1c8-ecd7-4b59-838b-3319bb12e7de | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Олег Антропов
f7188823-8fb1-449e-9c52-0707754845ed | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Сергей Ширинкин
feb2483f-9277-4033-b171-02f9934e339e | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Юлия Неваленая

# подпапка Артур Лагутин
passbolt list folders | grep "f94e6a18-4876-443a-bee1-03be0b8eee5c"
Enter Password:
f94e6a18-4876-443a-bee1-03be0b8eee5c | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Артур Лагутин

# подпапка Кирилл Кораблин
passbolt list folders | grep "a4e86d9a-d123-4042-9f98-fa722f20179c"
Enter Password:
f499ac52-5b80-4bb5-842f-328eb730215e | a4e86d9a-d123-4042-9f98-fa722f20179c | pbx-qa-clone.runtel.org
9dab5138-df72-4630-a92c-fbbbc3636107 | a4e86d9a-d123-4042-9f98-fa722f20179c | pbx-qa.runtel.org
f6cd3b04-c168-46ac-bb72-9a47361d928e | a4e86d9a-d123-4042-9f98-fa722f20179c | pbx-stage.runtel.org
a4e86d9a-d123-4042-9f98-fa722f20179c | 833541ff-b8a3-49d6-9ac2-70d268ba7f5d | Кирилл Кораблин

# что внутри подпапки Артур Лагутин
passbolt list resources --filter 'folder_parent_id == "f94e6a18-4876-443a-bee1-03be0b8eee5c"' | head -7
Enter Password:
id                                   | folder_parent_id                     | name                            | username       | uri
19342084-e22b-4b55-966b-ac6529708df9 | f94e6a18-4876-443a-bee1-03be0b8eee5c | 8-800                           | al@runtel.ru   | pbxv2.8-800.su
59958951-4261-40b3-98cb-74cc47c690bb | f94e6a18-4876-443a-bee1-03be0b8eee5c | ABCData                         | al@runtel.ru   | https://lk-abcdata.pbx.megafon.ru/
372a85da-263e-48f8-acc5-79cb00ffcf9e | f94e6a18-4876-443a-bee1-03be0b8eee5c | al@runtel.ru                    | al@runtel.ru   | https://lk-mo.cprt.su/users/edit
b23c7dc0-2a41-421c-9211-9b0695e9cd5c | f94e6a18-4876-443a-bee1-03be0b8eee5c | AURORA telecom                  | al@runtel.ru   | https://vpbx.su
d537ea49-8b6c-495b-8c29-44579e063f88 | f94e6a18-4876-443a-bee1-03be0b8eee5c | Billing                         | al@runtel.ru   | https://bl4.runtel.org/

# что внутри подпапки Кирилл Кораблин
passbolt list resources --filter 'folder_parent_id == "a4e86d9a-d123-4042-9f98-fa722f20179c"' | head -7
Enter Password:
id                                   | folder_parent_id                     | name                 | username       | uri
114ba102-940e-491b-8ff1-69a9e3293ea3 | a4e86d9a-d123-4042-9f98-fa722f20179c | kats.dogma.ru        | root@runtel.ru | https://kats.dogma.ru/
6f8897e8-42c9-4154-9ca8-09d5eb377f49 | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-bichev.cprt.su    | root@runtel.ru | https://lk-bichev.cprt.su/users
913f8247-224c-4d17-a155-9705ef91c50e | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-fianit.cprt.su    | root@runtel.ru | https://lk-fianit.cprt.su/
3ff8c07a-32ec-4b30-8ba0-b7c86a4e612d | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-novoselie.cprt.su | k@runtel.ru    | lk-novoselie.cprt.su
c3bc1922-0dc3-4d3a-b9b2-65063742b9db | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-repremium.cprt.su | k@runtel.ru    | https://lk-repremium.cprt.su/pbx-hosts

# что внутри подпапки Кирилл Кораблин/pbx-qa.runtel.org
passbolt list resources --filter 'folder_parent_id == "9dab5138-df72-4630-a92c-fbbbc3636107"' | head -7
Enter Password:
id                                   | folder_parent_id                     | name              | username       | uri
b1e6a217-6381-438a-be04-e3d50afd9c02 | 9dab5138-df72-4630-a92c-fbbbc3636107 | db_password       | postgres       |
c83f70b7-8249-45e2-8d27-15788eb09f7f | 9dab5138-df72-4630-a92c-fbbbc3636107 | pbx-qa.runtel.org | root@runtel.ru | https://pbx-qa.runtel.org/dashboard
9cd5bba2-e7e4-44ae-96d6-8cad5043d0b2 | 9dab5138-df72-4630-a92c-fbbbc3636107 | redis             | redis          |
a2ef6961-98b2-4313-930d-0698d897f8f9 | 9dab5138-df72-4630-a92c-fbbbc3636107 | root              | root           | 192.168.87.5


# проверить пароль/секрет db_password (b1e6a217-6381-438a-be04-e3d50afd9c02)
passbolt get resource --id b1e6a217-6381-438a-be04-e3d50afd9c02
Enter Password:
FolderParentID: 9dab5138-df72-4630-a92c-fbbbc3636107
Name: db_password
Username: postgres
URI:
Password: <LONG_PASS>
Description:


# Посмотреть всю информацию о ресурсе
passbolt get resource --id b1e6a217-6381-438a-be04-e3d50afd9c02 -j | jq '.'
Enter Password:{
  "folder_parent_id": "9dab5138-df72-4630-a92c-fbbbc3636107",
  "name": "db_password",
  "username": "postgres",
  "uri": "",
  "password": "<LONG_PASS>",
  "description": "",
  "metadata": {
    "description": "",
    "name": "db_password",
    "uri": "",
    "username": "postgres"
  },
  "secret": {
    "description": "",
    "password": "<LONG_PASS>"
  },
  "deleted": false,
  "expired": false
}

#  посмотреть permissions
passbolt get resource permission --id b1e6a217-6381-438a-be04-e3d50afd9c02 -j | jq '.'
Enter Password:[
  {
    "id": "174ecd8e-06ae-46af-ac7d-7b5b8cfcb7e5",
    "aco": "Resource",
    "aco_foreign_key": "b1e6a217-6381-438a-be04-e3d50afd9c02",
    "aro": "User",
    "aro_foreign_key": "955ab5fe-7638-46d3-8027-aea3bb13d993",
    "type": 15,
    "created_timestamp": "2026-05-15T10:45:42Z",
    "modified_timestamp": "2026-05-15T10:45:42Z"
  },
  {
    "id": "18f66161-d3d1-43cf-943d-c96d368caab9",
    "aco": "Resource",
    "aco_foreign_key": "b1e6a217-6381-438a-be04-e3d50afd9c02",
    "aro": "User",
    "aro_foreign_key": "86ec94e9-1772-47e5-89b6-4b68337ef126",
    "type": 15,
    "created_timestamp": "2026-05-15T10:45:42Z",
    "modified_timestamp": "2026-05-15T10:45:42Z"
  },
  {
    "id": "270339fe-0e4c-48d5-a595-04d51969ddda",
    "aco": "Resource",
    "aco_foreign_key": "b1e6a217-6381-438a-be04-e3d50afd9c02",
    "aro": "User",
    "aro_foreign_key": "06e5548f-950f-4dca-b060-9e6cc6f22240",
    "type": 15,
    "created_timestamp": "2026-05-15T10:45:42Z",
    "modified_timestamp": "2026-05-15T10:45:42Z"
  },
  {
    "id": "ade6ba7e-5562-45d8-b70a-7b49a08be33a",
    "aco": "Resource",
    "aco_foreign_key": "b1e6a217-6381-438a-be04-e3d50afd9c02",
    "aro": "User",
    "aro_foreign_key": "fa60566f-fcc4-4d2e-9f7f-97a32d784867",
    "type": 15,
    "created_timestamp": "2026-05-15T10:45:42Z",
    "modified_timestamp": "2026-05-15T10:45:42Z"
  }
]
```

</details>
<br/>


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

