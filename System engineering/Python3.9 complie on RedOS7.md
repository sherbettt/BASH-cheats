Установка Python 3.9.23 на RED OS 7 (основанную на RHEL/CentOS 7):
<br/> читай подсказку [how-can-i-install-python-3-9-on-a-linux-ubuntu-terminal](https://stackoverflow.com/questions/60824700/how-can-i-install-python-3-9-on-a-linux-ubuntu-terminal)

## 1. Установка зависимостей

```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
```

## 2. Скачивание исходного кода Python 3.9.23

```bash
cd /usr/src
curl https://www.python.org/ftp/python/3.9.23/
sudo wget https://www.python.org/ftp/python/3.9.23/Python-3.9.23.tgz
sudo tar xzf Python-3.9.23.tgz
cd Python-3.9.23
```

## 3. Конфигурация и компиляция

```bash
sudo ./configure --enable-optimizations --enable-shared --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions
sudo make -j$(nproc)
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
```

## 6. Проверка установки

```bash
python3.9 --version
which python3.9
```

## 7. Создание альтернативной ссылки (опционально)

```bash
sudo alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1
sudo alternatives --config python3
```

## 8. Установка pip для Python 3.9

```bash
python3.9 -m ensurepip --upgrade
python3.9 -m pip install --upgrade pip
```

## Важные замечания:

1. **`make altinstall`** вместо `make install` - чтобы не перезаписывать системный Python
2. **`--enable-shared`** - для создания shared библиотек
3. **`--enable-optimizations`** - для оптимизации производительности
4. RED OS основана на RHEL 7, поэтому используйте `dnf` вместо `dnf`
5. Проверьте доступное место на диске перед компиляцией (требуется ~2-3GB)

После установки у вас будет:
- Python 3.9.23 доступный как `python3.9`
- pip для Python 3.9
- Совместимость с существующими системными пакетами
