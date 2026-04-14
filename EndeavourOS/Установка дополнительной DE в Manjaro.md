см. также 
- [Пакетные менеджеры в Manjaro.md](https://github.com/sherbettt/BASH-cheats/blob/main/06.1.%20Пакетные%20менеджеры%20в%20Manjaro.md)
- [Смена раскладки на Wayland (GNOME).md](https://github.com/sherbettt/BASH-cheats/blob/main/Смена%20раскладки%20на%20Wayland%20(GNOME).md)
<br/>


### **1. Установили GNOME поверх XFCE**
```bash
# Установили GNOME компоненты
sudo pacman -S gnome gnome-extra

# Установили gnome-session для поддержки в LightDM
sudo pacman -S gnome-session
```

### **2. Не меняли дисплейный менеджер**
- Оставили **LightDM** (который был с XFCE)
- Не стали переходить на GDM (чтобы не усложнять)

### **3. Добавили GNOME сессию в LightDM**
Установка `gnome-session` автоматически создала:
- `/usr/share/xsessions/gnome.desktop`
- `/usr/share/xsessions/gnome-xorg.desktop`

## **Как переключаться между окружениями:**

### **ПРИ ВХОДЕ В СИСТЕМУ:**
1. **Выходим из текущей сессии** (Logout)
2. **На экране входа LightDM** видим:
   - Поле для ввода пароля
   - В **правом нижнем углу** - кнопка выбора сессии

3. **Нажимаем на текущую сессию** (например, "XFCE Session")
4. **Появляется список доступных сессий:**
   ```
   ┌──────────────────────────┐
   │ • XFCE Session           │ ← Текущая
   │ • GNOME                  │ ← Новая GNOME сессия
   │ • GNOME on Xorg          │ ← GNOME на X11 (стабильнее)
   │ • GNOME on Wayland       │ ← Если установлена поддержка
   └──────────────────────────┘
   ```

5. **Выбираем нужную сессию**
6. **Вводим пароль** - загружается выбранное окружение

## **Ключевые моменты:**

### **Что установилось:**
```
/usr/share/xsessions/
├── xfce.desktop          # Ваше оригинальное XFCE
├── gnome.desktop         # GNOME (обычно Wayland)
└── gnome-xorg.desktop    # GNOME на Xorg
```

### **Где хранятся настройки:**
```
~/.config/
├── xfce4/                # Настройки XFCE
└── gnome/                # Настройки GNOME (создастся при первом входе)

~/.cache/
├── xfce4/                # Кэш XFCE
└── gnome/                # Кэш GNOME

~/.local/share/
├── xfce4/                # Данные XFCE
└── gnome/                # Данные GNOME
```

## **Преимущества такого подхода:**

1. **Легковесность** - оставили LightDM вместо GDM
2. **Гибкость** - можно выбрать сессию при каждом входе
3. **Безопасность** - если GNOME не понравится, просто выбираем XFCE
4. **Раздельные настройки** - темы, обои, приложения настраиваются отдельно

## **Как удалить GNOME (если не понравится):**
```bash
# Удалить GNOME, но оставить общие зависимости
sudo pacman -Rsn gnome gnome-extra gnome-session

# Или полное удаление
sudo pacman -Rsc gnome

# После удаления в LightDM останется только XFCE сессия
```

## **Добавить другие окружения:**
По аналогии можно установить:
```bash
# KDE Plasma
sudo pacman -S plasma plasma-wayland-session

# Cinnamon
sudo pacman -S cinnamon

# Mate
sudo pacman -S mate mate-extra

# После установки - перезапустить LightDM
sudo systemctl restart lightdm
```

## **Важные команды для управления:**
```bash
# Посмотреть все доступные сессии
ls /usr/share/xsessions/

# Узнать текущую сессию (изнутри системы)
echo $XDG_CURRENT_DESKTOP

# Узнать какой display manager используется
cat /etc/systemd/system/display-manager.service 2>/dev/null

# Перезапустить LightDM без перезагрузки
sudo systemctl restart lightdm
```

## **Итоговая последовательность для любой новой DE:**

1. **Обновить систему:**
   ```bash
   sudo pacman -Syu
   ```

2. **Установить DE:**
   ```bash
   sudo pacman -S имя-de имя-de-extra
   ```

3. **Установить сессию для LightDM (если нужно):**
   ```bash
   sudo pacman -S имя-de-session
   ```

4. **Перезапустить LightDM:**
   ```bash
   sudo systemctl restart lightdm
   ```

5. **Выйти и выбрать новую сессию** в LightDM

## **Советы:**
- **Тестируйте новые DE в Live-сессии** перед полной установкой
- **Делайте бэкап системы** перед экспериментами
- **Каждое окружение** имеет свои горячие клавиши и логику работы


