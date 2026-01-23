## **Компиляция из исходниколв Python 3.8 на Astra Linux**


### 1. **Подготовка системы**
```bash
apt-get update -y
apt-get dist-upgrade -y
apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev wget
```

### 2. **Скачивание Python 3.8**
```bash
cd /tmp
wget https://www.python.org/ftp/python/3.8.18/Python-3.8.18.tgz
tar -xf Python-3.8.18.tgz
cd Python-3.8.18
```

### 3. **Компиляция Python 3.8**
```bash
./configure --enable-optimizations --prefix=/usr/local --with-ensurepip=install
make -j$(nproc)
make altinstall
```

### 4. **Проверка установки**
```bash
/usr/local/bin/python3.8 --version
/usr/local/bin/pip3.8 --version
```

### 5. **Создание симлинков**
```bash
# Создаем симлинк python3 -> python3.8
ln -sf /usr/local/bin/python3.8 /usr/bin/python3

# Создаем симлинк pip3 -> pip3.8  
ln -sf /usr/local/bin/pip3.8 /usr/bin/pip3

# Проверяем симлинки
python3 --version
pip3 --version
```

### 6. **Обновление pip**
```bash
python3 -m ensurepip
python3 -m pip install --upgrade pip
```

### 7. **Установка python3-apt**
```bash
apt-get install -y python3-apt
```

### 8. **Решение проблемы с модулем python-apt**
**Модуль python-apt недоступен через pip. Копируем его из системного Python 3.7:**
```bash
# Определяем пути
PYTHON37_PATH="/usr/lib/python3/dist-packages"
PYTHON38_PATH="/usr/local/lib/python3.8/site-packages"

# Копируем модули apt из Python 3.7 в Python 3.8
cp -r $PYTHON37_PATH/apt* $PYTHON38_PATH/
cp -r $PYTHON37_PATH/python_apt* $PYTHON38_PATH/

# Создаем симлинки для .so файлов
ln -sf $PYTHON37_PATH/apt_inst.cpython-37m-x86_64-linux-gnu.so $PYTHON38_PATH/apt_inst.so
ln -sf $PYTHON37_PATH/apt_pkg.cpython-37m-x86_64-linux-gnu.so $PYTHON38_PATH/apt_pkg.so
```

### 9. **Проверка работоспособности**
```bash
python3 -c "import apt; print('APT module works')"
python3 -c "import psycopg2; print('PostgreSQL module works')" || pip3 install psycopg2-binary
```

### 10. **Установка psycopg2-binary**
```bash
pip3 install psycopg2-binary
pip install --upgrade pip
```

### 11. **Проверка модулей**
```bash
python3 -c "
import apt
import psycopg2
import json
import sys
print('✓ APT module: OK')
print('✓ PostgreSQL module: OK') 
print('✓ JSON module: OK')
print('✓ Sys module: OK')
print('All required modules are available!')
"
```

### 12. **Настройка Ansible**
В inventory файле:
```ini
[ecd-test]
192.168.87.178

[ecd-test:vars]
ansible_user=root
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3
```

### 13. **Финальная проверка**
```bash
# С управляющей машины
ansible ecd-test -m ping
ansible ecd-test -m shell -a "python3 --version && pip3 --version"
```

### 14. **Запуск установки Runtel**
```bash
cd ~/projects/git/installer_pbxv2_singlenode
ansible <имя_хоста> -m ping -v
ansible-playbook playbook-ecd-pbx.yml --skip-tags freeswitch
```


