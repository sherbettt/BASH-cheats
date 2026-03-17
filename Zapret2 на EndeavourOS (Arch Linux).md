## 📗 **ИНСТРУКЦИЯ: Установка и настройка zapret на EndeavourOS (Arch Linux)**


## **1️⃣ Подготовка системы (установка необходимых пакетов)**

```bash
# Обновляем систему
sudo pacman -Syu

# Устанавливаем необходимые пакеты
sudo pacman -S nftables lua tcpdump
```

*Почему:* `nftables` нужен для перенаправления трафика, `lua` — для скриптов zapret, `tcpdump` — для отладки.

---

## **2️⃣ Настройка nftables (правила перенаправления трафика)**

Создаем файл с правилами:
```bash
sudo mcedit /etc/nftables/zapret.nft
```

Вставляем:
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

Загружаем правила:
```bash
sudo nft -f /etc/nftables/zapret.nft
```

Проверяем:
```bash
sudo nft list ruleset
```

**Автозагрузка правил при старте системы (через systemd):**
```bash
# Создаем сервис для загрузки правил
sudo systemctl enable nftables
sudo systemctl start nftables

# Добавляем наши правила в автозагрузку nftables
echo 'include "/etc/nftables/zapret.nft"' | sudo tee -a /etc/nftables/nftables.conf
```

---

## **3️⃣ Настройка параметра ядра (важно для TCP)**

```bash
# Временное включение
sudo sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1

# Постоянное включение
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" | sudo tee -a /etc/sysctl.d/99-zapret.conf
sudo sysctl --system
```

---

## **4️⃣ Скачивание zapret в системную директорию**

```bash
# Переходим в директорию для загрузок
cd ~/Загрузки/
# или
cd ~/Downloads/

# Скачиваем архив последней версии
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.5/zapret2-v0.9.4.5.tar.gz

# Распаковываем в /usr/local/bin/ (с правами root)
sudo tar -xzf zapret2-v0.9.4.5.tar.gz -C /usr/local/bin/

# Переименовываем для удобства (если нужно)
sudo mv /usr/local/bin/zapret2-v0.9.4.5 /usr/local/bin/zapret2

# Удаляем архив
rm zapret2-v0.9.4.5.tar.gz
```

---

## **5️⃣ Использование готовых бинарников (без компиляции)**

В EndeavourOS можно либо скомпилировать, либо использовать готовые бинарники:

```bash
cd /usr/local/bin/zapret2

# Копируем бинарники для x86_64 в соответствующие папки
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/

# Делаем их исполняемыми
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig
```

**Альтернатива: компиляция из исходников (если хотите):**
```bash
cd /usr/local/bin/zapret2
sudo pacman -S gcc make libcap zlib libnetfilter_queue libpcap
make
```

**Проверяем, что файлы на месте:**
```bash
ls -la /usr/local/bin/zapret2/nfq2/nfqws2
```
Должны увидеть: `-rwxr-xr-x 1 root root ... nfq2/nfqws2`

---

## **6️⃣ ВАЖНО: Права доступа к Lua файлам**

`nfqws2` после запуска понижает привилегии для безопасности, поэтому ему нужен доступ на чтение к Lua файлам. **Без этого шага zapret не запустится!**

```bash
# Даем права на чтение и выполнение для всех директорий в пути
sudo chmod a+x /usr/local/
sudo chmod a+x /usr/local/bin/
sudo chmod a+x /usr/local/bin/zapret2/
sudo chmod a+x /usr/local/bin/zapret2/lua/
sudo chmod a+r /usr/local/bin/zapret2/lua/*.lua
```

---

## **7️⃣ Запуск и тестирование стратегий**

### **Проверка ДО запуска:**
```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть медленно или ошибка
```

### **РАБОЧАЯ стратегия (multisplit) с отладкой:**
```bash
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### **Проверка ПОСЛЕ запуска (в другом терминале):**
```bash
curl -I https://www.youtube.com 2>/dev/null | head -n 1
# Должно быть быстро с HTTP/2 200
```

### **Если работает — запускаем без отладки (тихо):**
```bash
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### **Вариант с расширенными портами:**
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --filter-tcp=80,443,8443 --filter-l7=tls,http --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

---

## **8️⃣ Как управлять zapret**

### **Запуск:**
```bash
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### **Остановка:**
```bash
sudo pkill -f nfqws2
```
или `Ctrl+C` если запущено в терминале.

### **Проверка, работает ли:**
```bash
ps aux | grep nfqws2
```
Если видно `nfqws2` — работает. Если только `grep` — не работает.

---

## **9️⃣ Просмотр логов и отладка**

С флагом `--debug` видно всё в реальном времени:
```bash
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### Простая проверка работы:
```bash
# Посмотреть, обрабатывает ли nfqws2 трафик
sudo tcpdump -i any -n port 443 -c 10
```

---

## **🔟 Автозапуск при загрузке системы (systemd сервис)**

Создаем systemd сервис:
```bash
sudo mcedit /etc/systemd/system/zapret.service
```

Вставляем **самый надежный вариант** с абсолютными путями:
```ini
[Unit]
Description=Zapret DPI bypass
After=network.target nftables.service
Wants=network.target

[Service]
Type=simple
User=root
Group=root
# Абсолютные пути с @ — гарантированно работает!
ExecStart=/usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=on-failure
RestartSec=5
# Добавляем переменные окружения
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
```

Включаем и запускаем:
```bash
sudo systemctl daemon-reload
sudo systemctl enable zapret
sudo systemctl start zapret
sudo systemctl status zapret
```

Просмотр логов сервиса:
```bash
sudo journalctl -u zapret -f
```

### **Проверка после перезагрузки:**
```bash
sudo reboot
# После входа в систему:
systemctl status zapret
curl -I https://www.youtube.com 2>/dev/null | head -n 1
```

---

## **1️⃣1️⃣ Как посмотреть доступные стратегии**

```bash
cat /usr/local/bin/zapret2/lua/zapret-antidpi.lua | grep -A 5 "desync profiles"
```

---

## **1️⃣2️⃣ Как убрать всё (если надоест)**

Остановить zapret:
```bash
sudo pkill -f nfqws2
sudo systemctl stop zapret
sudo systemctl disable zapret
```

Удалить правила nftables:
```bash
sudo nft delete table inet zapret
# Или удалить из конфига:
sudo sed -i '/zapret/d' /etc/nftables/nftables.conf
```

Удалить сервис:
```bash
sudo rm /etc/systemd/system/zapret.service
sudo systemctl daemon-reload
```

Удалить zapret:
```bash
sudo rm -rf /usr/local/bin/zapret2
```

---

## **📌 ИТОГ: РАБОЧАЯ КОНФИГУРАЦИЯ**

| Компонент | Значение |
|-----------|----------|
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Команда запуска** | `sudo /usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5` |
| **Правила nftables** | В файле `/etc/nftables/zapret.nft` |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Автозапуск** | systemd сервис `/etc/systemd/system/zapret.service` |
| **Рабочая директория** | `/usr/local/bin/zapret2` |

---

## ✅ **Что теперь работает**
- YouTube открывается без тормозов
- Другие заблокированные сайты тоже могут работать

---

## 🐞 **ТИПИЧНАЯ ПРОБЛЕМА: systemd сервис запущен, но YouTube не работает**

### **Симптомы:**
- В терминале zapret работает отлично
- systemd сервис запускается без ошибок
- Но YouTube по-прежнему тормозит или не открывается

### **Диагностика:**

**1. Проверьте, видит ли nfqws2 Lua файлы:**
```bash
sudo journalctl -u zapret -f
# Или посмотрите последние логи:
sudo journalctl -u zapret -e
```

Если видите ошибку:
```
bad file 'lua/zapret-lib.lua'
```
Значит, **проблема в путях к Lua файлам!**

**2. Почему это происходит:**
- При ручном запуске из папки `/usr/local/bin/zapret2/` путь `@lua/zapret-lib.lua` работает
- При запуске через systemd текущая директория может быть другой
- Даже с указанным `WorkingDirectory` иногда возникают проблемы

**3. Быстрая проверка:**
```bash
# Остановите сервис
sudo systemctl stop zapret

# Перейдите в любую другую директорию
cd /tmp

# Попробуйте запустить вручную с относительными путями
sudo /usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```
Если увидите `bad file 'lua/zapret-lib.lua'` — вы воспроизвели проблему!

---

## 🔧 **РЕШЕНИЕ: Абсолютные пути к Lua файлам**

**Исправленный systemd сервис (уже приведен в разделе 10):**

```ini
ExecStart=/usr/local/bin/zapret2/nfq2/nfqws2 --qnum=200 --lua-init=@/usr/local/bin/zapret2/lua/zapret-lib.lua --lua-init=@/usr/local/bin/zapret2/lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

**Ключевые моменты:**
- **Абсолютный путь** — процесс точно знает, где искать файл
- **Символ @** — говорит nfqws2: "это путь к файлу, загрузи его"

---

## 📚 **Памятка по синтаксису --lua-init:**

| Синтаксис | Что означает |
|-----------|--------------|
| `--lua-init='print("hello")'` | Выполнить код напрямую |
| `--lua-init=@script.lua` | Загрузить из файла **относительно текущей директории** |
| `--lua-init=@/abs/path/script.lua` | Загрузить из файла **по абсолютному пути** (НАДЁЖНО) |

---

## ✅ **После исправления:**

```bash
sudo systemctl daemon-reload
sudo systemctl restart zapret
sudo systemctl status zapret -l --no-pager
sudo journalctl -u zapret -f
```

---

## ❓ **Если что-то пойдёт не так**

1. **Проверь, есть ли бинарник:**
   ```bash
   ls -la /usr/local/bin/zapret2/nfq2/nfqws2
   ```

2. **Проверь права на Lua файлы:**
   ```bash
   ls -la /usr/local/bin/zapret2/lua/
   ```

3. **Проверь, запущен ли nfqws2:**
   ```bash
   ps aux | grep nfqws2
   ```

4. **Проверь правила nftables:**
   ```bash
   sudo nft list ruleset
   ```

5. **Проверь статус nftables:**
   ```bash
   sudo systemctl status nftables
   ```

6. **Перезапусти с `--debug` и смотри ошибки:**
   ```bash
   sudo journalctl -u zapret -f
   ```

7. **Посмотри логи сервиса:**
   ```bash
   sudo journalctl -u zapret -e
   ```

8. **Проверка системных логов:**
   ```bash
   sudo dmesg | grep -i denied
   sudo journalctl -xe
   ```

---

## 🔥 **ИТОГОВАЯ РАБОЧАЯ КОМАНДА (РУЧНОЙ ЗАПУСК)**

```bash
cd /usr/local/bin/zapret2
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

---

## 🎯 **Дополнительно для Arch/EndeavourOS**

### **AUR пакет (альтернативный способ установки)**

В EndeavourOS можно установить zapret из AUR:
```bash
# С помощью yay (если установлен)
yay -S zapret

# Или с помощью paru
paru -S zapret
```

Но учтите: версия в AUR может отличаться, и настройка всё равно потребуется.

### **Проверка версии ядра**
```bash
uname -r
# Если ядро свежее (>6.0), всё должно работать отлично
```

---

## 📝 **Примечание:** 
Стратегии могут меняться со временем. Если перестанет работать — попробуйте другие варианты из файла `zapret-antidpi.lua` или проверьте актуальную документацию на https://github.com/bol-van/zapret2/

---

