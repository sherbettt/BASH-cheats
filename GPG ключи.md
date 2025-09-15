
# Полное руководство по настройке GPG-подписи RPM пакетов для Jenkins и репозитория Runtel

## 🔍 Диагностика текущего состояния

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
pub   rsa2048 2025-09-15 [SC] [   годен до: 2027-09-15]
      8410195CAB1378F5293B039239D988BC61EABBC4
uid         [  абсолютно ] root redos7 <support@runtel.ru>
sub   rsa2048 2025-09-15 [E] [   годен до: 2027-09-15]

pub   rsa4096 2019-04-03 [SC]
      ABDA81F04BB74A21936B194F325CE60C3AD367DE
uid         [  абсолютно ] runtel (RUNTEL GNUPG) <support@runtel.ru>
sub   rsa4096 2019-04-03 [E]

```

### 3. Проверка отпечатков ключей
```bash
for key in $(rpm -qa gpg-pubkey*); do
    echo "=== Ключ: $key ==="
    rpm -qi $key | grep -E "(отпечаток|fingerprint)|ID"
    echo
done
```

## 🎯 Проблема в Jenkins

**Ошибка:**
```
rpm --addsign package.rpm
Вы должны установить "%_gpg_name" в вашем макрофайле
```

**Причина:** Jenkins работает как Java-процесс под пользователем `root`, но не настроен GPG-ключ для подписи сборки пакетов.

## 🔧 Решение для Jenkins

### 1. Настройка .rpmmacros для root
```bash
mcedit /root/.rpmmacros
```

**Содержимое:**
```bash
%_signature gpg
%_gpg_path /root/.gnupg
%_gpg_name runtel (RUNTEL GNUPG)
%_gpgbin /usr/bin/gpg
%_unitdir /usr/lib/systemd/system/
```

### 2. Проверка настроек RPM
```bash
rpm --showrc | grep _gpg_name
```

### 3. Установка доверия для ключа
```bash
echo -e "trust\n5\ny\nquit" | gpg --batch --command-fd 0 --edit-key "runtel (RUNTEL GNUPG)"
```

### 3.1. Бессрочное действие ключа
```bash
gpg --edit-key "root redos7" ; gpg> expire; gpg> save
```
```bash
echo -e "expire\n0\ny\nsave" | gpg --batch --command-fd 0 --edit-key "root redos7"

#или с указанием точного ключа
echo -e "expire\n0\ny\nsave" | gpg --batch --command-fd 0 --edit-key 8410195CAB1378F5293B039239D988BC61EABBC4
```

### 4. Тестирование подписи
```bash
rpm --addsign /path/to/package.rpm
rpm --checksig /path/to/package.rpm
```

## 📦 Настройка репозитория Runtel

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

## 🔄 Перенос ключей между системами

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

## 🛠️ Альтернативные решения

### 1. Явное указание ключа в команде
```bash
rpm --addsign --define "_gpg_name runtel (RUNTEL GNUPG)" package.rpm
```

### 2. Глобальная настройка в /etc/rpm/macros.d/
```bash
mcedit /etc/rpm/macros.d/jenkins
```
**Содержимое:**
```bash
%_signature gpg
%_gpg_name runtel (RUNTEL GNUPG)
%_gpg_path /root/.gnupg
```

### 3. Переменные окружения в Jenkins job
```bash
#!/bin/bash
export HOME=/root
export GNUPGHOME=/root/.gnupg
rpm --addsign package.rpm
```

## 🔒 Безопасность

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

## 📋 Проверочный чеклист

- [ ] Ключ импортирован в GPG: `gpg --list-keys`
- [ ] Ключ импортирован в RPM: `rpm -qa gpg-pubkey*`
- [ ] Настроен `.rpmmacros`: `cat /root/.rpmmacros`
- [ ] Установлено доверие к ключу: `gpg --list-keys` (должно быть `[ абсолютно ]`)
- [ ] Репозиторий настроен: `cat /etc/dnf.repos.d/Runtel.repo`
- [ ] Тест подписи: `rpm --addsign test.rpm`

## ❌ Временное решение

Если нужно срочно запустить сборку:
```bash
# Закомментируйте в Jenkins job:
# rpm --addsign package.rpm
```

## ✅ Финальная проверка

После всех настроек:
```bash
# Проверка подписи
rpm --checksig package.rpm

# Проверка репозитория
dnf repository-packages runtel list
```

После выполнения всех шагов подпись RPM пакетов в Jenkins должна работать корректно! 🎉

## 📞 Дополнительная помощь

Если проблемы сохраняются:
1. Проверьте логи: `journalctl -f -u jenkins`
2. Проверьте пользователя: `ps aux | grep jenkins`
3. Проверьте переменные: `env | grep -E "HOME|GNUPGHOME"`

**Важно:** Все команды должны выполняться от того пользователя, под которым работает Jenkins (в данном случае - `root`).





