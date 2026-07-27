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
Password: <Long_Pass>
Description:


# создать запись в подпапке Кирилл Кораблин
passbolt create resource --help
passbolt list resources --filter 'folder_parent_id == "a4e86d9a-d123-4042-9f98-fa722f20179c"'
Enter Password:
id                                   | folder_parent_id                     | name                 | username       | uri
114ba102-940e-491b-8ff1-69a9e3293ea3 | a4e86d9a-d123-4042-9f98-fa722f20179c | kats.dogma.ru        | root@runtel.ru | https://kats.dogma.ru/
6f8897e8-42c9-4154-9ca8-09d5eb377f49 | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-bichev.cprt.su    | root@runtel.ru | https://lk-bichev.cprt.su/users
913f8247-224c-4d17-a155-9705ef91c50e | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-fianit.cprt.su    | root@runtel.ru | https://lk-fianit.cprt.su/
3ff8c07a-32ec-4b30-8ba0-b7c86a4e612d | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-novoselie.cprt.su | k@runtel.ru    | lk-novoselie.cprt.su
c3bc1922-0dc3-4d3a-b9b2-65063742b9db | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-repremium.cprt.su | k@runtel.ru    | https://lk-repremium.cprt.su/pbx-hosts
108414ff-49db-43e1-b8a0-784479f9bbb8 | a4e86d9a-d123-4042-9f98-fa722f20179c | lk-sirius.cprt.su    | k@runtel.ru    | https://lk-sirius.cprt.su/users
a2398c8e-c665-44bb-bfd9-7445b86c0492 | a4e86d9a-d123-4042-9f98-fa722f20179c | pbx.runtel.org       | k@runtel.ru    | https://pbx-test.runtel.org/
490c9d52-b029-4e3e-b57b-2c1f7fb2021c | a4e86d9a-d123-4042-9f98-fa722f20179c | Sonar Qube           | k@runtel.ru    | https://sq.runtel.ru
519de763-7238-4667-9e36-b1c44a35d28e | a4e86d9a-d123-4042-9f98-fa722f20179c | TEST_name_field      | k@runtel       | 83.139.182.254
96c21d2f-68d4-467f-a9d8-9627b89ca44f | a4e86d9a-d123-4042-9f98-fa722f20179c | биллинг              | k@runtel.ru    | https://bl4.runtel.org


# Посмотреть всю информацию о ресурсе
passbolt get resource --id b1e6a217-6381-438a-be04-e3d50afd9c02 -j | jq '.'
Enter Password:{
  "folder_parent_id": "9dab5138-df72-4630-a92c-fbbbc3636107",
  "name": "db_password",
  "username": "postgres",
  "uri": "",
  "password": "<Long_Pass>",
  "description": "",
  "metadata": {
    "description": "",
    "name": "db_password",
    "uri": "",
    "username": "postgres"
  },
  "secret": {
    "description": "",
    "password": "<Long_Pass>"
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


# проверить корневую папку ssh_users, в которой нет подпапок целенаправленно
passbolt list resources --filter 'folder_parent_id == "9d589e93-b8bf-4950-9185-c3485e09bc33"'
Enter Password:
id                                   | folder_parent_id                     | name              | username | uri
6af23369-4ac5-4c90-81b2-2f5f04595db9 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | kats              | odmen    | 10.100.210.2
b9d9592b-0b0c-4ce4-a057-71f58d880a86 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | kats              | root     | 10.100.210.2
da619ed7-5213-4177-8e34-e1cb8308aa7a | 9d589e93-b8bf-4950-9185-c3485e09bc33 | kats              | tcpdump  | 10.100.210.2
1c553a82-c7bc-4e5e-a81b-81841e5f6a11 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-a7ru           | odmen    | 10.146.148.2
4e7920d6-26cc-4579-b506-de808e76bd6d | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-a7ru           | root     | 10.146.148.2
b4c929ba-4063-4ba9-a7b1-073f4f910710 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-a7ru           | tcpdump  | 10.146.148.2
757ea72d-2ca9-4082-9abd-6a9b79d575b1 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-cher           | odmen    | 109.172.108.67
a3114a3b-6261-4f63-964d-c76fc37fcdd1 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-cher           | root     | 109.172.108.67
d0f26f27-212c-4e3c-9ff1-d9adb358f02d | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-cher           | tcpdump  | 109.172.108.67
77cbb2f7-f630-497a-b9ae-031ff4ead1c0 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-chmk           | root     | 192.168.0.2
db009d5b-bdbf-4a65-b8b4-7a2372f2642a | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-chmk           | tcpdump  | 192.168.0.2
fcd34384-6a91-41e2-8cbc-72373e640004 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-chmk           | odmen    | 192.168.0.2
17175108-2752-43d1-a1ed-48f9e2ef6cf7 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-fianit         | tcpdump  | 10.205.211.2
5d024292-65dc-424c-bebc-251302d5b48a | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-fianit         | odmen    | 10.205.211.2
675c1c9d-0627-4bc1-b831-ca5358e2cb5b | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-fianit         | root     | 10.205.211.2
4654f69a-e30a-4055-ba46-143ff3952765 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-gelioss        | odmen    | 10.144.145.3
df8bd37c-a6e4-47b0-b3f8-eff6a9b4ed89 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-gelioss        | tcpdump  | 10.144.145.3
e482b848-45d0-4d9c-8448-2c0d057b16b9 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-gelioss        | root     | 10.144.145.3
861075f3-0f3e-4876-b6b2-f8d061cc3035 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-itsoglasie     | odmen    | 10.146.41.2
a39a8db2-d805-4ff0-9c00-98f54d197fbb | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-itsoglasie     | tcpdump  | 10.146.41.2
b9d8c946-be8a-48bd-9be6-0343b885f821 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-itsoglasie     | root     | 10.146.41.2
3073b100-3ba5-4e09-b1e1-c88026bff96c | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-itsoglasie_2   | tcpdump  | 10.146.41.2
d6c01912-029c-485e-aa56-6a583479eb12 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-itsoglasie_2   | root     | 10.146.41.2
efd770a6-8411-4e8e-b458-54ceac924ef8 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-itsoglasie_2   | odmen    | 10.146.41.2
ac624d20-d971-4614-bdb3-2e89e6edf8d5 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-kkod           | root     | 10.146.42.2
b53fdf84-4405-4c5f-a0c9-337765082728 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-kkod           | tcpdump  | 10.146.42.2
d393f61f-b974-44e9-87b2-fed643407a17 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-kkod           | odmen    | 10.146.42.2
2846390b-c126-4093-b842-122fbf865b08 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-mo             | odmen    | 10.108.101.2
6bc7ebf3-92e9-4f42-92fd-544915d35297 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-mo             | tcpdump  | 10.108.101.2
d59069d1-f1b8-4483-a5d4-f2926587bc50 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-mo             | root     | 10.108.101.2
8817f85d-9786-4b55-98ad-e772176c3a0c | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-novoselie      | root     | 10.101.101.2
e269be02-94c7-4b47-a069-b479e12f8b1f | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-novoselie      | tcpdump  | 10.101.101.2
fc8c2bdc-0025-43ce-b109-dcec07220fbf | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-novoselie      | odmen    | 10.101.101.2
259fd610-eb0b-47ae-853a-3b4f311c943d | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-repremium      | root     | 10.197.168.2
8465597a-97fb-49f7-81b6-06818de3ddf5 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-repremium      | odmen    | 10.197.168.2
9a0e1b13-d14a-4bc4-8358-c0f0b73f24cf | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-repremium      | tcpdump  | 10.197.168.2
bad71d7c-b1d5-42b6-aea9-c25b84a2acf6 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-russilica      | tcpdump  | 10.178.178.2
c2516889-ab61-42fc-bdb4-925d8c3544af | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-russilica      | root     | 10.178.178.2
e8d89d12-2146-41d2-82b3-91531a5deec8 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-russilica      | odmen    | 10.178.178.2
44bc6a06-4975-4708-8e5a-88bac7b1397d | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-sirius         | root     | 192.168.100.7
4783ffe2-709a-4d55-a086-f994ccb34b86 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-sirius         | tcpdump  | 192.168.100.7
713b3445-c154-44ff-b216-0c3b39664c17 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-sirius         | odmen    | 192.168.100.7
02d3f130-3c86-44fc-8aa0-08d3a6c13ef9 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-spbpobeda      | root     | 10.146.148.2
97c341d5-df5e-41f8-a8fb-a5cca69ab27f | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-spbpobeda      | tcpdump  | 10.146.148.2
b8c14c8f-5993-4018-92d3-1c94ab1e932e | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-spbpobeda      | odmen    | 10.146.148.2
3f77bf95-a84d-4578-bfdc-fc1987d5016f | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-stepanov       | odmen    | 10.145.145.2
46353522-e8fc-48d0-ae01-3914fb12d8ed | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-stepanov       | tcpdump  | 10.145.145.2
ecf1cc08-3c39-4302-97bf-382b64b088ed | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-stepanov       | root     | 10.145.145.2
44a7ab57-4cf1-4522-960d-0b74234525c2 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-umnaylogistika | root     | 10.144.144.3
5edc073f-7a2a-4c9f-bf2c-1c6a9cb7749a | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-umnaylogistika | tcpdump  | 10.144.144.3
6bf25889-f79c-4a0e-bd00-b418a15a30a3 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-umnaylogistika | odmen    | 10.144.144.3
23505513-fc49-4c2e-bcb0-a1c41981c6f5 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-uprdor         | odmen    | 10.146.150.2
88a378b0-e430-4e13-a909-433114dec8b8 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-uprdor         | root     | 10.146.150.2
c6d3bfd8-8001-4899-9c05-c0d8fd69d2ed | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-uprdor         | tcpdump  | 10.146.150.2
485ac86d-a8da-4825-b71b-5a3ba9a9c6d0 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-zaim           | tcpdump  | 10.205.215.2
72d8cc51-c47a-493d-bf2d-8bf3efbdf4be | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-zaim           | odmen    | 10.205.215.2
9ac5fc49-6c94-4850-a39c-a1fb155452b7 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-zaim           | root     | 10.205.215.2

# проверка ресурса по uri (lk-umnaylogistika)
passbolt list resources --filter 'uri == "10.144.144.3"'
Enter Password:
id                                   | folder_parent_id                     | name              | username | uri
44a7ab57-4cf1-4522-960d-0b74234525c2 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-umnaylogistika | root     | 10.144.144.3
5edc073f-7a2a-4c9f-bf2c-1c6a9cb7749a | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-umnaylogistika | tcpdump  | 10.144.144.3
6bf25889-f79c-4a0e-bd00-b418a15a30a3 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-umnaylogistika | odmen    | 10.144.144.3


# проверка ресурса по имени
passbolt list resources --filter 'name == "lk-a7ru"'
Enter Password:
id                                   | folder_parent_id                     | name    | username | uri
1c553a82-c7bc-4e5e-a81b-81841e5f6a11 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-a7ru | odmen    | 10.146.148.2
4e7920d6-26cc-4579-b506-de808e76bd6d | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-a7ru | root     | 10.146.148.2
b4c929ba-4063-4ba9-a7b1-073f4f910710 | 9d589e93-b8bf-4950-9185-c3485e09bc33 | lk-a7ru | tcpdump  | 10.146.148.2


# проверить пароль root от kats
passbolt get resource --id b9d9592b-0b0c-4ce4-a057-71f58d880a86 -j | jq '.'
# проверить пароль root от lk-a7ru
passbolt get resource --id 4e7920d6-26cc-4579-b506-de808e76bd6d -j | jq '.'
## ====================================


"Сходить"  в папку ssh_users, посомтреть пароль для root для какого-нибудь ресурса (предположим нового, относительно свежедобавленного), этот пароль  root сохранить в runtime , а ещё в в файлик.
Сгенерировать новые пароли для пользователей из папки поддержки.
Создать записи для выше указанного нового, относительно свежедобавленного ресурса и добавить эти записи в:
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
т.е. внутрь каждой указанной папки.


ROOT_PASS=$(passbolt get resource --id 9ac5fc49-6c94-4850-a39c-a1fb155452b7 -j | jq -r '.password')
NEW_PASS=$(apg -m 14 -x 16 -n 1)
#сгенерировать пароль: apg -m 14 -x 16 -n 5
#mkpasswd --method=SHA-512 , после чего ввести свой пароль и подставить в поле выше


# для версии 0.5.0
passbolt create resource \
  --name="TEST_name_field" \
  --uri="83.139.182.254" \
  --username="k@runtel" \
  --password="TESTpass12345" \
  --description="тестовое создание записи для k@runtel.ru" \
  --folderParentID="a4e86d9a-d123-4042-9f98-fa722f20179c"

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

