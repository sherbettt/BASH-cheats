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

### **Практический пример: работа в интерактивном режиме**

Рассмотрим реальную сессию работы в Lua:

```bash
# Запуск интерактивного режима
$ lua -i
Lua 5.4.4  Copyright (C) 1994-2022 Lua.org, PUC-Rio
> 
```

**Попытка вызвать команду оболочки напрямую:**
```lua
> ls
nil
```
Команда `ls` не является функцией Lua, поэтому интерпретатор вернул `nil`.

**Создание собственной функции для вызова системных команд:**
```lua
> function ll() os.execute("ls -alFS --group-directories-first --si --sort=version") end
> ll
function: 0x5632734579f0
```
Мы создали функцию `ll()`, которая вызывает системную команду `ls` с нужными опциями. Проверка показала, что функция существует (адрес в памяти).

**Выполнение созданной функции:**
```lua
> ll()
итого 41k
drwx------  7 root root 4,1k июл 20 15:38 ./
drwxr-xr-x 18 root root 4,1k июл 20 14:40 ../
drwx------  3 root root 4,1k июл 20 14:57 .ansible/
...
```
Функция успешно выполнилась и показала содержимое директории.

**Попытка выйти нестандартным способом:**
```lua
> quit
nil
> exit
nil
```
Команды `quit` и `exit` не являются стандартными функциями Lua. Для выхода нужно использовать `os.exit()` или нажать Ctrl+D.

### **Как сделать работу в интерактивном режиме удобнее**

#### **Создание постоянного профиля Lua**

Создайте файл `~/.lua_profile` со следующим содержимым:

<details>
<summary>❗ ~/.lua_profile ❗</summary>

```lua
-- ~/.lua_profile
-- Автоматически загружается при запуске lua -i

-- ============================================
-- ОСНОВНЫЕ СИСТЕМНЫЕ ФУНКЦИИ
-- ============================================

function ll()
    os.execute("ls -alFS --group-directories-first --si --sort=version")
end

function pwd()
    print(os.getenv("PWD"))
end

function clear()
    os.execute("clear")
end

function ps_cpu_short()
    os.execute("ps -eo cmd,pid,%cpu,%mem,user --sort=-%cpu | head -15")
end

function top_cpu()
    os.execute("top -b -n 1 -o %CPU")
end

function top_mem()
    os.execute("top -b -n 1 -o %MEM")
end

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

function q()
    print("Exit from REPL!")
    os.exit()
end

-- ============================================
-- ФУНКЦИЯ СПРАВКИ ПО КОМАНДАМ
-- ============================================

function help_cmd(cmd)
    -- БАЗА ЗНАНИЙ О ФУНКЦИЯХ
    local help_db = {
        -- ---- ВСТРОЕННЫЕ ФУНКЦИИ LUA ----
        ["print"] = {
            desc = "Выводит значения в консоль",
            syntax = "print(value1, value2, ...)",
            example = 'print("Hello", 42, true)  --> Hello 42 true',
            note = "Автоматически преобразует значения в строки"
        },
        ["tostring"] = {
            desc = "Преобразует значение в строку",
            syntax = "tostring(value)",
            example = 'tostring(123)  --> "123"',
            note = "Используется для безопасной конкатенации"
        },
        ["tonumber"] = {
            desc = "Преобразует строку в число",
            syntax = "tonumber(value [, base])",
            example = 'tonumber("123")  --> 123  |  tonumber("FF", 16)  --> 255',
            note = "Возвращает nil если преобразование невозможно"
        },
        ["type"] = {
            desc = "Возвращает тип значения",
            syntax = "type(value)",
            example = 'type(42)  --> "number"  |  type("hello")  --> "string"',
            note = "Возвращает: nil, number, string, boolean, table, function, thread, userdata"
        },
        ["assert"] = {
            desc = "Проверяет условие, вызывает ошибку если false/nil",
            syntax = "assert(condition [, message])",
            example = 'assert(1 + 1 == 2, "Math is broken!")',
            note = "Полезно для проверки входных данных"
        },
        ["error"] = {
            desc = "Генерирует ошибку с сообщением",
            syntax = "error(message [, level])",
            example = 'error("Something went wrong!")',
            note = "Используется для обработки исключительных ситуаций"
        },
        ["pcall"] = {
            desc = "Безопасный вызов функции (перехватывает ошибки)",
            syntax = "pcall(function, ...)",
            example = 'local ok, err = pcall(function() error("test") end)',
            note = "Возвращает true/false и результат/ошибку"
        },
        ["xpcall"] = {
            desc = "Безопасный вызов с обработчиком ошибок",
            syntax = "xpcall(function, error_handler, ...)",
            example = 'xpcall(f, function(err) print("Error:", err) end)',
            note = "Позволяет кастомизировать обработку ошибок"
        },
        ["dofile"] = {
            desc = "Выполняет Lua-скрипт из файла",
            syntax = "dofile(filename)",
            example = 'dofile("script.lua")',
            note = "Загружает и выполняет файл сразу"
        },
        ["loadfile"] = {
            desc = "Загружает Lua-скрипт из файла (без выполнения)",
            syntax = "loadfile(filename)",
            example = 'local f = loadfile("script.lua"); f()',
            note = "Возвращает функцию, которую можно вызвать позже"
        },
        ["load"] = {
            desc = "Загружает Lua-код из строки",
            syntax = "load(code [, chunkname [, mode [, env]]])",
            example = 'local f = load("print(42)"); f()',
            note = "Позволяет выполнить динамический код"
        },
        ["collectgarbage"] = {
            desc = "Управляет сборщиком мусора",
            syntax = "collectgarbage([opt [, arg]])",
            example = 'collectgarbage("collect")  -- Принудительный сбор',
            note = "Полезно при работе с большими данными"
        },
        ["_G"] = {
            desc = "Глобальная таблица со всеми переменными",
            syntax = "_G",
            example = 'for k,v in pairs(_G) do print(k) end',
            note = "Хранит все глобальные переменные/функции"
        },
        ["_VERSION"] = {
            desc = "Версия Lua",
            syntax = "_VERSION",
            example = 'print(_VERSION)  --> Lua 5.4',
            note = "Проверка версии для обратной совместимости"
        },
        
        -- ---- БИБЛИОТЕКА OS ----
        ["os.execute"] = {
            desc = "Выполняет команду в системной оболочке",
            syntax = "os.execute(command)",
            example = 'os.execute("ls -la")',
            note = "Возвращает код завершения команды (0 = успех)"
        },
        ["os.getenv"] = {
            desc = "Получает значение переменной окружения",
            syntax = "os.getenv(varname)",
            example = 'local home = os.getenv("HOME")',
            note = "Возвращает nil если переменная не найдена"
        },
        ["os.setenv"] = {
            desc = "Устанавливает переменную окружения",
            syntax = "os.setenv(varname, value)",
            example = 'os.setenv("MYVAR", "hello")',
            note = "Изменяет окружение текущего процесса"
        },
        ["os.exit"] = {
            desc = "Завершает программу с кодом выхода",
            syntax = "os.exit([code [, close]])",
            example = 'os.exit(0)  -- Успешное завершение',
            note = "code: 0 = успех, 1 = ошибка"
        },
        ["os.date"] = {
            desc = "Форматирует дату и время",
            syntax = "os.date([format [, time]])",
            example = 'os.date("%Y-%m-%d %H:%M:%S")  --> 2026-07-20 20:35:29',
            note = "Спецификаторы: %Y(год), %m(месяц), %d(день), %H(час), %M(мин), %S(сек)"
        },
        ["os.time"] = {
            desc = "Возвращает текущее время в секундах",
            syntax = "os.time([table])",
            example = 'local now = os.time()',
            note = "Используйте для измерения времени выполнения"
        },
        ["os.clock"] = {
            desc = "Возвращает время CPU программы в секундах",
            syntax = "os.clock()",
            example = 'local start = os.clock(); -- код; print(os.clock() - start)',
            note = "Полезно для измерения производительности"
        },
        ["os.remove"] = {
            desc = "Удаляет файл",
            syntax = "os.remove(filename)",
            example = 'os.remove("temp.txt")',
            note = "Возвращает true/false в зависимости от успеха"
        },
        ["os.rename"] = {
            desc = "Переименовывает файл",
            syntax = "os.rename(oldname, newname)",
            example = 'os.rename("old.txt", "new.txt")',
            note = "Может также перемещать файлы"
        },
        ["os.tmpname"] = {
            desc = "Возвращает имя временного файла",
            syntax = "os.tmpname()",
            example = 'local temp = os.tmpname()',
            note = "Генерирует уникальное имя, но не создает файл"
        },
        
        -- ---- БИБЛИОТЕКА IO ----
        ["io.open"] = {
            desc = "Открывает файл для чтения/записи",
            syntax = "io.open(filename [, mode])",
            example = 'local f = io.open("file.txt", "r")',
            note = "Режимы: r(чтение), w(запись), a(добавление), r+(чтение/запись)"
        },
        ["io.close"] = {
            desc = "Закрывает открытый файл",
            syntax = "io.close([file])",
            example = 'f:close()  или  io.close()',
            note = "Всегда закрывайте файлы после работы"
        },
        ["io.read"] = {
            desc = "Читает из стандартного ввода",
            syntax = "io.read(...)",
            example = 'local line = io.read("*line")',
            note = "Форматы: *all (весь), *line (строка), *number (число)"
        },
        ["io.write"] = {
            desc = "Пишет в стандартный вывод",
            syntax = "io.write(...)",
            example = 'io.write("Hello World!\\n")',
            note = "Быстрее чем print(), но без автоматического форматирования"
        },
        ["io.input"] = {
            desc = "Устанавливает или возвращает текущий файл ввода",
            syntax = "io.input([file])",
            example = 'io.input("input.txt")',
            note = "По умолчанию stdin (клавиатура)"
        },
        ["io.output"] = {
            desc = "Устанавливает или возвращает текущий файл вывода",
            syntax = "io.output([file])",
            example = 'io.output("output.txt")',
            note = "По умолчанию stdout (экран)"
        },
        ["io.popen"] = {
            desc = "Открывает pipe для выполнения команды",
            syntax = "io.popen(prog [, mode])",
            example = 'local f = io.popen("ls -la", "r"); print(f:read("*all"))',
            note = "Позволяет читать вывод команд"
        },
        ["io.lines"] = {
            desc = "Итератор по строкам файла",
            syntax = "io.lines([filename])",
            example = 'for line in io.lines("file.txt") do print(line) end',
            note = "Удобно для обработки больших файлов"
        },
        
        -- ---- БИБЛИОТЕКА STRING ----
        ["string.len"] = {
            desc = "Возвращает длину строки",
            syntax = "string.len(s)",
            example = 'string.len("hello")  --> 5',
            note = "Альтернатива: #" .. '"hello"  --> 5'
        },
        ["string.sub"] = {
            desc = "Извлекает подстроку",
            syntax = "string.sub(s, i [, j])",
            example = 'string.sub("hello world", 1, 5)  --> "hello"',
            note = "Индексация начинается с 1"
        },
        ["string.find"] = {
            desc = "Ищет подстроку или шаблон",
            syntax = "string.find(s, pattern [, init [, plain]])",
            example = 'string.find("hello", "ll")  --> 3 4',
            note = "Возвращает позиции начала и конца"
        },
        ["string.gsub"] = {
            desc = "Глобальная замена по шаблону",
            syntax = "string.gsub(s, pattern, repl [, n])",
            example = 'string.gsub("hello world", "l", "L")  --> "heLLo worLd"',
            note = "Можно использовать шаблоны и функции"
        },
        ["string.gmatch"] = {
            desc = "Итератор по совпадениям с шаблоном",
            syntax = "string.gmatch(s, pattern)",
            example = 'for word in string.gmatch("a b c", "%w") do print(word) end',
            note = "Извлекает все части, соответствующие шаблону"
        },
        ["string.match"] = {
            desc = "Ищет первое совпадение с шаблоном",
            syntax = "string.match(s, pattern [, init])",
            example = 'string.match("hello 123", "%d+")  --> "123"',
            note = "Возвращает найденное совпадение"
        },
        ["string.format"] = {
            desc = "Форматирует строку (как printf в C)",
            syntax = "string.format(formatstring, ...)",
            example = 'string.format("Name: %s, Age: %d", "John", 30)',
            note = "Спецификаторы: %s(строка), %d(число), %f(дробное), %x(hex)"
        },
        ["string.upper"] = {
            desc = "Преобразует строку в верхний регистр",
            syntax = "string.upper(s)",
            example = 'string.upper("hello")  --> "HELLO"'
        },
        ["string.lower"] = {
            desc = "Преобразует строку в нижний регистр",
            syntax = "string.lower(s)",
            example = 'string.lower("HELLO")  --> "hello"'
        },
        ["string.rep"] = {
            desc = "Повторяет строку N раз",
            syntax = "string.rep(s, n [, sep])",
            example = 'string.rep("=", 10)  --> "=========="'
        },
        
        -- ---- БИБЛИОТЕКА TABLE ----
        ["table.insert"] = {
            desc = "Вставляет элемент в таблицу",
            syntax = "table.insert(table, [pos,] value)",
            example = 't = {1,2,3}; table.insert(t, 4)  --> {1,2,3,4}',
            note = "Вставляет в конец или по указанной позиции"
        },
        ["table.remove"] = {
            desc = "Удаляет элемент из таблицы",
            syntax = "table.remove(table [, pos])",
            example = 't = {1,2,3}; table.remove(t)  --> {1,2}',
            note = "Удаляет последний или по указанной позиции"
        },
        ["table.sort"] = {
            desc = "Сортирует таблицу",
            syntax = "table.sort(table [, comp])",
            example = 't = {3,1,2}; table.sort(t)  --> {1,2,3}',
            note = "Можно передать функцию сравнения"
        },
        ["table.concat"] = {
            desc = "Объединяет элементы таблицы в строку",
            syntax = "table.concat(table [, sep [, i [, j]]])",
            example = 'table.concat({"a","b","c"}, ",")  --> "a,b,c"',
            note = "Быстрее чем цикл с конкатенацией"
        },
        ["table.pack"] = {
            desc = "Упаковывает аргументы в таблицу",
            syntax = "table.pack(...)",
            example = 't = table.pack(1,2,3)  --> {1,2,3, n=3}',
            note = "Сохраняет количество аргументов в поле n"
        },
        ["table.unpack"] = {
            desc = "Распаковывает таблицу в аргументы",
            syntax = "table.unpack(table [, i [, j]])",
            example = 'a,b,c = table.unpack({1,2,3})  --> a=1,b=2,c=3'
        },
        
        -- ---- БИБЛИОТЕКА MATH ----
        ["math.abs"] = {
            desc = "Модуль числа (абсолютное значение)",
            syntax = "math.abs(x)",
            example = 'math.abs(-5)  --> 5'
        },
        ["math.floor"] = {
            desc = "Округление вниз (в меньшую сторону)",
            syntax = "math.floor(x)",
            example = 'math.floor(3.7)  --> 3'
        },
        ["math.ceil"] = {
            desc = "Округление вверх (в большую сторону)",
            syntax = "math.ceil(x)",
            example = 'math.ceil(3.2)  --> 4'
        },
        ["math.random"] = {
            desc = "Генерирует случайное число",
            syntax = "math.random([m [, n]])",
            example = 'math.random(1, 100)  --> случайное от 1 до 100',
            note = "Предварительно вызовите math.randomseed(os.time())"
        },
        ["math.randomseed"] = {
            desc = "Устанавливает seed для генератора случайных чисел",
            syntax = "math.randomseed(x)",
            example = 'math.randomseed(os.time())',
            note = "Используйте разные seed для разных запусков"
        },
        ["math.min"] = {
            desc = "Минимальное значение из списка",
            syntax = "math.min(x, ...)",
            example = 'math.min(3, 1, 5)  --> 1'
        },
        ["math.max"] = {
            desc = "Максимальное значение из списка",
            syntax = "math.max(x, ...)",
            example = 'math.max(3, 1, 5)  --> 5'
        },
        ["math.sqrt"] = {
            desc = "Квадратный корень",
            syntax = "math.sqrt(x)",
            example = 'math.sqrt(16)  --> 4'
        },
        ["math.pi"] = {
            desc = "Число Пи (3.14159...)",
            syntax = "math.pi",
            example = 'print(math.pi)  --> 3.1415926535898'
        },
        
        -- ---- ВАШИ ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ ----
        ["ll"] = {
            desc = "Подробный список файлов с сортировкой по версиям",
            syntax = "ll()",
            example = 'll()  -- показывает все файлы в текущей директории',
            note = "Использует: ls -alFS --group-directories-first --si --sort=version"
        },
        ["pwd"] = {
            desc = "Показывает текущую рабочую директорию",
            syntax = "pwd()",
            example = 'pwd()  --> /home/kkorablin',
            note = "Print Working Directory"
        },
        ["clear"] = {
            desc = "Очищает экран терминала",
            syntax = "clear()",
            example = 'clear()  -- Очистка экрана',
            note = "Аналог команды clear в терминале"
        },
        ["ps_cpu_short"] = {
            desc = "Показывает топ процессов по использованию CPU",
            syntax = "ps_cpu_short()",
            example = 'ps_cpu_short()  -- первые 15 процессов',
            note = "Использует: ps с сортировкой по CPU"
        },
        ["top_cpu"] = {
            desc = "Интерактивный просмотр процессов по CPU",
            syntax = "top_cpu()",
            example = 'top_cpu()  -- запускает top с сортировкой по CPU',
            note = "Однократный запуск top в пакетном режиме"
        },
        ["top_mem"] = {
            desc = "Интерактивный просмотр процессов по памяти",
            syntax = "top_mem()",
            example = 'top_mem()  -- запускает top с сортировкой по памяти',
            note = "Однократный запуск top в пакетном режиме"
        },
        ["sysinfo"] = {
            desc = "Показывает полную информацию о системе",
            syntax = "sysinfo()",
            example = 'sysinfo()  -- Ядро, аптайм, память, диски',
            note = "Объединяет: uname, uptime, free, df"
        },
        ["q"] = {
            desc = "Выход из интерактивного режима Lua",
            syntax = "q()",
            example = 'q()  -- Exit from REPL!',
            note = "Завершает сессию Lua с кодом 0"
        },
        ["help"] = {
            desc = "Показывает список доступных команд",
            syntax = "help()",
            example = 'help()  -- список всех пользовательских функций',
            note = "Показывает только базовые команды"
        },
        ["help_cmd"] = {
            desc = "Показывает подробную справку по функции",
            syntax = "help_cmd('function_name')",
            example = 'help_cmd("print")  -- справка по print',
            note = "Используйте кавычки вокруг имени функции"
        },
    }
    
    -- ============================================
    -- ЛОГИКА ВЫВОДА СПРАВКИ
    -- ============================================
    
    -- Если команда не указана - показываем все
    if not cmd then
        print("📚 ДОСТУПНЫЕ КОМАНДЫ ДЛЯ СПРАВКИ:")
        print("")
        print("📌 ВСТРОЕННЫЕ ФУНКЦИИ LUA:")
        local lua_funcs = {"print", "tostring", "tonumber", "type", "assert", 
                          "error", "pcall", "xpcall", "dofile", "loadfile", 
                          "load", "collectgarbage", "_G", "_VERSION"}
        
        for _, name in ipairs(lua_funcs) do
            if help_db[name] then
                print(string.format("  %-15s - %s", name, help_db[name].desc))
            end
        end
        
        print("")
        print("📌 БИБЛИОТЕКИ:")
        local libs = {"os.execute", "os.getenv", "os.date", "os.time", 
                     "io.open", "io.read", "io.write", 
                     "string.format", "string.gsub", "string.find",
                     "table.insert", "table.sort", "table.concat",
                     "math.random", "math.floor", "math.ceil"}
        
        for _, name in ipairs(libs) do
            if help_db[name] then
                print(string.format("  %-20s - %s", name, help_db[name].desc))
            end
        end
        
        print("")
        print("📌 ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ:")
        local user_funcs = {"ll", "pwd", "clear", "ps_cpu_short", 
                           "top_cpu", "top_mem", "sysinfo", "q", "help", "help_cmd"}
        
        for _, name in ipairs(user_funcs) do
            if help_db[name] then
                print(string.format("  %-15s - %s", name, help_db[name].desc))
            end
        end
        
        print("")
        print(string.rep("=", 60))
        print("💡 Используйте: help_cmd('имя_функции') для подробной справки")
        print("   Пример: help_cmd('os.execute')")
        return
    end
    
    -- ============================================
    -- ПОКАЗ СПРАВКИ ПО КОНКРЕТНОЙ ФУНКЦИИ
    -- ============================================
    
    local info = help_db[cmd]
    
    if not info then
        print("❌ Функция '" .. cmd .. "' не найдена в базе знаний")
        print("💡 Введите help_cmd() для списка доступных команд")
        return
    end
    
    print(string.rep("=", 60))
    print("📖 СПРАВКА: " .. cmd)
    print(string.rep("=", 60))
    print("")
    print("📌 Описание: " .. info.desc)
    print("")
    print("📝 Синтаксис: " .. info.syntax)
    print("")
    print("📋 Пример:    " .. info.example)
    
    if info.note then
        print("")
        print("💡 Примечание: " .. info.note)
    end
    
    print("")
    print(string.rep("=", 60))
end

-- ============================================
-- ОБНОВЛЕННАЯ ФУНКЦИЯ HELP
-- ============================================

function help()
    print(string.rep("=", 60))
    print("📚 ДОСТУПНЫЕ КОМАНДЫ")
    print(string.rep("=", 60))
    print("")
    print("📁 РАБОТА С ФАЙЛАМИ:")
    print("  ll()         - Подробный список файлов")
    print("  pwd()        - Показать текущую директорию")
    print("  clear()      - Очистить экран")
    print("")
    print("📊 МОНИТОРИНГ СИСТЕМЫ:")
    print("  ps_cpu_short() - Топ процессов по CPU (краткий)")
    print("  top_cpu()    - Топ процессов по CPU (интерактивный)")
    print("  top_mem()    - Топ процессов по памяти (интерактивный)")
    print("  sysinfo()    - Полная информация о системе")
    print("")
    print("🎯 УПРАВЛЕНИЕ:")
    print("  q()          - Выйти из Lua")
    print("  help()       - Показать эту справку")
    print("  help_cmd('func') - Подробная справка по функции")
    print("")
    print("💡 ПРИМЕРЫ:")
    print("  help_cmd('print')      - справка по print")
    print("  help_cmd('os.execute') - справка по os.execute")
    print("  help_cmd('ll')         - справка по ll()")
    print("")
    print(string.rep("=", 60))
    print("📖 Для детальной справки используйте help_cmd('имя_функции')")
end

print("Lua profile loaded! Type help() for available commands.")
```
</details> 
<br/>


<details>
<summary>❗ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ❗</summary>

```lua
-- Запуск Lua
> lua -i
Lua 5.4.7  Copyright (C) 1994-2024 Lua.org, PUC-Rio
Lua profile loaded! Type help() for available commands.

-- 1. БАЗОВАЯ СПРАВКА
> help()
-- Показывает все доступные команды

-- 2. СПРАВКА ПО КОНКРЕТНОЙ ФУНКЦИИ
> help_cmd('print')
============================================================
📖 СПРАВКА: print
============================================================

📌 Описание: Выводит значения в консоль

📝 Синтаксис: print(value1, value2, ...)

📋 Пример:    print("Hello", 42, true)  --> Hello 42 true

💡 Примечание: Автоматически преобразует значения в строки
============================================================

-- 3. СПРАВКА ПО OS.EXECUTE
> help_cmd('os.execute')
============================================================
📖 СПРАВКА: os.execute
============================================================

📌 Описание: Выполняет команду в системной оболочке

📝 Синтаксис: os.execute(command)

📋 Пример:    os.execute("ls -la")

💡 Примечание: Возвращает код завершения команды (0 = успех)
============================================================

-- 4. СПРАВКА ПО ВАШЕЙ ФУНКЦИИ
> help_cmd('ll')
============================================================
📖 СПРАВКА: ll
============================================================

📌 Описание: Подробный список файлов с сортировкой по версиям

📝 Синтаксис: ll()

📋 Пример:    ll()  -- показывает все файлы в текущей директории

💡 Примечание: Использует: ls -alFS --group-directories-first --si --sort=version
============================================================

-- 5. СПРАВКА ПО STRING.FORMAT
> help_cmd('string.format')
============================================================
📖 СПРАВКА: string.format
============================================================

📌 Описание: Форматирует строку (как printf в C)

📝 Синтаксис: string.format(formatstring, ...)

📋 Пример:    string.format("Name: %s, Age: %d", "John", 30)

💡 Примечание: Спецификаторы: %s(строка), %d(число), %f(дробное), %x(hex)
============================================================
```

</details> 
<br/>


#### **Настройка автоматической загрузки профиля**

**Способ 1: Использование переменной окружения LUA_INIT**

Добавьте в `~/.bashrc`:
```bash
export LUA_INIT="@$HOME/.lua_profile"
```

После этого при запуске `lua -i` профиль будет загружаться автоматически.

**Способ 2: Создание алиаса**

```bash
# В ~/.bashrc
alias mylua='lua -i -e "dofile(\"$HOME/.lua_profile\")"'
```

**Способ 3: Явная загрузка при запуске**

```bash
lua -i -e "dofile(os.getenv('HOME') .. '/.lua_profile')"
```

**Важное замечание о флаге `-l`:** Флаг `-l` ожидает **имя модуля**, а не путь к файлу. Поэтому использование `lua -l /root/.lua_profile` приведет к ошибке, так как Lua будет искать модуль с таким именем в стандартных путях. Правильный способ загрузить файл с функциями - использовать `dofile()` или настроить `LUA_INIT`.

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

### **Быстрое создание нескольких функций**

Если нужно быстро добавить набор функций в текущей сессии:

```lua
-- Создайте сразу несколько функций в цикле
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

-- Теперь все функции доступны:
ll()
lsa()
pwd()
date()
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

### **Сохранение функций для постоянного использования**

#### **Метод 1: Использовать `~/.lua`**

Создайте файл `~/.lua`:
```lua
-- Автоматически загружается при запуске lua -i

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

#### **Метод 2: Создать алиас с автозагрузкой**

```bash
# В ~/.bashrc
alias mylua='lua -i -e "dofile(\"$HOME/.lua-tools.lua\")"'
```

#### **Метод 3: Использовать `lua -l` с модулем**

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

### **Как правильно выйти из интерактивного режима**

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

### **Полезные сокращения для интерактивного режима**

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

---

## Типичные ошибки и их решение

### **Ошибка: попытка использовать команды оболочки напрямую**
```lua
> ls
nil
> pwd
nil
```
**Решение:** Используйте `os.execute()` для вызова системных команд или создайте функции-обертки.

### **Ошибка: неправильное использование `-l`**
```bash
lua -l /root/.lua_profile -e "sysinfo()"
lua: module '/root/.lua_profile' not found
```
**Решение:** Флаг `-l` ожидает имя модуля, а не путь. Используйте `dofile()` или настройте `LUA_INIT`.

Правильные способы:
```bash
# Способ 1: через LUA_INIT
export LUA_INIT="@$HOME/.lua_profile"
lua -i

# Способ 2: через dofile
lua -e 'dofile("/root/.lua_profile"); sysinfo()'

# Способ 3: интерактивный режим
lua -i
```

### **Ошибка: `os.execute()` не меняет текущую директорию**
```lua
> os.execute("cd /tmp")
> pwd()
/root
```
**Решение:** `os.execute()` запускает команду в новом процессе, поэтому `cd` не влияет на текущий процесс Lua. Используйте другие методы для работы с директориями.
