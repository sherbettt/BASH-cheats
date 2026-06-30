# Установка и настройка корпоративного мессенджера eXpress в Arch Linux / EndeavourOS

## 📥 1. Скачивание AppImage

Скачайте последнюю версию AppImage с официального сайта:
- **Ссылка**: https://express.ms/download/appimage
- Или через терминал:
```bash
wget -O ~/Загрузки/eXpress.AppImage https://express.ms/download/appimage
```

---

## 🚀 2. Подготовка к запуску

### Сделайте файл исполняемым:
```bash
chmod +x ~/Загрузки/eXpress.AppImage
```

### Проверьте, что AppImage работает:
```bash
~/Загрузки/eXpress.AppImage
```
Если окно открылось — всё хорошо. Закройте приложение и продолжайте настройку.

---

## 🖥️ 3. Интеграция в систему (запуск без терминала)

### Вариант А: Создание .desktop файла (рекомендуемый)

Создайте файл для интеграции в меню приложений:
```bash
mcedit ~/.local/share/applications/express.desktop
```

Вставьте следующее содержимое (подставьте свой путь к файлу):
```ini
[Desktop Entry]
Version=1.0
Name=eXpress
Comment=Корпоративный мессенджер
Exec=/home/kkorablin/Загрузки/eXpress.AppImage
Icon=/home/kkorablin/Загрузки/eXpress.AppImage
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupNotify=true
StartupWMClass=eXpress
```

**Важно**: 
- Если у вас другая версия (например, `eXpress-3.67.45.AppImage`), укажите полное имя файла
- Путь должен быть абсолютным (от корня `/`)

Сохраните (F2 → Enter) и выйдите (F10).

Обновите базу приложений:
```bash
update-desktop-database ~/.local/share/applications/
```

Проверьте синтаксис .desktop файла:
```bash
desktop-file-validate ~/.local/share/applications/express.desktop
```
Если команда не выдала ошибок — всё сделано правильно.

Теперь eXpress появится в меню приложений (поиск по Alt+F2 → "eXpress").

---

### Вариант Б: Перенос AppImage в постоянное место

Хранить AppImage в папке `Загрузки` неудобно — можно случайно удалить. Перенесите в специальную папку:

```bash
mkdir -p ~/.local/bin
mv ~/Загрузки/eXpress.AppImage ~/.local/bin/express.AppImage
chmod +x ~/.local/bin/express.AppImage
```

После этого обновите путь в `.desktop` файле:
```bash
mcedit ~/.local/share/applications/express.desktop
```
Замените строку `Exec=` на:
```
Exec=/home/kkorablin/.local/bin/express.AppImage
```

И так же для `Icon=`:
```
Icon=/home/kkorablin/.local/bin/express.AppImage
```

Обновите базу:
```bash
update-desktop-database ~/.local/share/applications/
```

---

### Вариант В: Запуск из терминала в фоне

Если хотите запускать из терминала без блокировки:

```bash
~/Загрузки/eXpress.AppImage &
```

Или с полным отвязыванием от терминала (процесс не завершится при закрытии терминала):
```bash
nohup ~/Загрузки/eXpress.AppImage > /dev/null 2>&1 &
```

---

### Вариант Г: Алиас для быстрого запуска

Добавьте в `~/.bashrc` или `~/.zshrc`:
```bash
echo 'alias express="nohup ~/.local/bin/express.AppImage > /dev/null 2>&1 &"' >> ~/.bashrc
source ~/.bashrc
```
Теперь можно запускать просто командой `express` в терминале.

---

## 📂 5. Где хранятся данные

Данные eXpress хранятся в скрытых папках в домашней директории:
```bash
~/.config/express/          # Настройки приложения
~/.local/share/express/     # Кэш, логи, сохраненные файлы
```

Если нужно сбросить настройки или очистить кэш — удалите эти папки (приложение пересоздаст их при следующем запуске).

---

## 🔄 6. Обновление приложения

AppImage не обновляется автоматически. Для обновления:

1. Скачайте новый `.AppImage` с официального сайта
2. Замените старый файл:
```bash
mv ~/Загрузки/eXpress-новый.AppImage ~/.local/bin/express.AppImage
chmod +x ~/.local/bin/express.AppImage
```
3. **Не нужно** пересоздавать `.desktop` файл, если путь не изменился
4. Если изменилось имя файла, обновите только `Exec=` и `Icon=` в `.desktop`

---

## 🗑️ 7. Удаление eXpress

Если приложение больше не нужно:

```bash
# Удалить AppImage
rm ~/.local/bin/express.AppImage   # или откуда вы его запускаете

# Удалить .desktop файл
rm ~/.local/share/applications/express.desktop

# Обновить базу
update-desktop-database ~/.local/share/applications/

# Удалить настройки и данные (опционально)
rm -rf ~/.config/express/ ~/.local/share/express/
```

---

## 🛠️ 8. Устранение неполадок

### Проблема: Приложение не запускается из меню

1. **Проверьте пути** в `.desktop` файле — они должны быть абсолютными:
```bash
cat ~/.local/share/applications/express.desktop
```

2. **Проверьте права** на AppImage:
```bash
chmod +x ~/.local/bin/express.AppImage
```

3. **Проверьте синтаксис**:
```bash
desktop-file-validate ~/.local/share/applications/express.desktop
```

4. **Пересоздайте .desktop файл** (удалите и создайте заново)

5. **Проверьте видимость в системе**:
```bash
xdg-desktop-menu list | grep express
```

### Проблема: Ошибки GTK в терминале

Ошибки вида:
```
Gtk: gtk_widget_get_scale_factor: assertion 'GTK_IS_WIDGET (widget)' failed
```

Это **не критично** — это предупреждения библиотек GTK, на работу приложения они не влияют. Можно игнорировать.

### Проблема: Не работает микрофон/камера

Проверьте, что система видит устройства:
```bash
pactl list sources          # для PulseAudio
pactl list short sources    # краткий список
```

Если используется Wayland, попробуйте запустить с флагом:
```bash
~/Загрузки/eXpress.AppImage --ozone-platform=x11
```

---

## 💎 9. Краткая памятка

| Действие | Команда / способ |
|----------|------------------|
| **Скачать** | `wget -O ~/Загрузки/eXpress.AppImage https://express.ms/download/appimage` |
| **Сделать исполняемым** | `chmod +x ~/Загрузки/eXpress.AppImage` |
| **Проверить** | `~/Загрузки/eXpress.AppImage` |
| **Запуск из меню** | Alt+F2 → `eXpress` |
| **Закрепить на панели** | ПКМ по иконке → "Закрепить" |
| **Обновить** | Скачать новый AppImage → заменить старый |
| **Удалить** | `rm ~/.local/share/applications/express.desktop` + `rm ~/.local/bin/express.AppImage` |

---

## 📝 Примечания

- Приложение работает на **X11** и **Wayland** (но могут быть мелкие особенности)
- Для корпоративной версии потребуется доступ к серверу компании
- Публичная версия работает через регистрацию по номеру телефона
- Все настройки сохраняются между перезапусками

---

