## 1. Скачать AppImage
Выполняйте любым удобным способом. Качаем https://express.ms/download/appimage

## 2. Запуск приложения (без терминала)

### 1. **Создайте `.desktop` файл** для интеграции в систему:

```bash
mcedit ~/.local/share/applications/express.desktop
```

Вставьте туда следующее содержимое:
*путь к располдожению файла подставить свой*
```ini
[Desktop Entry]
Name=eXpress
Comment=Корпоративный мессенджер
Exec=/home/kkorablin/Загрузки/eXpress-3.67.45.AppImage
Icon=/home/kkorablin/Загрузки/eXpress-3.67.45.AppImage
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupWMClass=eXpress
```

Сохраните (F2, Enter) и выйдите (F10).

2. **Обновите базу приложений** (иногда не нужно, но на всякий случай):
```bash
update-desktop-database ~/.local/share/applications/
```

Теперь eXpress появится в меню приложений (например, в EndeavourOS — в меню "Интернет" или поиске по Alt+F2), и запуск будет без терминала.

---

### **Вариант 2: Запуск в фоновом режиме**

Если хотите запускать прямо из терминала, но чтобы он не был занят:

```bash
~/Загрузки/eXpress-3.67.45.AppImage &
```

`&` отправляет процесс в фон. Терминал освободится сразу.

Чтобы процесс не завершился при закрытии терминала:
```bash
nohup ~/Загрузки/eXpress-3.67.45.AppImage > /dev/null 2>&1 &
```

---

### **Вариант 3: Создать алиас (для быстрого запуска)**

Добавьте в `~/.bashrc` или `~/.zshrc`:

```bash
echo 'alias express="nohup ~/Загрузки/eXpress-3.67.45.AppImage > /dev/null 2>&1 &"' >> ~/.bashrc
source ~/.bashrc
```

Теперь просто вводите `express` в терминале, и приложение запустится в фоне.

---

### **Вариант 4: Перенести AppImage в удобное место**

AppImage можно хранить где угодно. Рекомендую перенести его в `~/Applications/` или `~/.local/bin/`:

```bash
mkdir -p ~/.local/bin
mv ~/Загрузки/eXpress-3.67.45.AppImage ~/.local/bin/express.AppImage
chmod +x ~/.local/bin/express.AppImage
```

И тогда в `.desktop` файле путь будет:
```
Exec=/home/kkorablin/.local/bin/express.AppImage
```

---

##  **Итог**

**Самое правильное решение** — создать `.desktop` файл (Вариант 1). Тогда eXpress будет полноценным приложением в системе:
- Запускается из меню, иконка будет видна
- Не привязан к терминалу
- Можно закрепить на панели задач

После этого просто ищите eXpress в меню приложений или через поиск (Alt+F2 → введите "eXpress").

Ошибки `Gtk: gtk_widget_get_scale_factor` — это не страшно, они не влияют на работу. Это просто предупреждения от библиотек GTK, их можно игнорировать.


