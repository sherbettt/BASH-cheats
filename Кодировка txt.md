Если файл был создан в кодировке Windows-1251 (CP1251), вот несколько способов чтобы посмотреть на Linux:

## 1. Просмотр файла с правильной кодировкой

**Используйте iconv для конвертации:**
```bash
iconv -f WINDOWS-1251 -t UTF-8 <file>.txt
```

**Или используйте текстовые редакторы с определением кодировки:**
```bash
nano <file>.txt  # попробуйте сменить кодировку через Ctrl+\
```

## 2. Конвертация файла в UTF-8

**Создайте копию в правильной кодировке:**
```bash
iconv -f WINDOWS-1251 -t UTF-8 <file>.txt > <file>_utf8.txt
```

## 3. Для работы с файлами между Windows и Linux

**Создавайте файлы в UTF-8 на обеих системах:**

На Linux:
```bash
# Установите поддержку русской локали
sudo apt-get install locales
sudo dpkg-reconfigure locales  # выберите ru_RU.UTF-8

# Установите переменные окружения
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8
```

На Windows:
- Сохраняйте файлы в кодировке UTF-8
- Используйте редакторы типа Notepad++ с явным указанием кодировки

## 4. Автоматическое определение кодировки

**Установите утилиты для работы с кодировками:**
```bash
sudo apt-get install enca recode
```

**Определите кодировку:**
```bash
enca <file>.txt
```

**Конвертируйте:**
```bash
recode WINDOWS-1251..UTF-8 <file>.txt
```

## Рекомендация

Лучший подход - всегда использовать UTF-8 для создания текстовых файлов, которые будут использоваться на разных платформах. Сконвертируйте ваш файл в UTF-8 и в дальнейшем создавайте файлы в этой кодировке.

---------


## Как узнать кодировку файла

### 1. Команда `file` (самый простой способ)
```bash
file имя_файла.txt
file -i имя_файла.txt  # с MIME-типом
```

### 2. Команда `enca` (для определения русских кодировок)
```bash
# Установка
sudo apt-get install enca  # Debian/Ubuntu
sudo yum install enca      # CentOS/RHEL

# Использование
enca имя_файла.txt
enca -L russian имя_файла.txt  # явно указываем язык
```

### 3. Команда `uchardet`
```bash
# Установка
sudo apt-get install uchardet

# Использование
uchardet имя_файла.txt
```

### 4. Просмотр в hex-формате
```bash
hexdump -C имя_файла.txt | head -10
od -c имя_файла.txt | head -10
```

## Как создать файлы с разными кодировками

### 1. Создание UTF-8 файла (рекомендуемая)
```bash
echo "Привет мир" > файл_utf8.txt
# или
printf "Привет мир\n" > файл_utf8.txt
```

### 2. Создание файла в Windows-1251 (CP1251)
```bash
echo "Привет мир" | iconv -f UTF-8 -t WINDOWS-1251 > файл_win1251.txt
```

### 3. Создание файла в KOI8-R
```bash
echo "Привет мир" | iconv -f UTF-8 -t KOI8-R > файл_koi8r.txt
```

### 4. Создание файла в CP866 (DOS)
```bash
echo "Привет мир" | iconv -f UTF-8 -t CP866 > файл_cp866.txt
```

### 5. Использование текстовых редакторов

**Nano:**
```bash
nano +set encoding=UTF-8 файл.txt
```

**Vim:**
```bash
vim -c "set fileencoding=utf-8" файл.txt
# внутри Vim: :set fileencoding=windows-1251
```

## Полезные команды для конвертации

### Конвертация между кодировками
```bash
# UTF-8 → Windows-1251
iconv -f UTF-8 -t WINDOWS-1251 исходный.txt > конвертированный.txt

# Windows-1251 → UTF-8  
iconv -f WINDOWS-1251 -t UTF-8 исходный.txt > конвертированный.txt

# С автоматическим определением исходной кодировки
enca -L russian -x UTF-8 исходный.txt > конвертированный.txt
```

### Пакетная конвертация
```bash
# Все .txt файлы в UTF-8
for f in *.txt; do
    enca -L russian -x UTF-8 "$f" > "${f%.txt}_utf8.txt"
done
```

## Проверка созданных файлов
```bash
# Проверим кодировки созданных файлов
file файл_utf8.txt файл_win1251.txt файл_koi8r.txt

# Посмотрим содержимое
cat файл_utf8.txt
iconv -f WINDOWS-1251 -t UTF-8 файл_win1251.txt
```

## Пример создания файлов с разными кодировками
```bash
#!/bin/bash

# Создаем тестовый текст
TEXT="Привет мир! Hello world! 123"

# Создаем в разных кодировках
echo "$TEXT" > utf8.txt
echo "$TEXT" | iconv -f UTF-8 -t WINDOWS-1251 > win1251.txt
echo "$TEXT" | iconv -f UTF-8 -t KOI8-R > koi8r.txt

# Проверяем
echo "Кодировки файлов:"
file utf8.txt win1251.txt koi8r.txt

echo -e "\nРазмеры файлов:"
ls -la utf8.txt win1251.txt koi8r.txt
```

## Советы:
1. **Всегда используйте UTF-8** для новых файлов
2. Для определения кодировки используйте `file` или `enca`
3. Для конвертации используйте `iconv`
4. Установите локаль UTF-8 в системе:
```bash
export LANG=ru_RU.UTF-8
export LC_ALL=ru_RU.UTF-8
```
---------


