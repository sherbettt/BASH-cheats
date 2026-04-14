См. страницу [wiki.etersoft.ru/Epm](https://wiki.etersoft.ru/Epm)

См. страницу [ALT Linux Wiki/Epm](https://www.altlinux.org/Epm)

```bash
# графический EEPM 
eepm install eepm-play-gui
```

### **Список команд, epm --help:**


| Описание операции                                      | Команда epm              | Альтернативная команда epm                  | Команда Debian                                      | Команда ALT Linux                          |
|--------------------------------------------------------|--------------------------|---------------------------------------------|----------------------------------------------------|--------------------------------------------|
| Установка пакета по названию в систему                 | `epm -i (package)`       | `epm install (package)` или `epmi (package)` | `apt-get install (package)`                        | `apt-get install (package)`                |
| Установка файла пакета в систему                       | `epm -i (package file)`  | `epm install (package file)` или `epmi (package file)` | `dpkg -i (package file); apt-get -f install (package file)` | `apt-get install (package file)`           |
| Удаление пакета из системы                             | `epm -e (package)`       | `epm remove (package)` или `epme (package)`  | `apt-get remove (package)` ; `dpkg -P (package)`   | `apt-get remove (package)`                |
| Поиск пакета в репозитории                             | `epm -s (text)`          | `epm search (text)` или `epms (text)`        | `apt-cache search (text)`                          | `apt-cache search (text)`                 |
| Проверка наличия пакета в системе                      | `epm -q (package)`       | `epm installed (package)` или `epmq (package)` | `dpkg -l (package) \| grep 'ii (package)`          | `rpm -qa \| grep (package)`               |
| Список установленных пакетов                           | `epm -qa`                | `epm packages` или `epm list` или `epmqa`    | `dpkg -l`                                          | `rpm -qa`                                 |
| Поиск по названиям установленных пакетов               | `epm -qp <word>`         | `epmqp`                                      | `grep <word>`                                      | `grep <word>`                             |
| Принадлежность файла к (установленному) пакету         | `epm -qf (file)`         | `epmqf (file)`                               | `dpkg -S (file)`                                   | `rpm -qf (file)` или `rpmqf` из `etersoft-build-utils` |
| Поиск, в каком пакете есть указанный файл              | `epm -sf <file>`         | `epm filesearch`                             |                                                    |                                            |
| Список файлов в (установленном) пакете                 | `epm -ql (package)`      | `epm filelist <package>`                     | `dpkg -L (package)`                                | `rpm -ql (package)`                       |
| Вывести информацию о пакете                            | `epm -qi (package)`      | `epm info (package)`                         | `apt-cache show (package)`                         | `apt-cache show (package)`                |
| Обновить дистрибутив                                   | `epm upgrade`            | `epm dist-upgrade`                           | `apt-get dist-upgrade`                             | `apt-get dist-upgrade`                    |


```markdown
# epms name subtext — выполняет epms name | grep subtest
# epms name ^subtext — выполняет epms name | grep -v subtest
# epms "name1 name2" — выполняет поиск именно такого сочетания
```



