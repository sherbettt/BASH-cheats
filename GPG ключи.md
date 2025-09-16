# GPG-подписи RPM пакетов

репа: http://repo.runtel.ru/redos/redos/7/epel/x86_64/ , http://repo.runtel.ru/redos/redos/8/epel/x86_64/

## Условия для подписи в LXC контейнере:

В **~/.bashrc** добавить переменную: `export GPG_TTY=$(tty)`

Требуется создать **Backup** LXC контейнера и **восстанвоить** на той же машине с повышенными привилегиями. ЭТО ВАЖНО!

Прописать следующее:
```
[root@redos7-builder-priv] ~
12:22:40 > ccat ~/.gnupg/gpg.conf
use-agent 
pinentry-mode loopback
no-emit-version  
default-key ABDA81F04BB74A21936B194F325CE60C3AD367DE
auto-key-retrieve

[root@redos7-builder-priv] ~
12:22:41 > ccat ~/.gnupg/gpg-agent.conf
allow-loopback-pinentry
default-cache-ttl 3600
max-cache-ttl 7200
allow-loopback-pinentry
```
<br/>



## Настройка ключей

### 1. Проверка установленных ключей RPM
```bash
# Посмотреть информацию о всех ключах
rpm -qa gpg-pubkey* --qf "%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n"
```
**Результат:**
```
gpg-pubkey-f8ac18ee-591e99a0    RED SOFT (RED SOFT rpm sign key) <support@red-soft.ru> public key
gpg-pubkey-2c1355e5-5ca35145    runtel <support@runtel.ru> public key
gpg-pubkey-3ad367de-5ca4b9d6    runtel (RUNTEL GNUPG) <support@runtel.ru> public key
```

### 2. Проверка GPG ключей в системе
```bash
gpg --list-keys
gpg --list-secret-keys

# Проверим какие ключи есть в системе
gpg --list-secret-keys --with-colons

# Проверим точное имя ключа
gpg --list-keys --with-colons | grep uid
```
**Результат:**
```
/root/.gnupg/pubring.kbx
------------------------
pub   rsa2048 2025-09-15 [SC]
      8410195CAB1378F5293B039239D988BC61EABBC4
uid         [  абсолютно ] root redos7 <support@runtel.ru>
sub   rsa2048 2025-09-15 [E] [   годен до: 2027-09-15]

pub   rsa4096 2019-04-03 [SC]
      ABDA81F04BB74A21936B194F325CE60C3AD367DE
uid         [  абсолютно ] runtel (RUNTEL GNUPG) <support@runtel.ru>
sub   rsa4096 2019-04-03 [E]

pub   rsa2048 2025-09-16 [SCEA] [   годен до: 2027-09-15]
      AE6993C6F9752CB7AC5ADCA881C335431A0A310B
uid         [  абсолютно ] runtel_redos7 <support@runtel.ru>
sub   rsa2048 2025-09-16 [SEA] [   годен до: 2027-09-15]
```

### 3. Проверка отпечатков ключей
`gpg --list-secret-keys --with-fingerprint --with-colons | grep fpr | cut -d: -f10`

```bash
for key in $(rpm -qa gpg-pubkey*); do
    echo "=== Ключ: $key ==="
    rpm -qi $key | grep -E "(отпечаток|fingerprint)|ID"
    echo
done
```

### 4. настройка rpmmacros
```bash
mcedit /root/.rpmmacros
```

**Содержимое:**
```bash
# Other variant
%_signature gpg
%_gpg_path /root/.gnupg
%_gpg_name ABDA81F04BB74A21936B194F325CE60C3AD367DE   # это runtel (RUNTEL GNUPG)
%_gpgbin /usr/bin/gpg
%_unitdir /usr/lib/systemd/system/
```

### 5. Проверка настроек RPM
```bash
rpm --showrc | grep _gpg_name
```

### 6.1. Установка доверия для ключа
```bash
echo -e "trust\n5\ny\nquit" | gpg --batch --command-fd 0 --edit-key "runtel (RUNTEL GNUPG)"
```

### 6.2. Бессрочное действие ключа
```bash
gpg --edit-key "root redos7" ; gpg> expire; gpg> save
```
```bash
echo -e "expire\n0\ny\nsave" | gpg --batch --command-fd 0 --edit-key "root redos7"

#или с указанием точного ключа
echo -e "expire\n0\ny\nsave" | gpg --batch --command-fd 0 --edit-key 8410195CAB1378F5293B039239D988BC61EABBC4
```

### 7. Тестирование подписи
```bash
rpm --addsign /path/to/package.rpm
rpm --checksig /path/to/package.rpm
```
<br/>



## Настройка репозитория Runtel

### 1. Конфигурация репозитория
```bash
cat /etc/dnf.repos.d/Runtel.repo
```

**Содержимое:**
```ini
[runtel]
name = Runtel
baseurl = http://repo.runtel.ru/redos/redos/7/epel/x86_64/
gpgcheck = 1
gpgkey = http://repo.runtel.ru/runtel.gpg
enabled = 1
```

### 2. Обновление репозитория
```bash
dnf clean all
dnf makecache
dnf repolist
dnf repository-packages runtel list
```

## Перенос ключей между системами

### 1. Экспорт ключей с RedOS 8
```bash
gpg --export-secret-keys -a "runtel" > /tmp/runtel-private.key
gpg --export -a "runtel" > /tmp/runtel-public.key
```

### 2. Импорт ключей на RedOS 7
```bash
gpg --import /tmp/runtel-private.key
gpg --import /tmp/runtel-public.key
rpm --import /tmp/runtel-public.key
```
<br/>



## Альтернативные решения

### 1. Явное указание ключа в команде
```bash
rpm --addsign --define "_gpg_name runtel (RUNTEL GNUPG)" package.rpm
```

### 2. Переменные окружения в Jenkins job
```bash
#!/bin/bash
export HOME=/root
export GNUPGHOME=/root/.gnupg
rpm --addsign package.rpm
```
<br/>



## Безопасность

### 1. Права доступа
```bash
chown -R root:root /root/.gnupg
chmod 700 /root/.gnupg
chmod 600 /root/.gnupg/*
```

### 2. Резервное копирование ключей
```bash
# Backup приватного ключа
gpg --export-secret-keys -a "runtel" > backup-runtel-private.key

# Backup публичного ключа  
gpg --export -a "runtel" > backup-runtel-public.key
```
<br/>


Далее читай в https://github.com/sherbettt/runtel-frontend-build/tree/master/vars

Далее читай в https://gitlab.runtel.org/runtel/runtel-frontend-build
