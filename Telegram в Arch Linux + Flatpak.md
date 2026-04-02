# Инструкция по установке Telegram в Arch Linux (с решением проблемы Flatpak)

## Проблема: Flatpak-приложения не отображаются в меню

При добавлении репозитория Flathub вы можете увидеть предупреждение:
```
Обратите внимание, что каталоги 
'/var/lib/flatpak/exports/share'
'/home/kkorablin/.local/share/flatpak/exports/share'
не находятся по пути поиска, заданном переменной окружения XDG_DATA_DIRS,
поэтому приложения, установленные Flatpak, могут не отображаться на рабочем
столе, пока сеанс не будет перезапущен.
```

**Решение этой проблемы описано в разделе 4.**

---

## 1. Установка Telegram из разных источников

### A. Установка из официального репозитория Extra (рекомендуется)

```bash
# Установка через pacman
sudo pacman -S telegram-desktop

# Запуск (обратите внимание: с большой буквы T!)
Telegram
```

**Иконка**: Создаётся автоматически в меню приложений.

**Преимущества**: 
- Полная интеграция с системой
- Простота установки и обновления
- Нет проблем с отображением в меню

### B. Установка из AUR (например, telegram-desktop-bin)

```bash
# Если используете yay
yay -S telegram-desktop-bin

# Или paru
paru -S telegram-desktop-bin

# Запуск
telegram-desktop
```

**Иконка**: Создаётся автоматически.

### C. Установка из Flatpak (Flathub)

```bash
# Добавление репозитория Flathub (если ещё не добавлен)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Установка Telegram
flatpak install flathub org.telegram.desktop

# Запуск
flatpak run org.telegram.desktop
```

---

## 2. Настройка иконки в меню пуска (GNOME/KDE)

### Для версий из Extra/AUR

Иконка появляется автоматически. Если нет:

```bash
# Проверяем наличие .desktop файла
ls /usr/share/applications/ | grep -i telegram

# Если файл есть, но не отображается - обновляем кэш
update-desktop-database

# Перезапускаем оболочку
# GNOME: Alt+F2 → 'r' → Enter
# KDE: plasmashell --replace &
```

### Для версии из Flatpak (с решением проблемы)

#### Проблема: Flatpak не добавляет свои пути в XDG_DATA_DIRS

**Решение 1: Перезапустить сеанс (самое простое)**
```bash
# Выход из системы и вход заново
# Или перезагрузка
sudo reboot
```

**Решение 2: Добавить пути в XDG_DATA_DIRS вручную**

Добавьте в `~/.bashrc` или `~/.profile`:
```bash
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share"
```

Затем выполните:
```bash
source ~/.bashrc
```

**Решение 3: Перезапустить сеанс графической оболочки**
```bash
# Для GNOME
gnome-shell --replace &

# Для KDE
kwin_x11 --replace &
# или
kwin_wayland --replace &
```

**Решение 4: Создать .desktop файл вручную (если автоматический не работает)**

```bash
# Создаём директорию, если её нет
mkdir -p ~/.local/share/applications

# Создаём .desktop файл
nano ~/.local/share/applications/telegram-flatpak.desktop
```

Содержимое:
```ini
[Desktop Entry]
Name=Telegram (Flatpak)
Comment=Telegram messenger from Flathub
Exec=flatpak run org.telegram.desktop
Icon=org.telegram.desktop
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=Telegram
X-Flatpak=org.telegram.desktop
```

```bash
# Делаем исполняемым
chmod +x ~/.local/share/applications/telegram-flatpak.desktop

# Обновляем кэш
update-desktop-database ~/.local/share/applications/
```

#### Проверка, что проблема решена

```bash
# Проверяем значение XDG_DATA_DIRS
echo $XDG_DATA_DIRS

# Должны быть видны пути Flatpak
# Должно быть что-то вроде: /home/kkorablin/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:...

# Проверяем, видит ли система .desktop файлы Flatpak
ls /var/lib/flatpak/exports/share/applications/
ls ~/.local/share/flatpak/exports/share/applications/
```

---

## 3. Создание иконки на рабочем столе

### Для любой версии:

```bash
# Копируем .desktop файл на рабочий стол
cp /usr/share/applications/telegramdesktop.desktop ~/Рабочий\ стол/ 2>/dev/null || \
cp /usr/share/applications/org.telegram.desktop.desktop ~/Рабочий\ стол/ 2>/dev/null || \
cp ~/.local/share/applications/telegram-flatpak.desktop ~/Рабочий\ стол/ 2>/dev/null

# Если файл найден, делаем его исполняемым
chmod +x ~/Рабочий\ стол/*.desktop
```

### Создание вручную:

```bash
nano ~/Рабочий\ стол/Telegram.desktop
```

Содержимое для версии из Extra/AUR:
```ini
[Desktop Entry]
Name=Telegram
Comment=Official Telegram Desktop client
Exec=/usr/bin/Telegram
Icon=telegram
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=Telegram
```

```bash
chmod +x ~/Рабочий\ стол/Telegram.desktop
```

---

## 4. Диагностика и устранение проблем

### Проблема: Приложения Flatpak не видны в меню

**Причина:** Переменная XDG_DATA_DIRS не содержит пути Flatpak.

**Диагностика:**
```bash
# Проверяем текущее значение
echo $XDG_DATA_DIRS

# Проверяем, какие директории Flatpak существуют
ls -la /var/lib/flatpak/exports/share/
ls -la ~/.local/share/flatpak/exports/share/
```

**Решение:**
```bash
# Временное решение (до перезапуска сеанса)
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share"

# Постоянное решение - добавить в ~/.profile
echo 'export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"' >> ~/.profile

# Перезапустить сеанс или выполнить
source ~/.profile
```

### Проблема: Неправильная команда запуска

Для версии из Extra команда запуска - `Telegram` (с большой буквы), а не `telegram-desktop`.

```bash
# Правильно
Telegram

# Неправильно
telegram-desktop  # команда не найдена
```

### Проблема: Две версии Telegram конфликтуют

```bash
# Проверить установленные версии
pacman -Q | grep telegram
flatpak list | grep telegram

# Удалить ненужную версию
# Удалить Flatpak
flatpak uninstall org.telegram.desktop

# Удалить системную версию
sudo pacman -Rns telegram-desktop
```

---

## 5. Обновление кэша иконок

После любых изменений .desktop файлов:

```bash
# Обновить базу desktop-файлов для системы
sudo update-desktop-database

# Обновить для пользователя
update-desktop-database ~/.local/share/applications/

# Перезапустить оболочку GNOME (Alt+F2 → 'r')
# Или перезапустить KDE
kquitapp5 plasmashell && kstart5 plasmashell
```


---

## 6. Удаление ненужных версий

```bash
# Удалить версию из Extra
sudo pacman -Rns telegram-desktop

# Удалить версию из Flatpak
flatpak uninstall org.telegram.desktop

# Удалить версию из AUR
yay -Rns telegram-desktop-bin
# или
paru -Rns telegram-desktop-bin

# Удалить все неиспользуемые Flatpak-зависимости
flatpak uninstall --unused

# Очистить кэш Flatpak
flatpak repair
```

---




