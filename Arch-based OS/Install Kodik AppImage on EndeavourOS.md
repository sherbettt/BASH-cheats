## Полная инструкция для GNOME

### Шаг 1: Создайте папку `Applications` в домашней директории
Откройте терминал и выполните:
```bash
mkdir -p ~/Applications
```

### Шаг 2: Переместите Kodik в эту папку
```bash
mv ~/Загрузки/Kodik-1.4.0.AppImage ~/Applications/
```

### Шаг 3: Сделайте файл исполняемым
```bash
chmod +x ~/Applications/Kodik-1.4.0.AppImage
```

### Шаг 4: Создайте `.desktop` файл (это ярлык для GNOME)
Откройте текстовый редактор (например, `gnome-text-editor` или `nano`) и создайте файл:
```bash
nano ~/.local/share/applications/kodik.desktop
```

**Скопируйте и вставьте** это содержимое:
```ini
[Desktop Entry]
Name=Kodik
Comment=AI платформа для разработчиков
Exec=/home/kkorablin/Applications/Kodik-1.4.0.AppImage
Icon=applications-development
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Kodik
```

⚠️ **Важно**: В строке `Exec=` замените `kkorablin` на ваше имя пользователя, если оно другое.  
Можно проверить: `echo $HOME` покажет ваш путь.

### Шаг 5: Сохраните файл
- В **nano**: нажмите `Ctrl+O`, затем `Enter`, затем `Ctrl+X`
- В **gnome-text-editor**: просто сохраните

### Шаг 6: Обновите базу приложений GNOME
```bash
update-desktop-database ~/.local/share/applications/
```

### Шаг 7: Проверьте меню приложений
Нажмите `Super` (Windows) или кликните на «Сетка приложений» в GNOME, найдите **Kodik**.

## Альтернативный, более простой способ (без ручного создания файла)

Установите утилиту `appimaged`, которая автоматически добавляет все `.AppImage` из `~/Applications` в меню:

```bash
# Сначала установите libappimage (ещё нет в официальных репозиториях EndeavourOS)
yay -S appimaged
```

Затем запустите:
```bash
appimaged &
```

Теперь любые `.AppImage` в `~/Applications` будут **автоматически** появляться в меню GNOME.

## Как запустить сейчас (без перезагрузки)

Или просто запустите двойным кликом из файлового менеджера (Nautilus) после шага 3.

