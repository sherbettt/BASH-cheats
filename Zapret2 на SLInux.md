Я плохо разбираюсь в сетях иу меня всегда были проблемы с установокой https://github.com/bol-van/zapret2/ на ALT-based дистрибутивы Linux.

Тем не менее простую шпаргалку для SLInux  напишу, т.к. удалось случайно.

## 📋 Краткий отчёт: Что мы сделали

### 1️⃣ Установленные пакеты

**Для nftables:**
```bash
apt-get install nftables libnftnl
```

**Для компиляции (попытки):**
```bash
apt-get install gcc make libpcap-dev libssl-dev libnetfilter-queue-dev libnfnetlink-dev lua5.3 liblua5.3-devel libcap-devel zlib-devel
```

### 2️⃣ Настройка nftables (правила для zapret)

Создали файл `/etc/nftables/zapret.nft`:
```nft
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

### 3️⃣ Настройка параметра ядра
```bash
sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
echo "net.netfilter.nf_conntrack_tcp_be_liberal=1" >> /etc/sysctl.conf
```

### 4️⃣ Zapret: компиляция (неудачно) и готовые бинарники

Скачали и распаковали `zapret2-v0.9.4.3.tar.gz`

Пытались скомпилировать, но не хватило библиотек. Взяли готовые бинарники:
```bash
cp binaries/linux-x86_64/nfqws2 ./nfq2/nfqws2
cp binaries/linux-x86_64/ip2net ./ip2net/ip2net
cp binaries/linux-x86_64/mdig ./mdig/mdig
chmod +x ./nfq2/nfqws2 ./ip2net/ip2net ./mdig/mdig
```

### 5️⃣ Запуски (что пробовали)

**Первая попытка (fake стратегия):**
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=fake:blob=fake_default_tls:tcp_md5:tls_mod=rnd,rndsni,dupsid
```

**Вторая попытка (multisplit стратегия — **РАБОЧАЯ**):**
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

**Третья попытка (расширенные порты):**
```bash
sudo ./nfq2/nfqws2 --qnum=200 --debug --filter-tcp=80,443,8443 --filter-l7=tls,http --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

### 6️⃣ Как останавливать zapret

#### Вариант 1: Если запущено вручную (в терминале)
Просто нажмите `Ctrl+C` в том терминале, где запущен процесс.

#### Вариант 2: Если процесс остался в фоне
```bash
sudo pkill nfqws2
```

#### Вариант 3: Если сделали systemd сервис (НО МЫ ЕГО НЕ ДЕЛАЛИ)
```bash
sudo systemctl stop zapret.service
sudo systemctl disable zapret.service
```

### 7️⃣ Проверка, запущен ли zapret
```bash
ps aux | grep nfqws2
```

### 8️⃣ Удаление правил nftables (если нужно полностью отключить)
```bash
sudo nft delete table inet zapret
```

---

## 🔥 ИТОГ: РАБОЧАЯ КОМАНДА
```bash
cd ~/Загрузки/zapret2-v0.9.4.3
sudo ./nfq2/nfqws2 --qnum=200 --debug --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

Если хотите убрать `--debug` (чтобы не спамило в консоль):
```bash
sudo ./nfq2/nfqws2 --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
```

---


