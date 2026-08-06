## ГЛОБАЛЬНЫЕ МАКРОСЫ И ФУНКЦИИ (доступны везде)

```rust
// Базовые макросы вывода
print!(...)              // Вывод без перевода строки
println!(...)            // Вывод с переводом строки
eprint!(...)             // Вывод в stderr без перевода строки
eprintln!(...)           // Вывод в stderr с переводом строки

// Форматирование
format!(...)             // Форматирует строку
format_args!(...)        // Аргументы форматирования (низкий уровень)
write!(...)              // Пишет в реализацию Write
writeln!(...)            // Пишет в реализацию Write с переводом строки

// Ассерты (проверки)
assert!(cond, msg)       // Проверяет условие, паникует если false
assert_eq!(a, b)         // Проверяет равенство
assert_ne!(a, b)         // Проверяет неравенство
debug_assert!(cond)      // Проверка только в debug-режиме
debug_assert_eq!(a, b)   // Проверка равенства только в debug-режиме
debug_assert_ne!(a, b)   // Проверка неравенства только в debug-режиме

// Паника и ошибки
panic!(msg)              // Генерирует панику
unreachable!()           // Недостижимый код (паника)
unimplemented!()         // Не реализовано (паника)
compile_error!(msg)      // Ошибка компиляции

// Включение файлов (на этапе компиляции)
include!(path)           // Включает файл как выражение
include_bytes!(path)     // Включает файл как &[u8; N]
include_str!(path)       // Включает файл как &'static str
include!(path)           // Включает и парсит файл как код

// Информация о местоположении
file!()                  // Имя текущего файла
line!()                  // Номер текущей строки
column!()                // Номер текущей колонки
module_path!()           // Путь к текущему модулю

// Переменные окружения (на этапе компиляции)
env!(var)                // Переменная окружения (паника если нет)
option_env!(var)         // Переменная окружения (Option)

// Условная компиляция
cfg!(condition)          // Проверка условия компиляции (bool)

// Создание коллекций
vec![...]                // Создает Vec<T>
vec![elem; n]            // Создает Vec<T> с n элементами

// Встроенные константы
std::f64::INFINITY       // Бесконечность
std::f64::NAN            // Не число (NaN)
std::f64::PI             // Число π
std::f64::TAU            // Число 2π
std::f64::E              // Число e
std::f64::RADIX          // Основание системы счисления (2)
std::f64::MANTISSA_DIGITS // Количество бит мантиссы
std::f64::MAX            // Максимальное значение
std::f64::MIN            // Минимальное значение
std::f64::MIN_POSITIVE   // Минимальное положительное
```

---

## БИБЛИОТЕКА std::io (ВВОД-ВЫВОД)

```rust
use std::io;

// Основные функции и константы
io::stdin()              // Стандартный ввод (Stdin)
io::stdout()             // Стандартный вывод (Stdout)
io::stderr()             // Стандартный поток ошибок (Stderr)
io::stdin().read_line()  // Читает строку из stdin
io::stdout().write()     // Пишет в stdout
io::stdout().flush()     // Сбрасывает буфер вывода

// Работа с файлами
std::fs::File::open(path)    // Открывает файл (чтение)
std::fs::File::create(path)  // Создает/открывает файл (запись)
std::fs::read(path)          // Читает весь файл в Vec<u8>
std::fs::read_to_string(path)// Читает весь файл в String
std::fs::write(path, data)   // Пишет данные в файл
std::fs::remove_file(path)   // Удаляет файл
std::fs::rename(from, to)    // Переименовывает/перемещает файл
std::fs::copy(from, to)      // Копирует файл
std::fs::metadata(path)      // Метаданные файла
std::fs::symlink_metadata()  // Метаданные симлинка (не следя)

// Работа с директориями
std::fs::create_dir(path)    // Создает директорию
std::fs::create_dir_all(path)// Создает директорию и все родительские
std::fs::read_dir(path)      // Читает содержимое директории
std::fs::remove_dir(path)    // Удаляет пустую директорию
std::fs::remove_dir_all(path)// Удаляет директорию рекурсивно
std::fs::canonicalize(path)  // Абсолютный путь

// Трейты для I/O
std::io::Read               // Трейт для чтения (метод read)
std::io::Write              // Трейт для записи (методы write, flush)
std::io::Seek               // Трейт для позиционирования (seek)
std::io::BufRead            // Трейт для буферизованного чтения

// Утилиты
std::io::stdin().lock()     // Блокировка stdin (потокобезопасность)
io::copy(reader, writer)    // Копирует из Read в Write
io::empty()                 // Пустой источник данных
io::repeat(byte)            // Бесконечный повтор байта
io::sink()                  // Черная дыра для данных
io::BufReader::new()        // Буферизованный читатель
io::BufWriter::new()        // Буферизованный писатель
io::Cursor::new(data)       // Обертка для работы с памятью как с файлом

// Режимы открытия файлов
std::fs::OpenOptions::new()
  .read(true/false)        // Чтение
  .write(true/false)       // Запись
  .append(true/false)      // Добавление
  .truncate(true/false)    // Обрезать
  .create(true/false)      // Создать если нет
  .create_new(true/false)  // Создать только если нет
  .open(path)              // Открыть с опциями
```

---

## БИБЛИОТЕКА std::os (ОПЕРАЦИОННАЯ СИСТЕМА)

```rust
use std::os;

// Unix-специфичные (Linux, macOS)
use std::os::unix::fs::PermissionsExt;
std::os::unix::fs::symlink(original, link) // Создает симлинк
std::os::unix::fs::lstat(path)              // Статус файла (не следя симлинк)
std::os::unix::process::CommandExt::uid()   // Установка UID процесса
std::os::unix::process::CommandExt::gid()   // Установка GID процесса
std::os::unix::process::CommandExt::exec()  // Заменяет текущий процесс
std::os::unix::net::UnixStream              // Unix сокеты
std::os::unix::net::UnixListener            // Unix слушатель
std::os::unix::net::UnixDatagram            // Unix датаграммы

// Windows-специфичные
use std::os::windows::fs::symlink_file(original, link) // Создает симлинк файла
use std::os::windows::fs::symlink_dir(original, link)  // Создает симлинк директории
std::os::windows::process::CommandExt::creation_flags() // Флаги создания процесса
std::os::windows::io::AsRawHandle            // Получение HANDLE
std::os::windows::io::FromRawHandle          // Создание из HANDLE

// Общие
std::os::raw::c_char, c_int, c_long...      // Си-типы для FFI
```

---

## БИБЛИОТЕКА std::path (РАБОТА С ПУТЯМИ)

```rust
use std::path;

std::path::Path::new(path)           // Создает путь
std::path::PathBuf::from(path)       // Владеющий путь

// Методы Path
path.as_os_str()                     // Как OsStr
path.to_str()                        // Как &str (Option)
path.display()                       // Для форматирования
path.exists()                        // Существует ли
path.is_file()                       // Это файл?
path.is_dir()                        // Это директория?
path.is_symlink()                    // Это симлинк?
path.file_name()                     // Имя файла
path.file_stem()                     // Имя без расширения
path.extension()                     // Расширение
path.parent()                        // Родительская директория
path.join(path)                      // Объединяет пути
path.push(path)                      // Добавляет компонент пути
path.pop()                           // Удаляет последний компонент
path.ancestors()                     // Итератор по предкам
path.components()                    // Итератор по компонентам
path.canonicalize()                  // Абсолютный путь (разрешает симлинки)
path.read_link()                     // Читает симлинк
path.with_file_name(name)            // Заменяет имя файла
path.with_extension(ext)             // Заменяет расширение

// Константы
std::path::MAIN_SEPARATOR            // Разделитель пути (/ или \)
std::path::MAIN_SEPARATOR_STR        // Разделитель как &str
```

---

## БИБЛИОТЕКА std::env (ОКРУЖЕНИЕ И АРГУМЕНТЫ)

```rust
use std::env;

// Аргументы командной строки
env::args()                          // Итератор по аргументам
env::args_os()                       // Аргументы как OsString

// Переменные окружения
env::var(var)                        // Получает переменную (Result)
env::var_os(var)                     // Получает как OsString (Option)
env::set_var(var, value)             // Устанавливает переменную
env::remove_var(var)                 // Удаляет переменную
env::vars()                          // Итератор по всем переменным
env::vars_os()                       // Итератор как OsString

// Информация о программе
env::current_dir()                   // Текущая рабочая директория
env::set_current_dir(path)           // Устанавливает рабочую директорию
env::home_dir()                      // Домашняя директория (Option)
env::temp_dir()                      // Временная директория
env::current_exe()                   // Путь к исполняемому файлу
env::consts::ARCH                    // Архитектура (x86_64, arm...)
env::consts::OS                      // ОС (linux, windows, macos...)
env::consts::FAMILY                  // Семейство ОС (unix, windows)
env::consts::EXE_SUFFIX              // Суффикс исполняемых файлов (.exe)
env::consts::EXE_EXTENSION           // Расширение (.exe)

// Завершение
std::process::exit(code)             // Завершает программу с кодом
std::process::abort()                // Аварийное завершение
```

---

## БИБЛИОТЕКА std::process (ПРОЦЕССЫ)

```rust
use std::process;

// Запуск процессов
std::process::Command::new(cmd)       // Создает команду
  .arg(arg)                           // Добавляет аргумент
  .args(args)                         // Добавляет несколько аргументов
  .env(key, value)                    // Устанавливает переменную
  .envs(iter)                         // Устанавливает несколько
  .current_dir(path)                  // Рабочая директория
  .stdin(Stdio::piped())              // Перенаправление stdin
  .stdout(Stdio::piped())             // Перенаправление stdout
  .stderr(Stdio::piped())             // Перенаправление stderr
  .spawn()                            // Запускает в фоне (Child)
  .output()                           // Запускает и ждет (Output)
  .status()                           // Запускает и ждет (ExitStatus)

// Методы Child
child.wait()                          // Ждет завершения
child.kill()                          // Убивает процесс
child.id()                            // PID процесса
child.try_wait()                      // Проверяет без блокировки

// Текущий процесс
std::process::id()                    // PID текущего процесса
std::process::parent_id()             // PPID текущего процесса
std::process::Termination             // Трейт для завершения

// Константы и утилиты
std::process::Stdio::null()           // /dev/null или NUL
std::process::Stdio::piped()          // Создает pipe
std::process::Stdio::inherit()        // Наследует от родителя
```

---

## БИБЛИОТЕКА std::collections (КОЛЛЕКЦИИ)

```rust
use std::collections;

// Последовательности
Vec::new()                          // Вектор (динамический массив)
Vec::with_capacity(n)               // С предвыделенной памятью
vec.push(value)                     // Добавляет в конец
vec.pop()                           // Удаляет и возвращает последний
vec.insert(index, value)            // Вставляет по индексу
vec.remove(index)                   // Удаляет по индексу
vec.swap_remove(index)              // Удаляет с заменой местами
vec.append(&mut other)              // Переносит элементы
vec.drain(range)                    // Удаляет диапазон
vec.retain(condition)               // Оставляет по условию
vec.sort()                          // Сортирует
vec.sort_by_key()                   // Сортирует по ключу
vec.reverse()                       // Переворачивает
vec.binary_search(value)            // Бинарный поиск

VecDeque::new()                     // Двухсторонняя очередь
vec_deque.push_front(value)         // Добавляет в начало
vec_deque.push_back(value)          // Добавляет в конец
vec_deque.pop_front()               // Удаляет из начала
vec_deque.pop_back()                // Удаляет из конца

LinkedList::new()                   // Двусвязный список

BinaryHeap::new()                   // Бинарная куча (максимум)
BinaryHeap::with_capacity(n)
binary_heap.push(value)             // Добавляет
binary_heap.pop()                   // Удаляет максимум
binary_heap.peek()                  // Смотрит максимум

// Отображения (Словари)
HashMap::new()                      // Хеш-таблица
HashMap::with_capacity(n)
hash_map.insert(key, value)         // Вставляет
hash_map.get(&key)                  // Получает значение
hash_map.get_mut(&key)              // Получает мутабельно
hash_map.remove(&key)               // Удаляет
hash_map.contains_key(&key)         // Проверяет наличие
hash_map.entry(key)                 // API для вставки/обновления
hash_map.keys()                     // Итератор по ключам
hash_map.values()                   // Итератор по значениям
hash_map.values_mut()               // Мутабельный итератор

BTreeMap::new()                     // Дерево (отсортированное)
btree_map.range(start..end)         // Диапазон ключей

// Множества
HashSet::new()                      // Хеш-множество
hash_set.insert(value)              // Добавляет
hash_set.remove(value)              // Удаляет
hash_set.contains(value)            // Проверяет
hash_set.intersection()             // Пересечение
hash_set.union()                    // Объединение
hash_set.difference()               // Разность

BTreeSet::new()                     // Отсортированное множество
```

---

## БИБЛИОТЕКА std::string (СТРОКИ)

```rust
use std::string;

// Основные функции
String::new()                       // Пустая строка
String::with_capacity(n)            // С предвыделенной памятью
String::from(str)                   // Из &str
String::from_utf8(vec)              // Из Vec<u8>
String::from_utf8_lossy(vec)        // Из Vec<u8> (с заменой ошибок)
string.push_str(str)                // Добавляет &str
string.push(char)                   // Добавляет символ
string.pop()                        // Удаляет последний символ
string.remove(index)                // Удаляет по индексу символа
string.insert(index, char)          // Вставляет символ
string.insert_str(index, str)       // Вставляет строку
string.truncate(n)                  // Обрезает по байтам
string.clear()                      // Очищает
string.replace(old, new)            // Замена подстроки
string.replacen(old, new, n)        // Замена первых n
string.split(pat)                   // Разбивает по шаблону
string.split_whitespace()           // Разбивает по пробелам
string.lines()                      // Итератор по строкам
string.trim()                       // Удаляет пробелы с краев
string.trim_start()                 // Удаляет слева
string.trim_end()                   // Удаляет справа
string.to_lowercase()               // В нижний регистр
string.to_uppercase()               // В верхний регистр
string.repeat(n)                    // Повторяет n раз
string.len()                        // Длина в байтах
string.chars()                      // Итератор по символам
string.bytes()                      // Итератор по байтам
string.is_empty()                   // Пустая?
string.capacity()                   // Выделенная память
string.shrink_to_fit()              // Сокращает память
string.into_bytes()                 // Преобразует в Vec<u8>

// Методы &str
str.len()                           // Длина в байтах
str.chars()                         // Итератор по символам
str.bytes()                         // Итератор по байтам
str.is_empty()                      // Пустая?
str.starts_with(prefix)             // Начинается с
str.ends_with(suffix)               // Заканчивается на
str.contains(pattern)               // Содержит
str.find(pattern)                   // Поиск (Option<usize>)
str.rfind(pattern)                  // Поиск справа
str.replace(old, new)               // Замена
str.replacen(old, new, n)           // Замена первых n
str.split(pattern)                  // Разбивает
str.split_whitespace()              // Разбивает по пробелам
str.lines()                         // По строкам
str.trim()                          // Обрезает края
str.trim_start()                    // Обрезает слева
str.trim_end()                      // Обрезает справа
str.to_lowercase()                  // В нижний регистр
str.to_uppercase()                  // В верхний регистр
str.repeat(n)                       // Повторяет
str.parse()                         // Парсит в число
str.is_ascii()                      // Только ASCII?
str.is_alphabetic()                 // Буквы?
str.is_alphanumeric()               // Буквы или цифры?
str.is_whitespace()                 // Пробелы?
str.is_control()                    // Управляющие?
str.to_ascii_lowercase()            // В ASCII нижний
str.to_ascii_uppercase()            // В ASCII верхний
str.escape_default()                // Экранирует
str.escape_unicode()                // Экранирует в Unicode
```

---

## БИБЛИОТЕКА std::fmt (ФОРМАТИРОВАНИЕ)

```rust
use std::fmt;

// Трейты форматирования
fmt::Display                        // {} (пользовательский вывод)
fmt::Debug                          // {:?} (отладочный вывод)
fmt::Binary                         // {:b} (двоичный)
fmt::Octal                          // {:o} (восьмеричный)
fmt::LowerHex                       // {:x} (шестнадцатеричный)
fmt::UpperHex                       // {:X} (шестнадцатеричный HEX)
fmt::LowerExp                       // {:e} (экспонента)
fmt::UpperExp                       // {:E} (экспонента BIG)
fmt::Pointer                        // {:p} (указатель)

// Вспомогательные
fmt::format(args)                   // Форматирует аргументы
fmt::write(output, args)            // Пишет форматированный вывод
fmt::result::Result                 // Результат форматирования

// Макросы форматирования (уже перечислены в глобальных)
```

---

## БИБЛИОТЕКА std::thread (ПОТОКИ)

```rust
use std::thread;

// Создание потоков
thread::spawn(|| { ... })           // Создает поток
thread::Builder::new()              // Строитель потока
  .name("name")                     // Имя потока
  .stack_size(size)                 // Размер стека
  .spawn(|| { ... })                // Запускает

// Управление потоками
thread::sleep(duration)             // Спит
thread::yield_now()                 // Уступает процессор
thread::current()                   // Текущий поток
thread::park()                      // Блокирует текущий
thread::park_timeout(duration)      // Блокирует с таймаутом
Thread::unpark(thread)              // Разблокирует поток
thread::JoinHandle::join()          // Ждет завершения потока

// Информация
thread::available_parallelism()     // Количество доступных ядер
thread::sleep(Duration::from_secs(1)) // Засыпает на секунду
```

---

## БИБЛИОТЕКА std::sync (СИНХРОНИЗАЦИЯ)

```rust
use std::sync;

// Примитивы синхронизации
Arc::new(value)                     // Атомарный счетчик ссылок
Arc::clone(&arc)                    // Клонирует Arc
Mutex::new(value)                   // Мьютекс
mutex.lock()                        // Блокирует (Result<MutexGuard>)
mutex.try_lock()                    // Попытка блокировки
RwLock::new(value)                  // Блокировка чтения/записи
rwlock.read()                       // Блокировка чтения
rwlock.write()                      // Блокировка записи
Barrier::new(n)                     // Барьер (n потоков)
barrier.wait()                      // Ожидание на барьере
Condvar::new()                      // Условная переменная
condvar.wait(guard)                 // Ожидание сигнала
condvar.notify_one()                // Сигнал одному
condvar.notify_all()                // Сигнал всем
Once::new()                         // Инициализация один раз
once.call_once(|| { ... })          // Выполняет один раз

// Атомарные типы (работают без Mutex)
std::sync::atomic::AtomicBool       // Безопасный bool
std::sync::atomic::AtomicIsize      // Безопасный isize
std::sync::atomic::AtomicUsize      // Безопасный usize
std::sync::atomic::AtomicPtr<T>     // Атомарный указатель
atomic.load(Ordering::SeqCst)       // Чтение
atomic.store(value, Ordering::SeqCst)// Запись
atomic.swap(value, Ordering::SeqCst)// Обмен
atomic.compare_exchange()           // Сравнение и обмен (CAS)
atomic.fetch_add(value, Ordering)   // Атомарное сложение
atomic.fetch_sub(value, Ordering)   // Атомарное вычитание
atomic.fetch_and(value, Ordering)   // Атомарное И
atomic.fetch_or(value, Ordering)    // Атомарное ИЛИ
atomic.fetch_xor(value, Ordering)   // Атомарное XOR

// Ordering (порядок памяти)
Ordering::Relaxed                   // Неупорядоченный
Ordering::Release                   // Освобождение
Ordering::Acquire                   // Захват
Ordering::AcqRel                    // Захват+Освобождение
Ordering::SeqCst                    // Последовательная согласованность

// Lazy initialization
std::sync::OnceLock<T>              // Отложенная инициализация
OnceLock::get_or_init(|| { ... })   // Получает или инициализирует
std::sync::LazyLock<T>              // Ленивая инициализация (более простая)
```

---

## БИБЛИОТЕКА std::net (СЕТЬ)

```rust
use std::net;

// TCP
std::net::TcpListener::bind(addr)   // Создает слушатель
tcp_listener.accept()               // Принимает соединение
tcp_listener.incoming()             // Итератор по соединениям
tcp_listener.local_addr()           // Локальный адрес
tcp_listener.set_ttl(ttl)           // Устанавливает TTL

std::net::TcpStream::connect(addr)  // Соединяется
tcp_stream.read(buf)                // Читает (трейт Read)
tcp_stream.write(buf)               // Пишет (трейт Write)
tcp_stream.flush()                  // Сбрасывает буфер
tcp_stream.peer_addr()              // Адрес удаленного
tcp_stream.local_addr()             // Локальный адрес
tcp_stream.set_nodelay(bool)        // Отключает Nagle
tcp_stream.set_ttl(ttl)             // Устанавливает TTL

// UDP
std::net::UdpSocket::bind(addr)     // Создает сокет
udp_socket.send_to(buf, addr)       // Отправляет на адрес
udp_socket.recv_from(buf)           // Получает с адресом
udp_socket.connect(addr)            // Соединяет (фиксирует адрес)
udp_socket.send(buf)                // Отправляет (после connect)
udp_socket.recv(buf)                // Получает (после connect)
udp_socket.peer_addr()              // Адрес удаленного
udp_socket.local_addr()             // Локальный адрес
udp_socket.set_broadcast(bool)      // Разрешает широковещательные
udp_socket.set_ttl(ttl)             // Устанавливает TTL

// Адреса
std::net::SocketAddr                 // IP + порт
std::net::SocketAddrV4               // IPv4 + порт
std::net::SocketAddrV6               // IPv6 + порт
std::net::IpAddr                     // IPv4 или IPv6
std::net::Ipv4Addr                   // IPv4 адрес
std::net::Ipv6Addr                   // IPv6 адрес
Ipv4Addr::new(a,b,c,d)              // Создает IPv4
Ipv4Addr::LOCALHOST                  // 127.0.0.1
Ipv4Addr::UNSPECIFIED                // 0.0.0.0
Ipv4Addr::BROADCAST                  // 255.255.255.255
Ipv6Addr::LOCALHOST                  // ::1
Ipv6Addr::UNSPECIFIED                // ::

// Парсинг адресов
"127.0.0.1:8080".parse::<SocketAddr>() // Парсит адрес
"127.0.0.1".parse::<Ipv4Addr>()       // Парсит IPv4
"::1".parse::<Ipv6Addr>()              // Парсит IPv6
```

---

## БИБЛИОТЕКА std::time (ВРЕМЯ)

```rust
use std::time;

// Продолжительность
Duration::from_secs(secs)           // Секунды
Duration::from_millis(millis)       // Миллисекунды
Duration::from_micros(micros)       // Микросекунды
Duration::from_nanos(nanos)         // Наносекунды
Duration::new(secs, nanos)          // Секунды + наносекунды
duration.as_secs()                  // Секунды
duration.as_millis()                // Миллисекунды
duration.as_micros()                // Микросекунды
duration.as_nanos()                 // Наносекунды
duration.subsec_nanos()             // Дробная часть в наносекундах

// Моменты времени
Instant::now()                      // Текущий момент (монотонные часы)
instant.elapsed()                   // Прошедшее время
instant.duration_since(earlier)     // Разница с прошлым

SystemTime::now()                   // Системное время
system_time.duration_since(earlier) // Разница
system_time.elapsed()               // Прошедшее время (Result)
system_time.checked_add(duration)   // Прибавляет (проверка)
system_time.checked_sub(duration)   // Вычитает (проверка)

// Преобразование
UNIX_EPOCH                          // 1970-01-01 00:00:00 UTC
SystemTime::UNIX_EPOCH + duration   // Из UNIX времени
system_time.duration_since(UNIX_EPOCH) // В UNIX время

std::thread::sleep(Duration::from_secs(1)) // Засыпает
```

---

## БИБЛИОТЕКА std::iter (ИТЕРАТОРЫ)

```rust
use std::iter;

// Основные методы итераторов
iter.next()                         // Следующий элемент (Option)
iter.size_hint()                    // Подсказка размера
iter.collect()                      // Собирает в коллекцию
iter.count()                        // Количество элементов
iter.last()                         // Последний элемент
iter.nth(n)                         // Элемент на позиции n
iter.all(condition)                 // Все удовлетворяют
iter.any(condition)                 // Хотя бы один удовлетворяет
iter.find(condition)                // Находит первый
iter.position(condition)            // Находит позицию
iter.map(f)                         // Преобразует
iter.filter(condition)              // Фильтрует
iter.filter_map(f)                  // Фильтрует и преобразует
iter.enumerate()                    // Добавляет индекс
iter.flat_map(f)                    // Разворачивает итераторы
iter.flatten()                      // Разворачивает вложенные
iter.take(n)                        // Берет первые n
iter.skip(n)                        // Пропускает n
iter.take_while(condition)          // Берет пока условие
iter.skip_while(condition)          // Пропускает пока условие
iter.zip(other)                     // Объединяет с другим
iter.chain(other)                   // Цепочка итераторов
iter.peekable()                     // Можно заглядывать вперед
iter.cycle()                        // Бесконечный цикл
iter.rev()                          // Переворачивает
iter.cloned()                       // Клонирует элементы
iter.copied()                       // Копирует элементы
iter.sum()                          // Сумма
iter.product()                      // Произведение
iter.fold(init, f)                  // Сворачивает
iter.reduce(f)                      // Сворачивает (без начального)
iter.for_each(f)                    // Выполняет для каждого
iter.partition(condition)           // Разделяет на две коллекции
iter.max()                          // Максимум
iter.min()                          // Минимум
iter.max_by_key(f)                  // Максимум по ключу
iter.min_by_key(f)                  // Минимум по ключу
iter.cmp(other)                     // Сравнивает с другим
iter.partial_cmp(other)             // Частичное сравнение
iter.eq(other)                      // Равны?
iter.ne(other)                      // Не равны?
iter.le(other)                      // Меньше или равно?

// Создание итераторов
iter::empty::<T>()                  // Пустой итератор
iter::once(value)                   // Один элемент
iter::repeat(value)                 // Бесконечное повторение
iter::repeat_with(f)                // Бесконечный вызов функции
iter::successors(first, f)          // Последовательность (итерация)
iter::from_fn(f)                    // Из функции
iter::Iterator::step_by(n)          // Шаг n
iter::Iterator::fuse()              // Останавливается после None
iter::Iterator::inspect(f)          // Инспектирует элементы
```

---

## БИБЛИОТЕКА std::mem (ПАМЯТЬ)

```rust
use std::mem;

// Основные функции
mem::size_of::<T>()                 // Размер типа в байтах
mem::size_of_val(&value)            // Размер значения
mem::align_of::<T>()                // Выравнивание типа
mem::align_of_val(&value)           // Выравнивание значения
mem::needs_drop::<T>()              // Нужно ли вызывать Drop
mem::replace(&mut value, new)       // Заменяет и возвращает старое
mem::take(&mut value)               // Забирает значение (Default)
mem::swap(&mut a, &mut b)           // Обменивает значения
mem::forget(value)                  // Забывает (не вызывает Drop)
mem::drop(value)                    // Явно дропает (на самом деле не нужно)
mem::uninitialized()                // Неинициализированная память (unsafe)
mem::zeroed()                       // Обнуленная память (unsafe)
mem::transmute(src)                 // Преобразование типов (unsafe)
mem::discriminant(&value)           // Дискриминант enum

// Управление памятью
std::alloc::alloc(layout)           // Выделяет память (unsafe)
std::alloc::dealloc(ptr, layout)    // Освобождает память (unsafe)
std::alloc::realloc(ptr, layout, new_size) // Перевыделяет (unsafe)
std::alloc::Layout::new::<T>()      // Структура выравнивания
std::alloc::Layout::from_size_align(size, align) // Создает layout

// Сырые указатели
ptr::read(src)                      // Читает (unsafe)
ptr::write(dst, value)              // Пишет (unsafe)
ptr::swap(a, b)                     // Обменивает (unsafe)
ptr::replace(dst, src)              // Заменяет (unsafe)
ptr::copy(src, dst, count)          // Копирует (unsafe)
ptr::copy_nonoverlapping(src, dst, count) // Непересекающаяся (unsafe)
```

---

## БИБЛИОТЕКА std::ptr (УКАЗАТЕЛИ)

```rust
use std::ptr;

// Функции для указателей
ptr::null::<T>()                    // Нулевой указатель
ptr::null_mut::<T>()                // Нулевой мутабельный указатель
ptr::addr_of!(value)                // Получает адрес (константа)
ptr::addr_of_mut!(value)            // Получает мутабельный адрес
ptr::eq(a, b)                       // Сравнивает указатели
ptr::hash(ptr)                      // Хеширует указатель

// Методы указателей
ptr.as_ref()                        // Как &T (unsafe)
ptr.as_mut()                        // Как &mut T (unsafe)
ptr.add(offset)                     // Смещает на n элементов (unsafe)
ptr.sub(offset)                     // Смещает назад (unsafe)
ptr.offset(offset)                  // Смещает (unsafe)
ptr.wrapping_add(offset)            // Смещает с переполнением
ptr.wrapping_sub(offset)            // Смещает назад с переполнением
ptr.wrapping_offset(offset)         // Смещает с переполнением
ptr.is_null()                       // Нулевой?
ptr.cast()                          // Приводит к другому типу

// NonNull (ненагруженный указатель)
NonNull::new(ptr)                   // Создает (Option)
NonNull::new_unchecked(ptr)         // Создает без проверки (unsafe)
NonNull::dangling()                 // Висячий указатель (для Zero-Sized Types)
```

---

## БИБЛИОТЕКА std::borrow (ЗАИМСТВОВАНИЕ)

```rust
use std::borrow;

// Трейты
Borrow<T>                           // Заимствование как &T
BorrowMut<T>                        // Заимствование как &mut T
ToOwned                             // Превращает &T в T::Owned

// Типы
Cow<'a, T>                          // Clone-on-Write
Cow::Borrowed(&T)                   // Заимствованное
Cow::Owned(T)                       // Владеющее
cow.to_mut()                        // Получает &mut T (клонирует если надо)
cow.into_owned()                    // Превращает в Owned
```

---

## БИБЛИОТЕКА std::convert (ПРЕОБРАЗОВАНИЕ)

```rust
use std::convert;

// Трейты
From<T>                             // Преобразование из T
Into<T>                             // Преобразование в T
TryFrom<T>                          // Преобразование с ошибкой
TryInto<T>                          // Преобразование с ошибкой
AsRef<T>                            // Ссылка как другая ссылка
AsMut<T>                            // Мутабельная ссылка как другая
FromStr                             // Преобразование из строки (parse)

// Функции
try_from(value)                     // Пытается преобразовать (Result)
from(value)                         // Преобразует
into(value)                         // Преобразует
as_ref(value)                       // Получает &T
as_mut(value)                       // Получает &mut T

// Полезные реализации (много)
String::from("hello")               // &str -> String
Vec::from([1,2,3])                  // Массив -> Vec
std::convert::identity(x)           // x (полезно в higher-order функциях)
```

---

## БИБЛИОТЕКА std::ops (ОПЕРАТОРЫ)

```rust
use std::ops;

// Арифметические (перегрузка)
Add<Other>                          // a + b
Sub<Other>                          // a - b
Mul<Other>                          // a * b
Div<Other>                          // a / b
Rem<Other>                          // a % b
Neg                                 // -a
AddAssign<Other>                    // a += b
SubAssign<Other>                    // a -= b
MulAssign<Other>                    // a *= b
DivAssign<Other>                    // a /= b
RemAssign<Other>                    // a %= b

// Сравнение
PartialEq<Other>                    // ==, !=
Eq                                  // Полное равенство
PartialOrd<Other>                   // <, <=, >, >=
Ord                                 // Полный порядок

// Индексация
Index<Idx>                          // &a[idx]
IndexMut<Idx>                       // &mut a[idx]

// Функциональные
Fn(Args)                            // Замыкание (вызов)
FnMut(Args)                         // Мутабельное замыкание
FnOnce(Args)                        // Одноразовое замыкание

// Управление памятью
Deref                               // *a (разыменование)
DerefMut                            // *mut a
Drop                                // Деструктор

// Побитовые
BitAnd<Other>                       // a & b
BitOr<Other>                        // a | b
BitXor<Other>                       // a ^ b
Shl<Other>                          // a << b
Shr<Other>                          // a >> b
Not                                 // !a

// Диапазоны
Range<Idx>                          // start..end
RangeFrom<Idx>                      // start..
RangeTo<Idx>                        // ..end
RangeFull                           // ..
RangeInclusive<Idx>                 // start..=end
RangeToInclusive<Idx>               // ..=end
```

---

## БИБЛИОТЕКА std::any (РЕФЛЕКСИЯ)

```rust
use std::any;

// Основные функции
Any::type_id()                      // TypeId текущего типа
TypeId::of::<T>()                   // ID типа T
Any::is<T>()                        // Является ли T
Any::downcast_ref<T>()              // Приводит к &T (Option)
Any::downcast_mut<T>()              // Приводит к &mut T (Option)

// Использование
Box<dyn Any>                        // Бокс с динамическим типом
value.downcast_ref::<String>()      // Попытка приведения
value.downcast_mut::<String>()      // Мутабельное приведение

// Заметка: работает только с типами 'static
std::any::type_name::<T>()          // Имя типа (только для отладки)
std::any::type_name_of_val(&value)  // Имя типа значения
```

---

## БИБЛИОТЕКА std::panic (ПАНИКА)

```rust
use std::panic;

// Управление паникой
panic::catch_unwind(|| { ... })     // Ловит панику (Result)
panic::resume_unwind(payload)       // Продолжает панику
panic::set_hook(|| { ... })         // Устанавливает хук
panic::take_hook()                  // Забирает хук
panic::panic_any(payload)           // Паника с payload
panic::set_always_abort()           // Всегда abort (не unwind)
panic::Location::caller()           // Место вызова (для паники)
panic::AssertUnwindSafe             // Обертка для безопасного unwrap

// Методы паники
panic::PanicInfo                    // Информация о панике
panic::PanicInfo::payload()         // Payload паники
panic::PanicInfo::message()         // Сообщение паники
panic::PanicInfo::location()        // Местоположение
```

---

## БИБЛИОТЕКА std::error (ОШИБКИ)

```rust
use std::error;

// Основной трейт
std::error::Error                   // Трейт для ошибок
error.source()                      // Исходная ошибка (Option)
error.description()                 // Описание (deprecated)
error.cause()                       // Причина (deprecated)

// Типы ошибок
std::io::Error                      // Ошибка I/O
std::fmt::Error                     // Ошибка форматирования
std::num::ParseIntError             // Ошибка парсинга чисел
std::num::ParseFloatError           // Ошибка парсинга float
std::str::Utf8Error                 // Ошибка UTF-8
std::string::FromUtf8Error          // Ошибка из Vec<u8> в String
std::path::StripPrefixError         // Ошибка удаления префикса
std::array::TryFromSliceError       // Ошибка преобразования среза

// Вспомогательные
Box<dyn Error>                      // Ошибка любого типа
Box<dyn Error + Send + Sync>        // Ошибка с безопасностью потоков
Result<T, E>                        // Стандартный Result (в прелюдии)
```

---

## БИБЛИОТЕКА std::option (OPTION)

```rust
// Option уже в прелюдии
Option<T>                           // Some(T) или None

// Методы Option
opt.is_some()                       // Это Some?
opt.is_none()                       // Это None?
opt.unwrap()                        // Разворачивает (паника если None)
opt.unwrap_or(default)              // Значение или default
opt.unwrap_or_else(f)               // Значение или вычисленное
opt.map(f)                          // Преобразует Some
opt.map_or(default, f)              // Преобразует Some или default
opt.map_or_else(default_f, f)       // Преобразует Some или вычисляет
opt.and_then(f)                     // Цепочка (возвращает Option)
opt.and(other)                      // Some если оба Some
opt.or(other)                       // Первый Some или None
opt.or_else(f)                      // Первый Some или вычисленный
opt.filter(condition)               // Оставляет Some если условие
opt.ok_or(error)                    // Превращает в Result
opt.ok_or_else(f)                   // Превращает в Result с вычислением
opt.and_then()                      // Композиция
opt.take()                          // Забирает значение (оставляет None)
opt.replace(value)                  // Заменяет значение
opt.flatten()                       // Разворачивает Option<Option<T>>
opt.transpose()                     // Option<Result> -> Result<Option>
```

---

## БИБЛИОТЕКА std::result (RESULT)

```rust
// Result уже в прелюдии
Result<T, E>                        // Ok(T) или Err(E)

// Методы Result
res.is_ok()                         // Это Ok?
res.is_err()                        // Это Err?
res.ok()                            // Option<T>
res.err()                           // Option<E>
res.unwrap()                        // Разворачивает (паника если Err)
res.unwrap_err()                    // Разворачивает ошибку (паника если Ok)
res.unwrap_or(default)              // Значение или default
res.unwrap_or_else(f)               // Значение или вычисленное
res.map(f)                          // Преобразует Ok
res.map_err(f)                      // Преобразует Err
res.and_then(f)                     // Цепочка (возвращает Result)
res.or_else(f)                      // Первый Ok или вычисленный
res.and(other)                      // Ok если оба Ok
res.or(other)                       // Первый Ok или другой
res.err()                           // Превращает в Option
res.ok()                            // Превращает в Option
res.transpose()                     // Result<Option> -> Option<Result>
res.flatten()                       // Разворачивает Result<Result<T, E>, E>
```

---

## БИБЛИОТЕКА std::rc (ОДИНОЧНАЯ ССЫЛКА)

```rust
use std::rc;

// Rc (Reference Counted) - для однопоточного использования
Rc::new(value)                      // Создает
Rc::clone(&rc)                      // Клонирует (увеличивает счетчик)
Rc::strong_count(&rc)               // Количество сильных ссылок
Rc::weak_count(&rc)                 // Количество слабых ссылок
Rc::downgrade(&rc)                  // Понижает до Weak
Rc::ptr_eq(a, b)                    // Сравнивает указатели
Rc::get_mut(&mut rc)                // Получает &mut (если ссылка одна)
Rc::try_unwrap(rc)                  // Пытается развернуть (Result)

// Weak (слабая ссылка)
Weak::new()                         // Пустая слабая ссылка
weak.upgrade()                      // Пытается получить Rc (Option)
weak.strong_count()                 // Количество сильных ссылок
weak.weak_count()                   // Количество слабых ссылок

// Для многопоточности - std::sync::Arc
Arc::new(value)                     // Атомарный счетчик (для потоков)
Arc::clone(&arc)                    // Клонирует
Arc::downgrade(&arc)                // Понижает до Weak
Arc::get_mut(&mut arc)              // &mut если одна ссылка
Arc::try_unwrap(arc)                // Пытается развернуть
```

---

## БИБЛИОТЕКА std::cell (ВНУТРЕННЯЯ ИЗМЕНЯЕМОСТЬ)

```rust
use std::cell;

// RefCell - изменяемость с проверкой во время выполнения
RefCell::new(value)                 // Создает
ref_cell.borrow()                   // Заимствует (паника если уже занято)
ref_cell.borrow_mut()               // Заимствует мутабельно (паника если занято)
ref_cell.try_borrow()               // Заимствует (Result)
ref_cell.try_borrow_mut()           // Заимствует мутабельно (Result)
ref_cell.replace(value)             // Заменяет и возвращает старое
ref_cell.into_inner()               // Разворачивает

// Cell - изменяемость для Copy типов
Cell::new(value)                    // Создает
cell.get()                          // Читает (копирует)
cell.set(value)                     // Устанавливает
cell.replace(value)                 // Заменяет и возвращает старое
cell.get_mut()                      // Получает &mut (если доступно)
cell.into_inner()                   // Разворачивает
cell.take()                         // Забирает (для Default)

// OnceCell - только одна установка
OnceCell::new()                     // Создает
once_cell.set(value)                // Устанавливает (Result)
once_cell.get()                     // Получает (Option)
once_cell.get_or_init(|| { ... })   // Получает или инициализирует
once_cell.get_mut()                 // Получает &mut (если не установлено)
once_cell.into_inner()              // Разворачивает

// LazyCell - ленивая инициализация
LazyCell::new(|| { ... })           // Создает с инициализатором
lazy_cell.get()                     // Получает (инициализирует при первом вызове)
lazy_cell.force()                   // Принудительная инициализация
```

---

## БИБЛИОТЕКА std::fmt (УЖЕ БЫЛА, ДОПОЛНЕНИЕ)

```rust
// Форматирование чисел
format!("{:b}", 42)                 // 101010 (двоичное)
format!("{:o}", 42)                 // 52 (восьмеричное)
format!("{:x}", 42)                 // 2a (шестнадцатеричное)
format!("{:X}", 42)                 // 2A (шестнадцатеричное верхний)
format!("{:e}", 42.0)               // 4.2e1 (экспонента)
format!("{:E}", 42.0)               // 4.2E1 (экспонента верхний)
format!("{:p}", &42)                // 0x7ffc... (указатель)
format!("{:?}", value)              // Debug
format!("{:#?}", value)             // Pretty Debug
format!("{}", value)                // Display
format!("{:.*}", 3, 1.2345)         // Точность: 1.234
format!("{:10}", "hello")           // Ширина: "hello     "
format!("{:<10}", "hello")          // Выравнивание влево
format!("{:>10}", "hello")          // Выравнивание вправо
format!("{:^10}", "hello")          // Выравнивание по центру
format!("{:#}", value)              // Альтернативный формат
format!("{:+}", 42)                 // +42
format!("{:0>10}", 42)              // 0000000042 (дополнение нулями)
```

---

## БИБЛИОТЕКА std::char (СИМВОЛЫ)

```rust
use std::char;

// Основные функции
char::from_u32(code)                // Из Unicode кода (Option)
char::from_u32_unchecked(code)      // Без проверки (unsafe)
char::from_digit(digit, radix)      // Из цифры (Option)
char::to_digit(ch, radix)           // В цифру (Option)

// Методы char
ch.is_alphabetic()                  // Буква?
ch.is_alphanumeric()                // Буква или цифра?
ch.is_whitespace()                  // Пробел?
ch.is_control()                     // Управляющий?
ch.is_numeric()                     // Цифра?
ch.is_lowercase()                   // Нижний регистр?
ch.is_uppercase()                   // Верхний регистр?
ch.is_ascii()                       // ASCII?
ch.is_ascii_alphabetic()            // ASCII буква?
ch.is_ascii_alphanumeric()          // ASCII буква или цифра?
ch.is_ascii_whitespace()            // ASCII пробел?
ch.is_ascii_control()               // ASCII управляющий?
ch.is_ascii_hexdigit()              // Шестнадцатеричная цифра?
ch.to_ascii_lowercase()             // В ASCII нижний
ch.to_ascii_uppercase()             // В ASCII верхний
ch.to_lowercase()                   // В нижний регистр (итератор)
ch.to_uppercase()                   // В верхний регистр (итератор)
ch.len_utf8()                       // Длина в байтах UTF-8
ch.len_utf16()                      // Длина в байтах UTF-16
ch.encode_utf8(buf)                 // Кодирует в UTF-8
ch.encode_utf16(buf)                // Кодирует в UTF-16
ch.escape_unicode()                 // Экранирует Unicode
ch.escape_default()                 // Экранирует
```

---

## БИБЛИОТЕКА std::ascii (ASCII)

```rust
use std::ascii;

// Основные функции
ascii::escape_default(byte)         // Экранирует байт
ascii::AsciiExt                       // Трейт для работы с ASCII

// Методы для строк
"Hello".is_ascii()                  // Все символы ASCII?
"Hello".to_ascii_lowercase()        // В ASCII нижний
"Hello".to_ascii_uppercase()        // В ASCII верхний
"Hello".make_ascii_lowercase()      // Мутабельный в нижний
"Hello".make_ascii_uppercase()      // Мутабельный в верхний
"Hello".escape_ascii()              // Экранирует ASCII
```

---

## БИБЛИОТЕКА std::num (ЧИСЛА)

```rust
use std::num;

// Типы чисел (уже в прелюдии)
i8, i16, i32, i64, i128, isize
u8, u16, u32, u64, u128, usize
f32, f64

// Методы чисел
num.abs()                           // Модуль
num.abs_diff(other)                 // Абсолютная разница
num.signum()                        // Знак (-1, 0, 1)
num.is_positive()                   // Положительное?
num.is_negative()                   // Отрицательное?
num.is_zero()                       // Ноль?
num.pow(exp)                        // Возведение в степень
num.checked_pow(exp)                // Безопасное возведение
num.wrapping_pow(exp)               // С переполнением
num.overflowing_pow(exp)            // С индикацией переполнения
num.saturating_pow(exp)             // Насыщение
num.checked_add(other)              // Сложение с проверкой
num.checked_sub(other)              // Вычитание с проверкой
num.checked_mul(other)              // Умножение с проверкой
num.checked_div(other)              // Деление с проверкой
num.checked_rem(other)              // Остаток с проверкой
num.checked_neg()                   // Отрицание с проверкой
num.checked_shl(n)                  // Сдвиг влево с проверкой
num.checked_shr(n)                  // Сдвиг вправо с проверкой
num.wrapping_add(other)             // Сложение с переполнением
num.wrapping_sub(other)             // Вычитание с переполнением
num.wrapping_mul(other)             // Умножение с переполнением
num.wrapping_div(other)             // Деление с переполнением
num.wrapping_rem(other)             // Остаток с переполнением
num.saturating_add(other)           // Сложение с насыщением
num.saturating_sub(other)           // Вычитание с насыщением
num.saturating_mul(other)           // Умножение с насыщением
num.overflowing_add(other)          // Сложение с индикацией
num.overflowing_sub(other)          // Вычитание с индикацией
num.overflowing_mul(other)          // Умножение с индикацией
num.overflowing_div(other)          // Деление с индикацией
num.overflowing_rem(other)          // Остаток с индикацией
num.rotate_left(n)                  // Циклический сдвиг влево
num.rotate_right(n)                 // Циклический сдвиг вправо
num.swap_bytes()                    // Меняет порядок байт
num.reverse_bits()                  // Переворачивает биты
num.count_ones()                    // Количество единичных бит
num.count_zeros()                   // Количество нулевых бит
num.leading_zeros()                 // Ведущие нули
num.trailing_zeros()                // Трейлинг нули
num.next_power_of_two()             // Следующая степень двойки
num.checked_next_power_of_two()     // С проверкой
num.is_power_of_two()               // Это степень двойки?
num.to_be_bytes()                   // В байты (big-endian)
num.to_le_bytes()                   // В байты (little-endian)
num.to_ne_bytes()                   // В байты (native)
num.from_be_bytes(bytes)            // Из байт (big-endian)
num.from_le_bytes(bytes)            // Из байт (little-endian)
num.from_ne_bytes(bytes)            // Из байт (native)

// Функции для float
f32::INFINITY                       // Бесконечность
f32::NEG_INFINITY                   // Минус бесконечность
f32::NAN                            // Не число
f32::PI                             // π
f32::TAU                            // 2π
f32::E                              // e
f32::FRAC_1_PI                      // 1/π
f32::FRAC_1_SQRT_2                  // 1/√2
f32::SQRT_2                         // √2
f32::MAX_10_EXP                     // Максимальный экспонент
f32::MIN_10_EXP                     // Минимальный экспонент
f32::MIN                            // Минимальное значение
f32::MAX                            // Максимальное значение
f32::MIN_POSITIVE                   // Минимальное положительное
f32::EPSILON                        // Машинный эпсилон

f.is_nan()                          // Это NaN?
f.is_infinite()                     // Бесконечность?
f.is_finite()                       // Конечное?
f.is_normal()                       // Нормальное?
f.is_sign_positive()                // Положительное?
f.is_sign_negative()                // Отрицательное?
f.is_subnormal()                    // Денормализованное?
f.classify()                        // Классификация (Enum)
f.abs()                             // Модуль
f.signum()                          // Знак
f.recip()                           // Обратное
f.powf(exp)                         // Возведение в степень (float)
f.powf(exp)                         // Возведение в степень (integer)
f.sqrt()                            // Квадратный корень
f.exp()                             // Экспонента
f.exp2()                            // 2^x
f.ln()                              // Натуральный логарифм
f.log2()                            // Логарифм по основанию 2
f.log10()                           // Логарифм по основанию 10
f.log(base)                         // Логарифм по основанию
f.cbrt()                            // Кубический корень
f.hypot(other)                      // Гипотенуза
f.sin()                             // Синус
f.cos()                             // Косинус
f.tan()                             // Тангенс
f.asin()                            // Арксинус
f.acos()                            // Арккосинус
f.atan()                            // Арктангенс
f.atan2(other)                      // Арктангенс двух переменных
f.sin_cos()                         // Синус и косинус
f.exp_m1()                          // e^x - 1
f.ln_1p()                           // ln(1+x)
f.sinh()                            // Гиперболический синус
f.cosh()                            // Гиперболический косинус
f.tanh()                            // Гиперболический тангенс
f.asinh()                           // Гиперболический арксинус
f.acosh()                           // Гиперболический арккосинус
f.atanh()                           // Гиперболический арктангенс
f.mul_add(a, b)                     // (f * a) + b
f.fma(a, b)                         // (f * a) + b (точное)
f.clamp(min, max)                   // Ограничивает
f.round()                           // Округление
f.floor()                           // Вниз
f.ceil()                            // Вверх
f.trunc()                           // Отбрасывает дробную часть
f.fract()                           // Дробная часть
f.to_degrees()                      // Радианы -> градусы
f.to_radians()                      // Градусы -> радианы
f.to_bits()                         // Битное представление
f.from_bits(bits)                   // Из битного представления
f.to_be_bytes()                     // В байты (big-endian)
f.to_le_bytes()                     // В байты (little-endian)
f.to_ne_bytes()                     // В байты (native)
f.from_be_bytes(bytes)              // Из байт (big-endian)
f.from_le_bytes(bytes)              // Из байт (little-endian)
f.from_ne_bytes(bytes)              // Из байт (native)
```

---

## БИБЛИОТЕКА std::cmp (СРАВНЕНИЕ)

```rust
use std::cmp;

// Трейты (уже в прелюдии)
PartialEq                           // Частичное равенство
Eq                                  // Полное равенство
PartialOrd                          // Частичный порядок
Ord                                 // Полный порядок

// Константы
cmp::min(a, b)                      // Минимум
cmp::max(a, b)                      // Максимум
cmp::clamp(val, min, max)           // Ограничивает
cmp::Ordering::Less                 // Меньше
cmp::Ordering::Equal                // Равно
cmp::Ordering::Greater              // Больше

// Reverse
Reverse(value)                      // Инвертирует порядок

// Методы
a.cmp(&b)                           // Сравнивает (Ordering)
a.partial_cmp(&b)                   // Частичное сравнение
a.eq(&b)                            // Равны?
a.ne(&b)                            // Не равны?
a.lt(&b)                            // <
a.le(&b)                            // <=
a.gt(&b)                            // >
a.ge(&b)                            // >=
a.min(b)                            // Минимум из двух
a.max(b)                            // Максимум из двух
a.clamp(min, max)                   // Ограничивает

// Для упорядочивания
cmp::Ord::cmp( a, b)                // Сравнивает
cmp::Ord::max( a, b)                // Максимум
cmp::Ord::min( a, b)                // Минимум
cmp::Ord::clamp( a, min, max)       // Ограничивает
```

---

## БИБЛИОТЕКА std::default (ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ)

```rust
use std::default;

// Трейт Default (в прелюдии)
Default                            // Трейт для значения по умолчанию
default()                          // Получает значение по умолчанию

// Реализован для:
bool => false
char => '\0'
числа => 0
String => ""
Vec => []
Option => None
HashMap, HashSet, BTreeMap, BTreeSet => пустые
Box, Rc, Arc => (для типов с Default)
```

---

## БИБЛИОТЕКА std::hash (ХЕШИРОВАНИЕ)

```rust
use std::hash;

// Трейты
Hash                                // Может быть хеширован
Hasher                              // Хеш-функция
BuildHasher                         // Строитель хеш-функции

// Основные функции
hash.hash(&mut hasher)              // Хеширует
hasher.write(data)                  // Добавляет данные
hasher.write_u8(value)              // Добавляет u8
hasher.write_u16(value)             // Добавляет u16
hasher.write_u32(value)             // Добавляет u32
hasher.write_u64(value)             // Добавляет u64
hasher.write_u128(value)            // Добавляет u128
hasher.write_usize(value)           // Добавляет usize
hasher.write_i8(value)              // Добавляет i8
hasher.write_i16(value)             // Добавляет i16
hasher.write_i32(value)             // Добавляет i32
hasher.write_i64(value)             // Добавляет i64
hasher.write_i128(value)            // Добавляет i128
hasher.write_isize(value)           // Добавляет isize
hasher.write_str(value)             // Добавляет строку
hasher.finish()                     // Завершает (u64)

// Стандартные хешеры
std::collections::hash_map::DefaultHasher // Стандартный (SipHash)
```

---

## БИБЛИОТЕКА std::marker (МАРКЕРЫ)

```rust
use std::marker;

// Маркерные трейты (автоматически реализуются)
Send                                // Может быть отправлен в другой поток
Sync                                // Может быть разделен между потоками
Copy                                // Может быть скопирован побайтово
Sized                               // Имеет известный размер
Unpin                               // Может быть выпинан (для Pin)
Unsize<T>                           // Может быть уменьшен до T

// Использование
PhantomData<T>                      // Фиктивный тип (для маркеров)
PhantomPinned                       // Для Pin (нельзя перемещать)
```

---

## БИБЛИОТЕКА std::task и std::future (АСИНХРОННОСТЬ)

```rust
use std::task;
use std::future;

// Future
Future                              // Трейт для асинхронных вычислений
future.await                        // Ожидает (в async fn)

// Task
Context<'a>                         // Контекст выполнения
Waker                              // Будитель (для пробуждения)
Wake                               // Трейт для Waker

// Poll
Poll<T>                            // Poll::Ready(T) или Poll::Pending

// Готовность
task::ready()                      // Из функции возвращает Ready
task::pending()                    // Из функции возвращает Pending

// Pin (закрепление)
Pin<Ptr>                           // Закрепленный указатель
pin.pin()                          // Закрепляет
pin.as_mut()                       // Как &mut (для закрепленного)
pin.as_ref()                       // Как & (для закрепленного)

// Для создания Waker
task::Waker::from(arc)             // Из Arc<dyn Wake>
task::Wake::wake(self: Arc<Self>)  // Пробуждает
task::Wake::wake_by_ref(self: &Arc<Self>) // Пробуждает по ссылке
```

---

## БИБЛИОТЕКА std::alloc (АЛЛОКАЦИЯ)

```rust
use std::alloc;

// Глобальный аллокатор
std::alloc::alloc(Layout)           // Выделяет память (unsafe)
std::alloc::dealloc(ptr, Layout)    // Освобождает (unsafe)
std::alloc::realloc(ptr, Layout, new_size) // Перевыделяет (unsafe)
std::alloc::alloc_zeroed(Layout)    // Выделяет обнуленную (unsafe)

// Layout
Layout::new::<T>()                  // Для типа T
Layout::from_size_align(size, align) // По размеру и выравниванию
Layout::from_ptr_align(ptr, align)  // По указателю (unsafe)
Layout::array<T>(n)                 // Для массива [T; n]
layout.size()                       // Размер
layout.align()                      // Выравнивание
layout.pad_to_align()               // Дополняет до выравнивания
layout.repeat(n)                    // Повторяет n раз
layout.extend(other)                // Объединяет с другим

// Аллокатор трейт
Global                              // Глобальный аллокатор
Allocator                          // Трейт для аллокаторов
allocator.allocate(layout)         // Выделяет
allocator.deallocate(ptr, layout)  // Освобождает
allocator.shrink(ptr, old, new)    // Уменьшает
allocator.grow(ptr, old, new)      // Увеличивает

// Системный аллокатор
std::alloc::System                  // Системный аллокатор
```

---

## БИБЛИОТЕКА std::hint (ПОДСКАЗКИ КОМПИЛЯТОРУ)

```rust
use std::hint;

// Основные функции
hint::spin_loop()                   // Подсказка процессору (ожидание)
hint::black_box(value)              // Запрещает оптимизацию
hint::unreachable_unchecked()       // Недостижимо (UB если достигнуто)
hint::must_use(value)               // Результат должен быть использован
hint::maybe_unused()                // Подавляет warning о неиспользовании
```

---

## БИБЛИОТЕКА std::intrinsics (ВСТРОЕННЫЕ ИНТРИНСИКИ)

```rust
// Нестабильные, доступны только в nightly
use std::intrinsics;

// Арифметика (проверяемая)
intrinsics::add_with_overflow()
intrinsics::sub_with_overflow()
intrinsics::mul_with_overflow()

// Преобразования
intrinsics::transmute<T, U>()
intrinsics::size_of<T>()
intrinsics::align_of<T>()
intrinsics::offset<T>()

// Управление памятью
intrinsics::copy<T>()
intrinsics::copy_nonoverlapping<T>()
intrinsics::write_bytes<T>()

// Управление потоком
intrinsics::atomic_fence()
intrinsics::abort()
intrinsics::breakpoint()
intrinsics::unreachable()

// Информация
intrinsics::type_name<T>()
intrinsics::needs_drop<T>()
intrinsics::is_likely(cond)
intrinsics::is_unlikely(cond)

// Atomic операции (низкий уровень)
intrinsics::atomic_load()
intrinsics::atomic_store()
intrinsics::atomic_cxchg()
intrinsics::atomic_xchg()
intrinsics::atomic_add()
intrinsics::atomic_sub()
intrinsics::atomic_and()
intrinsics::atomic_or()
intrinsics::atomic_xor()
intrinsics::atomic_max()
intrinsics::atomic_min()
intrinsics::atomic_umin()
intrinsics::atomic_umax()

// Floating point
intrinsics::fabs()
intrinsics::fabsf()
intrinsics::fabsf32()
intrinsics::fabsf64()
intrinsics::sqrtf32()
intrinsics::sqrtf64()
intrinsics::powif32()
intrinsics::powif64()
intrinsics::sinf32()
intrinsics::cosf32()
intrinsics::tanf32()
```

---

## БИБЛИОТЕКА std::arch (АРХИТЕКТУРНО-ЗАВИСИМЫЕ ИНСТРУКЦИИ)

```rust
// x86/x86_64
#[cfg(target_arch = "x86")]
#[cfg(target_arch = "x86_64")]

// SIMD инструкции (для CPU с поддержкой)
std::arch::x86::_mm_add_ps()        // SSE
std::arch::x86::_mm256_add_ps()     // AVX
std::arch::x86::_mm512_add_ps()     // AVX-512

// ARM
#[cfg(target_arch = "arm")]
std::arch::arm::vaddq_f32()         // NEON

// WASM
#[cfg(target_arch = "wasm32")]
std::arch::wasm32::v128_load()      // SIMD

// Проверка возможностей
std::arch::is_x86_feature_detected!("avx") // Проверяет наличие AVX
std::arch::is_arm_feature_detected!("neon")
std::arch::is_wasm_feature_detected!("simd128")
```

---

## ВАЖНОЕ ПРИМЕЧАНИЕ

В отличие от Lua, Rust **не** включает все эти библиотеки автоматически. Для использования любой из них нужно явно импортировать (`use`) или использовать полный путь (`std::io::stdin()`). **Прелюдия** (`std::prelude`) автоматически импортирует только самые базовые типы:

- `std::marker::{Copy, Send, Sync, Unpin}`
- `std::ops::{Drop, Fn, FnMut, FnOnce}`
- `std::mem::drop`
- `std::boxed::Box`
- `std::convert::{AsRef, AsMut, From, Into}`
- `std::string::String`
- `std::vec::Vec`
- `std::option::Option::{self, Some, None}`
- `std::result::Result::{self, Ok, Err}`
- `std::collections::TryReserveError`

Все остальное нужно импортировать вручную, что является философией Rust: **явность важнее неявности**.

---

Этот список покрывает **все** стабильные библиотеки и функции стандартной библиотеки Rust. Он не включает внешние крейты, которые вы можете добавить в `Cargo.toml`.


