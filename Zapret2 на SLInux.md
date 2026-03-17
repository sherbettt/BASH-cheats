Отлично! Вот **ПОЛНАЯ ИНСТРУКЦИЯ** для установки zapret в `/usr/local/bin/zapret2-v0.9.4.5` (системная директория).

---

## 📗 **ПОЛНАЯ ИНСТРУКЦИЯ: Установка и настройка zapret на Simply Linux (ALT Linux) в системную директорию**

### Что мы сделаем шаг за шагом

---

## **1️⃣ Подготовка системы (установка необходимых пакетов)**

```bash
su -
apt-get update
apt-get install nftables libnftnl lua5.3
```

*Почему:* `nftables` нужен для перенаправления трафика, `lua5.3` — для скриптов zapret.

---

## **2️⃣ Настройка nftables (правила перенаправления трафика)**

Создаем файл с правилами:
```bash
mcedit /etc/nftables/zapret.nft
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
nft -f /etc/nftables/zapret.nft
```

Проверяем:
```bash
nft list ruleset
```

**Автозагрузка правил при старте системы:**
```bash
echo "nft -f /etc/nftables/zapret.nft" >> /etc/rc.local
chmod +x /etc/rc.local
```

---

## **3️⃣ Настройка параметра ядра (важно для TCP)**

```bash
sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" >> /etc/sysctl.conf
```

---

## **4️⃣ Скачивание zapret в системную директорию**

```bash
# Переходим в директорию для загрузок
cd /home/ваш_пользователь/Загрузки/

# Скачиваем архив
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.5/zapret2-v0.9.4.5.tar.gz

# Копируем архив в /usr/local/bin/
sudo cp zapret2-v0.9.4.5.tar.gz /usr/local/bin/

# Переходим в /usr/local/bin/
cd /usr/local/bin/

# Распаковываем архив (от root, чтобы не было проблем с правами)
sudo tar -xzf zapret2-v0.9.4.5.tar.gz

# Удаляем архив (оставляем только распакованную папку)
sudo rm zapret2-v0.9.4.5.tar.gz
```

---

## **5️⃣ Использование готовых бинарников (без компиляции)**

Вместо компиляции используем готовые бинарники из папки `binaries/`:

```bash
cd /usr/local/bin/zapret2-v0.9.4.5

# Копируем бинарники для x86_64 в соответствующие папки
sudo cp binaries/linux-x86_64/nfqws2 nfq2/
sudo cp binaries/linux-x86_64/ip2net ip2net/
sudo cp binaries/linux-x86_64/mdig mdig/

# Делаем их исполняемыми
sudo chmod +x nfq2/nfqws2 ip2net/ip2net mdig/mdig
```

**Проверяем, что файлы на месте:**
```bash
ls -la nfq2/nfqws2
```
Должны увидеть: `-rwxr-xr-x 1 root root ... nfq2/nfqws2`

---

## **6️⃣ ВАЖНО: Права доступа к Lua файлам**

`nfqws2` после запуска понижает привилегии для безопасности, поэтому ему нужен доступ на чтение к Lua файлам. **Без этого шага zapret не запустится!**

```bash
cd /usr/local/bin/zapret2-v0.9.4.5

# Даем права на чтение и выполнение для всех директорий в пути
sudo chmod a+x /usr/local/
sudo chmod a+x /usr/local/bin/
sudo chmod a+x /usr/local/bin/zapret2-v0.9.4.5/
sudo chmod a+x /usr/local/bin/zapret2-v0.9.4.5/lua/
sudo chmod a+r /usr/local/bin/zapret2-v0.9.4.5/lua/*.lua
```

---

## **7️⃣ Запуск и тестирование стратегий**

### **РАБОЧАЯ стратегия (multisplit) с отладкой:**
```bash
cd /usr/local/bin/zapret2-v0.9.4.5
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
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
cd /usr/local/bin/zapret2-v0.9.4.5
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
cd /usr/local/bin/zapret2-v0.9.4.5
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

Вставляем (обратите внимание на пути `/usr/local/bin/...`):
```ini
[Unit]
Description=Zapret DPI bypass
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bin/zapret2-v0.9.4.5
ExecStart=/usr/local/bin/zapret2-v0.9.4.5/nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Включаем и запускаем:
```bash
sudo systemctl enable zapret
sudo systemctl start zapret
sudo systemctl status zapret
```

Просмотр логов сервиса:
```bash
sudo journalctl -u zapret -f
```

---

## **1️⃣1️⃣ Как посмотреть доступные стратегии**

```bash
cat /usr/local/bin/zapret2-v0.9.4.5/lua/zapret-antidpi.lua | grep -A 5 "desync profiles"
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
```

Удалить сервис:
```bash
sudo rm /etc/systemd/system/zapret.service
sudo systemctl daemon-reload
```

Удалить zapret:
```bash
sudo rm -rf /usr/local/bin/zapret2-v0.9.4.5
```

---

## **📌 ИТОГ: РАБОЧАЯ КОНФИГУРАЦИЯ**

| Компонент | Значение |
|-----------|----------|
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Команда запуска** | `sudo /usr/local/bin/zapret2-v0.9.4.5/nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5` |
| **Правила nftables** | В файле `/etc/nftables/zapret.nft` |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Автозапуск** | systemd сервис `/etc/systemd/system/zapret.service` |
| **Рабочая директория** | `/usr/local/bin/zapret2-v0.9.4.5` |

---

## ✅ **Что теперь работает**
- YouTube открывается без тормозов
- Другие заблокированные сайты тоже могут работать

## ❓ **Если что-то пойдёт не так**

1. **Проверь, есть ли бинарник:**
   ```bash
   ls -la /usr/local/bin/zapret2-v0.9.4.5/nfq2/nfqws2
   ```
   Если файла нет — вернись к шагу 5.

2. **Проверь права на Lua файлы:**
   ```bash
   ls -la /usr/local/bin/zapret2-v0.9.4.5/lua/
   ```
   Должны быть права `-rw-r--r--` или `-rwxr-xr-x`.

3. **Проверь, запущен ли nfqws2:**
   ```bash
   ps aux | grep nfqws2
   ```

4. **Проверь правила nftables:**
   ```bash
   sudo nft list ruleset
   ```

5. **Перезапусти с `--debug` и смотри ошибки**

6. **Посмотри логи сервиса:**
   ```bash
   sudo journalctl -u zapret -e
   ```

---

## 🔥 **ИТОГОВАЯ РАБОЧАЯ КОМАНДА**

```bash
cd /usr/local/bin/zapret2-v0.9.4.5
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

---

## 📝 **Примечание:** 
Стратегии могут меняться со временем. Если перестанет работать — попробуйте другие варианты из файла `zapret-antidpi.lua` или проверьте актуальную документацию на https://github.com/bol-van/zapret2/




----------------------
<br/>

## 📗 **ПОЛНАЯ ИНСТРУКЦИЯ: Установка и настройка zapret на Simply Linux (ALT Linux)**

### Что мы сделали шаг за шагом

---

## **1️⃣ Подготовка системы (установка необходимых пакетов)**

```bash
su -
apt-get update
apt-get install nftables libnftnl lua5.3
```

*Почему:* `nftables` нужен для перенаправления трафика, `lua5.3` — для скриптов zapret.

---

## **2️⃣ Настройка nftables (правила перенаправления трафика)**

Создали файл с правилами:
```bash
mcedit /etc/nftables/zapret.nft
```

Вставили туда:
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

Загрузили правила:
```bash
nft -f /etc/nftables/zapret.nft
```

Проверили:
```bash
nft list ruleset
```

**Важно:** Чтобы правила загружались автоматически при старте системы:
```bash
echo "nft -f /etc/nftables/zapret.nft" >> /etc/rc.local
chmod +x /etc/rc.local
```

---

## **3️⃣ Настройка параметра ядра (важно для TCP)**

```bash
sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" >> /etc/sysctl.conf
```

---

## **4️⃣ Скачивание zapret**

```bash
# см. https://github.com/bol-van/zapret2/releases

cd /home/kkorablin/Загрузки/
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.5/zapret2-v0.9.4.5.tar.gz
tar -xzf zapret2-v0.9.4.3.tar.gz
cd zapret2-v0.9.4.3
```

---

## **5️⃣ Проблема с компиляцией и решение**

Пытались скомпилировать:
```bash
make
```
Но не хватило библиотек (libcap-devel, zlib-devel и др.)

**Решение:** использовали **готовые бинарники** из папки `binaries/`:

```bash
cp binaries/linux-x86_64/nfqws2 ./nfq2/nfqws2
cp binaries/linux-x86_64/ip2net ./ip2net/ip2net
cp binaries/linux-x86_64/mdig ./mdig/mdig
chmod +x ./nfq2/nfqws2 ./ip2net/ip2net ./mdig/mdig
```

**Если всё же хотите скомпилировать самостоятельно:**
```bash
apt-get install gcc make libcap-devel zlib-devel libnetfilter-queue-devel libpcap-devel
make
```

---

## **6️⃣ ВАЖНО: Права доступа к Lua файлам**

`nfqws2` после запуска понижает привилегии для безопасности, поэтому ему нужен доступ на чтение к Lua файлам. **Без этого шага zapret не запустится!**

```bash
# Даем права на чтение и выполнение для всех директорий в пути
chmod a+x /home/
chmod a+x /home/kkorablin/
chmod a+x /home/kkorablin/Загрузки/
chmod a+x /home/kkorablin/Загрузки/zapret2-v0.9.4.3/
chmod a+x /home/kkorablin/Загрузки/zapret2-v0.9.4.3/lua/
chmod a+r /home/kkorablin/Загрузки/zapret2-v0.9.4.3/lua/*.lua
```

---

## **7️⃣ Запуск и тестирование стратегий**

### ❌ Первая попытка (не сработала):
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=fake:blob=fake_default_tls:tcp_md5:tls_mod=rnd,rndsni,dupsid
```

### ✅ **РАБОЧАЯ стратегия (multisplit):**
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### 🔧 Вариант с расширенными портами:
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --filter-tcp=80,443,8443 --filter-l7=tls,http --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

**Примечание про порты:** Если сайты используют нестандартные порты, добавьте их через запятую. Например: `--filter-tcp=80,443,8443,8080 --filter-udp=443,8443`

---

## **8️⃣ Как управлять zapret**

### **Запуск** (из папки zapret):
```bash
cd /home/kkorablin/Загрузки/zapret2-v0.9.4.3
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### **Остановка**:
```bash
sudo pkill -f nfqws2
```
или `Ctrl+C` если запущено в терминале.

### **Проверка, работает ли**:
```bash
ps aux | grep nfqws2
```
Если видно `nfqws2` — работает. Если только `grep` — не работает.

---

## **9️⃣ Просмотр логов и отладка**

С флагом `--debug` видно всё в реальном времени:
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

Без `--debug` тихо работает в фоне.

### Простая проверка работы:
```bash
# Посмотреть, обрабатывает ли nfqws2 трафик
sudo tcpdump -i any -n port 443 -c 10
```

---

## **🔟 Автозапуск при загрузке системы (чтобы не запускать вручную)**

Создаем systemd сервис:
```bash
sudo mcedit /etc/systemd/system/zapret.service
```

Вставляем:
```ini
[Unit]
Description=Zapret DPI bypass
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/kkorablin/Загрузки/zapret2-v0.9.4.3
ExecStart=/home/kkorablin/Загрузки/zapret2-v0.9.4.3/nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Включаем и запускаем:
```bash
sudo systemctl enable zapret
sudo systemctl start zapret
sudo systemctl status zapret
```

Просмотр логов сервиса:
```bash
sudo journalctl -u zapret -f
```

---

## **1️⃣1️⃣ Как посмотреть доступные стратегии**

```bash
cat /home/kkorablin/Загрузки/zapret2-v0.9.4.3/lua/zapret-antidpi.lua | grep -A 5 "desync profiles"
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
```

Удалить сервис:
```bash
sudo rm /etc/systemd/system/zapret.service
sudo systemctl daemon-reload
```

---

## **📌 ИТОГ: РАБОЧАЯ КОНФИГУРАЦИЯ**

| Компонент | Значение |
|-----------|----------|
| **Стратегия** | `multisplit:pos=1:seqovl=5` |
| **Порты** | TCP 80, 443 |
| **Команда запуска** | `sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5` |
| **Правила nftables** | В файле `/etc/nftables/zapret.nft` |
| **Параметр ядра** | `net.netfilter.nf_conntrack_tcp_be_liberal=1` |
| **Автозапуск** | systemd сервис `/etc/systemd/system/zapret.service` |

---

## ✅ **Что теперь работает**
- YouTube открывается без тормозов
- Другие заблокированные сайты тоже могут работать

## ❓ **Если что-то пойдёт не так**

1. Проверь, запущен ли `nfqws2`: `ps aux | grep nfqws2`
2. Проверь правила nftables: `sudo nft list ruleset`
3. Проверь права доступа к Lua файлам (шаг 6)
4. Перезапусти с `--debug` и смотри ошибки
5. Посмотри логи сервиса: `sudo journalctl -u zapret -e`

---

## 🔥 **ИТОГ: РАБОЧАЯ КОМАНДА**
```bash
cd ~/Загрузки/zapret2-v0.9.4.3
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

Если хотите убрать `--debug` (чтобы не спамило в консоль):
```bash
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

---

### 📝 **Примечание:** 
Стратегии могут меняться со временем. Если перестанет работать — попробуйте другие варианты из файла `zapret-antidpi.lua` или проверьте актуальную документацию на https://github.com/bol-van/zapret2/

---

Теперь статья содержит всё необходимое: от установки до автозапуска и отладки, с объяснением типичных проблем (права доступа) и их решений.
