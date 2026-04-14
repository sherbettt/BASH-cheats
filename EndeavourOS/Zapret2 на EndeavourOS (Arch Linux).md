# 📗 **Установка и настройка zapret на EndeavourOS (Arch Linux)**


## **1️⃣ Подготовка системы (установка необходимых пакетов)**

```bash
# Обновляем систему
sudo pacman -Syu

# Устанавливаем необходимые пакеты
sudo pacman -S nftables lua tcpdump curl

# Для компиляции из исходников
sudo pacman -S gcc make libcap zlib libnetfilter_queue libpcap
```

*Почему:*  
- `nftables` — для перенаправления трафика  
- `lua` — для скриптов zapret  
- `tcpdump` — для отладки  
- `curl` — для проверки доступности сайтов

---

## **2️⃣ Настройка nftables (правила перенаправления трафика)**

В EndeavourOS используется `nftables`, но по умолчанию он может быть не активен. Мы создадим отдельный файл с правилами для zapret и подключим его к основному конфигу.

### **2.1 Создаем файл с правилами для zapret**

```bash
sudo mcedit /etc/nftables-zapret.conf
```

Вставляем:

```nft
#!/usr/sbin/nft -f

# Таблица для zapret
add table inet zapret
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

### **2.2 Подключаем правила к основному конфигу nftables**

```bash
echo 'include "/etc/nftables-zapret.conf"' | sudo tee -a /etc/nftables.conf
```

### **2.3 Включаем и запускаем nftables**

```bash
sudo systemctl enable nftables
sudo systemctl start nftables
```

### **2.4 Проверяем, что правила загрузились**

```bash
sudo nft list tables
sudo nft list table inet zapret
```

**Должны увидеть таблицу `inet zapret` с цепочками post, pre, output.**

> ⚠️ **Важно:** Статус `inactive (dead)` для сервиса `nftables` — это нормально. Сервис работает по принципу "загрузил правила и завершился". Главное, чтобы правила были видны в `nft list ruleset`.

---

## **3️⃣ Настройка параметра ядра (важно для TCP)**

```bash
# Временное включение
sudo sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1

# Постоянное включение
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

## **4️⃣ Скачивание zapret в системную директорию**

```bash
cd ~/Downloads
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.5/zapret2-v0.9.4.5.tar.gz
sudo tar -xzf zapret2-v0.9.4.5.tar.gz -C /usr/local/bin/
sudo mv /usr/local/bin/zapret2-v0.9.4.5 /usr/local/bin/zapret2
rm zapret2-v0.9.4.5.tar.gz
```

---

## **5️⃣ Использование готовых бинарников (без компиляции)**

```bash
cd /usr/local/bin/zapret2
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig
```

**Альтернатива: компиляция из исходников (если хотите):**

```bash
cd /usr/local/bin/zapret2
make
```

**Проверка:**

```bash
ls -la /usr/local/bin/zapret2/nfq2/nfqws2
# Должно быть: -rwxr-xr-x 1 root root ...
```

---

## **6️⃣ ВАЖНО: Права доступа к Lua файлам**

`nfqws2` после запуска понижает привилегии, поэтому ему нужен доступ на чтение к Lua файлам.

```bash
sudo chmod a+x /usr/local/
sudo chmod a+x /usr/local/bin/
sudo chmod a+x /usr/local/bin/zapret2/
sudo chmod a+x /usr/local/bin/zapret2/lua/
sudo chmod a+r /usr/local/bin/zapret2/lua/*.lua
```

---

## **7️⃣ Скрипты управления zapret (очень удобно!)**

Создаём три скрипта для повседневного использования:

```bash
sudo mcedit /usr/local/bin/zapret-start
```

```bash
#!/bin/bash
# Запуск zapret с проверкой nftables

echo "🔄 Загружаем правила nftables..."
sudo nft -f /etc/nftables-zapret.conf 2>/dev/null || {
    sudo nft delete table inet zapret 2>/dev/null
    sudo nft -f /etc/nftables-zapret.conf
}

echo "🚀 Запускаем nfqws2..."
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --daemon --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5

sleep 2
if pgrep -f nfqws2 >/dev/null; then
    echo "✅ Zapret запущен"
    curl -I https://www.youtube.com 2>/dev/null | head -n 1
else
    echo "❌ Ошибка запуска!"
fi
```

```bash
sudo mcedit /usr/local/bin/zapret-stop
```

```bash
#!/bin/bash
echo "🛑 Останавливаем nfqws2..."
sudo pkill -f nfqws2
echo "✅ Остановлен"
```

```bash
sudo mcedit /usr/local/bin/zapret-status
```

```bash
#!/bin/bash
echo "=== NFQWS2 ==="
pgrep -f nfqws2 >/dev/null && echo "✅ РАБОТАЕТ" || echo "❌ НЕ РАБОТАЕТ"

echo "=== NFTABLES ==="
sudo nft list table inet zapret &>/dev/null && echo "✅ ЗАГРУЖЕНЫ" || echo "❌ НЕ ЗАГРУЖЕНЫ"

echo "=== YouTube тест ==="
curl -I https://www.youtube.com 2>/dev/null | head -n 1 || echo "❌ Не отвечает"
```

Делаем скрипты исполняемыми:

```bash
sudo chmod +x /usr/local/bin/zapret-{start,stop,status}
```

Теперь управление одной командой:

```bash
sudo zapret-start
sudo zapret-stop
zapret-status
```

---

## **8️⃣ Ручной запуск и тестирование стратегий**

### **Проверка ДО запуска:**

```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть медленно или ошибка
```

### **Запуск с отладкой:**

```bash
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### **Проверка ПОСЛЕ запуска (в другом терминале):**

```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть HTTP/2 200
```

---

## **9️⃣ АВТОЗАПУСК: systemd сервис с правильной зависимостью**

### Создаём сервис для zapret

```bash
sudo mcedit /etc/systemd/system/zapret.service
```

```ini
[Unit]
Description=Zapret DPI bypass
After=network.target nftables.service
Wants=nftables.service
Before=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=on-failure
RestartSec=5
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
```

### Включаем и запускаем

```bash
sudo systemctl daemon-reload
sudo systemctl enable zapret
sudo systemctl start zapret
sudo systemctl status zapret
```

### Просмотр логов

```bash
sudo journalctl -u zapret -f
```

---

## **🔟 Просмотр доступных стратегий**

```bash
cat /usr/local/bin/zapret2/lua/zapret-antidpi.lua | grep -A 5 "desync profiles"
```

---

## **1️⃣1️⃣ Диагностика: сервис запущен, но YouTube не работает**

### Симптомы:
- `systemctl status zapret` показывает `active (running)`
- `zapret-status` показывает, что nfqws2 работает
- Но YouTube не открывается

### Возможные причины и проверки:

**1. Проверьте, загружены ли правила nftables:**

```bash
sudo nft list table inet zapret
# Если пусто — правила не загружены
sudo systemctl restart nftables
sudo nft list table inet zapret
```

**2. Проверьте, видит ли nfqws2 Lua файлы:**

```bash
sudo journalctl -u zapret -e | grep -i "bad file"
```

Если видите `bad file 'lua/zapret-lib.lua'` — используйте **абсолютные пути** (они уже прописаны в сервисе выше).

**3. Проверка, доходит ли трафик до очереди:**

```bash
# В одном терминале запустите с дебагом
sudo zapret-stop
sudo /usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --debug=1 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5

# В другом терминале
curl -I https://www.youtube.com
```

Если в дебаге видно `packet processed` — трафик доходит, проблема в стратегии.  
Если тишина — проблема в nftables.

---

## **1️⃣2️⃣ Особенности для EndeavourOS / Arch Linux**

### **Firewalld**
Если у вас включён firewalld, он может мешать:

```bash
sudo systemctl status firewalld
# Если активен, можно остановить:
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

Или добавить правило для очереди:

```bash
sudo firewall-cmd --add-forward-port=queue
```

### **Проверка версии ядра**

```bash
uname -r
# Если ядро свежее (>6.0), всё должно работать отлично
```

---

## **1️⃣3️⃣ Как убрать всё (если надоест)**

```bash
sudo systemctl stop zapret
sudo systemctl disable zapret
sudo rm /etc/systemd/system/zapret.service
sudo systemctl daemon-reload

# Удаляем правила nftables
sudo nft delete table inet zapret
sudo sed -i '/zapret/d' /etc/nftables.conf
sudo rm /etc/nftables-zapret.conf

# Удаляем zapret
sudo rm -rf /usr/local/bin/zapret2
sudo rm /usr/local/bin/zapret-{start,stop,status}

# Удаляем параметр ядра
sudo rm /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

## **📌 ИТОГ: РАБОЧАЯ КОНФИГУРАЦИЯ**

| Компонент | Значение |
|-----------|----------|
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Команда запуска** | `sudo /usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5` |
| **Правила nftables** | `/etc/nftables-zapret.conf` (подключен через include) |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Сервис nftables** | `nftables.service` |
| **Сервис zapret** | `zapret.service` |
| **Скрипты управления** | `zapret-start`, `zapret-stop`, `zapret-status` |
| **Рабочая директория** | `/usr/local/bin/zapret2` |

---

## ✅ **Что теперь работает**
- YouTube открывается без тормозов
- Другие заблокированные сайты тоже
- Всё запускается автоматически после перезагрузки
- Удобное управление через `zapret-start/stop/status`

---

## 📚 **Памятка по синтаксису --lua-init:**

| Синтаксис | Что означает |
|-----------|--------------|
| `--lua-init='print("hello")'` | Выполнить код напрямую |
| `--lua-init=@script.lua` | Загрузить из файла **относительно текущей директории** |
| `--lua-init=@/abs/path/script.lua` | Загрузить из файла **по абсолютному пути** (НАДЁЖНО) |

---

## 📝 **Примечание:** 
Стратегии могут меняться со временем. Если перестанет работать — попробуйте другие варианты из файла `zapret-antidpi.lua` или проверьте актуальную документацию на https://github.com/bol-van/zapret2/

----------
<br/>




## 🔄 **ДОПОЛНЕНИЕ К СТАТЬЕ: Обновление zapret до v0.9.4.7**

### **1️⃣ Останавливаем текущий сервис**

```bash
sudo systemctl stop zapret
sudo zapret-stop
```

### **2️⃣ Скачиваем новую версию**

```bash
# Создаем временную папку
mkdir /tmp/zapret_new ; cd /tmp/zapret_new

# Скачиваем новую версию
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.7/zapret2-v0.9.4.7.tar.gz
```



### **3️⃣ Распаковываем и устанавливаем**

```bash
# Распаковываем
sudo tar -xzf zapret2-v0.9.4.7.tar.gz -C /tmp/zapret_new/

# Сохраняем старую версию как бэкап
sudo mv /usr/local/bin/zapret2 /usr/local/bin/zapret2-0.9.4.5

# Устанавливаем новую
sudo mv /tmp/zapret_new/zapret2-v0.9.4.7 /usr/local/bin/zapret2

# Копируем готовые бинарники (без компиляции)
cd /usr/local/bin/zapret2
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig

# Чистим временные файлы
rm -rf /tmp/zapret_new 
```

### **4️⃣ Проверяем версию**

```bash
/usr/local/bin/zapret2/nfq2/nfqws2 --version
# Должно показать: github version v0.9.4.7 (32951c0...) lua_compat_ver 5
```

### **5️⃣ Обновляем права доступа**

```bash
sudo chmod a+x /usr/local/
sudo chmod a+x /usr/local/bin/
sudo chmod a+x /usr/local/bin/zapret2/
sudo chmod a+x /usr/local/bin/zapret2/lua/
sudo chmod a+r /usr/local/bin/zapret2/lua/*.lua
```

### **6️⃣ Обновляем systemd сервис (опционально)**

Можно добавить версию в название для наглядности:

```bash
sudo mcedit /etc/systemd/system/zapret.service
```

```ini
[Unit]
Description=Zapret DPI bypass v0.9.4.7
After=network.target nftables.service
Wants=nftables.service
Before=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=on-failure
RestartSec=5
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
```

### **7️⃣ Перезапускаем сервис**

```bash
sudo systemctl daemon-reload
sudo systemctl start zapret
sudo systemctl status zapret
```

**Ожидаемый вывод:**
```
● zapret.service - Zapret DPI bypass v0.9.4.7
     Loaded: loaded (/etc/systemd/system/zapret.service; disabled; preset: disabled)
     Active: active (running) since ... 
```

### **8️⃣ Проверяем работу**

```bash
# Проверяем версию в логах
sudo journalctl -u zapret -e | grep -i "version"

# Проверяем YouTube
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть: HTTP/2 200
```

### **9️⃣ Что нового в v0.9.4.7**

```bash
# Посмотреть изменения
curl -s https://api.github.com/repos/bol-van/zapret2/releases/tags/v0.9.4.7 | grep -A 5 "body"
```

Основное изменение (по данным официального релиза):
- **nfqws2:** ошибки применения dupsid, rndsni, padencap в tls_mod более не являются фатальными и не приводят к отказу от других успешно примененных модов. В debug log выдается предупреждение.

### **🔟 Возврат к старой версии (если нужно)**

```bash
sudo systemctl stop zapret
sudo rm -rf /usr/local/bin/zapret2
sudo mv /usr/local/bin/zapret2-0.9.4.5 /usr/local/bin/zapret2
sudo systemctl start zapret
```

---

## 📌 **Важные замечания**

| Что изменилось | Описание |
|----------------|----------|
| **Версия** | Обновлена с v0.9.4.5 до v0.9.4.7 |
| **Бинарники** | Используются готовые из `binaries/linux-x86_64/` |
| **Бэкап** | Старая версия сохранена как `/usr/local/bin/zapret2-0.9.4.5` |
| **Совместимость** | Все существующие скрипты (`zapret-start/stop/status`) продолжают работать |
| **Сервис** | systemd сервис обновлен с указанием версии в описании |

---

## ✅ **Итоговая рабочая конфигурация после обновления**

| Компонент | Значение |
|-----------|----------|
| **Версия zapret** | v0.9.4.7 |
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Правила nftables** | `/etc/nftables-zapret.conf` (без изменений) |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Сервис zapret** | `zapret.service` (с указанием версии) |
| **Рабочая директория** | `/usr/local/bin/zapret2` |
| **Бэкап старой версии** | `/usr/local/bin/zapret2-0.9.4.5` |

---

## 📝 **Примечания по обновлению**

1. **Скрипты управления** (`zapret-start`, `zapret-stop`, `zapret-status`) остаются без изменений и работают с новой версией
2. **Правила nftables** не требуют обновления
3. **Параметры ядра** остаются прежними
4. Если после обновления возникли проблемы — всегда есть бэкап для отката

-----------






