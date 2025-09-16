# Поиск больших файлов в Linux: Полное руководство
<br/>

## Базовые команды поиска

### Простой поиск по расширению
```bash
find / -type f -name "*.iso" 2>/dev/null
```

### Поиск без учета регистра
```bash
find / -type f -iname "*.iso" 2>/dev/null
```

## Поиск больших файлов по размеру

### Файлы больше 100 МБ
```bash
find / -type f -size +100M -name "*.iso" 2>/dev/null
```

### Файлы в диапазоне размеров (от 500МБ до 2ГБ)
```bash
find / -type f -size +500M -size -2G -name "*.iso" 2>/dev/null
```

## Расширенная фильтрация

### Исключение определенных путей
```bash
find / -type f -name "*.iso" -not -path "/mnt/*" -not -path "/proc/*" 2>/dev/null
```

### Поиск с выводом дополнительной информации
```bash
find / -type f -name "*.iso" -exec ls -lh {} \; 2>/dev/null
```

### Сортировка по размеру (самые большие первые)
```bash
find / -type f -name "*.iso" -exec du -h {} \; 2>/dev/null | sort -rh
```

## Поиск в конкретных директориях

### В домашних директориях пользователей
```bash
find /home -type f -name "*.iso" -size +100M 2>/dev/null
```

### В системных директориях
```bash
find /var /opt -type f -name "*.iso" -size +100M 2>/dev/null
```

## Полезные варианты вывода

### Только имена файлов
```bash
find / -type f -name "*.iso" -printf "%f\n" 2>/dev/null
```

### С полными путями и размерами
```bash
find / -type f -name "*.iso" -printf "%p - %s bytes\n" 2>/dev/null
```

### С человеко-читаемыми размерами
```bash
find / -type f -name "*.iso" -exec du -h {} \; 2>/dev/null
```

## Оптимизация поиска

### Ограничение глубины поиска
```bash
find / -maxdepth 3 -type f -name "*.iso" -size +100M 2>/dev/null
```

### Поиск за последние N дней
```bash
find / -type f -name "*.iso" -size +100M -mtime -30 2>/dev/null
```

## Практические примеры

### Поиск и удаление старых больших файлов
```bash
find /tmp -type f -name "*.iso" -size +100M -mtime +30 -delete 2>/dev/null
```

### Поиск с сохранением результатов в файл
```bash
find / -type f -name "*.iso" -size +100M 2>/dev/null > large_iso_files.txt
```

## Заключение

Правильное использование команды `find` с учетом фильтрации по размеру, пути и другим атрибутам позволяет эффективно управлять дисковым пространством. Всегда используйте `2>/dev/null` для подавления ошибок доступа и учитывайте особенности монтирования сетевых ресурсов.

**Важно**: Будьте осторожны с операциями удаления и всегда проверяйте результаты перед выполнением деструктивных операций.
