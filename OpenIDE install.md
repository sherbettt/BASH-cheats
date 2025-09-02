https://openide.ru/download/
<br/> Версия: 2025.1.3   Сборка: 251.26927.53.3   Релиз: 26.08.25


Если у вас ALT-образная ОС, то можно попробовать установить из репы:
```c
epm search openide
epm play openide -vv
```
----------------------------

# Подробная инструкция по установке OpenIDE (IntelliJ IDEA) на ALT Linux

## 1. Подготовка и проверка архива

Перейдите в папку с загруженным архивом:
```bash
cd ~/Загрузки
```

Убедитесь, что архив присутствует:
```bash
ls -la openIDE-*.tar.gz
```

## 2. Распаковка архива

Распакуйте архив:
```bash
tar -xzf openIDE-251.26927.53.3.tar.gz
```

Посмотрите содержимое распакованной папки:
```bash
ls -la openIDE-251.26927.53.3/
```

## 3. Перемещение в системную папку

Переместите распакованную папку в `/opt`:
```bash
sudo mv openIDE-251.26927.53.3 /opt/idea
```

Дайте права на выполнение:
```bash
sudo chmod -R +x /opt/idea/bin/
```

## 4. Проверка установки Java

Проверьте установленную версию Java:
```bash
java -version
```

Если Java не установлена, установите OpenJDK:
```bash
sudo apt-get update
sudo apt-get install openjdk-17-jdk
```

## 5. Создание .desktop файла для меню приложений

Создайте файл ярлыка:
```bash
sudo mcedit /usr/share/applications/idea.desktop
```

Добавьте следующее содержимое:
```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Community Edition
Name[ru]=IntelliJ IDEA Community Edition
Icon=/opt/idea/bin/openide.png
Exec=/opt/idea/bin/openide.sh
Comment=Powerful Java IDE
Comment[ru]=Мощная Java IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
Keywords=idea;java;ide;development;programming;
```

## 6. Создание симлинка для запуска из терминала

Создайте символьную ссылку:
```bash
sudo ln -s /opt/idea/bin/openide.sh /usr/local/bin/idea
```

## 7. Добавление в PATH (опционально)

Добавьте путь к бинарным файлам в переменную PATH:
```bash
echo 'export PATH="$PATH:/opt/idea/bin"' >> ~/.bashrc
source ~/.bashrc
```

## 8. Запуск IntelliJ IDEA

**Способ 1:** Прямой запуск из терминала
```bash
/opt/idea/bin/openide.sh
```

**Способ 2:** Через созданный симлинк
```bash
idea
```

**Способ 3:** Через меню приложений (после перезагрузки)

## 9. Первоначальная настройка

При первом запуске:
1. IDEA предложит принять лицензионное соглашение
2. Выберите цветовую тему (Light/Dark)
3. Настройте плагины по желанию
4. Создайте или импортируйте проект

## 10. Проверка установки

Проверьте что все компоненты установлены правильно:
```bash
# Проверка папки
ls -la /opt/idea/

# Проверка бинарных файлов
ls -la /opt/idea/bin/openide.sh

# Проверка симлинка
ls -la /usr/local/bin/idea

# Проверка .desktop файла
ls -la /usr/share/applications/idea.desktop

# Проверка Java
java -version
```

## 11. Дополнительные настройки

Для настройки размера heap памяти Java создайте файл:
```bash
mkdir -p ~/.config/OpenIDE/OpenIDE2025.1
mcedit ~/.config/OpenIDE/OpenIDE2025.1/openide64.vmoptions
```

Добавьте (пример):
```
-Xms512m
-Xmx2048m
-XX:ReservedCodeCacheSize=512m
```

## 12. Удаление (если потребуется)

Чтобы удалить IDEA:
```bash
sudo rm -rf /opt/idea
sudo rm /usr/local/bin/idea
sudo rm /usr/share/applications/idea.desktop
rm -rf ~/.config/OpenIDE
rm -rf ~/.local/share/OpenIDE
```

## Важные примечания:

1. **Первый запуск** может занять несколько минут - IDEA будет создавать конфигурационные файлы
2. **Конфигурация** хранится в `~/.config/OpenIDE/`
3. **Кэш** хранится в `~/.local/share/OpenIDE/`
4. **Проекты** рекомендуется хранить в отдельной папке (не в `/opt`)

Теперь у вас полностью установленная и настроенная IntelliJ IDEA Community Edition!

