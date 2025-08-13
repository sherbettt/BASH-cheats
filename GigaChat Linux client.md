https://pypi.org/project/gigachat/
https://gitverse.ru/gigachatteam/linux-client


### **1. Установка Python и pip на Ximper Linux**
Сначала убедитесь, что у вас установлен **Python 3.10+** и **pip**:
```bash
sudo epm update
sudo epmi python3 python3-pip
sudo epmi build-essential git cmake libssl-dev pkg-config python3-pip python-is-installable
```

Проверьте версию Python:  
```bash
python3 --version
```
(Если Python < 3.10, обновите его через `sudo apt-get install python3.11` или аналогично.)

### **2. Установка GigaChat через pip**  
```bash
pip3 install gigachat --user
```
(Флаг `--user` устанавливает пакет только для текущего пользователя, чтобы избежать конфликтов с системными пакетами.)

### **3. Проверка установки**  
Запустите Python и попробуйте импортировать библиотеку:  
```bash
python3 -c "from gigachat import GigaChat; print('GigaChat успешно установлен!')"
```
Если ошибок нет — всё готово.  

### **4. Настройка аутентификации**  
Для работы с API GigaChat нужны **client_id** и **client_secret** (получить можно на [developers.sber.ru](https://developers.sber.ru/)).  

Пример использования:  
```python
from gigachat import GigaChat

giga = GigaChat(
    client_id="ваш_client_id",
    client_secret="ваш_client_secret",
    verify_ssl_certs=False  # если возникают проблемы с SSL
)

response = giga.chat("Привет! Как дела?")
print(response.choices[0].message.content)
```

### **5. Если не работает (альтернативные варианты)**  
#### **Вариант 1. Установка из GitVerse (Linux-клиент)**  
```bash
git clone https://gitverse.ru/gigachatteam/linux-client.git
cd linux-client
pip3 install -r requirements.txt --user
python3 main.py  # или другой запускной файл
```
(Проверьте README в репозитории, так как интерфейс может отличаться.)

#### **Вариант 2. Ручная установка зависимостей**  
Если возникают ошибки, попробуйте установить зависимости вручную:  
```bash
sudo apt-get install libssl-dev python3-dev
pip3 install --upgrade certifi
```

### **6. Возможные проблемы и решения**  
| Проблема | Решение |
|----------|---------|
| **`SSL: CERTIFICATE_VERIFY_FAILED`** | Добавьте `verify_ssl_certs=False` в `GigaChat()` |
| **Нет `pip` или `python3`** | Установите через `sudo apt-get install python3 python3-pip` |
| **Ошибки с зависимостями** | Попробуйте `pip3 install --upgrade setuptools wheel` |

### **Вывод**  
1. Лучший вариант — установка через `pip install gigachat`.  
2. Если нужен GUI-клиент — используйте репозиторий с GitVerse.  
3. При проблемах с SSL можно временно отключить проверку сертификатов.  

Если что-то не получается — напишите конкретную ошибку, помогу разобраться! 🚀

