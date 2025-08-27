### 1. Создайте директорию для Jenkins на целевой ноде:

```bash
ssh root@192.168.87.211

# Создайте директорию
mkdir -p /var/lib/jenkins

# Установите правильные права
chown root:root /var/lib/jenkins
chmod 755 /var/lib/jenkins

# Проверьте
ls -la /var/lib/ | grep jenkins
```

### 2. Альтернативно: измените рабочую директорию в настройках ноды

В Jenkins при настройке ноды вы можете указать другую рабочую директорию, например:
- `/tmp/jenkins`
- `/home/jenkins`
- `/opt/jenkins`

### 3. Перезапустите подключение ноды

После создания директории перезапустите ноду в Jenkins:
1. **Manage Jenkins** → **Manage Nodes and Clouds**
2. Найдите вашу ноду
3. Нажмите **Launch agent**

### 4. Если проблема сохраняется

Проверьте вручную, может ли Java запускаться:

```bash
ssh root@192.168.87.211 "cd /var/lib/jenkins && java -version"
```

### 5. Дополнительная проверка

Убедитесь, что система может найти Java:

```bash
ssh root@192.168.87.211 "which java && java -version && echo $PATH"
```

### 6. Установите Java 17 на RedOS:

```bash
ssh root@192.168.87.211

# Поиск доступных пакетов Java 17
yum search openjdk17

# Установите Java 17
yum install -y java-17-openjdk-devel

# Проверьте установку
java -version
```

### 7. Переключите систему на использование Java 17:

```bash
# Проверьте доступные версии Java
alternatives --config java

# Выберите Java 17 (должна появиться после установки)
```

### 8. Если пакет Java 17 не найден:

```bash
# Добавьте репозиторий с более новыми версиями (если нужно)
# Для RedOS может потребоваться EPEL или другие репозитории

# Или установите вручную
```

### 9. Альтернативное решение: обновите Java на агенте до версии 17

Если в репозиториях RedOS нет Java 17, скачайте и установите вручную:

```bash
# Скачайте OpenJDK 17
wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz

# Распакуйте
tar -xzf openjdk-17.0.2_linux-x64_bin.tar.gz -C /opt/

# Создайте симлинк
ln -sf /opt/jdk-17.0.2 /opt/jdk17

# Добавьте в PATH
echo 'export PATH=/opt/jdk17/bin:$PATH' >> /etc/profile.d/java17.sh
source /etc/profile.d/java17.sh

# Проверьте
java -version
```

### 10. После установки Java 17 проверьте:

```bash
java -version
# Должно показать версию 17 или выше
```

### 11. Перезапустите подключение ноды в Jenkins

После установки Java 17 нода должна успешно подключиться.

## Если нужно оставить Java 11 на агенте:

Вам нужно будет **понизить версию Java на Jenkins master** до 11, но это не рекомендуется, так как современные версии Jenkins требуют Java 11+.

**Рекомендую установить Java 17 на агенте** - это наиболее правильное решение.



### 12. Подключитесь к целевой ноде и установите Java:

```bash
ssh root@192.168.87.211

# Для RedOS (основана на RedHat)
yum install -y java-11-openjdk-devel

# Или установите конкретную версию
yum install -y java-1.8.0-openjdk-devel

# Проверьте установку
java -version
which java
```

### 13. Альтернативно: установите через alternatives

```bash
# Если есть несколько версий Java, выберите нужную
alternatives --config java
```

### 14. Если нужна конкретная версия Java:

```bash
# Поиск доступных пакетов Java
yum search openjdk

# Установите нужную версию
yum install -y java-11-openjdk-devel
```

### 15. Проверьте переменные окружения:

```bash
# Убедитесь, что Java в PATH
echo $PATH
which java

# Если не найдено, добавьте в PATH
export PATH=$PATH:/usr/lib/jvm/java-11-openjdk/bin
```

### 16. После установки Java перезапустите подключение ноды:

В Jenkins:
1. Перейдите в **Manage Jenkins** → **Manage Nodes and Clouds**
2. Найдите вашу ноду
3. Нажмите **Launch agent** или дождитесь автоматического переподключения

### 17. Альтернативное решение: указать путь к Java в конфигурации ноды

В настройках ноды в Jenkins вы можете указать путь к Java:

```bash
# Узнайте полный путь к java
which java
# Обычно: /usr/bin/java или /usr/lib/jvm/java-11-openjdk/bin/java

# Затем в конфигурации ноды укажите путь в поле "JavaPath"
```

### 18. Проверка работы:

После установки Java проверьте вручную:

```bash
ssh root@192.168.87.211 "java -version"
```

**ПОЛУЧАЕМ**
https://jenkins.runtel.ru/manage/credentials/store/system/domain/_/credential/736/
https://jenkins.runtel.ru/computer/redos-7/

### 19. Установим GIT:
```bash
dnf install -y git
dnf install -y make gcc gcc-c++ rpm-build rpmdevtools
```

### 20. Установим python3:
```bash
dnf list available python3*
dnf install -y python3 python3-devel

# Установите инструменты для сборки native модулей
yum install -y make gcc gcc-c++ openssl-devel bzip2-devel libffi-devel

# Для node-gyp (если используется)
yum install -y nodejs npm

# Проверьте установку
python3 --version
which python3
```

Если нужно свежее то:
```bash
# Установите Software Collections (SCL)
yum install -y centos-release-scl

# Установите Python 3.8 или 3.9
yum install -y rh-python38 rh-python39

# Активируйте Python 3.8
scl enable rh-python38 bash

# Или сделайте постоянным
echo 'source scl_source enable rh-python38' >> /etc/profile.d/python38.sh
```

Создайте симлинк python3 → python (если нужно):
```bash
# Проверьте, есть ли симлинк
ls -la /usr/bin/python3

# Если нужно создать симлинк python → python3
ln -sf /usr/bin/python3 /usr/bin/python
```

Установите pip (менеджер пакетов Python):
```bash
yum install -y python3-pip

# Обновите pip
python3 -m pip install --upgrade pip

# Проверьте
pip3 --version
```

