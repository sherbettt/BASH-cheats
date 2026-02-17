Чтобы запустить **Double Commander** с правами суперпользователя (`sudo`) и при этом разгрузить терминал (CLI), можно использовать несколько способов:

### 1. **Запуск в фоновом режиме (`&`)**
```bash
sudo doublecmd &
```
Этот способ запустит Double Commander в фоне, освободив терминал. Однако если вы закроете терминал, Double Commander может завершиться.

### 2. **Запуск с `nohup` (игнорируя сигнал HUP)**
```bash
sudo nohup doublecmd >/dev/null 2>&1 &
```
- `nohup` предотвращает завершение процесса при закрытии терминала.
- `>/dev/null 2>&1` перенаправляет вывод (stdout и stderr) в никуда, чтобы не засорять консоль.

### 3. **Запуск через `disown` (отсоединение от терминала)**
***(Рекомендуемый способ)***
```bash
sudo doublecmd & disown
```
После этого процесс Double Commander не будет зависеть от терминала.


### 4. **Использование `sudo -b` (фоновый режим для sudo)**
```bash
sudo -b doublecmd
```
Это запустит команду в фоне от имени `sudo`, но не гарантирует, что сам Double Commander не будет связан с терминалом.


### 5. **Запуск через `screen` или `tmux`**
Если нужно оставить процесс работающим даже после закрытия терминала:
```bash
sudo apt install screen tmux  # если не установлены
sudo screen -dmS doublecmd_session doublecmd
```
или
```bash
sudo tmux new-session -d -s doublecmd_session 'doublecmd'
```
Позже можно подключиться к сессии:
```bash
sudo tmux attach -t doublecmd_session
```

### 6. **Запуск через `setsid` (в новой сессии)**
```bash
sudo setsid doublecmd
```
Этот метод запускает процесс в новой сессии, независимой от терминала.



