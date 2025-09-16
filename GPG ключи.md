
#  руководство по настройке GPG-подписи RPM пакетов для Jenkins и репозитория Runtel

репа: http://repo.runtel.ru/redos/redos/7/epel/x86_64/ , http://repo.runtel.ru/redos/redos/8/epel/x86_64/

Условия для подписи в LXC контейнере:
```c
[root@redos7-builder] /var/lib/jenkins/workspace
11:25:13 > ccat ~/.gnupg/gpg.conf 
use-agent 
pinentry-mode loopback
[root@redos7-builder] /var/lib/jenkins/workspace
11:28:14 > ccat ~/.gnupg/gpg-agent.conf 
allow-loopback-pinentry
default-cache-ttl 3600
max-cache-ttl 7200
allow-loopback-pinentry
```

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
```bash
for key in $(rpm -qa gpg-pubkey*); do
    echo "=== Ключ: $key ==="
    rpm -qi $key | grep -E "(отпечаток|fingerprint)|ID"
    echo
done
```
`gpg --list-secret-keys --with-fingerprint --with-colons | grep fpr | cut -d: -f10`

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
#%_topdir /var/lib/jenkins/workspace/pbx_v2_redos
#%_builddir /var/lib/jenkins/workspace/pbx_v2_redos
#%_sourcedir /var/lib/jenkins/workspace/pbx_v2_redos
#%_buildroot /var/lib/jenkins/workspace/pbx_v2_redos
#%_signature gpg
#%_gpg_path /root/.gnupg
#%_gpg_name root redos7
#%_gpgbin /usr/bin/gpg2
#%_unitdir /usr/lib/systemd/system/
#%_gpg_name Jenkins RPM Signer

# Other variant
%_signature gpg
%_gpg_path /root/.gnupg
%_gpg_name ABDA81F04BB74A21936B194F325CE60C3AD367DE   # это runtel (RUNTEL GNUPG)
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

------------

Отлично! Используем ключ `AE6993C6F9752CB7AC5ADCA881C335431A0A310B` (runtel_redos7). Сначала нужно убрать passphrase с этого ключа.

## 1. Убираем passphrase с ключа

```bash
# Экспортируем и импортируем ключ без пароля
gpg --export-secret-keys -a "AE6993C6F9752CB7AC5ADCA881C335431A0A310B" > temp.key
gpg --delete-secret-keys "AE6993C6F9752CB7AC5ADCA881C335431A0A310B"
gpg --import --pinentry-mode loopback --passphrase '' temp.key
rm -f temp.key

# Проверяем, что ключ теперь без пароля
echo "test message" > test.txt
gpg --clear-sign test.txt -u "AE6993C6F9752CB7AC5ADCA881C335431A0A310B"
```

## 2. Настраиваем `.rpmmacros` с правильным fingerprint

```bash
# Создаем правильный .rpmmacros
cat > /root/.rpmmacros << 'EOF'
%_signature gpg
%_gpg_path /root/.gnupg
%_gpg_name AE6993C6F9752CB7AC5ADCA881C335431A0A310B
%_gpgbin /usr/bin/gpg
%_unitdir /usr/lib/systemd/system/
EOF
```

## 3. Тестируем подпись RPM

```bash
# Создаем простой тестовый RPM
mkdir -p testrpm/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo "test content" > testrpm/SOURCES/test.file

cat > testrpm/SPECS/test.spec << 'EOF'
Name: testrpm
Version: 1.0
Release: 1
Summary: Test RPM
License: MIT
Source0: test.file

%description
Test RPM package

%prep
%setup -q

%install
mkdir -p %{buildroot}/tmp
install -m 644 test.file %{buildroot}/tmp/test.file

%files
/tmp/test.file
EOF

# Собираем и подписываем
rpmbuild -bb testrpm/SPECS/test.spec --define "_topdir $(pwd)/testrpm"
test_rpm=$(find testrpm/RPMS -name "*.rpm")

echo "Подписываем: $test_rpm"
rpm --addsign $test_rpm

echo "Проверяем подпись:"
rpm --checksig $test_rpm

# Убираем тестовые файлы
rm -rf testrpm test.txt*
```

## 4. Упрощенная версия BuildFrontendRPMs() для Jenkins

```groovy
def BuildFrontendRPMs() {
    echo "Рабочая директория Jenkins: ${env.WORKSPACE}"
    def uniqueRPMDir = "${env.WORKSPACE}/rpmbuild/"
    
    // Чтение версии
    def version = sh(
        script: "cat ${env.WORKSPACE}/src/assets/version",
        returnStdout: true
    ).trim()
    def safeBuildId = env.BUILD_ID.replaceAll('-', '_')
    
    // 1. Подготовка директорий RPM
    sh label: 'Подготовка директорий RPM', script: """
        rm -rf ${uniqueRPMDir}
        mkdir -p ${uniqueRPMDir}/{SOURCES,SPECS,RPMS,SRPMS,BUILD,BUILDROOT}
    """

    // 2. Копирование файлов
    sh label: 'Копирование dist в SOURCES', script: """
        cp -a ${env.WORKSPACE}/dist/ ${uniqueRPMDir}/SOURCES/
        find ${uniqueRPMDir}/SOURCES/dist/ -name "*.wasm" -exec chmod 644 {} \\;
    """

    // 3. Подготовка spec-файла
    sh label: 'Подготовка spec файла', script: """
        cp -v ${env.WORKSPACE}/runtel-web-v2.spec ${uniqueRPMDir}/SPECS/
        sed -i "s/VERSION/${version}/g" ${uniqueRPMDir}/SPECS/runtel-web-v2.spec
        sed -i "s/RELEASE/${safeBuildId}/g" ${uniqueRPMDir}/SPECS/runtel-web-v2.spec
    """

    // 4. Сборка RPM
    sh label: 'Сборка RPM пакета', script: """
        rpmbuild -bb ${uniqueRPMDir}/SPECS/runtel-web-v2.spec \\
            --define "_topdir ${uniqueRPMDir}" \\
            --nocheck
        
        echo "=== Собранные RPM файлы ==="
        find ${uniqueRPMDir}/RPMS/ -name '*.rpm' -ls
    """

    // 5. Подпись RPM
    sh label: 'Подпись RPM пакета', script: """
        RPM_FILE=\$(find ${uniqueRPMDir}/RPMS/ -name '*.rpm' | head -1)
        if [ -z "\$RPM_FILE" ]; then
            echo "ОШИБКА: RPM файл не найден!"
            exit 1
        fi
        
        echo "Подписываем RPM: \$RPM_FILE"
        rpm --addsign "\$RPM_FILE"
        
        # Проверяем подпись
        if rpm --checksig "\$RPM_FILE"; then
            echo "RPM успешно подписан"
            cp -v "\$RPM_FILE" ${env.WORKSPACE}/
        else
            echo "ОШИБКА: Не удалось подписать RPM"
            echo "Детальная информация:"
            rpm --checksig -v "\$RPM_FILE"
            exit 1
        fi
    """

    // 6. Финальная проверка
    sh label: 'Финальная проверка', script: """
        echo "=== Финальный список RPM файлов ==="
        ls -la ${env.WORKSPACE}/*.rpm
        echo "=== Информация о RPM ==="
        rpm -qip ${env.WORKSPACE}/*.rpm
    """
}
```

## 5. Проверка настройки GPG

Добавьте эту stage в Jenkins pipeline для отладки:

```groovy
stage('Check GPG setup on redos7') {
    steps {
        script {
            sh """
            echo "=== Проверка GPG на redos7 ==="
            echo "Используемый fingerprint: AE6993C6F9752CB7AC5ADCA881C335431A0A310B"
            echo "Содержимое .rpmmacros:"
            cat /root/.rpmmacros || echo "Файл .rpmmacros не существует"
            echo "Секретные ключи:"
            gpg --list-secret-keys --with-fingerprint
            echo "Тест подписи:"
            echo "test" > gpg_test.txt
            gpg --clear-sign gpg_test.txt -u "AE6993C6F9752CB7AC5ADCA881C335431A0A310B" && echo "Тест подписи успешен" || echo "Тест подписи failed"
            rm -f gpg_test.txt*
            echo "=== Конец проверки GPG ==="
            """
        }
    }
}
```

После этих настроек ключ должен работать без passphrase и подпись RPM в Jenkins будет работать автоматически.


