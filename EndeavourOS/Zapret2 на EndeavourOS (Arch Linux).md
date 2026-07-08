# 📗 **Установка и настройка zapret v1.0.2 на EndeavourOS (Arch Linux)**

## **🚨 ГЛАВНЫЕ ИЗМЕНЕНИЯ В ВЕРСИИ 1.0.2 (от 16 июня 2026)**

1. **Исправлена критическая регрессия** с интервалом сборки мусора (Lua GC) — теперь снова 60 секунд вместо 60 миллисекунд, что **значительно снижает нагрузку на процессор**.
2. **Оптимизирован цикл обработки таймеров** — улучшена производительность при добавлении/удалении таймеров в функциях таймеров.
3. **Рекомендуется обновление** для всех пользователей версий 1.0.0 и 1.0.1 из-за экономии ресурсов CPU.

---

## **⚠️ ВАЖНОЕ ПРИМЕЧАНИЕ О МОДУЛЕ ЯДРА И ЕГО ВЕРСИЯХ**

**Проблема:** Модуль `nfnetlink_queue` должен строго соответствовать версии загруженного ядра. Если вы обновили пакет `linux-lts`, но не перезагрузились, модуль может отсутствовать для текущего ядра.

**Как проверить соответствие:**
```bash
# Версия загруженного ядра
uname -r

# Для каких ядер есть модуль
find /lib/modules -name "nfnetlink_queue.ko*" 2>/dev/null
```

**Если модуль есть для другого ядра** — нужно перезагрузиться с тем ядром, для которого модуль существует:
```bash
# Смотрим доступные ядра в загрузчике
sudo bootctl list

# Устанавливаем нужное ядро по умолчанию
sudo bootctl set-default "ID_НУЖНОЙ_ЗАПИСИ.conf"

# Перезагружаемся
sudo reboot
```

**Решение проблемы:** Всегда проверяйте соответствие модуля и ядра перед запуском zapret. Если после обновления системы zapret перестал работать — скорее всего, вы загрузились со старым ядром, а модуль установлен для нового.

---

## **Способы установки zapret v1.0.2 на EndeavourOS**

| Способ | Сложность | Когда использовать |
|--------|-----------|-------------------|
| **1. Из AUR (бинарный)** | ⭐ Простой | Быстрая установка, не нужно компилировать |
| **2. Из AUR (исходники)** | ⭐⭐ Средний | Хотите компилировать сами |
| **3. Из GitHub (релиз v1.0.2)** | ⭐⭐ Средний | **РЕКОМЕНДУЕТСЯ** — свежая стабильная версия |
| **4. Из GitHub (master ветка)** | ⭐⭐⭐ Сложный | Нужны самые свежие изменения (может быть нестабильно) |

---

# **ЧАСТЬ 1: УСТАНОВКА ИЗ AUR**

## **1️⃣ Подготовка системы**

```bash
# Обновляем систему
sudo pacman -Syu

# Устанавливаем необходимые пакеты
sudo pacman -S nftables lua tcpdump curl base-devel

# Устанавливаем библиотеку для NFQUEUE (обязательно!)
sudo pacman -S libnetfilter_queue

# Устанавливаем AUR-помощник paru (если ещё нет)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
```

## **2️⃣ Установка zapret2 из AUR**

### **Вариант А: Бинарный пакет (самый простой)**
```bash
paru -S zapret2-bin
```
**Примечание:** Убедитесь, что в AUR обновлена версия до 1.0.2. Если нет — используйте установку из GitHub.

### **Вариант Б: Пакет с исходниками**
```bash
paru -S zapret2
```

---

# **ЧАСТЬ 2: УСТАНОВКА ИЗ РЕЛИЗА GitHub v1.0.2 (РЕКОМЕНДУЕТСЯ)**

Этот способ подойдёт, если вы хотите использовать **свежую стабильную версию с исправлениями**.

```bash
# Скачиваем релиз v1.0.2
cd /opt
sudo wget https://github.com/bol-van/zapret2/releases/download/v1.0.2/zapret2-v1.0.2.tar.gz

# Распаковываем
sudo tar -xzf zapret2-v1.0.2.tar.gz

# Переименовываем для удобства
sudo mv zapret2-v1.0.2 zapret2

# Удаляем архив
sudo rm zapret2-v1.0.2.tar.gz

# Копируем бинарники
cd /opt/zapret2
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig

# Права на Lua файлы
sudo chmod a+x /opt/
sudo chmod a+x /opt/zapret2/
sudo chmod a+x /opt/zapret2/lua/
sudo chmod a+r /opt/zapret2/lua/*.lua
```

---

# **ЧАСТЬ 3: УСТАНОВКА ИЗ MASTER ВЕТКИ GitHub (С КОМПИЛЯЦИЕЙ)**

**Когда это нужно:** Если вы хотите получить самые свежие изменения из репозитория, которые ещё не вошли в стабильный релиз. **Внимание:** master-ветка может содержать нестабильные изменения.

## **3.1 Клонирование репозитория**

```bash
# Клонируем репозиторий целиком
cd /opt
sudo git clone https://github.com/bol-van/zapret2.git
cd zapret2
```

**Важное замечание:** В master ветке бинарники **не включены** в репозиторий — их нужно компилировать самостоятельно из исходного кода.

## **3.2 Установка зависимостей для компиляции**

```bash
# Устанавливаем необходимые для компиляции пакеты
sudo pacman -S base-devel gcc make cmake
sudo pacman -S libnetfilter_queue libmnl libnfnetlink
```

## **3.3 Компиляция бинарников**

```bash
cd /opt/zapret2

# Компилируем nfqws2 (основной компонент)
cd nfq2
sudo make
cd ..

# Компилируем ip2net (для работы с IP-списками)
cd ip2net
sudo make
cd ..

# Компилируем mdig (для DNS-запросов)
cd mdig
sudo make
cd ..
```

## **3.4 Проверка успешной компиляции**

```bash
# Проверяем, что бинарники создались
ls -la /opt/zapret2/nfq2/nfqws2
ls -la /opt/zapret2/ip2net/ip2net
ls -la /opt/zapret2/mdig/mdig

# Проверяем, что бинарники работают
/opt/zapret2/nfq2/nfqws2 --version
```

**Ожидаемый вывод:** должна показаться версия и информация о компиляции.

## **3.5 Если компиляция не удалась**

**Проблема 1: `make: command not found`**
```bash
sudo pacman -S base-devel
```

**Проблема 2: `fatal error: netlink/netfilter.h: No such file`**
```bash
sudo pacman -S libnfnetlink
```

**Проблема 3: `fatal error: libnetfilter_queue/libnetfilter_queue.h: No such file`**
```bash
sudo pacman -S libnetfilter_queue
```

**Проблема 4: Ошибка при компиляции nfqws2 из-за Lua**
```bash
# Установите LuaJIT или Lua
sudo pacman -S luajit lua51
```

## **3.6 Настройка прав доступа**

После компиляции не забудьте настроить права:

```bash
cd /opt/zapret2
sudo chmod a+x /opt/
sudo chmod a+x /opt/zapret2/
sudo chmod a+x /opt/zapret2/lua/
sudo chmod a+r /opt/zapret2/lua/*.lua
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig
```

## **3.7 Обновление master-версии**

Когда нужно обновиться до последних изменений в репозитории:

```bash
cd /opt/zapret2
sudo git pull

# Перекомпилируем всё заново
cd nfq2 && sudo make clean && sudo make && cd ..
cd ip2net && sudo make clean && sudo make && cd ..
cd mdig && sudo make clean && sudo make && cd ..

# Перезапускаем zapret
zapret-stop
zapret-start
```

---

# **ЧАСТЬ 4: УНИВЕРСАЛЬНЫЕ СКРИПТЫ УПРАВЛЕНИЯ (РАБОТАЮТ ДЛЯ ЛЮБОГО СПОСОБА УСТАНОВКИ)**

**Почему скрипты, а не systemd-сервис?**  
При использовании systemd-сервиса возникали конфликты с firewalld и проблемы с отслеживанием PID процесса. Скрипты управления работают стабильнее и не ломают сеть.

## **Создаём скрипты**

```bash
cd /opt/zapret2

# Скрипт запуска
sudo tee /opt/zapret2/zapret-start.sh << 'EOF'
#!/bin/bash
# Zapret start script

echo "🔄 Загружаем модуль ядра..."
sudo modprobe nfnetlink_queue 2>/dev/null || true

echo "🔄 Загружаем правила nftables..."
sudo nft -f /etc/nftables/zapret.nft

echo "🚀 Запускаем nfqws2..."
cd /opt/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@/opt/zapret2/lua/zapret-lib.lua --lua-init=@/opt/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5 --daemon

sleep 2
if pgrep -f nfqws2 > /dev/null; then
    echo "✅ Zapret запущен (PID: $(pgrep -f nfqws2))"
    curl -I https://youtube.com 2>/dev/null | head -1
else
    echo "❌ Ошибка запуска!"
fi
EOF

# Скрипт остановки
sudo tee /opt/zapret2/zapret-stop.sh << 'EOF'
#!/bin/bash
# Zapret stop script

echo "🛑 Останавливаем nfqws2..."
sudo pkill -f nfqws2
echo "✅ Zapret остановлен"
EOF

# Скрипт проверки статуса
sudo tee /opt/zapret2/zapret-status.sh << 'EOF'
#!/bin/bash
# Zapret status check

echo "=== NFQWS2 ==="
if pgrep -f nfqws2 > /dev/null; then
    echo "✅ РАБОТАЕТ (PID: $(pgrep -f nfqws2))"
else
    echo "❌ НЕ РАБОТАЕТ"
fi

echo ""
echo "=== МОДУЛЬ ЯДРА ==="
if lsmod | grep -q nfnetlink_queue; then
    echo "✅ nfnetlink_queue загружен"
else
    echo "❌ nfnetlink_queue не загружен"
fi

echo ""
echo "=== NFTABLES ZAPRET ==="
if sudo nft list table inet zapret &>/dev/null; then
    echo "✅ Правила загружены"
else
    echo "❌ Правила не загружены"
fi

echo ""
echo "=== YOUTUBE ТЕСТ ==="
curl -I https://youtube.com 2>/dev/null | head -1
EOF

# Делаем скрипты исполняемыми
sudo chmod +x /opt/zapret2/zapret-{start,stop,status}.sh

# Создаём символические ссылки
sudo ln -sf /opt/zapret2/zapret-start.sh /usr/local/bin/zapret-start
sudo ln -sf /opt/zapret2/zapret-stop.sh /usr/local/bin/zapret-stop
sudo ln -sf /opt/zapret2/zapret-status.sh /usr/local/bin/zapret-status
```

## **Использование скриптов**

```bash
zapret-start   # Запуск
zapret-status  # Проверка статуса
zapret-stop    # Остановка
```

## **Автозапуск при загрузке**

```bash
(sudo crontab -l 2>/dev/null; echo "@reboot /opt/zapret2/zapret-start.sh") | sudo crontab -
```

---

# **ЧАСТЬ 5: ОБЩИЕ НАСТРОЙКИ (ДЛЯ ЛЮБОГО СПОСОБА УСТАНОВКИ)**

## **5.1 Настройка модуля ядра**

```bash
# Проверяем соответствие
uname -r
find /lib/modules/$(uname -r)/kernel/net/netfilter/ -name "*nfnetlink_queue*" 2>/dev/null

# Загружаем модуль
sudo modprobe nfnetlink_queue

# Автозагрузка
echo "nfnetlink_queue" | sudo tee /etc/modules-load.d/nfqueue.conf
```

## **5.2 Настройка nftables**

```bash
# Создаём файл правил
sudo mcedit /etc/nftables/zapret.nft
```

**Содержимое:**
```nft
#!/usr/sbin/nft -f

table inet zapret
delete table inet zapret
table inet zapret {
    chain post {
        type filter hook postrouting priority 101; policy accept;
        tcp dport {80, 443} ct original packets 1-12 queue flags bypass to 200
        udp dport 443 ct original packets 1-12 queue flags bypass to 200
    }
    chain pre {
        type filter hook prerouting priority -101; policy accept;
        tcp sport {80, 443} ct reply packets 1-12 queue flags bypass to 200
        udp sport 443 ct reply packets 1-12 queue flags bypass to 200
    }
    chain output {
        type filter hook output priority -401; policy accept;
        queue flags bypass to 200
    }
}
```

```bash
# Загружаем правила
sudo nft -f /etc/nftables/zapret.nft
```

## **5.3 Настройка параметра ядра**

```bash
sudo sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

# **ЧАСТЬ 6: ДИАГНОСТИКА И УСТРАНЕНИЕ ПРОБЛЕМ**

## **Проблема 1: Несоответствие модуля ядра и версии ядра**

**Симптомы:** `modprobe: FATAL: Module nfnetlink_queue not found`

**Решение:**
```bash
sudo bootctl list
sudo bootctl set-default "ID_ЗАПИСИ_С_ПРАВИЛЬНЫМ_ЯДРОМ.conf"
sudo reboot
```

## **Проблема 2: Конфликт с firewalld (пропадает сеть)**

**Решение:**
```bash
sudo nft flush ruleset
sudo systemctl restart firewalld
sudo systemctl restart NetworkManager
sudo nft -f /etc/nftables/zapret.nft
zapret-start
```

## **Проблема 3: Ошибка компиляции при установке из master**

| Ошибка | Решение |
|--------|---------|
| `make: command not found` | `sudo pacman -S base-devel` |
| `netlink/netfilter.h: No such file` | `sudo pacman -S libnfnetlink` |
| `libnetfilter_queue/...: No such file` | `sudo pacman -S libnetfilter_queue` |
| Lua ошибки | `sudo pacman -S luajit lua51` |

## **Проблема 4: YouTube не открывается**

1. Отключите QUIC в браузере
2. Проверьте через `zapret-status`
3. Попробуйте изменить стратегию: `pos=1` вместо `midsld`

## **Проблема 5: Высокая нагрузка на CPU после обновления до 1.0.2**

**Решение:** В версии 1.0.2 исправлена регрессия с Lua GC, поэтому нагрузка должна снизиться. Если проблема осталась:
```bash
# Проверьте, что используете версию 1.0.2
/opt/zapret2/nfq2/nfqws2 --version

# Если версия старая — обновитесь до 1.0.2
```

---

# **📌 ИТОГОВАЯ ТАБЛИЦА СПОСОБОВ УСТАНОВКИ**

| Способ | Сложность | Компиляция | Обновление | Когда использовать |
|--------|-----------|------------|------------|-------------------|
| **AUR (бинарный)** | ⭐ | ❌ | `paru -Syu` | Быстрая установка |
| **AUR (исходники)** | ⭐⭐ | ✅ | `paru -Syu` | Хотите компилировать сами |
| **GitHub релиз v1.0.2** | ⭐⭐ | ❌ | Вручную | **РЕКОМЕНДУЕТСЯ** — свежая стабильная версия |
| **GitHub master** | ⭐⭐⭐ | ✅ | `git pull` + make | Нужны свежие изменения (может быть нестабильно) |

---

# **🎯 РАБОЧАЯ КОНФИГУРАЦИЯ (ПРОВЕРЕНО 23 ИЮНЯ 2026)**

| Компонент | Значение |
|-----------|----------|
| **Версия** | **1.0.2 (рекомендуется)** |
| **Путь установки** | `/opt/zapret2` |
| **Стратегия** | `multisplit:pos=midsld:seqovl=5` |
| **Очередь NFQUEUE** | 200 |
| **Модуль ядра** | `nfnetlink_queue` |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **QUIC в браузере** | **ДОЛЖЕН БЫТЬ ОТКЛЮЧЁН** |

---

# **✅ ФИНАЛЬНАЯ ПРОВЕРКА**

```bash
# Проверяем модуль
lsmod | grep nfnetlink_queue

# Проверяем правила
sudo nft list table inet zapret

# Запускаем
zapret-start

# Проверяем статус
zapret-status
```

---

**📝 Последнее примечание:** Версия 1.0.2 содержит важные исправления производительности. Рекомендуется обновляться до неё с предыдущих версий. Стратегии обхода могут меняться со временем. Если перестанет работать — попробуйте `pos=1` вместо `midsld` или используйте `blockcheck2.sh` для автоматического подбора. Актуальная документация: https://github.com/bol-van/zapret2/

---

**📌 Что нового в версии 1.0.2:**
- ✅ Исправлена регрессия с интервалом Lua GC (было 60 мс, стало 60 секунд) — **снижение нагрузки на CPU**
- ✅ Оптимизирован цикл обработки таймеров — **улучшена производительность**
