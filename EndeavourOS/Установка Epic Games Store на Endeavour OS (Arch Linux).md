# Установка Epic Games Store на Endeavour OS (Arch Linux)

## Оглавление
1. [Введение](#введение)
2. [Подготовка системы](#подготовка-системы)
3. [Установка Heroic Games Launcher](#установка-heroic-games-launcher)
4. [Установка дополнительных зависимостей](#установка-дополнительных-зависимостей)
5. [Решение проблем с Python и pipx](#решение-проблем-с-python-и-pipx)
6. [Установка Flatpak (опционально)](#установка-flatpak-опционально)
7. [Настройка и использование Heroic Games Launcher](#настройка-и-использование-heroic-games-launcher)
8. [Альтернативный способ: Lutris](#альтернативный-способ-lutris)
9. [Решение типичных проблем](#решение-типичных-проблем)
10. [Очистка системы](#очистка-системы)
11. [Заключение](#заключение)

---

## Введение

**Endeavour OS** — это дистрибутив на основе Arch Linux, который славится своей простотой, гибкостью и доступом к свежим пакетам через Arch User Repository (AUR). Однако официального клиента **Epic Games Store** для Linux не существует. 
К счастью, сообщество Linux создало отличные альтернативы, которые позволяют играть в любимые игры без использования Windows.

---

## Подготовка системы

Перед началом установки игрового лаунчера важно убедиться, что система обновлена и имеет все необходимые базовые компоненты.

### Обновление системы

Первым делом обновим все пакеты системы:

```bash
sudo pacman -Syu
paru
```

**Что делает эта команда:**
- `sudo` — выполняет команду с правами суперпользователя
- `pacman` — пакетный менеджер Arch Linux
- `-Syu` — синхронизирует базы данных пакетов и обновляет все установленные пакеты

### Проверка видеодрайверов

Для игр критически важны правильные драйверы видеокарты. В Endeavour OS они обычно устанавливаются автоматически, но проверить стоит.

**Для NVIDIA:**
```bash
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader
paru -S nvidia-dkms nvidia-utils lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader
```

**Для AMD:**
```bash
sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
paru -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
```

**Для Intel:**
```bash
paru -S -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel
```

### Включение multilib репозитория

Многие игры требуют 32-битные библиотеки. Убедитесь, что в файле `/etc/pacman.conf` раскомментирована строка `[multilib]`:

```bash
sudo mcedit /etc/pacman.conf
```

Найдите и раскомментируйте:
```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Сохраните файл (`F2`, выйти `F10`) и снова обновите базы данных:
```bash
sudo pacman -Syu
```

---

## Установка Heroic Games Launcher

**Heroic Games Launcher** — это специализированный лаунчер с открытым исходным кодом, созданный для Epic Games, GOG и Amazon Games. Это самый простой и надежный способ запускать игры из Epic Store на Linux.

### Варианты установки Heroic Games Launcher

Существует несколько вариантов установки. Мы выбрали бинарную версию из AUR, так как она не требует компиляции и устанавливается быстрее всего.

#### Поиск пакета в AUR

Сначала посмотрим, какие версии доступны:

```bash
paru -Ss heroic-games-launcher
```

**Результат:**
```
aur/heroic-games-launcher-bin 2.20.1-1 [+267 ~9.69]
    An Open source Launcher for Epic, Amazon and GOG Games
aur/heroic-games-launcher 2.20.1-1 [+39 ~2.82]
    Native GOG, Epic Games and Amazon games launcher for Linux
aur/heroic-games-launcher-git 2.19.1.r11.g27e43eac1-2 [+7 ~0.32]
    Native GOG, Epic Games and Amazon games launcher for Linux
aur/heroic-games-launcher-electron-git 2.20.1.r22.g46edb4836-1 [+0 ~0.00]
    Native GOG, Epic Games and Amazon games launcher. Development version
aur/heroic-games-launcher-proxy-bin 2.20.1-1 [+0 ~0.00]
    An Open source Launcher for Epic, Amazon and GOG Games. Patched for proxy envs support
```

**Что означают эти варианты:**
- `heroic-games-launcher-bin` — **бинарная версия** (рекомендуется). Уже скомпилированный пакет, устанавливается быстро.
- `heroic-games-launcher` — версия, которая собирается из исходников на вашем компьютере
- `heroic-games-launcher-git` — самая свежая версия из Git-репозитория (может быть нестабильной)
- `heroic-games-launcher-electron-git` — использует системный Electron вместо встроенного
- `heroic-games-launcher-proxy-bin` — версия с поддержкой прокси для обхода блокировок

#### Установка бинарной версии

Мы выбрали `heroic-games-launcher-bin`:

```bash
paru -S heroic-games-launcher-bin
```

**Что происходит во время установки:**

1. **Загрузка PKGBUILD** — paru скачивает файл с инструкциями по сборке пакета
2. **Просмотр PKGBUILD** — вам покажут содержимое файла. Нажмите `q` для выхода
3. **Загрузка пакета** — скачивается файл `Heroic-2.20.1-linux-x64.pacman` (около 120 МБ)
4. **Проверка целостности** — проверяется контрольная сумма (SHA256) скачанного файла
5. **Распаковка** — содержимое распаковывается в систему
6. **Установка** — файлы копируются в `/opt/Heroic/` и создаются символические ссылки

**Что устанавливается:**
- `/opt/Heroic/heroic` — основной исполняемый файл
- `/opt/Heroic/resources/` — ресурсы лаунчера
- `/opt/Heroic/locales/` — файлы перевода на разные языки
- `/usr/share/applications/heroic.desktop` — ярлык в меню приложений
- `/usr/share/icons/hicolor/` — иконки разных размеров

**Размер установки:** около 417 МБ

После успешной установки вы увидите сообщение:
```
(1/1) установка heroic-games-launcher-bin [100%]
:: Запуск post-transaction hooks...
(1/3) Arming ConditionNeedsUpdate...
(2/3) Updating icon theme caches...
(3/3) Updating the desktop file MIME type cache...
```

---

## Установка дополнительных зависимостей

Для корректной работы игр необходимы дополнительные компоненты. Главный из них — **vkbasalt-cli**, который используется для постобработки графики в играх.

### Проблема: ошибка при установке vkbasalt-cli из AUR

При попытке установить `vkbasalt-cli` через paru возникла ошибка:

```bash
paru -S vkbasalt-cli
```

**Ошибка:**
```
==> Клонирование репозитория 'vkbasalt-cli' (git)...
error: RPC failed; curl 56 Recv failure: Время ожидания соединения истекло
error: 51745 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: неожиданный конец файла
fatal: fetch-pack: invalid index-pack output
==> ОШИБКА: Ошибка при загрузке репозитория 'vkbasalt-cli' (git)
```

**Причина ошибки:** Исходный код `vkbasalt-cli` находится на GitLab. В некоторых регионах или сетях GitLab работает нестабильно, и соединение обрывается по таймауту. Это проблема сети, а не самого пакета.

---

## Решение проблем с Python и pipx

### Установка pipx

**pipx** — это инструмент для установки и запуска Python-приложений в изолированных окружениях. Он рекомендован для Arch Linux вместо прямого использования `pip`, так как не нарушает работу системного Python.

```bash
sudo pacman -S python-pipx
```

**Что устанавливается вместе с pipx:**
- `python-click` — библиотека для создания интерфейсов командной строки
- `python-userpath` — утилита для управления переменной PATH

**Процесс установки:**
```
разрешение зависимостей...
Пакет (3)              Новая версия  Изменение размера
extra/python-click     8.3.2-1                1,36 MiB
extra/python-userpath  1.9.2-4                0,08 MiB
extra/python-pipx      1.11.1-1               0,92 MiB
```

### Установка vkbasalt-cli через pipx

```bash
pipx install vkbasalt-cli

#альтернативно скачать, если требуется определённая версия
pip download vkbasalt-cli==3.1.1.post2 --dest /tmp/packages
pip download vkbasalt-cli==3.1.1.post2 --dest /tmp/packages --no-deps
```

**Что происходит:**
1. pipx создает виртуальное окружение в `~/.local/share/pipx/venvs/vkbasalt-cli`
2. Устанавливает пакет и все его зависимости в это окружение
3. Создает символические ссылки на исполняемые файлы в `~/.local/bin/`

**Результат:**
```
  installed package vkbasalt-cli 3.1.1.post2, installed using Python 3.14.4
  These apps are now available
    - vkbasalt
⚠  Note: '/home/kiko/.local/bin' is not on your PATH environment variable.
```

### Добавление ~/.local/bin в PATH

Чтобы система могла находить исполняемые файлы из `~/.local/bin`, нужно добавить эту директорию в переменную окружения PATH:

```bash
pipx ensurepath
```

**Результат:**
```
Success! Added /home/kiko/.local/bin to the PATH environment variable.

Consider adding shell completions for pipx. Run 'pipx completions' for instructions.

You will need to open a new terminal or re-login for the PATH changes to take effect.
```

**Важно:** После этой команды нужно либо перезапустить терминал, либо выполнить:
```bash
source ~/.bashrc
```

### Проверка установки

```bash
which vkbasalt
```

Должно показать:
```
/home/kiko/.local/bin/vkbasalt
```

### Обновление vkbasalt-cli (если нужно)

```bash
pipx upgrade vkbasalt-cli
```

---

## Установка Flatpak (опционально)

**Flatpak** — это система для установки изолированных приложений. Она не зависит от версий библиотек в системе, что делает приложения более стабильными. Flatpak-версия Heroic Games Launcher — хорошая альтернатива AUR-версии.

### Установка Flatpak

```bash
sudo pacman -S flatpak
```

**Что устанавливается:**
- `composefs` — файловая система для контейнеров
- `ostree` — система для управления образами
- `flatpak` — основной пакет

**Процесс установки:**
```
Пакет (3)        Новая версия  Изменение размера
extra/composefs  1.0.8-1                0,15 MiB
extra/ostree     2025.7-3               4,37 MiB
extra/flatpak    1:1.16.6-1             7,36 MiB
```

### Добавление репозитория Flathub

Flathub — это основной репозиторий приложений для Flatpak:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Установка Heroic Games Launcher через Flatpak

```bash
flatpak install flathub com.heroicgameslauncher.hgl
```

### Запуск Flatpak-версии

```bash
flatpak run com.heroicgameslauncher.hgl
```

---

## Настройка и использование Heroic Games Launcher

### Первый запуск

Запустите Heroic Games Launcher любым способом:

**Из терминала:**
```bash
heroic
```

**Из меню приложений:**
Найдите "Heroic Games Launcher" в меню (обычно в разделе "Игры")

### Вход в Epic Games

1. **На левой панели нажмите "Log in"**

2. **Выберите "Epic Games"** из списка сервисов

3. **Авторизация через браузер:**
   - Откроется встроенное окно браузера
   - Введите логин (email) и пароль от Epic Games
   - Если страница не загружается, нажмите кнопку обновления в верхней части окна
   - После успешного входа окно закроется автоматически

4. **Библиотека игр:**
   - После входа все ваши игры появятся в разделе "Library"
   - Игры синхронизируются с вашим аккаунтом Epic Games

### Установка Proton-GE

**Proton-GE** — это кастомная сборка Proton от сообщества GloriousEggroll. Она содержит множество патчей и исправлений, которых нет в официальном Proton.

**Почему Proton-GE:**
- Поддержка большего количества игр
- Исправления для видео-кодеков
- Улучшенная совместимость с медиа-контентом в играх

**Как установить:**

1. На левой панели нажмите **"Wine Manager"** (иконка с бутылкой)

2. В верхней части окна выберите вкладку **"Proton-GE"**

3. Нажмите **"Download"** на самой последней версии (с самым большим номером)

4. Дождитесь завершения загрузки — статус изменится на "Installed"

### Настройка Wine/Proton по умолчанию

1. Нажмите на **шестеренку (Settings)** в левом нижнем углу

2. Перейдите в раздел **"Wine"**

3. В выпадающем списке **"Wine Version"** выберите установленный Proton-GE

4. Остальные настройки можно оставить по умолчанию

### Настройка путей для игр

1. В разделе **"Settings"** перейдите в **"Game Defaults"**

2. В поле **"Install path"** укажите папку для установки игр:
   ```
   /home/ваше_имя/Games
   ```
   (создайте эту папку, если её нет: `mkdir ~/Games`)

3. В поле **"Wine prefix"** укажите:
   ```
   /home/ваше_имя/Games/Heroic/Prefixes
   ```
   (здесь будут храниться виртуальные окружения Wine для каждой игры)

### Установка игры

1. Перейдите в раздел **"Library"**

2. Найдите игру, которую хотите установить

3. Нажмите кнопку **"Install"**

4. **Настройки установки:**
   - **Install Path** — можно оставить по умолчанию
   - **Wine Version** — выберите Proton-GE (если не выбран автоматически)
   - **Language** — выберите язык игры

5. Нажмите **"Install"** и дождитесь завершения загрузки

### Запуск игры

1. В разделе **"Library"** нажмите на игру

2. Нажмите **"Play"** (зеленая кнопка)

**Важно:** Первый запуск может занять несколько минут — в это время:
- Создается Wine префикс (виртуальное окружение Windows)
- Компилируются шейдеры
- Настраиваются библиотеки

### Настройки для конкретной игры

У каждой игры есть индивидуальные настройки. Чтобы их открыть:

1. Нажмите на игру в библиотеке
2. Нажмите на **три точки** (⋮) или **шестеренку** рядом с кнопкой Play
3. Выберите **"Settings"**

**Полезные настройки для игр:**
- **Wine Version** — можно указать другую версию Proton для конкретной игры
- **Wine Arguments** — дополнительные аргументы запуска (например, `-dx11` для принудительного использования DirectX 11)
- **Environment Variables** — переменные окружения для отладки
- **Sync Mode** — выбор метода синхронизации (Esync, Fsync)

### Облачные сохранения

Heroic Games Launcher поддерживает облачные сохранения для Epic Games. Они синхронизируются автоматически при условии, что игра поддерживает эту функцию.

**Проверка статуса облачных сохранений:**
1. Откройте настройки игры
2. Найдите раздел **"Cloud saves"**
3. Должно быть отмечено "Enabled"

---

## Альтернативный способ: Lutris

**Lutris** — это универсальный менеджер игр с открытым исходным кодом. Он поддерживает огромное количество источников: Steam, Epic Games, GOG, Humble Bundle, эмуляторы консолей и даже физические диски.

### Установка Lutris

```bash
sudo pacman -S lutris
```

### Установка библиотеки для сети

Для корректной работы Epic Games Store в Lutris необходима 32-битная версия библиотеки `gnutls`:

```bash
sudo pacman -S lib32-gnutls
```

**Зачем это нужно:** Epic Games Store использует защищенные соединения (HTTPS) через 32-битную версию библиотеки GnuTLS. Без неё страница входа может не загружаться.

### Установка Epic Games Store через Lutris

1. **Запустите Lutris:**
   ```bash
   lutris
   ```

2. **Нажмите на значок «+»** в левом верхнем углу

3. **Выберите «Поиск в онлайн-библиотеке Lutris»** (Search the Lutris website)

4. **Введите в поиске «Epic Games»**

5. **Нажмите на результат «Epic Games Store»**

6. **Нажмите «Install»**

7. **Выберите папку для установки** (можно оставить по умолчанию: `/home/Games/epic-games-store`)

8. **Дождитесь завершения установки** — Lutris автоматически:
   - Скачает подходящую версию Wine (Wine-GE)
   - Создаст Wine префикс
   - Установит Epic Games Store
   - Настроит все необходимые параметры

### Запуск Epic Games Store в Lutris

1. В главном окне Lutris найдите **«Epic Games Store»** в списке игр

2. Нажмите **«Play»** (треугольник)

3. **Войдите в аккаунт** в открывшемся окне Epic Games Store

4. **Устанавливайте игры** через интерфейс самого Epic Games Store

### Установка игр через Lutris

В отличие от Heroic Games Launcher, где установкой управляет сам лаунчер, в Lutris процесс выглядит так:

1. Запустите Epic Games Store через Lutris
2. Войдите в аккаунт
3. Найдите игру в библиотеке Epic Games Store
4. Нажмите "Установить" в интерфейсе Epic Games Store
5. Выберите папку для установки (рекомендуется создавать папки внутри Wine префикса)

### Добавление установленной игры в Lutris

Чтобы игра появилась в основном интерфейсе Lutris:

1. В Lutris нажмите «+» → «Добавить локально установленную игру»

2. Заполните поля:
   - **Name** — название игры
   - **Runner** — выберите «Wine»
   - **Executable** — укажите путь к .exe файлу игры

### Настройка Wine для конкретной игры в Lutris

1. Нажмите правой кнопкой мыши на игру
2. Выберите **«Configure»**
3. Перейдите в раздел **«Runner options»**
4. Настройте:
   - **Wine version** — выберите последнюю версию Wine-GE
   - **Enable DXVK/VKD3D** — включено для поддержки DirectX
   - **Enable Esync/Fsync** — улучшение производительности

---

## Решение типичных проблем

### Проблема 1: Ошибка «externally-managed-environment» при использовании pip

**Ошибка:**
```
error: externally-managed-environment
× This environment is externally managed
╰─> To install Python packages system-wide, try 'pacman -S python-xyz'
```

**Причина:** Arch Linux защищает системный Python от случайной поломки через pip. Это правильное поведение, а не баг.

**Решение:** Использовать `pipx` или создать виртуальное окружение:

```bash
# Вариант 1: pipx (рекомендуется)
sudo pacman -S python-pipx
pipx install package_name

# Вариант 2: виртуальное окружение
python -m venv myenv
source myenv/bin/activate
pip install package_name
```

### Проблема 2: Таймаут при клонировании из GitLab

**Ошибка:**
```
error: RPC failed; curl 56 Recv failure: Время ожидания соединения истекло
fatal: неожиданный конец файла
```

**Причины:**
- Медленное или нестабильное соединение с GitLab
- Сетевая блокировка GitLab
- Большой размер репозитория

**Решения:**

1. **Использовать зеркало AUR на GitHub** (paru автоматически пытается):
   ```bash
   paru -S пакет --mkmakepkg-option "'--skippgpcheck'"
   ```

2. **Установить через pipx** (для Python-пакетов):
   ```bash
   pipx install vkbasalt-cli
   ```

3. **Использовать Flatpak версию**:
   ```bash
   flatpak install flathub com.usebottles.bottles
   ```

4. **Увеличить таймаут Git:**
   ```bash
   git config --global http.postBuffer 524288000
   git config --global http.lowSpeedLimit 0
   git config --global http.lowSpeedTime 999999
   ```

5. **Использовать прокси или Tor:**
   ```bash
   # Через Tor
   sudo systemctl start tor
   git config --global http.proxy socks5://127.0.0.1:9050
   git config --global https.proxy socks5://127.0.0.1:9050
   ```

### Проблема 3: Страница входа Epic Games не загружается в Heroic

**Причина:** Отсутствие 32-битных библиотек для сети.

**Решение:**
```bash
sudo pacman -S lib32-gnutls
```

Если не помогло, попробуйте использовать встроенный браузер:

1. Откройте настройки Heroic
2. Найдите раздел **"Advanced"**
3. Включите **"Use alternative login method"** или **"Use external browser for login"**

### Проблема 4: Игра не запускается или вылетает

**Пошаговая диагностика:**

1. **Проверьте версию Proton:**
   - В настройках игры попробуйте другую версию Proton-GE
   - Иногда старые игры лучше работают с Wine-GE, чем с Proton-GE

2. **Проверьте наличие Vulkan:**
   ```bash
   vulkaninfo | grep "deviceName"
   ```
   Если команда не найдена:
   ```bash
   sudo pacman -S vulkan-tools
   ```

3. **Запустите игру из терминала для просмотра логов:**
   ```bash
   heroic
   # Затем запустите игру и смотрите вывод в терминале
   ```

4. **Очистите Wine префикс:**
   - Удалите папку с префиксом игры
   - При следующем запуске префикс создастся заново

5. **Проверьте права на папку с играми:**
   ```bash
   ls -la ~/Games
   chown -R ваш_пользователь:ваш_пользователь ~/Games
   ```

### Проблема 5: Отсутствует звук в игре

**Решение:**
```bash
# Установка дополнительных аудио-библиотек
sudo pacman -S lib32-pipewire lib32-pulseaudio
```

В настройках игры в Heroic попробуйте включить **"Faudio"** (продвинутая звуковая прослойка для Wine).

### Проблема 6: Нет видео в игре (черный экран при воспроизведении роликов)

**Причина:** Отсутствие кодеков.

**Решение:**
```bash
sudo pacman -S gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly
sudo pacman -S lib32-gst-plugins-base lib32-gst-plugins-good lib32-gst-plugins-bad
```

Или используйте Proton-GE — он уже включает все необходимые кодеки.

---

## Очистка системы

В процессе работы мы накопили кэш и временные пакеты. Их можно и нужно удалять для экономии места.

### Очистка кэша paru

```bash
paru -c
```

**Что делает эта команда:**
- Удаляет пакеты, которые больше не нужны (сироты)
- Очищает кэш скачанных пакетов
- Освобождает дисковое пространство

**В нашем случае было удалено:**
```
Пакет (27)                      Старая версия  Изменение размера
ada                             3.4.4-1                -1,08 MiB
blueprint-compiler              0.20.4-1               -2,70 MiB
fvs2                            0.1.5-1                -2,95 MiB
go                              2:1.26.2-1           -215,45 MiB
icoextract                      0.2.0-4                -0,06 MiB
meson                           1.10.2-1              -16,09 MiB
node-gyp                        12.2.0-1               -7,84 MiB
nodejs                          25.9.0-1              -63,78 MiB
nodejs-nopt                     9.0.0-1                -0,03 MiB
npm                             11.12.1-1              -7,47 MiB
patool                          4.0.4-1                -0,62 MiB
python-build                    1.4.3-1                -0,26 MiB
python-click                    8.3.2-1                -1,36 MiB
python-fvs                      0.3.4-4                -0,22 MiB
python-installer                0.7.0-14               -0,20 MiB
python-pathvalidate             3.3.1-1                -0,30 MiB
python-pycurl                   7.45.7-3               -0,40 MiB
python-pyproject-hooks          1.2.0-6                -0,11 MiB
python-setuptools-reproducible  0.1-1                  -0,02 MiB
python-setuptools-scm           10.0.5-1               -0,15 MiB
python-steamgriddb              1.0.5-5                -0,20 MiB
python-tqdm                     4.67.3-1               -0,62 MiB
python-vcs-versioning           1.1.1-1                -0,80 MiB
python-yara                     4.5.4-1                -0,06 MiB
semver                          7.7.4-1                -0,09 MiB
simdjson                        1:4.6.1-1              -7,55 MiB
yara                            4.5.5-1                -1,31 MiB

Будет освобождено:  331,71 MiB
```

### Очистка кэша pacman

```bash
sudo pacman -Sc
```
Удаляет все старые версии пакетов из кэша, оставляя только последние.

```bash
sudo pacman -Scc
```
Удаляет **весь** кэш (будьте осторожны — после этого при переустановке пакетов их придется скачивать заново).

### Очистка кэша pip/pipx

```bash
pip cache purge
pipx uninstall-all  # если нужно удалить все пакеты pipx
```

### Очистка временных файлов

```bash
rm -rf ~/.cache/paru/clone/*  # удалить клонированные репозитории AUR
rm -rf /tmp/*  # временные файлы (только не от root)
```

---

## Сравнение Heroic Games Launcher и Lutris

| Характеристика | Heroic Games Launcher | Lutris |
|----------------|------------------------|--------|
| **Специализация** | Epic Games, GOG, Amazon | Все игровые платформы |
| **Сложность установки** | Низкая (одна команда) | Средняя |
| **Интерфейс** | Собственный, современный | Единый для всех игр |
| **Управление играми** | Через интерфейс лаунчера | Через Epic Games Store |
| **Wine/Proton** | Автоматическая настройка | Ручная или автоматическая |
| **Облачные сохранения** | Поддерживаются | Зависят от платформы |
| **Импорт установленных игр** | Да | Да |
| **Поддержка модов** | Ограниченная | Расширенная |
| **Для кого** | Новички и casual-геймеры | Опытные пользователи |

### Когда выбирать Heroic Games Launcher

- ✅ Вы в основном играете в игры из Epic Games Store
- ✅ Хотите простой и понятный интерфейс
- ✅ Не хотите разбираться в настройках Wine
- ✅ Нужен быстрый доступ к библиотеке

### Когда выбирать Lutris

- ✅ У вас есть игры из разных источников (Steam, GOG, Humble, физические диски)
- ✅ Вы хотите управлять ВСЕМИ играми из одного приложения
- ✅ Вам нужна поддержка эмуляторов (PS2, GameCube, SNES и т.д.)
- ✅ Вы готовы потратить время на настройку

---

## Заключение

Мы проделали полный путь от установки системы до запуска первой игры из Epic Games Store. Вот итоговый список всех выполненных действий:

### Краткий чек-лист (что мы сделали):

1. **Обновили систему:** `sudo pacman -Syu`
2. **Установили Heroic Games Launcher:** `paru -S heroic-games-launcher-bin`
3. **Столкнулись с проблемой GitLab** при попытке установить vkbasalt-cli
4. **Решили проблему через pipx:** `sudo pacman -S python-pipx`, `pipx install vkbasalt-cli`, `pipx ensurepath`
5. **Установили Flatpak** (как альтернативу): `sudo pacman -S flatpak`
6. **Настроили Heroic:** вошли в Epic Games, установили Proton-GE
7. **Очистили систему:** `paru -c`

### Итоговые установленные пакеты:

| Пакет | Версия | Назначение |
|-------|--------|------------|
| heroic-games-launcher-bin | 2.20.1-1 | Лаунчер для Epic Games |
| python-pipx | 1.11.1-1 | Установка Python-приложений |
| vkbasalt-cli | 3.1.1.post2 | Графическая постобработка |
| flatpak | 1:1.16.6-1 | Система изолированных приложений |
| lib32-gnutls | (последняя) | Сетевые библиотеки для 32-битных приложений |

### Ключевые выводы:

1. **Heroic Games Launcher** — это лучший выбор для запуска Epic Games на Endeavour OS. Он прост, надежен и не требует глубоких знаний Linux.

2. **Проблемы с GitLab** решаются через pipx. Это официально рекомендованный способ установки Python-приложений в Arch Linux.

3. **Proton-GE** необходим для максимальной совместимости с играми. Устанавливайте последнюю версию через Wine Manager в Heroic.

4. **Не бойтесь ошибок** — почти все проблемы имеют простое решение. Сообщество Arch Linux очень активное, и ответы на большинство вопросов можно найти за 5 минут поиска.

5. **Очистка системы** после установки помогает освободить место. `paru -c` удалил более 300 МБ временных файлов.

### Полезные ресурсы:

- [Официальный сайт Heroic Games Launcher](https://heroicgameslauncher.com/)
- [ProtonDB](https://www.protondb.com/) — проверка совместимости игр с Proton


