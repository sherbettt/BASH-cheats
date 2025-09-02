https://openide.ru/download/
<br/> Версия: 2025.1.3   Сборка: 251.26927.53.3   Релиз: 26.08.25


Если у вас ALT-образная ОС, то можно попробовтаь устанвоить из репы:
```c
epm play openide -vv
```

Для других случаев - качаем и устанавливаем:

**IntelliJ IDEA Community Edition** (версия 251.26927.53.3). 
Вот как правильно установить его на ALT Linux:

## Установка IntelliJ IDEA

```bash
# Переместите распакованную папку в /opt
sudo mv ~/Загрузки/openIDE-251.26927.53.3 /opt/idea

# Дайте права на выполнение
sudo chmod +x /opt/idea/bin/idea.sh
```

## Создание ярлыка для запуска

```bash
# Создайте .desktop файл
sudo mcedit /usr/share/applications/idea.desktop
```

Добавьте содержимое:
```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Community Edition
Icon=/opt/idea/bin/idea.png
Exec=/opt/idea/bin/idea.sh
Comment=Powerful Java IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
```

## Создание симлинка для запуска из терминала

```bash
sudo ln -s /opt/idea/bin/idea.sh /usr/local/bin/idea
```

## Проверка Java

```bash
# Проверьте установлена ли Java
java -version
epm -qi java


# Если Java не установлена, установите её
sudo apt-get install openjdk-17-jdk
```

## Запуск IntelliJ IDEA

```bash
# Способ 1: Прямой запуск
/opt/idea/bin/idea.sh

# Способ 2: Через симлинк
idea

# Способ 3: Через меню приложений (после перезагрузки)
```

## Дополнительные настройки (опционально)

```bash
# Добавление в PATH
echo 'export PATH="$PATH:/opt/idea/bin"' >> ~/.bashrc
source ~/.bashrc
```

## Проверка установки

```bash
# Проверьте что папка на месте
ls -la /opt/idea/

# Проверьте что файл запуска исполняемый
ls -la /opt/idea/bin/idea.sh
```

Теперь у вас должна быть полноценно работающая IntelliJ IDEA Community Edition! При первом запуске она создаст конфигурационные файлы в `~/.config/JetBrains/`.

