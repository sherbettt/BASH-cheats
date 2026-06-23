# Создание автоматизированного ISO-образа Windows 11 с обходом TPM для Proxmox

## Введение

При установке Windows 11 на виртуальные машины в Proxmox часто возникают две основные проблемы:
1. **Требование TPM 2.0 и Secure Boot** — Windows 11 официально требует эти технологии, что создаёт сложности в виртуальных средах.
2. **Требование учетной записи Microsoft** — при установке Windows 11 настаивает на входе в онлайн-аккаунт, что не всегда удобно для лабораторных и корпоративных сред.

В этой статье мы подробно рассмотрим, как создать собственный ISO-образ Windows 11, который:
- Автоматически обходит проверки TPM 2.0 и Secure Boot
- Создаёт локальную учетную запись
- Автоматизирует весь процесс установки
- Поддерживает русский язык и региональные настройки

Вся работа выполняется в **Linux Manjaro** (основан на Arch Linux), но инструкции легко адаптируются для любого дистрибутива Linux.

---

## Предварительные требования

### Системные требования
- Операционная система: Linux (в нашем случае Manjaro)
- Свободное место: минимум 15 ГБ (8 ГБ для ISO + 7 ГБ для временных файлов)
- Права root/sudo для монтирования образов

### Необходимые файлы
1. Официальный ISO-образ Windows 11 (скачанный с сайта Microsoft)
2. (Опционально) VirtIO-драйверы для Proxmox

---

## Установка необходимых инструментов в Manjaro

### Установка xorriso (рекомендуемый способ)

`xorriso` — это современная утилита для работы с образами CD/DVD, которая входит в состав пакета `libisoburn`:

```bash
sudo pacman -S xorriso
```

В процессе установки будут установлены зависимости:
- `libburn` — библиотека для записи CD/DVD
- `libisoburn` — утилиты для работы с образами

Проверьте установку:
```bash
xorriso -version
```

### Альтернативные инструменты

Если `xorriso` по каким-то причинам не подходит, можно использовать другие утилиты:

#### 1. cdrtools (mkisofs)

Традиционный набор утилит для создания ISO-образов:

```bash
sudo pacman -S cdrtools
```

После установки доступна команда `mkisofs`:
```bash
mkisofs -version
```

#### 2. genisoimage (форк cdrtools)

В некоторых дистрибутивах используется форк `genisoimage`:

```bash
# Для Debian/Ubuntu
sudo apt-get install genisoimage

# Для Arch/Manjaro (устанавливается как cdrtools)
sudo pacman -S cdrtools
```

#### 3. Сравнение инструментов

| Инструмент | Преимущества | Недостатки |
|------------|--------------|------------|
| **xorriso** | Современный, активно развивается, поддерживает все форматы | Синтаксис может отличаться от mkisofs |
| **mkisofs** (cdrtools) | Классический, хорошо документирован | Старый, может не поддерживать новые форматы |
| **genisoimage** | Совместим с mkisofs, есть в большинстве репозиториев | Может отсутствовать в некоторых дистрибутивах |

---

## Структура файла autounattend.xml

Файл `autounattend.xml` — это файл ответов Windows Setup, который автоматизирует процесс установки. Он должен быть помещён в корень ISO-образа.

### Полный шаблон для Windows 11

Создайте файл с этим содержимым:

```xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <UserData>
                <AcceptEula>true</AcceptEula>
            </UserData>
            <EnableFirewall>false</EnableFirewall>
            <ComplianceCheck>
                <DisplayReport>Never</DisplayReport>
            </ComplianceCheck>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Name>Admin</Name>
                        <DisplayName>Admin</DisplayName>
                        <Group>Administrators</Group>
                        <Password>
                            <Value>ВашПароль</Value>
                            <PlainText>true</PlainText>
                        </Password>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <OOBE>
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
                <HideEULAPage>true</HideEULAPage>
            </OOBE>
            <RegisteredOrganization>MyCompany</RegisteredOrganization>
            <RegisteredOwner>Admin</RegisteredOwner>
            <TimeZone>Russian Standard Time</TimeZone>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>ru-RU</InputLocale>
            <SystemLocale>ru-RU</SystemLocale>
            <UILanguage>ru-RU</UILanguage>
            <UserLocale>ru-RU</UserLocale>
        </component>
    </settings>
</unattend>
```

### Объяснение ключевых секций

| Секция | Назначение |
|--------|------------|
| `AcceptEula` | Автоматическое согласие с лицензионным соглашением |
| `EnableFirewall` | Отключение брандмауэра на время установки |
| `ComplianceCheck` / `DisplayReport` | **Ключевой параметр для обхода TPM 2.0** — отключает проверку совместимости |
| `LocalAccount` | Создание локальной учетной записи вместо Microsoft-аккаунта |
| `SkipMachineOOBE` / `SkipUserOOBE` | Пропуск этапов начальной настройки (OOBE) |
| `Russian Standard Time` | Установка московского часового пояса |
| `ru-RU` | Настройка русского языка, раскладки и локали |

---

## Пошаговая инструкция по созданию ISO

### Шаг 1: Подготовка рабочего окружения

Создайте необходимые директории:

```bash
mkdir ~/win11_iso
mkdir ~/win11_mount
```

### Шаг 2: Извлечение содержимого оригинального ISO

Смонтируйте оригинальный ISO-образ Windows 11 и скопируйте его содержимое:

```bash
# Монтируем образ (тип UDF обязателен для современных образов Windows)
sudo mount -o loop -t udf /путь/к/Windows-11.iso ~/win11_mount

# Копируем все файлы (используем rsync для сохранения прав)
rsync -av --chmod=u+w ~/win11_mount/ ~/win11_iso/

# Отмонтируем образ
sudo umount ~/win11_mount
```

> **Важно:** Использование `rsync` с параметром `--chmod=u+w` позволяет сохранить права доступа и снять защиту от записи для последующего редактирования.

#### Альтернатива с cp

Если `rsync` не установлен:

```bash
cp -rT ~/win11_mount ~/win11_iso
chmod -R u+w ~/win11_iso
```

### Шаг 3: Добавление файла autounattend.xml

Скопируйте подготовленный файл `autounattend.xml` в корень рабочей папки:

```bash
# Если файл создан в домашней папке
cp ~/autounattend.xml ~/win11_iso/

# Или если создан в другой папке
cp /путь/к/autounattend.xml ~/win11_iso/
```

Проверьте наличие файла:

```bash
ls -l ~/win11_iso/autounattend.xml
```

### Шаг 4: Создание нового ISO-образа

#### Вариант A: С использованием mkisofs (рекомендуемый)

```bash
cd ~/win11_iso

mkisofs -no-emul-boot \
    -b "efi/microsoft/boot/efisys.bin" \
    -iso-level 4 \
    -udf \
    -joliet \
    -joliet-long \
    -disable-deep-relocation \
    -omit-version-number \
    -relaxed-filenames \
    -output ~/win11_automated.iso \
    .
```

#### Вариант B: С использованием xorriso

```bash
cd ~/win11_iso

xorriso -as mkisofs \
    -no-emul-boot \
    -b "efi/microsoft/boot/efisys.bin" \
    -iso-level 4 \
    -udf \
    -joliet \
    -joliet-long \
    -disable-deep-relocation \
    -omit-version-number \
    -relaxed-filenames \
    -output ~/win11_automated.iso \
    -uid "$(id -u nobody)" \
    -gid "$(id -g nobody)" \
    .
```

#### Вариант C: С использованием genisoimage

```bash
cd ~/win11_iso

genisoimage -no-emul-boot \
    -b "efi/microsoft/boot/efisys.bin" \
    -iso-level 4 \
    -udf \
    -joliet \
    -joliet-long \
    -disable-deep-relocation \
    -omit-version-number \
    -relaxed-filenames \
    -output ~/win11_automated.iso \
    .
```

### Объяснение параметров

| Параметр | Назначение |
|----------|------------|
| `-no-emul-boot` | Создание загрузочного образа без эмуляции дискеты |
| `-b "efi/microsoft/boot/efisys.bin"` | Указание загрузочного файла для UEFI |
| `-iso-level 4` | Использование ISO 9660 версии 4 (поддержка больших файлов) |
| `-udf` | Включение формата UDF (универсальный формат диска) |
| `-joliet` | Добавление расширений Joliet для длинных имён файлов |
| `-joliet-long` | Разрешение имён файлов до 103 символов |
| `-disable-deep-relocation` | Отключение глубокой перелокации (совместимость) |
| `-omit-version-number` | Удаление номеров версий из имён файлов |
| `-relaxed-filenames` | Разрешение специальных символов в именах |
| `-uid` / `-gid` (xorriso) | Установка владельца файлов |

### Шаг 5: Проверка созданного ISO

Создайте временную папку и смонтируйте новый ISO для проверки:

```bash
mkdir ~/win11_check
sudo mount -o loop -t udf ~/win11_automated.iso ~/win11_check

# Проверяем наличие файла autounattend.xml
ls -l ~/win11_check/autounattend.xml

# Проверяем содержимое (опционально)
cat ~/win11_check/autounattend.xml | grep -A2 "ComplianceCheck"

# Проверяем размер ISO
ls -lh ~/win11_automated.iso

sudo umount ~/win11_check
```

Успешный результат должен показать файл `autounattend.xml` в корне образа.

---

## Устранение возможных ошибок

### Проблема 1: "xorriso: Unrecognized option '-rockridge'"

**Причина:** В некоторых версиях xorriso параметр `-rockridge` не поддерживается.

**Решение:** Используйте вместо него `-joliet-long` и `-relaxed-filenames`. Для Windows ISO этих параметров достаточно:

```bash
xorriso -as mkisofs \
    -no-emul-boot \
    -b "efi/microsoft/boot/efisys.bin" \
    -iso-level 4 \
    -udf \
    -joliet \
    -joliet-long \
    -disable-deep-relocation \
    -omit-version-number \
    -relaxed-filenames \
    -output ~/win11_automated.iso \
    -uid "$(id -u nobody)" \
    -gid "$(id -g nobody)" \
    .
```

### Проблема 2: "mkisofs: Error: files have the same Joliet name"

**Причина:** Конфликт длинных имён файлов в Joliet.

**Решение:** Добавьте параметр `-joliet-long`:

```bash
mkisofs -no-emul-boot \
    -b "efi/microsoft/boot/efisys.bin" \
    -iso-level 4 \
    -udf \
    -joliet \
    -joliet-long \
    ...
```

### Проблема 3: "Permission denied" при копировании файлов

**Причина:** Монтирование ISO только для чтения.

**Решение:** Используйте `rsync` с параметром `--chmod=u+w`:

```bash
rsync -av --chmod=u+w ~/win11_mount/ ~/win11_iso/
```

Или добавьте права после копирования:

```bash
cp -rT ~/win11_mount ~/win11_iso
chmod -R u+w ~/win11_iso
```

### Проблема 4: "mount: failed to set up loop device"

**Причина:** ISO-образ уже используется или повреждён.

**Решение:**
1. Убедитесь, что образ не смонтирован в другом месте:
   ```bash
   sudo umount ~/win11_mount
   ```
2. Проверьте целостность ISO:
   ```bash
   ls -lh /путь/к/Windows-11.iso
   ```
3. Используйте другой загрузочный образ.

### Проблема 5: ISO не загружается в Proxmox

**Причина:** Неправильные настройки BIOS или загрузки.

**Решение:**
1. Проверьте, что в настройках ВМ выбран BIOS: OVMF (UEFI)
2. Убедитесь, что в загрузочных параметрах ISO выставлен правильный приоритет
3. Проверьте целостность ISO (размер должен быть ~7.7 ГБ)

---

## Настройка виртуальной машины в Proxmox

### Создание ВМ

1. **Загрузите ISO** в Proxmox:
   - Перейдите в `Datacenter` → Ваш сервер → `local` → `ISO Images`
   - Нажмите "Upload" и выберите `win11_automated.iso`

2. **Создайте виртуальную машину:**
   - **OS:** Windows 11 (или Windows 10/2016)
   - **ISO:** win11_automated.iso
   - **System:** BIOS: OVMF (UEFI), включите QEMU Agent
   - **Hard Disk:** SCSI или VirtIO Block, минимум 64 ГБ
   - **CPU:** 4+ ядра
   - **Memory:** 8+ ГБ (рекомендуется)
   - **Network:** VirtIO

### Подключение VirtIO-драйверов

VirtIO-драйверы необходимы для работы диска и сети в Proxmox:

1. Скачайте ISO с VirtIO-драйверами:
   ```
   https://fedorapeople.org/groups/virt/virtio-win/
   ```

2. Загрузите его в Proxmox

3. Добавьте второй CD/DVD-привод в настройках ВМ и подключите VirtIO ISO

4. При установке Windows, когда появится запрос на выбор диска:
   - Нажмите "Загрузить драйвер"
   - Выберите папку с соответствующими драйверами
   - Обычно это `vioscsi\w10\amd64` или `viostor\w10\amd64`

### Запуск установки

После настройки ВМ:
1. Запустите виртуальную машину
2. Установка Windows 11 начнётся автоматически
3. Через 15-30 минут установка завершится
4. Войдите под пользователем Admin с указанным паролем

---

## Альтернативные методы обхода TPM

### Метод 1: Ручной обход через командную строку

Если автоматизированная установка не подходит, можно использовать ручной метод:

1. При первом запуске установки нажмите `Shift + F10` для вызова командной строки
2. Выполните команду:
   ```cmd
   regedit
   ```
3. В редакторе реестра перейдите к:
   ```
   HKEY_LOCAL_MACHINE\SYSTEM\Setup
   ```
4. Создайте ключ `LabConfig`
5. Внутри `LabConfig` создайте DWORD-параметры:
   - `BypassTPMCheck` = 1
   - `BypassSecureBootCheck` = 1
   - `BypassRAMCheck` = 1
6. Закройте редактор и командную строку
7. Продолжите установку

### Метод 2: Скрипт обхода OOBE

Для быстрого обхода и создания локального пользователя:

1. На экране OOBE нажмите `Shift + F10`
2. Выполните команду:
   ```cmd
   OOBE\BYPASSNRO
   ```
3. Система перезагрузится
4. После перезагрузки нажмите "У меня нет интернета"
5. Выберите "Продолжить с ограниченной настройкой"
6. Создайте локальную учётную запись

---

## Заключение

В результате всех проделанных операций мы получили:

1. **Автоматизированный ISO-образ Windows 11** с интегрированным файлом ответов
2. **Обход требований TPM 2.0 и Secure Boot** через параметры в файле ответов
3. **Создание локальной учетной записи** без привязки к Microsoft
4. **Полную автоматизацию процесса установки** с русской локализацией

Этот образ можно использовать для быстрой и удобной установки Windows 11 на любое количество виртуальных машин в Proxmox без необходимости ручного вмешательства.

### Преимущества подхода

- ✅ Полная автоматизация установки
- ✅ Обход всех системных требований Windows 11
- ✅ Создание локальной учётной записи
- ✅ Поддержка русского языка
- ✅ Возможность массового развертывания
- ✅ Работает в любой системе Linux

### Дальнейшее развитие

Для более сложных сценариев можно расширить файл `autounattend.xml`, добавив:
- Установку приложений
- Настройку групповых политик
- Интеграцию в домен
- Установку драйверов


----

### 📥 Где скачать ISO-образ VirtIO

Вот ссылки на самые актуальные и рекомендуемые версии:

*   **Стабильная версия (рекомендовано)**:
    ```
    https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

    https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.285-1/
    ```
    Это основная ссылка, которую советует Proxmox и большинство руководств. Она всегда ведет на последнюю стабильную сборку.

*   **Последняя сборка (может быть менее стабильна)**:
    ```
    https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
    ```
    Если вам нужна самая новая версия (например, для Windows 11 на ARM64), можно использовать эту ссылку, но она содержит более свежие, но потенциально менее протестированные драйверы.

### 💡 Альтернативы и пояснения

*   **Архив версий**: Если вам вдруг понадобится более старая версия драйвера (например, для Windows 7 или 8), все они доступны в папке `direct-downloads/archive-virtio/`.
*   **Легковесный ISO**: Также существует опциональный проект на GitHub, который автоматически создает "очищенную" версию ISO — из нее удаляют файлы разработки, оставляя только необходимые драйверы. Эту версию можно найти в релизах проекта `caoquocdung/virtio-win-iso-lite`. Но использование официальной версии с `fedorapeople.org` — более стандартный путь.

### ⚙️ Как использовать ISO

Скачайте этот файл (он будет иметь имя `virtio-win.iso`) и **загрузите его в Proxmox** так же, как вы загружали ISO-образ Windows 11. Затем, при создании виртуальной машины, подключите его как второй CD/DVD-привод. Во время установки Windows, когда потребуется найти диск, нажмите **"Загрузить драйвер"** и укажите путь к папке с драйверами на этом подключённом диске.

Этот файл нужен для того, чтобы виртуальная машина могла работать с вашим виртуальным диском и сетью на высокой скорости через технологию VirtIO.

---

## Ссылки и полезные ресурсы

1. **Официальная документация Windows Setup:** [Microsoft Docs](https://docs.microsoft.com/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs)
2. **Генератор файлов ответов:** [schneegans.de](https://schneegans.de/windows/unattend-generator/)
3. **VirtIO-драйверы:** [fedorapeople.org](https://fedorapeople.org/groups/virt/virtio-win/)
4. **Документация xorriso:** [libburnia-project.org](https://libburnia-project.org/)
5. **Proxmox Wiki:** [pve.proxmox.com](https://pve.proxmox.com/wiki/Main_Page)



