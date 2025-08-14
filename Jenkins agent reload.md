Узел: https://jenkins.runtel.ru/computer/redos-7/

Похоже, что на сервере `redos-7` (192.168.87.24) Jenkins **не установлен как системный сервис**, но при этом существует рабочая директория `/var/lib/jenkins/workspace`. Это означает, что:

1. **Jenkins agent работает в другом режиме** (возможно, как `java -jar agent.jar` вручную или через Docker).
2. **Нужно перезапустить именно агент**, а не сервер Jenkins.

### Как перезапустить Jenkins agent на redos-7:

#### **1. Проверьте запущенные процессы**
Найдите процесс Jenkins agent:
```bash
ps aux | grep -i jenkins
```
Или:
```bash
ps aux | grep -i 'agent.jar'
```
```bash
[root@redos workspace]# ps aux | grep -i jenkins
root        1102  0.4  2.4 6571140 201816 ?      Ssl  авг04  70:07 java -jar remoting.jar -workDir /var/lib/jenkins -jar-cache /var/lib/jenkins/remoting/jarCache
root      108824  0.0  0.0 217780   944 pts/0    S+   14:30   0:00 grep --color=always -i jenkins
[root@redos workspace]# ps aux | grep -i 'agent.jar'
root      108830  0.0  0.0 217780   884 pts/0    S+   14:32   0:00 grep --color=always -i agent.jar
```


#### **2. Перезапуск агента**
Если агент запущен вручную:

##### Вариант 1: Через PID
1. Найдите PID процесса:
   ```bash
   pgrep -f 'agent.jar'
   ```
   Пример: `12345`

2. Остановите процесс:
   ```bash
   kill -9 12345
   ```

3. Запустите агент заново (команда должна быть такой же, как в оригинальном запуске):
   ```bash
   java -jar agent.jar -jnlpUrl http://jenkins.runtel.ru/computer/redos-7/jenkins-agent.jnlp -secret YOUR_SECRET -workDir "/var/lib/jenkins"
   ```

##### Вариант 2: Если используется systemd (редко для агентов)
Проверьте наличие сервиса агента:
```bash
systemctl list-units | grep -i jenkins
```
Если есть (например, `jenkins-agent.service`):
```bash
sudo systemctl restart jenkins-agent
```


#### **3. Где взять команду для запуска агента?**
1. Откройте в браузере:  
   `https://jenkins.runtel.ru/computer/redos-7/`
2. Нажмите **"Launch agent"** → скопируйте команду (она выглядит так):
   ```bash
   java -jar agent.jar -jnlpUrl http://jenkins.runtel.ru/computer/redos-7/jenkins-agent.jnlp -secret 123abc... -workDir "/var/lib/jenkins"
   ```


#### **4. Если агент не запускается**
1. **Проверьте Java**:
   ```bash
   java -version
   ```
   Если Java не установлена:
   ```bash
   sudo yum install -y java-11-openjdk
   ```

2. **Проверьте сетевой доступ**:
   ```bash
   curl -v http://jenkins.runtel.ru/computer/redos-7/jenkins-agent.jnlp
   ```
   Должен вернуть `JNLP`-файл.

3. **Логи агента**:
   Запустите агент вручную с логированием:
   ```bash
   java -jar agent.jar -jnlpUrl http://jenkins.runtel.ru/computer/redos-7/jenkins-agent.jnlp -secret YOUR_SECRET -workDir "/var/lib/jenkins" > /tmp/jenkins-agent.log 2>&1 &
   ```
   Затем проверьте логи:
   ```bash
   tail -f /tmp/jenkins-agent.log
   ```


### **5. Автозапуск агента (если нужно)**
Чтобы агент запускался автоматически после перезагрузки:

1. Создайте systemd-сервис:
   ```bash
   sudo tee /etc/systemd/system/jenkins-agent.service <<EOF
   [Unit]
   Description=Jenkins Agent
   After=network.target

   [Service]
   ExecStart=/usr/bin/java -jar /path/to/agent.jar -jnlpUrl http://jenkins.runtel.ru/computer/redos-7/jenkins-agent.jnlp -secret YOUR_SECRET -workDir "/var/lib/jenkins"
   User=jenkins
   Restart=always

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

2. Включите сервис:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable jenkins-agent
   sudo systemctl start jenkins-agent
   ```

