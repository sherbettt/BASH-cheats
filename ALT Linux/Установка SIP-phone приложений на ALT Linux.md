
# Установка ZoIPer на ALT Linux / Ximper Linux

Помощь: https://zadarma.com/ru/support/instructions/linux/zoiper/

Скачать отсюда https://www.zoiper.com/en/voip-softphone/download/current
<br/> Для установки пакета `Zoiper5_5.6.10_x86_64.deb` на **XIMPER LINUX** с использованием менеджера пакетов **EEPM** (Elbrus Easy Package Manager), выполните следующие шаги:

### 1. **Установка через EEPM**
Откройте терминал и выполните команду:
```bash
sudo eepm install ./Zoiper5_5.6.10_x86_64.deb
```
Если `eepm` поддерживает установку локальных `.deb`-пакетов, это должно сработать.

### 2. **Если EEPM не поддерживает прямую установку .deb**
Попробуйте установить вручную через `dpkg`:
```bash
sudo dpkg -i Zoiper5_5.6.10_x86_64.deb
```
Если возникнут ошибки зависимостей, выполните:
```bash
sudo eepm install -f  # или sudo apt-get install -f
```

### 3. **Запуск Zoiper 5**
После установки запустите программу:
```bash
zoiper5
```
Или найдите её в меню приложений.

### 4. **Если пакет несовместим**
Если XIMPER LINUX основан на **ALT Linux** или другом не-Debian дистрибутиве, `.deb` может не работать. В таком случае:
- Попробуйте найти Zoiper в репозиториях EEPM:
  ```bash
  sudo eepm install zoiper
  ```
- Или скачайте **RPM-версию** (если XIMPER использует RPM-пакеты).

### 5. **Ручная установка (если ничего не помогло)**
Распакуйте `.deb` и скопируйте файлы вручную:
```bash
ar x Zoiper5_5.6.10_x86_64.deb
tar -xf data.tar.xz
sudo cp -r usr /
```

Созданы:
<br/> 4028@office.runtel.org - telephone
<br/> 4029@office.runtel.org - softphone

```ini
## https://192.168.87.140/servlet?m=mod_data&p=status&q=load ##
	Версия	
Версия ПО	                53.84.0.15
Сборка	                    53.0.0.224.0.0.0
    Сертификат устройства	
Сертификат устройства	    Заводской сертификат
Сеть	
Порт Internet	            IPv4
IPv4	
Режим порта Internet	    DHCP
IP-адрес порта Internet	    192.168.87.140
Маска подсети	            255.255.255.0
Шлюз	                    192.168.87.1
Осн. DNS-сервер	            8.8.8.8
Доп. DNS-сервер	            77.88.8.8
    Общие	
MAC-адрес	                00:15:65:D5:DB:7B
VLAN ID	                    0
Статус WAN-порта	        100Mbps Full Duplex
PC Port статус	            Link Down
Режим порта PC	            Мост
Время работы	            0 дни 00:08
Текущее время	            19:29:36 Ср Июл 09
    Статус аккаунта	
Аккаунт 1	                4028@office.runtel.org : Зарегистрировано
```










------------------------------------------------------------

# Установка Linphone на ALT Linux / Ximper Linux

Помощь: https://zadarma.com/ru/support/instructions/linux/linphone/

```bash
└─ $ batp /etc/*release
Ximper Linux 0.9.3 (Alice)
Ximper Linux 0.9.3 (Alice)
NAME="Etersoft Ximper"
VERSION="0.9.3"
ID=altlinux
VERSION_ID=0.9.3
PRETTY_NAME="Ximper Linux 0.9.3 (Alice)"
ANSI_COLOR="1;33"
CPE_NAME="cpe:/o:alt:ximper:0.9.3"
BUILD_ID="Etersoft Ximper 0.9.3"
HOME_URL="https://ximperlinux.ru/"
BUG_REPORT_URL="https://github.com/Etersoft/XimperLinux/issues/new/choose"
LOGO=ximperlinux
Ximper Linux 0.9.3 (Alice)
Ximper Linux 0.9.3 (Alice)
```

Поскольку в **Ximper Linux** используется **EEPM** (Etersoft Enhanced Package Manager) вместо APT, установка Linphone будет немного отличаться.


### **1. Поиск Linphone в репозиториях Etersoft/Ximper Linux**
Проверим, есть ли пакет в доступных репозиториях:
```bash
epm query linphone
```
Если пакет найден, устанавливаем его:
```bash
epm install linphone
```

Если пакета нет, можно попробовать поискать в других репозиториях ALT Linux:
```bash
epm --repack --auto --repo=sisyphus linphone
```
*(Попытка установки из Sisyphus, но возможны конфликты зависимостей.)*



### **2. Установка вручную из RPM (если есть подходящий пакет)**
Если где-то найден RPM-пакет (например, для ALT Linux p10), можно попробовать установить его вручную:
```bash
epm --repack linphone-3.12.0-alt7.x86_64.rpm
```
*(Но, как вы уже обнаружили, актуальных RPM для Linphone в репозиториях ALT нет.)*



### **3. Установка через Flatpak (рекомендуемый способ)**
Поскольку в репозиториях Etersoft/Ximper Linux пакет отсутствует, лучший вариант — установить **Linphone через Flatpak**:
```bash
# Установка Flatpak (если ещё не установлен)
epm install flatpak

# Добавление репозитория Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Установка Linphone
flatpak install flathub org.linphone.Linphone

# Запуск
flatpak run org.linphone.Linphone
```
*(Этот метод обеспечит актуальную версию без проблем с зависимостями.)*



### **4. Сборка из исходников (если Flatpak не подходит)**
Если нужна именно системная установка, можно собрать Linphone вручную:
```bash
# Установка зависимостей для сборки
epm install git cmake gcc-c++ intltool libtool automake pkg-config \
    gtk2-devel libexosip2-devel libortp-devel libmediastreamer-devel

# Клонирование и сборка (например, версии 5.x)
git clone --recursive https://gitlab.linphone.org/BC/public/linphone-desktop.git
cd linphone-desktop
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc)
sudo make install
```
*(Этот способ сложнее и может потребовать дополнительных библиотек.)*



### **5. Альтернативные SIP-клиенты**
Если Linphone не удаётся установить, попробуйте другие VoIP-приложения:
```bash
epm search sip  # Поиск альтернатив (например, Jitsi, MicroSIP)
epm install jitsi  # Или другой клиент
```

### **Вывод**
1. **Лучший вариант** → **Установка через Flatpak** (актуальная версия, минимум проблем).  
2. **Если нужна системная установка** → попробовать `epm --repack` с RPM из других репозиториев или сборку из исходников.  
3. **Альтернативы** → другие SIP-клиенты (`jitsi`, `twinkle` и т. д.).  



---------------------
Для установки Linphone на ALT Linux (версия p10) из существующего пакета, выполните следующие шаги:

### 1. **Скачайте пакет**
   ```bash
   wget https://ftp.altlinux.org/pub/distributions/ALTLinux/classic/p10/x86_64/RPMS.classic//linphone-3.12.0-alt7.x86_64.rpm
   ```
но он уже не существует, как и не сущесвтует в https://ftp.altlinux.org/pub/distributions/ALTLinux/Sisyphus/x86_64/RPMS.classic/, хотя сам пакет присутсвтует в https://altlinux.pkgs.org/p10/classic-x86_64/linphone-3.12.0-alt7.x86_64.rpm.html

### 2. **Установите пакет**
   Используйте `apt-get` (который в ALT Linux работает с RPM-пакетами) или `rpm`:
   ```bash
   sudo apt-get install ./linphone-3.12.0-alt7.x86_64.rpm
   ```
   **Или** через `rpm`:
   ```bash
   sudo rpm -i linphone-3.12.0-alt7.x86_64.rpm
   ```

### 3. **Разрешите зависимости**
   Если при установке возникнут ошибки из-за зависимостей, выполните:
   ```bash
   sudo apt-get update
   sudo apt-get install -f  # автоматическое исправление зависимостей
   ```

### 4. **Запустите Linphone**
   После успешной установки запустите его из меню приложений или через терминал:
   ```bash
   linphone
   ```

