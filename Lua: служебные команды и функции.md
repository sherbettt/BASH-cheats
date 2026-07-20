## Где читать про служебные команды и функции Lua

### 1. **Официальная документация Lua**
- **Основная документация**: https://www.lua.org/manual/5.4/
- **Стандартные библиотеки**: https://www.lua.org/manual/5.4/manual.html#6
  - `io` - операции ввода/вывода
  - `os` - системные операции
  - `string` - работа со строками
  - `table` - работа с таблицами
  - `math` - математические функции

### 2. **Книги**
- **"Programming in Lua"** (PIL) - официальная книга от создателя Lua
  - Бесплатная онлайн версия для Lua 5.0: https://www.lua.org/pil/
  - Для последних версий - печатное издание

### 3. **Русскоязычные ресурсы**
- http://www.lua.ru/ - русскоязычный портал
- Документация на русском: http://www.lua.ru/doc/

---

## ПОЛНЫЙ СПИСОК ВСТРОЕННЫХ БИБЛИОТЕК И ФУНКЦИЙ LUA

### **Глобальные функции (доступны везде)**

```lua
-- Базовые функции
assert(v [, message])    -- Проверяет условие, вызывает ошибку если false/nil
collectgarbage([opt [, arg]]) -- Управляет сборщиком мусора
dofile([filename])       -- Выполняет Lua-код из файла
error(message [, level]) -- Генерирует ошибку
getmetatable(object)     -- Возвращает метатаблицу объекта
ipairs(t)                -- Итератор для таблицы-массива
load(chunk [, chunkname [, mode [, env]]]) -- Загружает код из строки
loadfile([filename [, mode [, env]]])      -- Загружает код из файла
next(table [, index])    -- Следующий элемент таблицы
pairs(t)                 -- Итератор для таблицы
pcall(f [, arg1, ...])   -- Безопасный вызов функции
print(...)               -- Вывод в консоль
rawequal(v1, v2)         -- Сравнение без метаметодов
rawget(table, index)     -- Получение без метаметодов
rawlen(v)                -- Длина без метаметодов
rawset(table, index, value) -- Установка без метаметодов
select(index, ...)       -- Выбор аргументов
setmetatable(table, metatable) -- Установка метатаблицы
tonumber(e [, base])     -- Преобразование в число
tostring(v)              -- Преобразование в строку
type(v)                  -- Тип переменной
warn(msg1, ...)          -- Вывод предупреждения
xpcall(f, msgh [, arg1, ...]) -- Безопасный вызов с обработчиком
_G                       -- Глобальное окружение
_VERSION                 -- Версия Lua
```

### **Библиотека `io` (ввод-вывод)**

```lua
-- Основные функции
io.close([file])         -- Закрывает файл
io.flush()               -- Сбрасывает буфер вывода
io.input([file])         -- Устанавливает/возвращает stdin
io.lines([filename, ...]) -- Итератор по строкам
io.open(filename [, mode]) -- Открывает файл
io.output([file])        -- Устанавливает/возвращает stdout
io.popen(prog [, mode])  -- Открывает pipe для команды
io.read(...)             -- Читает из stdin
io.stderr                -- Стандартный поток ошибок
io.stdin                 -- Стандартный ввод
io.stdout                -- Стандартный вывод
io.tmpfile()             -- Создает временный файл
io.type(obj)             -- Тип файлового объекта
io.write(...)            -- Пишет в stdout

-- Методы файлового дескриптора (f:)
f:close()                -- Закрывает файл
f:flush()                -- Сбрасывает буфер
f:lines(...)             -- Итератор по строкам
f:read(...)              -- Читает из файла
f:seek([whence [, offset]]) -- Перемещает позицию
f:setvbuf(mode [, size]) -- Устанавливает буферизацию
f:write(...)             -- Пишет в файл
```

**Режимы чтения в `io.read()` и `f:read()`:**
- `"*all"` или `"a"` - читать весь файл
- `"*line"` или `"l"` - читать строку
- `"*number"` или `"n"` - читать число
- `число` - читать N символов

### **Библиотека `os` (операционная система)**

```lua
os.clock()               -- Время выполнения CPU
os.date([format [, time]]) -- Форматированная дата/время
os.difftime(t2, t1)      -- Разница во времени
os.execute([command])    -- Выполняет системную команду
os.exit([code [, close]]) -- Завершает программу
os.getenv(varname)       -- Переменная окружения
os.remove(filename)      -- Удаляет файл
os.rename(oldname, newname) -- Переименовывает файл
os.setlocale(locale [, category]) -- Устанавливает локаль
os.time([table])         -- Время в секундах
os.tmpname()             -- Временное имя файла
```

### **Библиотека `string` (строки)**

```lua
string.byte(s [, i [, j]]) -- Код символа
string.char(...)         -- Символ по коду
string.dump(function [, strip]) -- Дамп функции
string.find(s, pattern [, init [, plain]]) -- Поиск подстроки
string.format(formatstring, ...) -- Форматирование
string.gmatch(s, pattern) -- Итератор по совпадениям
string.gsub(s, pattern, repl [, n]) -- Глобальная замена
string.len(s)            -- Длина строки
string.lower(s)          -- В нижний регистр
string.match(s, pattern [, init]) -- Поиск шаблона
string.pack(fmt, v1, v2, ...) -- Упаковка в бинарный формат
string.packsize(fmt)     -- Размер упаковки
string.rep(s, n [, sep]) -- Повторение
string.reverse(s)        -- Переворот
string.sub(s, i [, j])   -- Подстрока
string.unpack(fmt, s [, pos]) -- Распаковка бинарных данных
string.upper(s)          -- В верхний регистр
```

### **Библиотека `table` (таблицы)**

```lua
table.concat(list [, sep [, i [, j]]]) -- Объединение элементов
table.insert(list, [pos,] value) -- Вставка элемента
table.move(a1, f, e, t [, a2]) -- Перемещение элементов
table.pack(...)          -- Упаковка аргументов в таблицу
table.remove(list [, pos]) -- Удаление элемента
table.sort(list [, comp]) -- Сортировка
table.unpack(list [, i [, j]]) -- Распаковка таблицы
```

### **Библиотека `math` (математика)**

```lua
math.abs(x)              -- Модуль числа
math.acos(x)             -- Арккосинус
math.asin(x)             -- Арксинус
math.atan(y [, x])       -- Арктангенс
math.ceil(x)             -- Округление вверх
math.cos(x)              -- Косинус
math.deg(x)              -- Радианы → градусы
math.exp(x)              -- Экспонента
math.floor(x)            -- Округление вниз
math.fmod(x, y)          -- Остаток от деления
math.huge                -- Огромное число
math.log(x [, base])     -- Логарифм
math.max(x, ...)         -- Максимум
math.min(x, ...)         -- Минимум
math.modf(x)             -- Целая и дробная часть
math.pi                  -- Число π
math.pow(x, y)           -- Возведение в степень
math.rad(x)              -- Градусы → радианы
math.random([m [, n]])   -- Случайное число
math.randomseed(x)       -- Установка seed
math.sin(x)              -- Синус
math.sqrt(x)             -- Квадратный корень
math.tan(x)              -- Тангенс
math.tointeger(x)        -- Преобразование в целое
math.type(x)             -- Тип числа
math.ult(m, n)           -- Беззнаковое сравнение
```

### **Библиотека `coroutine` (сопрограммы)**

```lua
coroutine.create(f)      -- Создает корутину
coroutine.isyieldable([co]) -- Можно ли передать управление
coroutine.resume(co [, val1, ...]) -- Возобновляет корутину
coroutine.running()      -- Текущая корутина
coroutine.status(co)     -- Статус корутины
coroutine.wrap(f)        -- Оборачивает корутину
coroutine.yield(...)     -- Передает управление
```

### **Библиотека `package` (управление модулями)**

```lua
package.config           -- Строка конфигурации
package.cpath            -- Путь к C-модулям
package.loaded           -- Загруженные модули
package.loadlib(libname, funcname) -- Загружает C-библиотеку
package.path             -- Путь к Lua-модулям
package.preload          -- Предзагруженные модули
package.seeall(module)   -- Создает таблицу для модуля
package.searchpath(name, path [, sep [, rep]]) -- Поиск модуля
```

### **Библиотека `debug` (отладка)**

```lua
debug.debug()            -- Вход в интерактивный отладчик
debug.gethook([thread])  -- Получает текущий хук
debug.getinfo([thread,] f [, what]) -- Информация о функции
debug.getlocal([thread,] f, local) -- Локальная переменная
debug.getmetatable(value) -- Метатаблица
debug.getregistry()      -- Таблица реестра
debug.getupvalue(f, up)  -- Upvalue функция
debug.sethook([thread,] hook, mask [, count]) -- Устанавливает хук
debug.setlocal([thread,] f, local, value) -- Устанавливает локальную
debug.setmetatable(value, table) -- Устанавливает метатаблицу
debug.setupvalue(f, up, value) -- Устанавливает upvalue
debug.traceback([thread,] [message [, level]]) -- Стек вызовов
debug.upvalueid(f, n)    -- ID upvalue
debug.upvaluejoin(f1, n1, f2, n2) -- Объединение upvalue
```

### **Библиотека `utf8` (UTF-8 строки, Lua 5.3+)**

```lua
utf8.char(...)           -- Символы по коду
utf8.codes(s)            -- Итератор по кодам символов
utf8.codepoint(s [, i [, j]]) -- Код символа
utf8.len(s [, i [, j]])  -- Длина строки
utf8.offset(s, n [, i])  -- Смещение символа
```

---

## Про `io.open` - почему она уже предустановлена?

**`io.open` - это часть стандартной библиотеки Lua**, которая автоматически загружается при запуске интерпретатора. Lua включает базовые библиотеки по умолчанию:

1. **Базовые функции** - всегда доступны
2. **Библиотека `io`** - всегда доступна
3. **Библиотека `os`** - всегда доступна
4. **Библиотека `string`** - всегда доступна
5. **Библиотека `table`** - всегда доступна
6. **Библиотека `math`** - всегда доступна
7. **Библиотека `debug`** - доступна (если не отключена)

### Почему она предустановлена?

```lua
-- Это работает без каких-либо require или импортов
local f = io.open("file.txt", "r")  -- сразу доступно
```

В отличие от некоторых других языков, где нужно писать `import` или `include`, в Lua все основные библиотеки загружены по умолчанию для удобства.

### Исключения:
- **Библиотека `coroutine`** - доступна, но редко используется напрямую
- **Библиотека `package`** - управление модулями
- Встроенные модули требуют `require`, например: `require("socket")`, `require("json")`

---

## РАБОТА В ИНТЕРАКТИВНОМ РЕЖИМЕ LUA

### **Запуск интерактивного режима**

```bash
# Простой запуск
lua -i

# Или просто
lua

# С загрузкой модуля
lua -l mymodule -i

# С выполнением кода перед входом в интерактивный режим
lua -e "print('Hello')" -i
```

### **Основные команды интерактивного режима**

В интерактивном режиме доступны специальные команды, начинающиеся с `=`:

| Команда | Описание | Пример |
|---------|----------|--------|
| `=выражение` | Вычисляет и выводит значение | `=2+2` → `4` |
| `=table` | Показывает содержимое таблицы | `={1,2,3}` |
| `=string` | Показывает строку | `="Hello"` |
| `do` | Начало многострочного блока | `do ... end` |

### **Полезные однострочники для интерактивного режима**

```bash
# 1. Показать все глобальные функции
lua -e "for k,v in pairs(_G) do if type(v)=='function' then print(k) end end"

# 2. Показать все глобальные переменные
lua -e "for k,v in pairs(_G) do print(k, type(v)) end"

# 3. Показать версию Lua
lua -e "print(_VERSION)"

# 4. Проверить синтаксис файла
lua -p script.lua

# 5. Выполнить скрипт с отладкой
lua -e "require('debug').debug()" script.lua

# 6. Показать стек вызовов
lua -e "print(debug.traceback())"

# 7. Показать все загруженные модули
lua -e "for k,v in pairs(package.loaded) do print(k) end"

# 8. Показать путь поиска модулей
lua -e "print(package.path)"

# 9. Выполнить код из строки
lua -e "for i=1,10 do print(i) end"

# 10. Интерактивный режим с автодополнением (требуется rlwrap)
rlwrap lua -i
```

### **Полезные команды внутри интерактивного режима**

```lua
-- Просмотр документации по функции (в некоторых реализациях)
help(print)

-- Просмотр всех глобальных переменных
for k,v in pairs(_G) do print(k, type(v)) end

-- Очистка экрана (зависит от ОС)
os.execute("clear")  -- Linux/Mac
os.execute("cls")    -- Windows

-- Выход из интерактивного режима
os.exit()
-- Или Ctrl+D (Linux/Mac) / Ctrl+Z (Windows)
```

### **Сохранение и загрузка сессии**

```lua
-- Сохранить текущую сессию в файл
local f = io.open("session.lua", "w")
for k,v in pairs(_G) do
    if type(v) ~= "function" and type(v) ~= "table" then
        f:write(string.format("%s = %s\n", k, tostring(v)))
    end
end
f:close()

-- Загрузить сессию
dofile("session.lua")
```

---

## Как проверить, какие функции доступны:

```lua
-- Список всех глобальных функций
for k,v in pairs(_G) do
    if type(v) == "function" then
        print(k)
    end
end

-- Проверка существования функции
if io.open then
    print("io.open exists!")
end

-- Подробная информация о функции
local info = debug.getinfo(print)
for k,v in pairs(info) do
    print(k, v)
end
```

---

## Полезные команды для изучения:

```bash
# Интерактивный режим Lua
lua -i

# Выполнить скрипт с отладкой
lua -e "print(debug.traceback())"

# Показать все глобальные переменные
lua -e "for k,v in pairs(_G) do print(k, type(v)) end"

# Запустить с профилированием
lua -e "require('debug').profile()" script.lua

# Проверить синтаксис без выполнения
lua -p script.lua

# Выполнить с дополнительным путём поиска модулей
lua -e "package.path = package.path .. ';./?.lua'" script.lua

# Запустить с ограничением памяти (если поддержка есть)
lua -e "collectgarbage('setpause', 200)" script.lua
```

---

## Быстрый справочник по флагам командной строки Lua

```bash
lua [options] [script [args]]

# Основные опции:
-e stat    # Выполнить строку кода
-l name    # Загрузить модуль
-i         # Войти в интерактивный режим после выполнения
-v         # Показать версию
-E         # Игнорировать переменные окружения
--         # Остановить обработку опций

# Примеры:
lua -e "print('Hello')"          # Выполнить код
lua -l io -i                     # Загрузить модуль и войти в REPL
lua -v                           # Показать версию
lua -E script.lua                # Игнорировать окружение
lua script.lua arg1 arg2         # Запустить скрипт с аргументами
```

---

## Сводная таблица всех библиотек Lua

| Библиотека | Количество функций | Назначение |
|------------|-------------------|------------|
| **Глобальные** | 24 | Базовые функции языка |
| **io** | 14 + методы | Ввод-вывод |
| **os** | 11 | Операционная система |
| **string** | 17 | Работа со строками |
| **table** | 7 | Работа с таблицами |
| **math** | 26 | Математические функции |
| **coroutine** | 7 | Сопрограммы |
| **package** | 8 | Управление модулями |
| **debug** | 14 | Отладка |
| **utf8** | 5 | UTF-8 строки |
| **ИТОГО** | **~133** | **Всего функций** |

---

## Полезные трюки для интерактивного режима

### **Создание своих команд в REPL**

```lua
-- Создать сокращения для часто используемых команд
function ls() os.execute("ls -la") end
function ll() os.execute("ls -alFS --group-directories-first --si --sort=version") end
function pwd() print(os.getenv("PWD")) end
function clear() os.execute("clear") end
function help() 
    print("Available commands: ls(), pwd(), clear(), help()")
    print("Try: =2+2, ={1,2,3}, ='hello'")
end

-- Теперь можно использовать:
ls()
pwd()
clear()
help()
```

### **Работа с историей команд**

```bash
# Установить rlwrap для истории и автодополнения
sudo apt-get install rlwrap  # Debian/Ubuntu
sudo yum install rlwrap      # CentOS/RHEL

# Запустить с rlwrap
rlwrap lua -i
```

### **Быстрая справка в REPL**

```lua
-- Функция для быстрой справки
function help(func)
    if type(func) == "string" then
        func = _G[func]
    end
    if type(func) == "function" then
        local info = debug.getinfo(func)
        print("Function: " .. (info.name or "anonymous"))
        print("Defined at: " .. info.short_src .. ":" .. info.linedefined)
        print("Number of upvalues: " .. info.nups)
    else
        print("Not a function")
    end
end

-- Использование:
help("print")
help(print)
```
-------------------------------------------------------
<br/>



## Разбор вашей сессии

### 1. **Запуск интерактивного режима**
```bash
lua -i
```
Вы вошли в интерактивный режим Lua (REPL - Read-Eval-Print Loop).

### 2. **Первая попытка**
```lua
> ls
nil
```
Вы попытались выполнить `ls` как Lua-команду, но `ls` - это команда оболочки, а не Lua. Поэтому получили `nil`.

### 3. **Создание функции**
```lua
> function ll() os.execute("ls -alFS --group-directories-first --si --sort=version") end
> ll
function: 0x5632734579f0
```
Вы создали функцию `ll()` и проверили, что она существует (Lua показала адрес функции в памяти).

### 4. **Выполнение функции**
```lua
> ll()
```
Выполнили функцию - она вызвала системную команду `ls` и показала содержимое домашней директории. ✅

### 5. **Выход**
```lua
> quit
nil
> exit
nil
```
`quit` и `exit` - не являются стандартными командами Lua. Для выхода нужно использовать:
- `os.exit()` 
- Или нажать `Ctrl+D` (Linux/Mac)
- Или `Ctrl+Z` (Windows)

---

## Как сделать это удобнее

### **Вариант 1: Автозагрузка функций при запуске Lua**

Создайте файл `~/.lua_profile`:

```lua
-- ~/.lua_profile
-- Автоматически загружается при запуске lua -i

-- Полезные функции для работы с системой
function ll() 
    os.execute("ls -alFS --group-directories-first --si --sort=version") 
end

function lsa() 
    os.execute("ls -la") 
end

function lsl() 
    os.execute("ls -l") 
end

function pwd() 
    print(os.getenv("PWD")) 
end

function cd(path) 
    os.execute("cd " .. path) 
    -- Внимание: cd не работает напрямую через os.execute!
end

function clear() 
    os.execute("clear") 
end

function grep(pattern, file)
    os.execute("grep " .. pattern .. " " .. file)
end

function ps()
    os.execute("ps aux")
end

function top()
    os.execute("top -b -n 1")
end

-- Информация о системе
function sysinfo()
    print("=== System Info ===")
    os.execute("uname -a")
    print("\n=== Uptime ===")
    os.execute("uptime")
    print("\n=== Memory ===")
    os.execute("free -h")
    print("\n=== Disk ===")
    os.execute("df -h")
end

-- Сокращение для выхода
function q()
    print("Bye!")
    os.exit()
end

-- Помощник
function help()
    print("Available commands:")
    print("  ll()    - list files with details")
    print("  lsa()   - list all files")
    print("  lsl()   - simple list")
    print("  pwd()   - show current directory")
    print("  clear() - clear screen")
    print("  ps()    - show processes")
    print("  top()   - show top processes")
    print("  sysinfo() - show system information")
    print("  q()     - quit Lua")
    print("  help()  - show this help")
end

print("Lua profile loaded! Type help() for available commands.")
```

Теперь запускайте Lua с профилем:

```bash
lua -i -e "dofile(os.getenv('HOME') .. '/.lua_profile')"
```

Или создайте алиас в `~/.bashrc`:
```bash
alias lua='lua -i -e "dofile(os.getenv(\"HOME\") .. \"/.lua_profile\")"'
```

### **Вариант 2: Создать отдельный скрипт с функциями**

Создайте файл `~/my-lua-tools.lua`:

```lua
#!/usr/bin/lua

-- Мой набор инструментов для работы в Lua

local M = {}

-- Системные команды
function M.ll()
    os.execute("ls -alFS --group-directories-first --si --sort=version")
end

function M.lsa()
    os.execute("ls -la")
end

function M.clear()
    os.execute("clear")
end

function M.pwd()
    print(os.getenv("PWD") or "Unknown")
end

function M.date()
    print(os.date("%Y-%m-%d %H:%M:%S"))
end

function M.uptime()
    os.execute("uptime")
end

function M.free()
    os.execute("free -h")
end

function M.df()
    os.execute("df -h")
end

-- Работа с файлами
function M.cat(filename)
    local f = io.open(filename, "r")
    if f then
        print(f:read("*all"))
        f:close()
    else
        print("File not found: " .. filename)
    end
end

function M.head(filename, n)
    n = n or 10
    local f = io.open(filename, "r")
    if f then
        local count = 0
        for line in f:lines() do
            print(line)
            count = count + 1
            if count >= n then break end
        end
        f:close()
    else
        print("File not found: " .. filename)
    end
end

function M.tail(filename, n)
    n = n or 10
    os.execute("tail -n " .. n .. " " .. filename)
end

-- Поиск
function M.grep(pattern, filename)
    os.execute("grep --color=auto " .. pattern .. " " .. filename)
end

function M.find(pattern)
    os.execute("find . -name '" .. pattern .. "'")
end

-- Информация
function M.sysinfo()
    print("=== System Information ===")
    os.execute("uname -a")
    print("\n=== Uptime ===")
    os.execute("uptime")
    print("\n=== Memory ===")
    os.execute("free -h")
    print("\n=== Disk Usage ===")
    os.execute("df -h")
    print("\n=== CPU Info ===")
    os.execute("lscpu | head -10")
end

function M.help()
    print("=== Available Functions ===")
    for k,v in pairs(M) do
        if type(v) == "function" then
            print("  " .. k .. "()")
        end
    end
end

-- Возвращаем таблицу
return M
```

Использование:

```bash
# Запустить с загрузкой модуля
lua -i -lmy-lua-tools

# Внутри Lua:
> my_lua_tools.ll()
> my_lua_tools.sysinfo()
> my_lua_tools.help()
```

Или с алиасом:
```bash
alias lua='lua -i -lmy-lua-tools'
```

### **Вариант 3: Функции прямо в интерактивной сессии**

Если нужно быстро добавить функции только для текущей сессии:

```lua
-- В интерактивном режиме выполните:

-- Создайте сразу несколько функций
for name, cmd in pairs({
    ll  = "ls -alFS --group-directories-first --si --sort=version",
    lsa = "ls -la",
    pwd = "pwd",
    clear = "clear",
    date = "date",
    who = "who",
    ps = "ps aux"
}) do
    _G[name] = function() os.execute(cmd) end
end

-- Теперь доступны:
ll()
lsa()
pwd()
clear()
date()
who()
ps()
```

### **Вариант 4: Создать bash-функцию для быстрого запуска**

Добавьте в `~/.bashrc`:
```bash
# Функция для запуска Lua с моими инструментами
lua-tools() {
    lua -i <<'EOF'
    function ll() os.execute("ls -alFS --group-directories-first --si --sort=version") end
    function lsa() os.execute("ls -la") end
    function clear() os.execute("clear") end
    function pwd() print(os.getenv("PWD")) end
    function sysinfo()
        os.execute("uname -a")
        os.execute("uptime")
        os.execute("free -h")
    end
    print("=== Lua Tools Loaded ===")
    print("Available: ll(), lsa(), clear(), pwd(), sysinfo()")
EOF
}

# Использование:
# $ lua-tools
```

---

## Как сохранить функции для постоянного использования

### **Метод 1: Использовать `~/.lua`**

Создайте файл `~/.lua`:
```lua
-- Автоматически загружается, если установлена переменная LUA_INIT
-- или при запуске lua -i

function ll()
    os.execute("ls -alFS --group-directories-first --si --sort=version")
end

function lsa()
    os.execute("ls -la")
end

function clear()
    os.execute("clear")
end

function q()
    os.exit()
end

print("Custom functions loaded: ll(), lsa(), clear(), q()")
```

В `~/.bashrc` добавьте:
```bash
export LUA_INIT="@$HOME/.lua"
```

Теперь `lua -i` автоматически загрузит ваши функции.

### **Метод 2: Создать алиас с автозагрузкой**

```bash
# В ~/.bashrc
alias mylua='lua -i -e "dofile(\"$HOME/.lua-tools.lua\")"'
```

### **Метод 3: Использовать `lua -l`**

Если вы создали модуль:

```lua
-- ~/lua/myutils.lua
local M = {}

function M.ll()
    os.execute("ls -alFS --group-directories-first --si --sort=version")
end

function M.lsa()
    os.execute("ls -la")
end

return M
```

Запускайте:
```bash
lua -lmyutils -i
# Теперь myutils.ll(), myutils.lsa()
```

---

## Как правильно выйти из интерактивного режима

```lua
-- Способ 1: Функция
os.exit()

-- Способ 2: Сокращение (если определили)
function q() os.exit() end
q()

-- Способ 3: Клавиши
-- Ctrl+D (Linux/Mac)
-- Ctrl+Z (Windows)

-- Способ 4: Если определили в профиле
q()
```

---

## Полезные сокращения для интерактивного режима

Создайте в `~/.lua`:
```lua
-- Быстрый выход
function q() os.exit() end

-- Быстрая очистка
function c() os.execute("clear") end

-- Быстрый листинг
function l() os.execute("ls -la") end

-- Быстрый переход (работает только для новых процессов)
function cd(path)
    os.execute("cd " .. path .. " && pwd")
end

-- Повтор последней команды
function r()
    if _G.last_cmd then
        _G.last_cmd()
    else
        print("No last command")
    end
end

-- Обертка для выполнения команд
function run(cmd)
    _G.last_cmd = function() os.execute(cmd) end
    _G.last_cmd()
end

-- Использование:
run("ls -la")  -- выполнит и запомнит
r()             -- повторит последнюю команду
```

