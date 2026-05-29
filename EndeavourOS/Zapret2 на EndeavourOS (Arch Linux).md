# 📗 **Установка и настройка zapret на EndeavourOS (Arch Linux) — ПОЛНОЕ РУКОВОДСТВО**

## **🚨 ГЛАВНЫЕ ВЫВОДЫ ИЗ ПРАКТИЧЕСКОГО ЭКСПЕРИМЕНТА (29 мая 2026)**

1. **Zapret ДОЛЖЕН быть установлен в `/opt/zapret2`** — скрипты и сервисы ожидают именно этот путь
2. **Рабочая стратегия на текущий момент:** `multisplit:pos=midsld:seqovl=5`
3. **Модуль ядра `nfnetlink_queue` должен быть загружен ДО запуска zapret**
4. **Использование абсолютных путей в `--lua-init` критически важно**
5. **В EndeavourOS есть 3 способа установки** — все рабочие, выбирайте любой

---

## **Способы установки zapret на EndeavourOS**

| Способ | Сложность | Когда использовать |
|--------|-----------|-------------------|
| **1. Из AUR (бинарный)** | ⭐ Простой | Быстрая установка, не нужно компилировать |
| **2. Из AUR (исходники)** | ⭐⭐ Средний | Хотите компилировать сами |
| **3. Из GitHub (релиз v0.9.5.2)** | ⭐⭐ Средний | Нужна конкретная стабильная версия |
| **4. Из GitHub (master ветка)** | ⭐⭐⭐ Сложный | Нужны самые свежие изменения |

---

# **ЧАСТЬ 1: УСТАНОВКА ИЗ AUR (РЕКОМЕНДУЕТСЯ ДЛЯ НОВИЧКОВ)**

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

*Почему:*  
- `nftables` — для перенаправления трафика  
- `libnetfilter_queue` — библиотека для работы с очередями nftables  
- `lua` — для скриптов zapret  
- `paru` — удобный AUR-помощник

---

## **2️⃣ Установка zapret2 из AUR**

### **Вариант А: Бинарный пакет (самый простой, рекомендую)**

```bash
# Устанавливаем бинарный пакет (уже скомпилирован)
paru -S zapret2-bin
```

**Что происходит:**  
- Скачивается готовый бинарник из официального релиза на GitHub
- Установка занимает 10-15 секунд
- Файлы устанавливаются в `/opt/zapret2/`
- Создаются systemd-сервисы: `zapret2.service`, `zapret2-list-update.service`, `zapret2-list-update.timer`

### **Вариант Б: Пакет с исходниками (компиляция на своей машине)**

```bash
# Устанавливаем из исходников (дольше, но полностью из кода)
paru -S zapret2
```

**Что происходит:**  
- Скачиваются исходники с GitHub
- Компиляция на вашей машине (занимает 1-2 минуты)
- Бинарник оптимизирован под вашу систему
- Файлы также в `/opt/zapret2/`

---

## **3️⃣ Проверка установки из AUR**

```bash
# Проверяем, что файлы на месте
ls -la /opt/zapret2/
# Должны быть директории: nfq2/, lua/, ip2net/, mdig/, init.d/

# Проверяем бинарник
ls -la /opt/zapret2/nfq2/nfqws2
# Должен быть исполняемый файл

# Проверяем сервисы
systemctl list-unit-files | grep zapret2
# Должны увидеть: zapret2.service, zapret2-list-update.service, zapret2-list-update.timer
```

---

## **4️⃣ Настройка модуля ядра nfnetlink_queue**

**⚠️ КРИТИЧЕСКИ ВАЖНО!** Без этого модуля nftables не сможет перенаправлять пакеты в очередь.

```bash
# Проверяем, есть ли модуль в системе
find /lib/modules/$(uname -r)/kernel/net/netfilter/ -name "*nfnetlink_queue*" 2>/dev/null

# Загружаем модуль
sudo modprobe nfnetlink_queue

# Проверяем, что загрузился
lsmod | grep nfnetlink_queue
# Ожидаемый вывод:
# nfnetlink_queue        36864  0
# nfnetlink              20480  4 nfnetlink_queue,nf_tables

# Включаем автозагрузку модуля при старте системы
echo "nfnetlink_queue" | sudo tee /etc/modules-load.d/nfqueue.conf

# Проверяем
cat /etc/modules-load.d/nfqueue.conf
```

---

## **5️⃣ Настройка nftables (правила перенаправления трафика)**

```bash
# Создаём файл с правилами для zapret
sudo nano /etc/nftables/zapret.nft
```

**Содержимое файла (упрощённые правила — работают стабильнее):**

```nft
#!/usr/sbin/nft -f

table inet zapret
delete table inet zapret
table inet zapret {
    chain post {
        type filter hook postrouting priority 101; policy accept;
        tcp dport {80, 443} queue flags bypass to 200
        udp dport 443 queue flags bypass to 200
    }
    chain pre {
        type filter hook prerouting priority -101; policy accept;
        tcp sport {80, 443} queue flags bypass to 200
        udp sport 443 queue flags bypass to 200
    }
    chain output {
        type filter hook output priority -401; policy accept;
        queue flags bypass to 200
    }
}
```

**Важное примечание:** Правила упрощены (без `ct original packets 1-12`), потому что:
- Упрощённые правила работают на всех версиях ядра
- Они не менее эффективны для обхода DPI
- Меньше шансов получить ошибку `No such file or directory`

```bash
# Загружаем правила
sudo nft -f /etc/nftables/zapret.nft

# Проверяем, что таблица создалась
sudo nft list table inet zapret
```

**Ожидаемый вывод:**
```
table inet zapret {
    chain post {
        type filter hook postrouting priority srcnat + 1; policy accept;
        tcp dport { 80, 443 } queue flags bypass to 200
        udp dport 443 queue flags bypass to 200
    }
    chain pre {
        type filter hook prerouting priority dstnat - 1; policy accept;
        tcp sport { 80, 443 } queue flags bypass to 200
        udp sport 443 queue flags bypass to 200
    }
    chain output {
        type filter hook output priority -401; policy accept;
        queue flags bypass to 200
    }
}
```

```bash
# Включаем и запускаем nftables (если ещё не включен)
sudo systemctl enable nftables
sudo systemctl start nftables
```

> **Примечание:** Статус `inactive (dead)` для сервиса nftables — это нормально. Сервис работает по принципу "загрузил правила и завершился". Главное, чтобы правила были видны в `nft list ruleset`.

---

## **6️⃣ Настройка параметра ядра для TCP**

```bash
# Временное включение
sudo sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1

# Постоянное включение (сохранится после перезагрузки)
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

## **7️⃣ Редактирование конфига zapret (указываем рабочую стратегию)**

После установки из AUR нужно отредактировать файл конфигурации:

```bash
sudo nano /opt/zapret2/config
```

**Найдите и измените/добавьте следующие строки (в конец файла):**

```bash
# ========== РАБОЧАЯ КОНФИГУРАЦИЯ (29 мая 2026) ==========
NFQWS2_ENABLE=1
NFQWS2_PORTS_TCP=80,443
NFQWS2_PORTS_UDP=443
NFQUEUE_NUM=200

# Стратегия multisplit с разрезом по середине домена
DESYNC_MODE=multisplit
DESYNC_OFS=midsld
DESYNC_SEQOVL=5

# Полная команда (переопределяет стандартную)
NFQWS2_OPT="--qnum=200 --lua-init=@/opt/zapret2/lua/zapret-lib.lua --lua-init=@/opt/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5"

# Отключаем IPv6 (если не нужен)
DISABLE_IPV6=1
```

---

## **8️⃣ Запуск zapret через штатный сервис AUR**

```bash
# Запускаем сервис
sudo systemctl start zapret2.service

# Проверяем статус
sudo systemctl status zapret2.service --no-pager

# Смотрим, что процесс запустился
ps aux | grep nfqws2 | grep -v grep

# Включаем автозагрузку
sudo systemctl enable zapret2.service
```

---

## **9️⃣ Проверка работы**

```bash
# Тестируем YouTube
curl -I https://youtube.com 2>/dev/null | head -1

# Ожидаемый вывод: HTTP/2 200 или HTTP/2 301
```

---

# **ЧАСТЬ 2: УСТАНОВКА ИЗ РЕЛИЗА GitHub (v0.9.5.2)**

Этот способ подойдёт, если вы хотите использовать **конкретную стабильную версию**, а не master ветку.

```bash
# Скачиваем релиз v0.9.5.2
cd /opt
sudo wget https://github.com/bol-van/zapret2/releases/download/v0.9.5.2/zapret2-v0.9.5.2.tar.gz

# Распаковываем
sudo tar -xzf zapret2-v0.9.5.2.tar.gz

# Переименовываем для удобства
sudo mv zapret2-v0.9.5.2 zapret2

# Удаляем архив
sudo rm zapret2-v0.9.5.2.tar.gz

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

**Далее настройка nftables и модуля ядра — та же, что в Части 1 (шаги 4-6).**

### **Создание сервиса для релизной версии:**

```bash
sudo tee /etc/systemd/system/zapret.service << 'EOF'
[Unit]
Description=Zapret DPI bypass v0.9.5.2 (release)
After=network.target nftables.service
Wants=nftables.service

[Service]
Type=simple
ExecStartPre=/usr/bin/modprobe nfnetlink_queue
ExecStart=/opt/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/opt/zapret2/lua/zapret-lib.lua --lua-init=@/opt/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now zapret.service
```

---

# **ЧАСТЬ 3: УСТАНОВКА ИЗ MASTER ВЕТКИ GitHub (С КОМПИЛЯЦИЕЙ)**

Этот способ подойдёт, если вам нужны **самые свежие изменения** из репозитория.

```bash
# Клонируем репозиторий целиком
cd /opt
sudo git clone https://github.com/bol-van/zapret2.git
cd zapret2

# Компилируем nfqws2
cd nfq2
sudo make
cd ..

# Компилируем ip2net
cd ip2net
sudo make
cd ..

# Компилируем mdig
cd mdig
sudo make
cd ..

# Проверяем, что бинарники создались
ls -la nfq2/nfqws2
ls -la ip2net/ip2net
ls -la mdig/mdig
```

**Примечание:** В master ветке бинарники не включены в репозиторий — их нужно компилировать самостоятельно. Компиляция требует установки `base-devel` и зависимостей.

```bash
# Устанавливаем зависимости для компиляции (если ещё нет)
sudo pacman -S base-devel gcc make libnetfilter_queue
```

**Далее настройка nftables и модуля ядра — та же, что в Части 1 (шаги 4-6).**

### **Создание сервиса для master-версии:**

```bash
sudo tee /etc/systemd/system/zapret-master.service << 'EOF'
[Unit]
Description=Zapret DPI bypass (master branch)
After=network.target nftables.service
Wants=nftables.service

[Service]
Type=simple
ExecStartPre=/usr/bin/modprobe nfnetlink_queue
ExecStart=/opt/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/opt/zapret2/lua/zapret-lib.lua --lua-init=@/opt/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now zapret-master.service
```

### **Обновление master-версии:**

```bash
cd /opt/zapret2
sudo git pull
cd nfq2 && sudo make clean && sudo make && cd ..
cd ip2net && sudo make clean && sudo make && cd ..
cd mdig && sudo make clean && sudo make && cd ..
sudo systemctl restart zapret-master.service
```

---

# **ЧАСТЬ 4: УНИВЕРСАЛЬНЫЕ СКРИПТЫ УПРАВЛЕНИЯ**

Создаём скрипты, которые работают независимо от способа установки:

```bash
# Скрипт для проверки статуса
sudo tee /usr/local/bin/zapret-status << 'EOF'
#!/bin/bash
echo "=== ZAPRET ПРОЦЕСС ==="
if pgrep -f nfqws2 > /dev/null; then
    echo "✅ РАБОТАЕТ (PID: $(pgrep -f nfqws2))"
else
    echo "❌ НЕ РАБОТАЕТ"
fi

echo ""
echo "=== NFTABLES ПРАВИЛА ==="
if sudo nft list table inet zapret &>/dev/null; then
    echo "✅ ЗАГРУЖЕНЫ"
else
    echo "❌ НЕ ЗАГРУЖЕНЫ"
fi

echo ""
echo "=== МОДУЛЬ ЯДРА ==="
if lsmod | grep -q nfnetlink_queue; then
    echo "✅ nfnetlink_queue ЗАГРУЖЕН"
else
    echo "❌ nfnetlink_queue НЕ ЗАГРУЖЕН"
fi

echo ""
echo "=== YOUTUBE ТЕСТ ==="
curl -I https://youtube.com 2>/dev/null | head -1
EOF

# Скрипт для перезапуска
sudo tee /usr/local/bin/zapret-restart << 'EOF'
#!/bin/bash
echo "🔄 Перезапускаем zapret..."
sudo systemctl restart zapret2.service 2>/dev/null || \
sudo systemctl restart zapret.service 2>/dev/null || \
sudo systemctl restart zapret-master.service 2>/dev/null
sleep 2
zapret-status
EOF

# Скрипт для остановки
sudo tee /usr/local/bin/zapret-stop << 'EOF'
#!/bin/bash
echo "🛑 Останавливаем zapret..."
sudo systemctl stop zapret2.service 2>/dev/null
sudo systemctl stop zapret.service 2>/dev/null
sudo systemctl stop zapret-master.service 2>/dev/null
echo "✅ Остановлен"
EOF

# Делаем скрипты исполняемыми
sudo chmod +x /usr/local/bin/zapret-{status,restart,stop}
```

---

# **ЧАСТЬ 5: ДИАГНОСТИКА И УСТРАНЕНИЕ ПРОБЛЕМ**

## **Проблема 1: `nfnetlink_queue: No such file or directory`**

```bash
# Проверяем наличие модуля
find /lib/modules/$(uname -r)/kernel/net/netfilter/ -name "*nfnetlink_queue*"

# Если нет — обновляем ядро
sudo pacman -Syu
sudo reboot

# Загружаем модуль
sudo modprobe nfnetlink_queue

# Включаем автозагрузку
echo "nfnetlink_queue" | sudo tee /etc/modules-load.d/nfqueue.conf
```

## **Проблема 2: `delete table inet zapret` Error**

**Решение:** Убедитесь, что в файле правил есть строка `delete table inet zapret` ПЕРЕД определением таблицы. Или используйте упрощённые правила из шага 5.

## **Проблема 3: `bad file` в логах**

```bash
# Проверяем логи
sudo journalctl -u zapret2.service -n 50 --no-pager | grep -i "bad file"

# Решение: использовать абсолютные пути в --lua-init
# Правильно:
--lua-init=@/opt/zapret2/lua/zapret-lib.lua
# Неправильно:
--lua-init=@lua/zapret-lib.lua
```

## **Проблема 4: Zapret работает, но YouTube не открывается**

```bash
# 1. Отключите QUIC в браузере
# Chrome: chrome://flags/#enable-quic → Disabled
# Firefox: about:config → network.http.http3.enabled → false

# 2. Проверьте, доходят ли пакеты до очереди
sudo /opt/zapret2/nfq2/nfqws2 --qnum=200 --debug --lua-init=@/opt/zapret2/lua/zapret-lib.lua --lua-init=@/opt/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=midsld:seqovl=5

# В другом терминале выполните:
curl -I https://youtube.com

# Если видите "packet processed" — трафик доходит, проблема в стратегии
```

## **Проблема 5: Полная потеря доступа к сайтам (Красная кнопка)**

```bash
# Останавливаем zapret
sudo zapret-stop

# Сбрасываем ВСЕ правила nftables
sudo nft flush ruleset

# Перезапускаем NetworkManager
sudo systemctl restart NetworkManager

# Если используется firewalld — перезапускаем его
sudo systemctl restart firewalld
```

---

# **📌 ИТОГОВАЯ ТАБЛИЦА: СРАВНЕНИЕ СПОСОБОВ УСТАНОВКИ**

| Характеристика | AUR (бинарный) | AUR (исходники) | GitHub релиз | GitHub master |
|----------------|----------------|-----------------|--------------|---------------|
| **Сложность** | ⭐ Простой | ⭐⭐ Средний | ⭐⭐ Средний | ⭐⭐⭐ Сложный |
| **Время установки** | 15 сек | 1-2 мин | 30 сек | 2-3 мин + компиляция |
| **Обновление** | `paru -Syu` | `paru -Syu` | Вручную | `git pull` + make |
| **Стабильность** | Высокая | Высокая | Высокая (фиксированная версия) | Средняя (может быть сыро) |
| **Свежесть** | Стабильный релиз | Стабильный релиз | Стабильный релиз | Последние коммиты |
| **Создаёт сервис** | ✅ Да | ✅ Да | ❌ Вручную | ❌ Вручную |
| **Рекомендация** | ✅ **Лучший выбор** | 👍 Хороший выбор | 👍 Для конкретной версии | 🔧 Для разработчиков |

---

# **🎯 РАБОЧАЯ КОНФИГУРАЦИЯ (ПРОВЕРЕНО 29 МАЯ 2026)**

| Компонент | Значение |
|-----------|----------|
| **Путь установки** | `/opt/zapret2` |
| **Версия** | v0.9.5.2 (релиз) или master (с компиляцией) |
| **Стратегия** | `multisplit:pos=midsld:seqovl=5` |
| **Очередь NFQUEUE** | 200 |
| **Порты** | TCP 80, 443 и UDP 443 |
| **Модуль ядра** | `nfnetlink_queue` (автозагрузка) |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **QUIC в браузере** | **ДОЛЖЕН БЫТЬ ОТКЛЮЧЁН** |

---

# **✅ ФИНАЛЬНАЯ ПРОВЕРКА**

После выполнения любого из способов установки выполните:

```bash
# 1. Проверяем модуль ядра
lsmod | grep nfnetlink_queue

# 2. Проверяем правила nftables
sudo nft list table inet zapret

# 3. Проверяем процесс zapret
pgrep -f nfqws2 && echo "✅ Zapret запущен" || echo "❌ Zapret не запущен"

# 4. Тестируем YouTube
curl -I https://youtube.com 2>/dev/null | head -1

# 5. Смотрим статус сервиса
sudo systemctl status zapret2.service --no-pager
```

**Если везде ✅ и YouTube отвечает `HTTP/2 200` или `HTTP/2 301` — установка прошла успешно!** 🎉

---

**📝 Последнее примечание:** Стратегии обхода могут меняться со временем. Если перестанет работать — попробуйте `pos=1` вместо `midsld` или используйте `blockcheck2.sh` для автоматического подбора. Актуальная документация: https://github.com/bol-van/zapret2/
