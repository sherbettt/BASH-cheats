Чтобы изменить строку `base_color=` в файле `~/.config/mc/ini` в секции `[Colors]`, выполните следующие шаги:

### 1. Откройте файл в текстовом редакторе (например, `nano` или `vim`):
```bash
nano ~/.config/mc/ini
```

### 2. Найдите секцию `[Colors]` и строку `base_color=`.  
Замените её на:
```ini
base_color=editnormal=lightgray,black:editbold=yellow,black:editmarked=black,cyan
```

### 3. Сохраните изменения:
- В `nano`: `Ctrl+O` → Enter → `Ctrl+X`  
- В `vim`: `:wq` → Enter  

### Альтернативные контрастные темы для `base_color`:
Если вам нужны другие контрастные варианты, попробуйте:

#### 1. **Высококонтрастная (белый на чёрном)**:
```ini
base_color=editnormal=white,black:editbold=brightwhite,black:editmarked=black,brightwhite
```

#### 2. **Зелёная (как классический терминал)**:
```ini
base_color=editnormal=lightgreen,black:editbold=white,black:editmarked=black,lightgreen
```

#### 3. **Синяя (для любителей тёмных тем)**:
```ini
base_color=editnormal=lightblue,black:editbold=white,black:editmarked=black,lightblue
```

#### 4. **Инверсная (чёрный на белом)**:
```ini
base_color=editnormal=black,white:editbold=black,brightwhite:editmarked=white,black
```

#### 5. **Фиолетовая (необычный стиль)**:
```ini
base_color=editnormal=lightmagenta,black:editbold=white,black:editmarked=black,lightmagenta
```

#### 6. **Оранжевая на тёмном фоне**:
```ini
base_color=editnormal=brightyellow,black:editbold=orange,black:editmarked=black,brightred
```

### Проверка изменений:
После сохранения файла перезапустите Midnight Commander (`mc`), чтобы применить настройки.  
Если изменения не вступили в силу, убедитесь, что вы редактировали правильный файл (путь может отличаться в некоторых системах — проверьте `~/.config/mc/ini` или `~/.mc/ini`). 

Если вам нужно автоматизировать замену через командную строку, используйте `sed`:
```bash
sed -i '/^\[Colors\]/,/^\[/ s/^base_color=.*/base_color=editnormal=lightgray,black:editbold=yellow,black:editmarked=black,cyan/' ~/.config/mc/ini;
```
```bash
sed -i '
/^\[Colors\]/,/^\[/ {
    s/^base_color=.*/base_color=editnormal=brightyellow,black:editbold=orange,black:editmarked=black,brightred/
}' ~/.config/mc/ini
```

### Пояснение:
- `sed -i` — редактирует файл на месте (in-place).  
- `/^\[Colors\]/,/^\[/` — диапазон строк от `[Colors]` до следующей секции (строки, начинающейся с `[`).  
- Внутри этого диапазона (`{ ... }`) выполняется замена (`s/.../.../`) строки, начинающейся с `base_color=`, на новое значение.  
- Файл для редактирования — `~/.config/mc/ini`.  

Такой формат удобнее для чтения и модификации.

Это изменит строку только в секции `[Colors]`.

--------------------

Чтобы включить подсветку текущей строки в **Midnight Commander (mc)**, нужно изменить параметр `highlight` в файле конфигурации. Вот как это сделать:

### **Способ 1: Ручное редактирование `~/.config/mc/ini`**
1. Откройте файл настроек:
   ```bash
   nano ~/.config/mc/ini
   ```
2. Найдите секцию `[Colors]` и добавьте (или измените) параметр:
   ```ini
   [Colors]
   highlight=yes          # Включает подсветку текущей строки
   base_color=...         # Ваши текущие настройки цветов
   ```
3. Сохраните (`Ctrl+O`, затем `Enter`) и выйдите (`Ctrl+X`).

### **Способ 2: Использование `sed` для автоматической настройки**
Если файл уже существует, можно добавить параметр автоматически:
```bash
sed -i '/^\[Colors\]/a highlight=yes' ~/.config/mc/ini
```

### **Способ 3: Через встроенные настройки mc**
1. Запустите `mc`.
2. Нажмите **F9** → **Options** → **Appearance**.
3. Включите опцию **Highlight current item** (подсветка текущей строки).
4. Сохраните (**Save**).

### **Дополнительные настройки цвета подсветки**
Если подсветка есть, но её плохо видно, можно изменить цвет в `~/.config/mc/skins/default.ini` (или другом используемом скине). Например:
```ini
[core]
selected=white,brightblue  # Цвет выделенной строки (передний, задний)
```

После изменений **перезапустите `mc`**, чтобы применить настройки.

### **Проверка**
- Откройте `mc`, текущая строка должна подсвечиваться.
- Если подсветка не работает, убедитесь, что в `~/.config/mc/ini` нет `highlight=no`.

Если нужно усилить контраст, попробуйте другие цвета, например:
```ini
[Colors]
highlight=yes
base_color=...,menuhot=black,yellow:menusel=black,lightgray:...
```

-------------------------------------------------

Чтобы включить отображение **номеров строк** в редакторе **Midnight Commander (mc)**, выполните следующие шаги:


### **Способ 1: Через графическое меню mc**
1. **Откройте файл** в редакторе mc (нажмите `F4` на файле).
2. Нажмите **`F9`** → **`Options`** → **`Editor options`**.
3. Включите пункт **`Line numbers`** (или **`Show line numbers`**).
4. Сохраните настройки (**`Save`**).


### **Способ 2: Ручное редактирование конфига**
1. Откройте файл настроек mc:
   ```bash
   nano ~/.config/mc/ini
   ```
2. Найдите или добавьте секцию `[Editor]` и установите:
   ```ini
   [Editor]
   line_numbers=1     # 1 — включить, 0 — выключить
   ```
3. Сохраните (`Ctrl+O` → `Enter` → `Ctrl+X`) и перезапустите `mc`.



### **Способ 3: Команда sed (если нет секции [Editor])**
```bash
sed -i '/^\[Editor\]/a line_numbers=1' ~/.config/mc/ini
```
Если секции `[Editor]` нет, она будет создана автоматически.



### **Дополнительные настройки**
- Чтобы номера строк выделялись цветом, отредактируйте параметры в `~/.config/mc/skins/default.ini`:
  ```ini
  [editor]
  line_number_color=yellow,black  # Цвет номеров (текст, фон)
  ```


### **Проверка**
1. Откройте любой файл в редакторе mc (`F4`).
2. Номера строк должны отображаться слева.

Если изменения не применились, убедитесь, что в `~/.config/mc/ini` нет противоречащих параметров (например, `line_numbers=0`).

-------------------------------------------------

В Linux можно установить редактор по умолчанию для команд, которые требуют текстового редактора (например, `git commit`, `visudo`, `crontab -e` и т. д.), с помощью переменной окружения `EDITOR` или `VISUAL`.  

### **Способы установки редактора по умолчанию**  

#### **1. Временная установка (для текущей сессии)**  
```bash
export EDITOR=/usr/bin/mcedit  # или vim, code, nano и т. д.
export VISUAL=$EDITOR       # VISUAL используется в некоторых программах
```

#### **2. Постоянная установка (для пользователя)**  
Добавьте в файл `~/.bashrc`, `~/.zshrc` (для Zsh) или `~/.profile`:  
```bash
export EDITOR=/usr/bin/nano
export VISUAL=$EDITOR
```
После этого перезагрузите оболочку:  
```bash
source ~/.bashrc  # или source ~/.zshrc
```

#### **3. Глобальная установка (для всех пользователей)**  
Можно задать редактор в `/etc/environment`:  
```bash
sudo nano /etc/environment
```
Добавьте строки:  
```
EDITOR="/usr/bin/nano"
VISUAL="/usr/bin/nano"
```
После этого перезагрузите систему или войдите заново.  

#### **4. Альтернативный способ (через update-alternatives, если поддерживается)**  
Некоторые дистрибутивы (например, Debian/Ubuntu) позволяют выбрать редактор через:  
```bash
sudo update-alternatives --config editor
```
Затем выберите нужный вариант из списка.  

### **Проверка текущего редактора**  
```bash
echo $EDITOR
echo $VISUAL
```

### **Примеры популярных редакторов**  
- Nano: `/usr/bin/nano`  
- Vim: `/usr/bin/vim`  
- Neovim: `/usr/bin/nvim`  
- VSCode: `/usr/bin/code` (если установлен)  
- Micro: `/usr/bin/micro`  



