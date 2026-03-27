# Пошаговая инструкция: Настройка SSH подключения к Windows из Linux

## 🔧 **Этап 1: Подготовка Windows машины**

### 1. **Установка OpenSSH Server**
```powershell
# В PowerShell от администратора
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

### 2. **Запуск и настройка службы SSH**
```powershell
# Запустить службу
Start-Service sshd

# Включить автозапуск
Set-Service -Name sshd -StartupType 'Automatic'

# Проверить статус
Get-Service sshd
```

### 3. **Настройка брандмауэра**
```powershell
# Разрешить SSH в брандмауэре
New-NetFirewallRule -Name "OpenSSH-Server" -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

### 4. **Проверка работы SSH**
```cmd
netstat -an | findstr :22
```
Должна быть строка: `0.0.0.0:22 LISTENING`

## 🔑 **Этап 2: Настройка SSH ключей**

### 1. **На Linux: Генерация SSH ключа**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
Ключи сохраняются в: `~/.ssh/id_ed25519` (приватный) и `~/.ssh/id_ed25519.pub` (публичный)

### 2. **Копирование публичного ключа на Windows**
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub maxro@192.168.87.125
```
Или вручную скопировать содержимое `id_ed25519.pub` в файл на Windows:
`C:\Users\maxro\.ssh\authorized_keys`

## 🌐 **Этап 3: Определение сетевых параметров**

### 1. **Узнать IP Windows машины**
```cmd
ipconfig
```
Ищем `IPv4-адрес` в активном подключении

### 2. **Узнать имя пользователя Windows**
```cmd
echo %username%
```
или
```cmd
whoami
```

## 🔗 **Этап 4: Подключение с Linux**

### 1. **Базовое подключение**
```bash
ssh username@windows_ip
```
Пример:
```bash
ssh maxro@192.168.87.125
```

### 2. **Подключение с указанием ключа**
```bash
ssh -i ~/.ssh/id_ed25519 maxro@192.168.87.125
```

### 3. **Подключение с подробным выводом (для диагностики)**
```bash
ssh -v maxro@192.168.87.125
```

## 📁 **Этап 5: Передача файлов**

### **Копирование с Windows на Linux**
Из Linux терминала:
```bash
scp username@windows_ip:"C:/path/to/file" /local/path/
```
Пример:
```bash
scp maxro@192.168.87.125:"C:/Users/maxro/Documents/file.txt" /home/user/
```

### **Копирование из SSH сессии Windows на Linux**
Из SSH сессии Windows:
```bash
scp "C:\path\to\file" linux_user@linux_ip:/path/
scp "C:\Users\maxro\Documents\SKUD_1Oct_10Nov (clear time).ods" kiko0625@192.168.87.151:/home/kiko0625/Документы/SKUD
```

### **Копирование с Linux на Windows**
Пример:
```bash
kkorablin@runtel-re ~/Загрузки $ scp 02006301-GL-1-50.lic maxro@192.168.97.43:"C:/Users/maxro/Documents/"
maxro@192.168.97.43's password: 
02006301-GL-1-50.lic                                                                     100%  104     7.9KB/s   00:00 
```


## 🚪 **Этап 6: Завершение работы**

### **Выйти из SSH сессии**
```bash
exit
```
или
```bash
logout
```

### **Выйти из пользовательской сессии Windows** (разлогиниться)
```cmd
logoff
```

## ✅ **Проверка работоспособности**

1. **Пинг до Windows машины**
   ```bash
   ping 192.168.87.125
   ```

2. **Проверка порта SSH**
   ```bash
   telnet 192.168.87.125 22
   ```

3. **Тестовое подключение**
   ```bash
   ssh maxro@192.168.87.125 "whoami"
   ```

## ⚠️ **Возможные проблемы и решения**

- **Connection timed out** - Проверить статус службы SSH и брандмауэр
- **Permission denied** - Проверить SSH ключи и файл authorized_keys
- **Command not found** - В Windows использовать `dir` вместо `ls`, `type` вместо `cat`

Эта последовательность позволит надежно настроить SSH подключение между Linux и Windows машинами.
