**Установка Python 3.9.17 на RED OS 7 (Oracle9) (основанную на RHEL/CentOS 7):**
<br/> читай подсказку [how-can-i-install-python-3-9-on-a-linux-ubuntu-terminal](https://stackoverflow.com/questions/60824700/how-can-i-install-python-3-9-on-a-linux-ubuntu-terminal)

## 1. Установка зависимостей

```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
```

## 2. Скачивание исходного кода Python 3.9.17

```bash
cd /usr/src
curl https://www.python.org/ftp/python/3.9.17/
sudo wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz
sudo tar xzf Python-3.9.17.tgz
cd Python-3.9.17
```

## 3. Конфигурация и компиляция

```bash
sudo ./configure --enable-optimizations --enable-shared --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions
sudo make -j$(nproc)

# Для систем с /proc/cpuinfo
sudo make -j$(grep -c processor /proc/cpuinfo)

# Или указать фиксированное количество (например, 4 потока)
sudo make -j4
```

## 4. Установка

```bash
sudo make altinstall
```

## 5. Настройка библиотек

```bash
# Добавление пути к библиотекам
echo '/usr/local/lib' | sudo tee /etc/ld.so.conf.d/python3.9.conf
sudo ldconfig

# Проверить, что библиотеки найдены
ldconfig -p | grep libpython3.9

# Проверить, откуда Python грузит библиотеки
ldd /usr/local/bin/python3.9 | grep libpython  # Важно: указывайте полный путь!

# Проверить, что Python запускается без ошибок
python3.9 -c 'print("Библиотеки работают!")'  # Используйте одинарные кавычки снаружи
```

## 6. Проверка установки

```bash
python3.9 --version
which python3.9
```

## 7. Создание альтернативной ссылки (опционально)

```bash
# Регистрируем нашу версию Python в системе альтернатив
sudo alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1

# Проверяем и выбираем версию по умолчанию
sudo alternatives --config python3

# Смотрим статус
alternatives --display python3

# Проверяем, какой именно Python теперь используется
# Важно! В разных дистрибутивах команда 'which' может вести себя по-разному:
# - В некоторых показывает только первый найденный в PATH
# - В других (с алиасом 'type -all') показывает все вхождения
# Вот несколько способов проверки:

# Способ 1: command -v (наиболее надежный)
command -v python3.9

# Способ 2: type без алиаса
\type python3.9

# Способ 3: readlink для проверки симлинков
readlink -f $(command -v python3.9)

# Способ 4: проверить всю цепочку симлинков
ls -la /usr/bin/python3
ls -la /etc/alternatives/python3
```

### Важно понимать про механизм alternatives:

После настройки alternatives может возникнуть путаница с выводами команд:
- `command -v python3.9` может показывать `/usr/bin/python3.9`
- `python3.9 --version` показывает `Python 3.9.17`

**Это нормально!** Так происходит потому что:
1. `/usr/bin/python3.9` становится симлинком на `/etc/alternatives/python3`
2. `/etc/alternatives/python3` указывает на `/usr/local/bin/python3.9`
3. Реально исполняется ваша версия 3.9.17

## 8. Установка pip для Python 3.9

```bash
python3.9 -m ensurepip --upgrade
python3.9 -m pip install --upgrade pip
```

## 🔍 Как отличить системный Python от скомпилированного

После установки у вас в системе будет два Python 3.9:
- **Системный Python** (из пакетного менеджера)
- **Ваш скомпилированный Python** (из исходников)

Вот несколько способов их различить:

### Способ 1: По размеру исполняемого файла

```bash
# Ваш скомпилированный Python обычно БОЛЬШЕ по размеру
ls -la /usr/local/bin/python3.9
# Пример вывода: -rwxr-xr-x. 1 root root 19320 мар 12 15:58 /usr/local/bin/python3.9

# Системный Python обычно МЕНЬШЕ
ls -la /usr/bin/python3.9  
# Пример вывода: -rwxr-xr-x. 1 root root 15448 мар 10 15:09 /usr/bin/python3.9
```

**Объяснение:** Скомпилированный из исходников Python включает больше встроенных модулей и отладочной информации, поэтому его размер больше.

### Способ 2: По принадлежности к пакетам

```bash
# Проверяем, из какого пакета установлен файл
rpm -qf /usr/bin/python3.9
# Должно показать: python3-3.9.25-3.0.1.el9_7.1.x86_64 (это системный)

rpm -qf /usr/local/bin/python3.9  
# Должно показать: файл /usr/local/bin/python3.9 не принадлежит ни одному из пакетов
# (это ваш скомпилированный Python)
```

**Объяснение:** Пакетный менеджер RPM знает только о файлах, установленных из официальных пакетов. Файлы в `/usr/local/` обычно не отслеживаются RPM.

### Способ 3: По наличию системных модулей

```bash
# Системный Python должен иметь модуль dnf (для работы пакетного менеджера)
/usr/bin/python3.9 -c 'import dnf; print("Системный Python с dnf")' 2>/dev/null && echo "✅ Системный" || echo "❌ Не системный"

# Ваш Python может не иметь dnf, если вы не настроили пути
/usr/local/bin/python3.9 -c 'import dnf; print("Ваш Python с dnf")' 2>/dev/null && echo "✅ Видит dnf" || echo "❌ Не видит dnf"
```

**Объяснение:** Системный Python изначально настроен на работу с системными модулями. Ваш Python может их видеть только после специальной настройки (через .pth файлы).

### Способ 4: По путям поиска модулей

```bash
# Посмотрим, где Python ищет модули
echo "=== Системный Python ==="
/usr/bin/python3.9 -c 'import sys; print("\n".join([p for p in sys.path if "usr" in p]))'

echo -e "\n=== Ваш Python ==="
/usr/local/bin/python3.9 -c 'import sys; print("\n".join([p for p in sys.path if "usr" in p]))'
```

**Объяснение:** Системный Python по умолчанию ищет модули в `/usr/lib/...`, а ваш - в `/usr/local/lib/...`. После настройки .pth файлов они могут стать похожими.

### Способ 5: Создание метки-идентификатора

```bash
# Создайте файл-маркер для вашего Python
echo "Это скомпилированный Python 3.9.17" > /usr/local/lib/python3.9/compiled-python.txt

# Теперь можно легко проверить:
/usr/local/bin/python3.9 -c 'import os; print(open("/usr/local/lib/python3.9/compiled-python.txt").read())'
# Вывод: Это скомпилированный Python 3.9.17

# Системный Python не сможет прочитать этот файл (если только вы не настроили общие пути)
/usr/bin/python3.9 -c 'import os; print(open("/usr/local/lib/python3.9/compiled-python.txt").read())' 2>/dev/null || echo "Это системный Python"
```

### Способ 6: По версии пакета (если они разные)

```bash
# Если версии отличаются, это самый простой способ
/usr/local/bin/python3.9 --version  # Ваша версия (например, 3.9.17)
/usr/bin/python3.9 --version        # Системная версия (может быть другой)
```

### Сводная таблица отличий:

| Характеристика | Системный Python | Ваш Python |
|----------------|------------------|------------|
| **Путь** | `/usr/bin/python3.9` | `/usr/local/bin/python3.9` |
| **Размер файла** | Меньше (~15 KB) | Больше (~19 KB) |
| **Принадлежит RPM** | Да | Нет |
| **Модуль dnf** | Есть по умолчанию | Только после настройки |
| **Пути поиска** | `/usr/lib/...` | `/usr/local/lib/...` |

## ⚠️ Важное предупреждение: Не сломайте DNF!

При установке Python из исходного кода и настройке через alternatives **НИКОГДА НЕ УДАЛЯЙТЕ И НЕ ЗАМЕНЯЙТЕ** системный файл `/usr/bin/python3.9`! Это может привести к поломке пакетного менеджера DNF/YUM.

### Что происходит при поломке DNF:

Если вы случайно заменили системный Python, при попытке использовать DNF вы получите ошибку:
```
Traceback (most recent call last):
  File "/usr/bin/dnf", line 61, in <module>
    from dnf.cli import main
ModuleNotFoundError: No module named 'dnf'
```

### Почему это происходит:

- **Системный Python** ищет модули в `/usr/lib/python3.9/site-packages/`
- **Ваш Python из исходников** ищет модули в `/usr/local/lib/python3.9/site-packages/`
- Модули DNF установлены в системной директории, но ваш Python их не видит

### Как восстановить DNF (если сломалось):

#### Шаг 1: Скачайте необходимые RPM-пакеты

```bash
cd /tmp
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-3.9.25-3.0.1.el9_7.1.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-libs-3.9.25-3.0.1.el9_7.1.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-dnf-4.14.0-31.0.1.el9.noarch.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-rpm-4.16.1.3-39.el9.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-gpg-1.15.1-6.el9.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-librepo-1.14.5-3.el9.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-libcomps-0.1.18-1.el9.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-hawkey-0.69.0-17.0.1.el9_7.x86_64.rpm
wget http://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/python3-libdnf-0.69.0-17.0.1.el9_7.x86_64.rpm
```

#### Шаг 2: Переустановите пакеты в правильном порядке

```bash
# Удалите конфликтующие пакеты
rpm -e --nodeps python3-dnf python3-hawkey python3-libdnf python3-libcomps python3-librepo python3-gpg python3-rpm

# Установите заново в правильной последовательности
rpm -Uvh python3-libcomps-*.rpm
rpm -Uvh python3-librepo-*.rpm
rpm -Uvh python3-gpg-*.rpm
rpm -Uvh python3-rpm-*.rpm
rpm -Uvh python3-libdnf-*.rpm
rpm -Uvh python3-hawkey-*.rpm
rpm -Uvh python3-dnf-*.rpm
```

#### Шаг 3: Настройте пути поиска модулей Python

Создайте файл `.pth` с путями к системным модулям:

```bash
cat > /usr/local/lib/python3.9/site-packages/system-packages.pth << 'EOF'
/usr/lib/python3.9/site-packages
/usr/lib64/python3.9/site-packages
/usr/lib/python3.9/site-packages/libdnf
/usr/lib64/python3.9/site-packages/libdnf
EOF
```

Этот файл заставит Python искать модули также и в системных директориях.

#### Шаг 4: Исправьте шебанги в системных утилитах

```bash
# Укажите правильный интерпретатор для DNF (platform-python)
sed -i '1s|^#!.*|#!/usr/libexec/platform-python|' /usr/bin/dnf
sed -i '1s|^#!.*|#!/usr/libexec/platform-python|' /usr/bin/dnf-3
sed -i '1s|^#!.*|#!/usr/libexec/platform-python|' /usr/bin/yum
sed -i '1s|^#!.*|#!/usr/libexec/platform-python|' /usr/bin/yumdownloader
```

#### Шаг 5: Проверьте восстановление

```bash
# Проверьте импорт модулей
/usr/libexec/platform-python -c 'import libdnf; print("libdnf OK")'
/usr/libexec/platform-python -c 'import dnf; print("dnf OK")'

# Проверьте работу DNF
dnf --version
dnf makecache
```

### Почему это работает:

- **platform-python** - это специальный интерпретатор в Oracle Linux/RED OS, который используется системными утилитами
- **.pth файлы** - механизм Python для добавления дополнительных путей поиска модулей
- Системные модули DNF находятся в `/usr/lib/python3.9/site-packages/`, и мы явно указали Python искать там

## Важные замечания:

1. **`make altinstall`** вместо `make install` - чтобы не перезаписывать системный Python
2. **`--enable-shared`** - для создания shared библиотек
3. **`--enable-optimizations`** - для оптимизации производительности
4. RED OS основана на RHEL 7, поэтому желательно использовать `yum` вместо `dnf`
5. **Никогда не удаляйте и не заменяйте `/usr/bin/python3.9`** - это системный файл!
6. Проверьте доступное место на диске перед компиляцией (требуется ~2-3GB)

После установки у вас будет:
- Python 3.9.17 доступный как `python3.9`
- pip для Python 3.9
- Совместимость с существующими системными пакетами (если следовать инструкциям выше)

```
┌─ root
├─ redos7
└─ /usr/src/Python-3.9.17 # python3.9 --version; python3.8 --version; which python3.9; which python3.8; pip3.8 --version; pip3.9 --version
Python 3.9.17
Python 3.8.20
python3.9 является /usr/local/bin/python3.9
python3.8 является /usr/bin/python3.8
pip 25.0.1 from /usr/local/lib/python3.8/site-packages/pip (python 3.8)
pip 25.2 from /usr/local/lib/python3.9/site-packages/pip (python 3.9)
┌─ root
├─ redos7
└─ /usr/src/Python-3.9.17 # which pip3.8
pip3.8 является /usr/local/bin/pip3.8
pip3.8 является /usr/bin/pip3.8
┌─ root
├─ redos7
└─ /usr/src/Python-3.9.17 # which pip3.9
pip3.9 является /usr/local/bin/pip3.9
```

https://mirror.yandex.ru/redos/7.3/x86_64/os/

---------------

В Red OS 7 требуется настроить Ansible для использования Python 3.9.17 вместо Python 3.8. 
<br/> Вот несколько способов:

## Способ 1: Настройка через ansible.cfg

Создайте или отредактируйте файл `/etc/ansible/ansible.cfg`:

```ini
[defaults]
interpreter_python = /usr/local/bin/python3.9
```

## Способ 2: Установка Python 3.9 как системного по умолчанию (безопасный способ)

```bash
# Создайте символическую ссылку через alternatives (НЕ заменяйте /usr/bin/python3.9!)
sudo alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 100
sudo alternatives --install /usr/bin/python3 python3 /usr/libexec/platform-python 90
sudo alternatives --config python3

# После настройки проверьте
python3 --version  # Должно показывать 3.9.17
/usr/bin/python3.9 --version  # Должно показывать системную версию (для DNF)
```

## Способ 3: Настройка для конкретного инвентаря

В инвентарном файле укажите Python интерпретатор:

```ini
[all:vars]
ansible_python_interpreter=/usr/local/bin/python3.9  # Важно: используйте полный путь!
```

## Способ 4: Переустановка Ansible с Python 3.9

Если предыдущие способы не работают, переустановите Ansible:

```bash
# Удалите текущую версию
sudo yum remove ansible

# Установите pip для Python 3.9
python3.9 -m pip install --upgrade pip

# Установите Ansible через pip для Python 3.9
python3.9 -m pip install ansible

# Проверьте версию
python3.9 -m ansible --version
```

## Способ 5: Создание виртуального окружения

```bash
# Создайте виртуальное окружение с Python 3.9
python3.9 -m venv ~/ansible-venv

# Активируйте окружение
source ~/ansible-venv/bin/activate

# Установите Ansible
pip install ansible

# Добавьте алиас в .bashrc
echo "alias ansible='~/ansible-venv/bin/ansible'" >> ~/.bashrc
source ~/.bashrc
```

## Проверка

После настройки проверьте:

```bash
# Явное указание интерпретатора
ansible localhost -m ping -e 'ansible_python_interpreter=/usr/local/bin/python3.9'

# Или если настроили через alternatives/cfg
ansible localhost -m ping

# Проверка какой Python использует Ansible
ansible --version | grep "python version"
```

### Важное примечание по путям:

При настройке Ansible обращайте внимание на пути:
- **`/usr/local/bin/python3.9`** - ваша установленная версия (3.9.17)
- **`/usr/bin/python3.9`** - системная версия (не трогать!)
- **`/usr/libexec/platform-python`** - специальный системный интерпретатор для DNF

Для надежности всегда указывайте полный путь `/usr/local/bin/python3.9` в конфигурациях Ansible и никогда не изменяйте системный `/usr/bin/python3.9`.
