читай https://alt-gnome.wiki/keyboard-layouts.html

Смена раскладки по Caps кнопке:
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:caps_toggle']"
```

Сброс раскладки для Caps кнопки:
```bash
gsettings reset org.gnome.desktop.input-sources xkb-options
```

Caps Lock как дополнительный Ctrl:
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
```


Caps Lock как Escape (полезно для Vim/Emacs):
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
```


Смена раскладки по  Shift+Alt L
```bash
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
```

Смена раскладки по  Alt+Shift L
```bash
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Alt>Shift_L']"
```
</br>
</br>


В GNOME (и в целом в Linux с XKB) можно назначить самые разные функции на **Caps Lock** и другие клавиши. Вот основные варианты:  

### **1. Варианты для Caps Lock (`grp:` и `caps:`)**
Команда для применения (замените значение в `xkb-options`):  
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['вариант_здесь']"
```

#### **Основные модификации Caps Lock:**
| Вариант               | Описание |
|-----------------------|----------|
| `caps:none`           | **Отключить Caps Lock** (клавиша ничего не делает) |
| `caps:escape`         | **Caps = Escape** (удобно для Vim/Emacs) |
| `caps:ctrl_modifier`  | **Caps = Ctrl** (удобно для программ, где часто используется Control) |
| `caps:super`          | **Caps = Super (Win/Command)** |
| `caps:shift`          | **Caps = Shift** (удобно для печати в верхнем регистре без удержания) |
| `caps:backspace`      | **Caps = Backspace** |
| `caps:caps`           | **Вернуть стандартное поведение** (вкл/выкл верхний регистр) |

#### **Переключение раскладки (альтернативы Caps Lock):**
| Вариант               | Описание |
|-----------------------|----------|
| `grp:caps_toggle`     | **Caps Lock переключает раскладку** (по умолчанию в примере) |
| `grp:shift_caps_toggle`| **Shift + Caps переключает раскладку** |
| `grp:alt_caps_toggle` | **Alt + Caps переключает раскладку** |



### **2. Другие полезные XKB-опции**
Можно комбинировать несколько настроек через запятую:  
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape', 'compose:ralt']"
```

#### **Отключение/переназначение других клавиш:**
| Вариант                | Описание |
|------------------------|----------|
| `ctrl:nocaps`          | **Caps Lock становится Ctrl, а оригинальный Ctrl остаётся** |
| `ctrl:swapcaps`        | **Поменять местами Caps Lock и Left Ctrl** |
| `altwin:swap_alt_win`  | **Поменять местами Alt и Win** |
| `compose:ralt`         | **Правый Alt = Compose Key** (для ввода спецсимволов, типа `ö`, `é`) |
| `terminate:ctrl_alt_bksp` | **Ctrl+Alt+Backspace завершает X-сервер** (аварийный выход) |



### **3. Переназначение клавиш через `xmodmap` (если `gsettings` недостаточно)**
Если нужно что-то сложное (например, **Caps Lock = Hyper Key**), можно использовать `xmodmap`:  
```bash
xmodmap -e "keycode 66 = Hyper_L"  # Caps Lock = Hyper
```
(но это сбрасывается после перезагрузки, нужно добавлять в автозагрузку).



### **4. Сброс всех настроек**
Чтобы вернуть всё как было:  
```bash
gsettings reset org.gnome.desktop.input-sources xkb-options
```



### **Где найти ещё варианты?**
Полный список XKB-опций можно посмотреть в:  
```bash
cat /usr/share/X11/xkb/rules/base.lst | grep -i "caps\|grp\|ctrl"
```
или в [документации XKB](https://www.x.org/releases/current/doc/xorg-docs/input/XKB-Config.html).  

Если нужно что-то нестандартное (например, **Caps Lock = F13** или **мультимедийные клавиши**), лучше использовать `xmodmap` или `setxkbmap`.


