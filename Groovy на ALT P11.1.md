# Инструкция по установке SDKMAN! и Groovy на ALT Linux 11.1

##  **Итоговая проблема и решение**
**Проблема**: Groovy 5.0.3 несовместим с Java 11.  
**Решение**: Использовать Groovy 4.0.29 + Java 11 или Docker.

---

##  **Шаг 0: Проверка системы**
```bash
# 1. Проверьте ОС
cat /etc/os-release

# 2. Проверьте установленную Java
java --version
# Если есть Java 21, но нет Java 11 - продолжите
```

---

##  **Шаг 1: Установка Java 11 (если нет)**
```bash
# Установите OpenJDK 11
sudo apt-get update
sudo apt-get install java-11-openjdk java-11-openjdk-headless

# Проверьте установку
ls -la /usr/lib/jvm/
# Должно быть: java-11-openjdk-11.0.29.0.7-0.x86_64
```

---

##  **Шаг 2: Установка SDKMAN!**
```bash
# 1. Установите zip/unzip (обязательно!)
sudo apt-get install zip unzip curl

# 2. Установите SDKMAN!
curl -s "https://get.sdkman.io" | bash

# 3. Активируйте SDKMAN! в текущей сессии
source "$HOME/.sdkman/bin/sdkman-init.sh"

# 4. Проверьте установку
sdk version
# Должно быть: SDKMAN! script: 5.20.0
```

---

##  **Шаг 3: Настройка Java для SDKMAN! (ВАЖНО!)**
```bash
# 1. Пропустите установку Java через SDKMAN! (она сломана на ALT)
# Вместо этого используйте системную Java

# 2. Настройте переменные окружения для системной Java
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.29.0.7-0.x86_64
export PATH=$JAVA_HOME/bin:$PATH

# 3. Проверьте
java --version
# Должно быть: OpenJDK 11.0.29
```

---

##  **Шаг 4: Установка Groovy 4.0.29 (НЕ 5.0.3!)**
```bash
# 1. Посмотрите доступные версии Groovy
sdk list groovy

# 2. Установите Groovy 4.0.29 (совместим с Java 11)
sdk install groovy 4.0.29

# 3. Сделайте версией по умолчанию
sdk default groovy 4.0.29

# 4. Проверьте установку
groovy --version
# Должно быть: Groovy Version: 4.0.29 JVM: 11.0.29

groovydoc --version
# Должно быть: GroovyDoc 4.0.29
```

---

##  **Шаг 5: Создание скрипта для генерации документации**
```bash
cat > ~/bin/generate-groovy-docs.sh << 'EOF'
#!/bin/bash
# Скрипт для генерации документации Groovy на ALT Linux

# Используем системную Java 11
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.29.0.7-0.x86_64
export PATH=$JAVA_HOME/bin:$PATH

echo "======================================"
echo "Генератор документации Groovy"
echo "======================================"
echo "Java: $(java --version 2>&1 | head -1)"
echo "Groovy: $(groovy --version 2>&1 | head -1)"
echo ""

if [ $# -eq 0 ]; then
    echo "Использование: $0 <файл.groovy>"
    echo "Пример: $0 vars/build.groovy"
    exit 1
fi

SOURCE_FILE="$1"
DOCS_DIR="./docs"

echo "Генерация документации из: $SOURCE_FILE"

# Очистка старой документации
rm -rf "$DOCS_DIR"

# Генерация новой
groovydoc \
  -d "$DOCS_DIR" \
  -windowtitle "Groovy Documentation" \
  -doctitle "Project Documentation" \
  -header "Generated on $(date '+%Y-%m-%d')" \
  -footer "ALT Linux 11.1 | Java 11 | Groovy 4.0.29" \
  "$SOURCE_FILE"

if [ $? -eq 0 ] && [ -f "$DOCS_DIR/index.html" ]; then
    echo ""
    echo "Успешно!"
    echo "Документация: $(pwd)/$DOCS_DIR/"
    echo "Главный файл: file://$(pwd)/$DOCS_DIR/index.html"
    echo ""
    echo "Сгенерировано файлов: $(find "$DOCS_DIR" -name "*.html" | wc -l)"
else
    echo "Ошибка генерации!"
    exit 1
fi
EOF

chmod +x ~/bin/generate-groovy-docs.sh
```

---

## **Шаг 6: Тестирование**
```bash
# 1. Создайте тестовый файл
cd ~
cat > TestDemo.groovy << 'EOF'
/**
 * Демонстрационный класс для теста Groovydoc
 * @author Test User
 * @version 1.0
 */
class TestDemo {
    /** Имя проекта */
    String projectName = "Demo"
    
    /**
     * Метод возвращает описание
     * @return строку описания
     */
    String getDescription() {
        "Project: $projectName"
    }
}
EOF

# 2. Сгенерируйте документацию
~/bin/generate-groovy-docs.sh TestDemo.groovy

# 3. Проверьте
ls -la docs/
```

---

## **Шаг 7: Генерация документации для вашего проекта**
```bash
# Перейдите в проект
cd ~/projects/git/runtel-backend-build

# Сгенерируйте документацию
~/bin/generate-groovy-docs.sh vars/build.groovy

# Или напрямую
groovydoc -d ./docs vars/build.groovy
```

---

##  **Альтернатива: Docker (если SDKMAN! не работает)**
```bash
# Однострочная команда Docker
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  groovy:4.0.29-jdk11 \
  groovydoc -d /workspace/docs /workspace/vars/build.groovy
```

Создайте скрипт:
```bash
cat > ~/bin/groovydoc-docker.sh << 'EOF'
#!/bin/bash
docker run --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  groovy:4.0.29-jdk11 \
  groovydoc -d /workspace/docs "$@"
EOF
chmod +x ~/bin/groovydoc-docker.sh
```

---

##  **Шаг 8: Постоянная настройка (для всех сессий)**
Добавьте в `~/.bashrc`:
```bash
# SDKMAN!
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Системная Java 11 (важно для Groovy 4)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.29.0.7-0.x86_64
export PATH=$JAVA_HOME/bin:$PATH

# Groovy 4.0.29 по умолчанию
export GROOVY_HOME=$HOME/.sdkman/candidates/groovy/current
export PATH=$GROOVY_HOME/bin:$PATH
```

Примените:
```bash
source ~/.bashrc
```

---

##  **Частые проблемы и решения**

### **1. `Unsupported Java Version: false`**
```bash
# Решение: Используйте Groovy 4.0.29 вместо 5.0.3
sdk uninstall groovy
sdk install groovy 4.0.29
sdk default groovy 4.0.29
```

### **2. `lchmod error` при установке Java через SDKMAN!**
```bash
# Решение: Не устанавливайте Java через SDKMAN! на ALT
# Используйте системную Java
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.29.0.7-0.x86_64
```

### **3. Groovydoc не видит Java**
```bash
# Решение: Явно укажите переменные
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.29.0.7-0.x86_64 \
PATH=$JAVA_HOME/bin:$PATH \
groovydoc -d ./docs ваш_файл.groovy
```

---

## 📊 **Проверка работоспособности**
```bash
# Полная проверка
echo "=== ПРОВЕРКА СИСТЕМЫ ==="
echo "1. Java: $(java --version 2>&1 | head -1)"
echo "2. Groovy: $(groovy --version 2>&1 | head -1)"
echo "3. Groovydoc: $(groovydoc --version 2>&1 | head -1)"
echo "4. SDKMAN!: $(sdk version 2>&1 | head -1)"
echo "5. Каталог Java: $JAVA_HOME"

# Тест генерации
echo "class Test { String ok = 'YES' }" > /tmp/test.groovy
groovydoc -d /tmp/test-out /tmp/test.groovy 2>/dev/null && echo "Groovydoc работает!" || echo "Проблема с Groovydoc"
```

---

## **Краткая памятка для ALT Linux**
```bash
# Установка за 5 минут:
1. sudo apt-get install java-11-openjdk zip unzip curl
2. curl -s "https://get.sdkman.io" | bash
3. source ~/.sdkman/bin/sdkman-init.sh
4. export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.29.0.7-0.x86_64
5. sdk install groovy 4.0.29
6. groovydoc -d ./docs ваш_файл.groovy
```


---

##  **Полезные команды**
```bash
# Обновить SDKMAN!
sdk selfupdate

# Посмотреть установленные SDK
sdk current

# Переключить версию Groovy
sdk use groovy 4.0.29

# Удалить версию
sdk uninstall groovy 5.0.3

# Очистить кэш
sdk flush archives
```

