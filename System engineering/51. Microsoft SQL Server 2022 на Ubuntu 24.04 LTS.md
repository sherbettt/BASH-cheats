# Инструкция по установке Microsoft SQL Server 2022 на Ubuntu 24.04 LTS

## Цель
Установить полнофункциональный, бесплатный экземпляр SQL Server для разработки и тестирования на сервере с Ubuntu 24.04.

### Почему выбран именно этот вариант?
1.  **SQL Server 2022 вместо 2025**: На момент установки (16 Июня 2026) пакет SQL Server 2025 (`17.x`) содержал критическую ошибку, из-за которой установка на Ubuntu 24.04 прерывалась фатальным сбоем. Версия 2022 (`16.x`) стабильна и полностью работоспособна.
2.  **Редакция Developer (выпуск 2)**: Это бесплатная редакция, которая включает **все функции платной Enterprise-версии**. Она идеально подходит для разработки, тестирования и обучения. Единственное ограничение — её нельзя использовать в боевых (продакшен) средах.
3.  **Ubuntu 24.04 LTS**: Это современная долгосрочная версия, но официально SQL Server 2022 поддерживается на Ubuntu 22.04. Поэтому пришлось использовать "ручной" обходной путь для установки недостающих библиотек.

---

## 🔧 Пошаговая инструкция

### Часть 1: Подготовка системы

#### 1.1 Удаление проблемного пакета SQL Server 2025 (если был установлен)
```bash
# Останавливаем службу, если она запущена
sudo systemctl stop mssql-server

# Полностью удаляем пакеты SQL Server 2025 и зависимые компоненты
sudo apt remove --purge -y mssql-server mssql-server-fts mssql-server-ha
sudo apt autoremove -y

# Удаляем конфигурационные файлы и репозиторий старой версии
sudo rm -rf /var/opt/mssql/
sudo rm -rf /etc/apt/sources.list.d/mssql-server-2025.list
```
*   **Комментарий**: `remove --purge` удаляет пакет и все его конфигурационные файлы. `autoremove` очищает ненужные зависимости. Ручное удаление папок гарантирует, что старые настройки не повлияют на новую установку.

### Часть 2: Установка стабильной версии SQL Server 2022

#### 2.1 Добавление репозитория Microsoft для SQL Server 2022
```bash
# Импортируем публичный GPG-ключ Microsoft для проверки подлинности пакетов
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

# Добавляем репозиторий SQL Server 2022 с указанием пути к ключу
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022 jammy main" | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list
```
*   **Комментарий**: Мы используем репозиторий для **Ubuntu 22.04 (jammy)**, так как для 24.04 (noble) официального репозитория SQL Server 2022 нет. Однако пакеты совместимы. Ключ `signed-by` гарантирует, что `apt` будет доверять этому репозиторию.

#### 2.2 Установка пакетов
```bash
# Обновляем список доступных пакетов
sudo apt update

# Устанавливаем ядро SQL Server и компонент полнотекстового поиска
sudo apt install -y mssql-server mssql-server-fts
```
*   **Комментарий**: Пакет `mssql-server-ha` (High Availability) не был установлен из-за проблем с зависимостями. Для целей разработки он не обязателен.

### Часть 3: Настройка и устранение ошибок

#### 3.1 Первая настройка и фатальная ошибка
```bash
# Запускаем мастер настройки
sudo /opt/mssql/bin/mssql-conf setup
```
На этом шаге мы столкнулись с ошибкой:
```
/opt/mssql/bin/sqlservr: error while loading shared libraries: liblber-2.5.so.0: cannot open shared object file: No such file or directory
```
*   **Причина**: SQL Server 2022 собран со старой версией библиотеки LDAP (`liblber-2.5`), а в Ubuntu 24.04 используется более новая (`liblber-2.6`).
*   **Решение**: Ручная установка недостающей библиотеки из репозитория Ubuntu 22.04.

#### 3.2 Установка библиотеки liblber-2.5
```bash
# Скачиваем пакет с библиотекой из репозитория Ubuntu 22.04
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openldap/libldap-2.5-0_2.5.20+dfsg-0ubuntu0.22.04.1_amd64.deb

# Устанавливаем скачанный пакет в обход менеджера зависимостей
sudo dpkg -i libldap-2.5-0_2.5.20+dfsg-0ubuntu0.22.04.1_amd64.deb

# Исправляем возможные проблемы с зависимостями
sudo apt install -f
```
*   **Комментарий**: `dpkg -i` устанавливает пакет напрямую. Версия `2.5.20` — последняя доступная. Команда `apt install -f` нужна, чтобы "дотянуть" все необходимые зависимости для пакета.

#### 3.3 Проверка библиотеки и перезапуск
```bash
# Проверяем, что библиотека теперь найдена
ldd /opt/mssql/bin/sqlservr | grep lber

# Перезапускаем службу, чтобы изменения вступили в силу
sudo systemctl restart mssql-server
```
*   **Комментарий**: `ldd` показывает, какие разделяемые библиотеки использует исполняемый файл. Если видите путь к `liblber-2.5.so.0`, значит, проблема решена.

#### 3.4 Установка пароля администратора
```bash
# Останавливаем службу для смены пароля
sudo systemctl stop mssql-server

# Запускаем мастер смены пароля для учётной записи 'sa'
sudo /opt/mssql/bin/mssql-conf set-sa-password

# Запускаем службу заново
sudo systemctl start mssql-server
```
*   **Комментарий**: Пароль должен быть сложным. Мы использовали `HardPass1729VeryW`. Службу обязательно нужно остановить перед сменой пароля, иначе мастер выдаст ошибку.

### Часть 4: Установка клиентских инструментов

```bash
# Импортируем ключ для репозитория инструментов
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

# Добавляем репозиторий инструментов (для Ubuntu 22.04)
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

# Обновляем список пакетов и устанавливаем sqlcmd и odbc-драйвер
sudo apt update
sudo ACCEPT_EULA=Y apt install -y mssql-tools18 unixodbc-dev
```
*   **Комментарий**: `sqlcmd` — основная утилита для работы с SQL Server из командной строки. `ACCEPT_EULA=Y` автоматически принимает лицензионное соглашение.

### Часть 5: Проверка и подключение

```bash
# Экспортируем пароль в переменную окружения, чтобы не вводить его каждый раз
export SQLCMDPASSWORD="HardPass1729VeryW"

# Подключаемся к локальному серверу
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C
```
После подключения вы увидите приглашение `1>`. Введите запрос:
```sql
1> SELECT @@VERSION
2> GO
```
```bash
root@mssql ~
12:37:57 # /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C
1> SELECT @@VERSION
2> GO
                                                                                                                                                                                                                                                                                                            
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Microsoft SQL Server 2022 (RTM-CU25) (KB5081477) - 16.0.4255.1 (X64) 
        Apr 23 2026 22:38:54 
        Copyright (C) 2022 Microsoft Corporation
        Developer Edition (64-bit) on Linux (Ubuntu 24.04.4 LTS) <X64>                                                                                                      

(1 rows affected)
1> QUIT
```
Для выхода из `sqlcmd` введите `QUIT`.

---

## Где что лежит после установки

-   **Исполняемые файлы сервера**: `/opt/mssql/bin/`
-   **Файлы данных и логов по умолчанию**: `/var/opt/mssql/`
-   **Конфигурационный файл сервера**: `/var/opt/mssql/mssql.conf`
-   **Лог ошибок**: `/var/opt/mssql/log/errorlog`
-   **Клиентские утилиты**: `/opt/mssql-tools18/bin/`

-------------------------
<br>



## 🗄️ Основные операции с базами данных в SQL Server

В этом разделе рассмотрим базовые команды для работы с базами данных, таблицами и данными через утилиту `sqlcmd`.

### 🔌 Подключение к серверу

Перед выполнением команд подключитесь к серверу:

```bash
export SQLCMDPASSWORD="HardPass1729VeryW"
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C
```

После подключения вы увидите приглашение `1>`. Все последующие команды вводятся в этом режиме, а `GO` выполняет их.

---

### 1️⃣ Создание базы данных

#### Команда:
```sql
CREATE DATABASE MyProject;
GO
```

#### Полный пример сессии:
```bash
1> CREATE DATABASE MyProject;
2> GO
```

После выполнения вы увидите сообщение:
```
Commands completed successfully.
```

#### Проверка, что база создана:
```sql
SELECT name FROM sys.databases;
GO
```

---

### 2️⃣ Выбор (переключение на) базу данных

Перед созданием таблиц нужно переключиться на нужную базу:

```sql
USE MyProject;
GO
```

При успешном переключении вы увидите:
```
Changed database context to 'MyProject'.
```

---

### 3️⃣ Создание таблицы

#### Пример создания таблицы "Пользователи":
```sql
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO
```

#### Расшифровка:
- `INT` — целочисленный тип
- `NVARCHAR(50)` — строковый тип с поддержкой Unicode
- `PRIMARY KEY` — первичный ключ (уникальный идентификатор записи)
- `IDENTITY(1,1)` — автоматическое увеличение значения (начало с 1, шаг 1)
- `NOT NULL` — поле обязательно для заполнения
- `UNIQUE` — значение должно быть уникальным
- `DEFAULT GETDATE()` — если не указано, подставляется текущая дата и время

#### Другой пример (таблица "Заказы"):
```sql
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL
);
GO
```

---

### Просмотр структуры базы данных

#### ✅ Список всех баз данных:
```sql
SELECT name, database_id, create_date 
FROM sys.databases
ORDER BY name;
GO
```

#### ✅ Список всех таблиц в текущей базе:
```sql
SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
```

#### ✅ Структура конкретной таблицы (поля, типы данных):
```sql
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users'
ORDER BY ORDINAL_POSITION;
GO
```

---

### Работа с данными (CRUD)

#### 📥 Вставка данных (INSERT)
```sql
-- Добавление одного пользователя
INSERT INTO Users (FirstName, LastName, Email)
VALUES ('Иван', 'Петров', 'ivan@example.com');
GO

-- Добавление нескольких записей сразу
INSERT INTO Users (FirstName, LastName, Email)
VALUES 
    ('Мария', 'Иванова', 'maria@example.com'),
    ('Петр', 'Сидоров', 'petr@example.com');
GO
```

#### 📖 Чтение данных (SELECT)
```sql
-- Выбрать всех пользователей
SELECT * FROM Users;
GO

-- Выбрать только определённые поля
SELECT FirstName, LastName, Email FROM Users;
GO

-- Выбрать с условием (WHERE)
SELECT * FROM Users 
WHERE LastName = 'Петров';
GO

-- Сортировка
SELECT * FROM Users 
ORDER BY CreatedDate DESC;
GO

-- Ограничение количества записей (первые 10)
SELECT TOP 10 * FROM Users;
GO
```

#### ✏️ Обновление данных (UPDATE)
```sql
-- Изменить email пользователя с Id=1
UPDATE Users 
SET Email = 'ivan.new@example.com' 
WHERE Id = 1;
GO
```

#### ❌ Удаление данных (DELETE)
```sql
-- Удалить пользователя с Id=3
DELETE FROM Users 
WHERE Id = 3;
GO

-- Удалить всех пользователей с фамилией 'Иванова'
DELETE FROM Users 
WHERE LastName = 'Иванова';
GO
```

---

### Удаление базы данных

#### Команда для удаления базы:
```sql
DROP DATABASE MyProject;
GO
```

⚠️ **Внимание!** Эта команда **безвозвратно** удаляет базу данных и все её таблицы с данными. Восстановить их будет невозможно без бэкапа.

#### Проверка удаления:
```sql
SELECT name FROM sys.databases;
GO
```

---

### 📋 Команды для работы с существующими данными

| Команда | Описание |
|---------|----------|
| `SELECT * FROM TableName;` | Вывести все данные из таблицы |
| `SELECT COUNT(*) FROM TableName;` | Узнать количество записей |
| `SELECT DISTINCT ColumnName FROM TableName;` | Уникальные значения столбца |
| `TRUNCATE TABLE TableName;` | Очистить таблицу (удалить все данные, но сохранить структуру) |

---

### 🔑 Важные замечания

1. **Все команды в `sqlcmd` выполняются после ввода `GO`** — не забывайте эту команду!
2. **Регистр не важен** — `SELECT` и `select` работают одинаково.
3. **Точка с запятой (`;`)** не обязательна, но рекомендуется для читаемости.
4. **Чтобы выйти из `sqlcmd`**, введите `QUIT` или `EXIT` (без `GO`).
5. **Для многострочных запросов** просто нажимайте Enter на новых строках, пока не введёте `GO`.

### 🔄 Быстрый полный пример сессии

```bash
# Подключение
export SQLCMDPASSWORD="HardPass1729VeryW"
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C

# Создание базы
1> CREATE DATABASE TestDB;
2> GO

# Переключение на неё
1> USE TestDB;
2> GO

# Создание таблицы
1> CREATE TABLE Employees (Id INT PRIMARY KEY IDENTITY(1,1), Name NVARCHAR(50), Position NVARCHAR(50));
2> GO

# Добавление данных
1> INSERT INTO Employees (Name, Position) VALUES ('Анна', 'Менеджер'), ('Сергей', 'Разработчик');
2> GO

# Просмотр данных
1> SELECT * FROM Employees;
2> GO

# Удаление базы
1> DROP DATABASE TestDB;
2> GO

# Выход
1> QUIT
```

---


