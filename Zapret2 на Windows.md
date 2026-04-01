## **Настройка zapret на Windows 🪟**

### **Способ 1: Готовая сборка winws2 (рекомендуется)**

Разработчик предоставляет готовые бинарники для Windows в папке `binaries/`:

```bash
# В вашей установке Linux посмотрите:
ls -la /usr/local/bin/zapret2/binaries/windows-*
```

Должны быть файлы:
- `winws2.exe` — основной рабочий инструмент для Windows
- `windivert.dll` — библиотека для перехвата трафика
- `wdig.exe` — аналог mdig

**Установка на Windows:**

1. **Скачайте архив** с GitHub:
   ```
   https://github.com/bol-van/zapret2/releases/download/v0.9.4.7/zapret2-v0.9.4.7.tar.gz
   ```

2. **Распакуйте** в `C:\zapret2\`

3. **Скопируйте бинарники**:
   ```cmd
   cd C:\zapret2
   copy binaries\windows-x86_64\winws2.exe .
   copy binaries\windows-x86_64\windivert.dll .
   copy binaries\windows-x86_64\wdig.exe .
   ```

4. **Создайте bat-файл для запуска** `C:\zapret2\start.bat`:
   ```batch
   @echo off
   cd /d C:\zapret2
   
   echo Запускаем zapret...
   winws2.exe --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
   
   pause
   ```

5. **Запуск от имени администратора** (обязательно!)

---

### **Способ 2: Автоматическая установка через install_easy.sh (WSL)**

Если у вас есть WSL (Windows Subsystem for Linux), можно использовать Linux-версию:

```bash
# В WSL (Ubuntu/Debian) выполните:
wget https://github.com/bol-van/zapret2/releases/download/v0.9.4.7/zapret2-v0.9.4.7.tar.gz
tar -xzf zapret2-v0.9.4.7.tar.gz
cd zapret2-v0.9.4.7
sudo ./install_easy.sh
```

**Но!** WSL требует настройки сетевого фильтра, что сложнее.

---

### **Способ 3: Компиляция из исходников под Windows**

Если нужна именно компиляция из папки `nfq2/windows/`:

#### **Требования:**
- Visual Studio (Community Edition)
- Windows SDK
- WinDivert (уже включен в исходники)

#### **Шаги компиляции:**

1. **Установите Visual Studio** с поддержкой C++

2. **Откройте "Developer Command Prompt for VS"**

3. **Перейдите в папку с исходниками:**
   ```cmd
   cd C:\zapret2\nfq2
   ```

4. **Скомпилируйте:**
   ```cmd
   cl /O2 /std:c11 /D_WIN32_WINNT=0x0601 /D_WIN32 /DWIN32 /DNDEBUG /MT /Iwindows /Iwindows/windivert /Iwindows/netinet /Fe:winws2.exe *.c windows/netinet/*.c windows/windivert/*.c windows/res/*.c crypto/*.c /link user32.lib advapi32.lib ws2_32.lib
   ```

   **Или используйте Makefile (если есть nmake):**
   ```cmd
   nmake -f Makefile.win
   ```

5. **Готовый файл** `winws2.exe` появится в папке

---

### **Способ 4: Использование winws2 с GUI (опционально)**

Некоторые пользователи создают GUI-оболочку:

```batch
@echo off
:: C:\zapret2\zapret-gui.bat
title Zapret DPI Bypass
color 0A

:menu
cls
echo ====================================
echo   Zapret v0.9.4.7 for Windows
echo ====================================
echo 1. Запустить zapret
echo 2. Остановить zapret
echo 3. Проверить статус
echo 4. Выход
echo ====================================
set /p choice="Выберите действие: "

if "%choice%"=="1" goto start
if "%choice%"=="2" goto stop
if "%choice%"=="3" goto status
if "%choice%"=="4" exit

:start
echo Запуск zapret...
start /min winws2.exe --qnum=200 --lua-init=@lua/zapret-lib.lua --lua-init=@lua/zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5
echo Zapret запущен!
timeout /t 2
goto menu

:stop
echo Остановка zapret...
taskkill /f /im winws2.exe
echo Zapret остановлен!
timeout /t 2
goto menu

:status
tasklist | find "winws2.exe" > nul
if errorlevel 1 (
    echo Zapret НЕ РАБОТАЕТ
) else (
    echo Zapret РАБОТАЕТ
)
timeout /t 3
goto menu
```

---

### **Важные особенности Windows-версии:**

| Параметр | Значение |
|----------|----------|
| **Перехват трафика** | Использует WinDivert вместо nftables |
| **Права** | Обязательно запускать **от имени администратора** |
| **Порты** | Фильтрует TCP/UDP 80, 443 |
| **Стратегии** | Аналогичны Linux-версии |
| **Логи** | Выводятся в консоль |
| **Автозапуск** | Можно добавить в автозагрузку через Планировщик задач |

---

### **Автозапуск на Windows (через планировщик)**

1. **Создайте задачу:**
   ```powershell
   # В PowerShell от имени администратора
   $action = New-ScheduledTaskAction -Execute "C:\zapret2\winws2.exe" -Argument "--qnum=200 --lua-init=@C:\zapret2\lua\zapret-lib.lua --lua-init=@C:\zapret2\lua\zapret-antidpi.lua --filter-tcp=80,443 --filter-l7=tls,http --payload=tls_client_hello --lua-desync=multisplit:pos=1:seqovl=5"
   $trigger = New-ScheduledTaskTrigger -AtStartup
   $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
   Register-ScheduledTask -TaskName "ZapretDPI" -Action $action -Trigger $trigger -Principal $principal
   ```

2. **Или через GUI:**
   - `Win+R` → `taskschd.msc`
   - Создать задачу → триггер "При запуске системы"
   - Действие: запуск `C:\zapret2\winws2.exe` с аргументами
   - Обязательно: "Выполнять с наивысшими правами"

---

### **Проверка работы на Windows:**

```cmd
# В отдельной консоли (администратор)
curl -I https://www.youtube.com

# Должно быть:
HTTP/2 200
```

---

## 📦 **Что где находится в архиве zapret:**

```
zapret2-v0.9.4.7/
├── binaries/
│   ├── linux-x86_64/          # Готовые бинарники для Linux
│   │   ├── nfqws2
│   │   ├── ip2net
│   │   └── mdig
│   ├── windows-x86_64/        # Готовые бинарники для Windows
│   │   ├── winws2.exe
│   │   ├── windivert.dll
│   │   └── wdig.exe
│   └── my/                    # Скомпилированные пользователем
├── nfq2/                      # Исходники для Linux
│   └── windows/               # Исходники для Windows
│       ├── windivert/         # WinDivert для перехвата трафика
│       ├── netinet/           # Заголовки сетевых протоколов
│       └── res/               # Ресурсы
├── lua/                       # Скрипты (общие для всех ОС)
└── ip2net/                    # Утилиты для работы с IP-сетями
```

---

## 🎯 **Итог для Windows:**

**Самый простой способ:**
1. Скачать архив
2. Распаковать
3. Скопировать `binaries/windows-x86_64/*` в корень
4. Запускать `winws2.exe` от администратора

**Скрипты Lua (zapret-lib.lua, zapret-antidpi.lua) работают одинаково на всех ОС!**

Ваша существующая конфигурация (стратегия `multisplit:pos=1:seqovl=5`) будет работать и на Windows точно так же.
