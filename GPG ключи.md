```c
# Посмотреть информацию о всех ключах
rpm -qa gpg-pubkey* --qf "%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n"

gpg-pubkey-f8ac18ee-591e99a0    RED SOFT (RED SOFT rpm sign key) <support@red-soft.ru> public key
gpg-pubkey-2c1355e5-5ca35145    runtel <support@runtel.ru> public key
```

```c
root@redos7 /etc/nginx # gpg --list-keys 
/root/.gnupg/pubring.kbx
------------------------
pub   rsa4096 2019-04-03 [SC]
      ABDA81F04BB74A21936B194F325CE60C3AD367DE
uid         [  абсолютно ] runtel (RUNTEL GNUPG) <support@runtel.ru>
sub   rsa4096 2019-04-03 [E]

root@redos7 /etc/nginx # cd /tmp/
root@redos7 /tmp # ccat runtel.gpg 
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQGNBFyjUU **********
***************
lxkolx6wOEGa5i8****************FRfftFqNqzFHGFqhP+r+CGKpt7nVA4b8n3
veNAiMYzvhp3AA9a
=KELh
-----END PGP PUBLIC KEY BLOCK-----
```

или `rpm -qi $(rpm -qa gpg-pubkey*)`


Посмотреть отпечатки ключей: `gpg --list-keys --with-fingerprint --with-colons` или
```bash
for key in $(rpm -qa gpg-pubkey*); do
    echo "=== Ключ: $key ==="
    rpm -qi $key | grep -E "(отпечаток|fingerprint)|ID"
    echo
done
```

Чтобы ваш GPG-ключ считался валидным для репозитория RPM на сервере `http://repo.runtel.ru/`, вам нужно выполнить несколько действий:

## 0. Скачать
```bash
# Скачать ключ заново на всякий случай
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-runtel http://repo.runtel.ru/runtel.gpg

# Импортировать
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-runtel

# устанвока без подписи
dnf install --nogpgcheck freeswitch-codec-passthru-g729-debuginfo
```

## 1. Экспорт ключа в правильном формате

Сначала экспортируйте ваш ключ в формате, который понимает RPM:

```bash
gpg --export -a "ABDA81F04BB74A21936B194F325CE60C3AD367DE" > RPM-GPG-KEY-runtel
```

## 2. Импорт ключа в RPM базу данных

```bash
rpm --import RPM-GPG-KEY-runtel
```

## 3. Размещение ключа на сервере репозитория

На сервере `repo.runtel.ru` в директории репозитория разместите файл с ключом:

```c
# На сервере repo.runtel.ru
cp RPM-GPG-KEY-runtel /path/to/repo/redos/redos/7/epel/x86_64/
```
http://repo.runtel.ru/ - прямо в корне лежит runtel.gpg

## 4. Настройка репозитория RPM

В файле `.repo` на клиентских машинах укажите путь к ключу:

```ini
root@redos7 /tmp # ccat /etc/dnf.repos.d/Runtel.repo
[runtel]
name = Runtel
baseurl = http://repo.runtel.ru/redos/redos/7/epel/x86_64/
gpgcheck = 1
gpgkey = http://repo.runtel.ru/runtel.gpg
enabled = 1

[Runtel]
baseurl = http://repo.runtel.ru/redos/redos/7/epel/x86_64/
enabled = 1
gpgcheck = 0
name = Runtel dnf repo
```

## 5. Подписание метаданных репозитория

Для того чтобы ключ действительно работал, вам нужно подписывать метаданные репозитория при каждом обновлении:

```bash
# При обновлении репозитория
createrepo /path/to/repo/redos/redos/7/epel/x86_64/
gpg --detach-sign --armor /path/to/repo/redos/redos/7/epel/x86_64/repodata/repomd.xml
```


## 6. Проверка на клиенте

На клиентских машинах проверьте, что ключ импортирован правильно:

```bash
rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n' | grep runtel

gpg-pubkey-2c1355e5-5ca35145 --> runtel <support@runtel.ru> public key
gpg-pubkey-3ad367de-5ca4b9d6 --> runtel (RUNTEL GNUPG) <support@runtel.ru> public key
```
```bash
root@redos7 /tmp # rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'
gpg-pubkey-f8ac18ee-591e99a0 --> RED SOFT (RED SOFT rpm sign key) <support@red-soft.ru> public key
gpg-pubkey-083a7a9a-6463ac3e --> Yandex Browser Repository Key <browser@support.yandex.ru> public key
gpg-pubkey-2c1355e5-5ca35145 --> runtel <support@runtel.ru> public key
gpg-pubkey-3ad367de-5ca4b9d6 --> runtel (RUNTEL GNUPG) <support@runtel.ru> public key
```

## Альтернативный вариант - размещение ключа в отдельной директории

Часто ключи размещают в корневой директории репозитория:

```
http://repo.runtel.ru/keys/RPM-GPG-KEY-runtel
```

И тогда в конфигурации репозитория указывают:
```ini
gpgkey=http://repo.runtel.ru/keys/RPM-GPG-KEY-runtel
```

## Проверка работы

После настройки проверьте работу репозитория:

```bash
dnf clean all
dnf makecache
dnf repolist
```

Если всё настроено правильно, RPM пакеты из вашего репозитория будут проходить проверку подписи без ошибок.

---------------------

Отлично! Теперь видна полная картина. У вас есть два ключа:
1. `gpg-pubkey-f8ac18ee-591e99a0` - RED SOFT (RedOS)
2. `gpg-pubkey-2c1355e5-5ca35145` - Runtel

Но проблема в Jenkins не связана с этими ключами. Ошибка `"Вы должны установить "%_gpg_name" в вашем макрофайле"` означает, что **не настроен GPG-ключ для подписи СБОРКИ пакетов**, а не для установки.

## Решение для Jenkins

### 1. Создайте GPG-ключ для подписи пакетов

```bash
# Создаем новый GPG-ключ (выполните от пользователя jenkins или root)
gpg --gen-key
# Выберите:
# - Type: RSA and RSA (1)
# - Size: 2048
# - Expire: 0 (never expires)
# - Real name: Jenkins Builder
# - Email: jenkins@yourcompany.com
# - Comment: RPM signing key
```

### 2. Настройте .rpmmacros для пользователя jenkins

```bash
# Перейдите в домашнюю директорию jenkins
cd /var/lib/jenkins

# Создайте файл .rpmmacros
mcedit .rpmmacros
```

**Добавьте содержимое (замените на ваше имя ключа):**
```bash
%_signature gpg
%_gpg_name Jenkins Builder
%_gpg_path ~/.gnupg
%_gpgbin /usr/bin/gpg
%__gpg_sign_cmd %{__gpg} gpg --batch --no-verbose --no-armor --use-agent --no-secmem-warning -u "%{_gpg_name}" -sbo %{__signature_filename} %{__plaintext_filename}
```

### 3. Экспортируйте открытый ключ

```bash
# Экспортируйте открытый ключ
gpg --export -a "Jenkins Builder" > /etc/pki/rpm-gpg/RPM-GPG-KEY-JENKINS

# Импортируйте в RPM базу
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-JENKINS
```

### 4. Настройте права для Jenkins

```bash
# Убедитесь, что jenkins имеет доступ к GPG
chown -R jenkins:jenkins /var/lib/jenkins/.gnupg
chmod 700 /var/lib/jenkins/.gnupg
```

### 5. Альтернативное решение: настройка через /etc/rpm/macros

```bash
# Создайте глобальный конфиг
mcedit /etc/rpm/macros.d/jenkins
```

Добавьте:
```bash
%_signature gpg
%_gpg_name Jenkins Builder
%_gpg_path /var/lib/jenkins/.gnupg
```

### 6. Проверьте настройки

```bash
# Проверьте, что настройки применяются
rpm --showrc | grep _gpg_name
```

### 7. Для текущей сессии можно установить переменную

В Jenkins job добавьте шаг:
```bash
export GPG_NAME="Jenkins Builder"
```

Или в самом скрипте:
```bash
#!/bin/bash
export GPG_NAME="Jenkins Builder"
rpm --addsign ваш-пакет.rpm
```

### 8. Если не хотите настраивать подпись, отключите её

В Jenkins job можно пропустить подпись:
```bash
# Пропустить шаг подписи в скрипте
# rpm --addsign ...  # Закомментируйте эту строку
```

### 9. Проверьте работу

```bash
# Проверьте подпись
rpm --checksig ваш-пакет.rpm
```

## Важно!
Убедитесь, что все команды выполняются от правильного пользователя (jenkins или того, под которым запускается сборка).

После этих настроек ошибка `"%_gpg_name"` должна исчезнуть, и подпись пакетов будет работать корректно.





