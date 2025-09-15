
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

Чтобы ваш GPG-ключ считался валидным для репозитория RPM на сервере `http://repo.runtel.ru/`, вам нужно выполнить несколько действий:

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







