Оф. док.: [SBOM4Python](https://pypi.org/project/sbom4python/)
<br/> дополнение: [Generating distribution archives](https://packaging.python.org/en/latest/tutorials/packaging-projects/#generating-distribution-archives)


### sbom4python
**`sbom4python`** — это инструмент для генерации **SBOM (Software Bill of Materials)** для Python-проектов, Он анализирует зависимости (`requirements.txt`, `setup.py`, `pyproject.toml`) и создаёт SBOM в форматах:  **SPDX** (`.spdx`) ,  **CycloneDX** (`.json`).

#### **1. Проверьте, установлен ли CLI-интерфейс**  
Из вывода `pip3 show -f sbom4python` видно, что скрипт `sbom4python` должен быть доступен в `~/.local/bin/` (или `/home/<user>/.local/bin/sbom4python`).  

Попробуйте запустить его напрямую:  
```bash
~/.local/bin/sbom4python --help
```
Или добавьте `~/.local/bin` в `PATH`, если его там нет, а лучше сразу в `.bashrc`:  
```bash
export PATH=$PATH:~/.local/bin
sbom4python --help

# или

export PATH="$PATH:$HOME/.local/bin"
sbom4python --help
```

#### **2. Если CLI не работает — используйте как модуль**  
Поскольку `python3 -m sbom4python` не работает, значит, модуль не предназначен для прямого запуска. Вместо этого, его нужно использовать в Python-коде.  

Пример использования (предположительно):  
```python
from sbom4python.scanner import scan_project

# Сканируем проект и генерируем SBOM
sbom_data = scan_project("/path/to/your/python/project")
print(sbom_data)
```

#### **3. Изучите исходный код**  
Из структуры файлов видно, что основные модули:  
- `cli.py` — интерфейс командной строки (возможно, не установлен в `PATH`).  
- `scanner.py` — основной модуль сканирования зависимостей.  
- `license.py` — работа с лицензиями.  

Попробуйте заглянуть в `cli.py`, чтобы понять, какие аргументы принимает программа:  
```bash
cat ~/.local/lib/python3/site-packages/sbom4python/cli.py
cat ~/.local/lib/python3/site-packages/sbom4python/cli.py | grep sbom4python
```
-----------

Имеется очень простой пример:
```bash
┌─ kirill ~/Projects/py/DZ_DictList 
└─ $ ll
итого 52K
drwxr-xr-x 1 kirill kirill  482 июн 27 17:36 ./
drwxr-xr-x 1 kirill kirill   52 июн 26 18:12 ../
drwxr-xr-x 1 kirill kirill  204 июн 27 10:36 .git/
-rwxr-xr-x 1 kirill kirill  376 июн 26 18:38 Fibonacci_number_var1.py*
-rw-r--r-- 1 kirill kirill  768 июн 27 10:01 Fibonacci_number_var1.spec
-rwxr-xr-x 1 kirill kirill  289 июн 26 18:36 Fibonacci_number_var2.py*
-rw-r--r-- 1 kirill kirill  768 июн 26 18:16 Fibonacci_number_var2.spec
-rw-r--r-- 1 kirill kirill  252 июн 26 18:37 Fibonacci_number_var3.py
-rw-r--r-- 1 kirill kirill  768 июн 26 18:41 Fibonacci_number_var3.spec
-rw-r--r-- 1 kirill kirill 1,3K июн 26 18:12 fib.zsh
-rw-r--r-- 1 kirill kirill   12 июн 27 10:25 .gitignore
-rwxr-xr-x 1 kirill kirill  658 июн 26 18:43 py_dz2_var1.py*
-rw-r--r-- 1 kirill kirill  212 июн 26 18:12 py_dz2_var2.py
-rw-r--r-- 1 kirill kirill 1,1K июн 26 18:12 README.md
-rw-r--r-- 1 kirill kirill 4,0K июн 27 16:56 requirements.txt
```

1. Файл `requirements.txt` можно предварительно сформировать командой
   ```bash
   pip freeze > requirements.txt
   
   # Сначала соберите все зависимости в один файл (если нужно)
   pip freeze > all_deps.txt

   # Затем проанализируйте его
   sbom4python -r all_deps.txt -o sbom.spdx

   sbom4python -r requirements.txt -o sbom.spdx --sbom spdx
   ```

2. Проанализируйте конкретный модуль:
   ```bash
   sbom4python -m Fibonacci_number_var1.py -o sbom.spdx --sbom spdx

   # и если нужно добавить requirements.txt, отключить лицензию
   sbom4python -m Fibonacci_number_var1.py -r requirements.txt -o sbom.spdx --sbom spdx --exclude-license
   ```
   ```bash
   ┌─ kirill ~/Projects/py/DZ_DictList 
   └─ $ bat sbom.spdx 
   ───────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
          │ File: sbom.spdx
   ───────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
      1   │ SPDXVersion: SPDX-2.3
      2   │ DataLicense: CC0-1.0
      3   │ SPDXID: SPDXRef-DOCUMENT
      4   │ DocumentName: Python-Fibonacci_number_var1.py
      5   │ DocumentNamespace: http://spdx.org/spdxdocs/Python-Fibonacci_number_var1.py-8b6514af-fa22-4a69-bde1-ab10390bb85f
      6   │ LicenseListVersion: 3.26
      7   │ Creator: Tool: sbom4python-0.12.4
      8   │ Created: 2025-06-27T17:51:30Z
      9   │ CreatorComment: <text>SBOM Type: Build - This document has been automatically generated.</text>
     10   │ ##### 
     11   │ 
   ───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   ```
3. Конвернтируем результат в json и смотрим с применением jq.
   ```bash
   sbom4python -r requirements.txt -o sbom.json --sbom cyclonedx --format json;
   cat sbom.json | jq
   ```

4. Как прочитать `sbom.spdx`?
<br/> Файл в формате SPDX состоит из:
- **Заголовка** (метаданные документа)
- **Списка пакетов** (каждый в блоке `#####`)

**Пример вывода:**
```spdx
PackageName: aiohttp
SPDXID: SPDXRef-2-aiohttp
PackageVersion: 3.12.13
PackageLicenseDeclared: Apache-2.0
PackageDownloadLocation: https://pypi.org/project/aiohttp/3.12.13/#files
```

5. Как проверить, какие зависимости включены?**
- **Способ 1**: Посмотрите список пакетов в `sbom.spdx`:
  ```bash
  grep "PackageName: " sbom.spdx
  ```

- **Способ 2**: Сравните с `requirements.txt`:
  ```bash
  cat requirements.txt | wc -l  # Число зависимостей
  grep "PackageName: " sbom.spdx | wc -l  # Число пакетов в SBOM
  ```

6. Если SBOM не включает все зависимости**
- **Проверьте**:  
  - Есть ли все зависимости в `requirements.txt`?  
    ```bash
    cat requirements.txt
    ```
  - Нет ли ошибок при генерации:  
    ```bash
    sbom4python -r requirements.txt -o sbom.spdx --sbom spdx -v
    ```

- **Решение**:  
  Если `requirements.txt` неполный, обновите его:  
  ```bash
  pip freeze > requirements.txt
  ```



7. Как конвертировать SPDX в JSON?**
Если нужно работать с `jq`, но есть только `sbom.spdx`:
1. Установите инструмент `spdx-tools`:
   ```bash
   pip install spdx-tools
   ```
2. Конвертируйте:
   ```bash
   spdx-tools convert sbom.spdx sbom.json --format json
   ```

В результате получим:
```bash
┌─ kirill ~/Projects/py/DZ_DictList 
└─ $ lz
Octal Permissions Size User   Group  Date Created Name
0755  drwxr-xr-x   19M kirill kirill 26 июн 18:12  .git/
0644  .rw-r--r--    12 kirill kirill 27 июн 10:25  .gitignore
0644  .rw-r--r--  4,0k kirill kirill 27 июн 17:48  all_deps.txt
0644  .rw-r--r--  1,3k kirill kirill 26 июн 18:12  fib.zsh
0755  .rwxr-xr-x   376 kirill kirill 26 июн 18:12  Fibonacci_number_var1.py*
0644  .rw-r--r--   768 kirill kirill 26 июн 18:14  Fibonacci_number_var1.spec
0755  .rwxr-xr-x   289 kirill kirill 26 июн 18:12  Fibonacci_number_var2.py*
0644  .rw-r--r--   768 kirill kirill 26 июн 18:16  Fibonacci_number_var2.spec
0644  .rw-r--r--   252 kirill kirill 26 июн 18:37  Fibonacci_number_var3.py
0644  .rw-r--r--   768 kirill kirill 26 июн 18:41  Fibonacci_number_var3.spec
0755  .rwxr-xr-x   658 kirill kirill 26 июн 18:12  py_dz2_var1.py*
0644  .rw-r--r--   212 kirill kirill 26 июн 18:12  py_dz2_var2.py
0644  .rw-r--r--  1,1k kirill kirill 26 июн 18:12 󰂺 README.md
0644  .rw-r--r--  4,0k kirill kirill 27 июн 16:53  requirements.txt
0644  .rw-r--r--  446k kirill kirill 27 июн 18:07  sbom.json
0644  .rw-r--r--  305k kirill kirill 27 июн 17:36  sbom.spdx

```

------------

Если установлена **Python-версия `yq`**, которая не поддерживает флаг `-o xml` для конвертации в XML. Вместо неё нужно использовать **Go-версию `yq`** (более мощную и поддерживающую XML). В

### **0. Убедитесь, что установлен xmltodict: `pip install xmltodict`**

### **1. Установите Go-версию `yq` (рекомендуется)**
#### Для Linux (через `snap` или вручную):
```bash
sudo snap install yq  # Если snap установлен
```
Или (если нет snap):
```bash
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
```
#### Проверьте версию:
```bash
yq --version  # Должно быть v4.x.x
```

### **2. Конвертируйте JSON → XML**
Теперь команда сработает:
```bash
yq -o=xml sbom.json > sbom.xml
```
Или (если нужен более читаемый XML):
```bash
yq -o=xml -P sbom.json > sbom.xml  # -P для красивого форматирования
```


### **3. Альтернатива: Python-скрипт (если Go-yq не подходит)**
Если установка Go-yq невозможна, используйте этот скрипт:

#### Установите зависимости:
```bash
pip install xmltodict
```

#### Создайте файл `json_to_xml.py`:
```python
import json
import xmltodict

with open("sbom.json", "r") as f:
    data = json.load(f)

with open("sbom.xml", "w") as f:
    f.write(xmltodict.unparse(data, pretty=True))
```

#### Запустите:
```bash
python3 json_to_xml.py
```

### **4. Проверьте результат**
```bash
cat sbom.xml
```
Вы должны увидеть валидный XML (не пустой файл).

--------

### Проблема
После установки Go-версии `yq` в `/usr/local/bin/yq` система продолжает искать его в `/home/kirill/.local/bin/yq` (где была старая Python-версия).

### Решение

#### 1. Проверьте текущий PATH
```bash
echo $PATH ;
echo -e ${PATH//:/\\n} ;
```
Убедитесь, что `/usr/local/bin` есть в выводе (обычно он там есть по умолчанию).

#### 2. Обновите PATH для текущей сессии
```bash
export PATH="/usr/local/bin:$PATH"
```

#### 3. Проверьте, что `yq` теперь доступен
```bash
which yq
```
Должно вернуть `/usr/local/bin/yq`.

#### 4. Проверьте версию
```bash
yq --version
```
Теперь должно показать `v4.45.4` (или другую актуальную версию).

#### 5. Повторите конвертацию
```bash
yq -o=xml sbom.json > sbom.xml
```

#### 6. Проверьте результат
```bash
head sbom.xml
```
Должен показать начало XML-файла.

#### 7. Сохранить переменную в ~/.bashrc
```bash
export PATH="/usr/local/bin:$PATH"
```


### Если всё ещё не работает

#### Вариант A: Явно укажите полный путь к `yq`
```bash
/usr/local/bin/yq -o=xml sbom.json > sbom.xml
```

#### Вариант B: Перезагрузите терминал
Закройте и откройте терминал заново, чтобы обновить PATH.

#### Вариант C: Создайте симлинк
```bash
mkdir -p ~/.local/bin
ln -s /usr/local/bin/yq ~/.local/bin/yq
```


### Альтернативное решение через Python
Если проблемы с `yq` сохраняются, используйте ваш скрипт `json_to_xml.py`:
```bash
python3 json_to_xml.py
```

