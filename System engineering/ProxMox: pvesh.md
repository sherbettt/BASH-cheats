
## **1. Основы `pvesh`**
**`pvesh`** — это API-клиент Proxmox, который позволяет управлять кластером через командную строку.  
- Работает через **HTTP API** (как и веб-интерфейс).  
- Поддерживает **GET, POST, PUT, DELETE** запросы.  
- Полезен для автоматизации (скрипты, cron, задачи).  

### **Синтаксис**
```bash
pvesh <метод> <путь> [--параметры]
```
- **Методы:** `get` (чтение), `create` (создание), `set` (изменение), `delete` (удаление).  
- **Путь:** Аналогичен API (например, `/nodes/pmx5/lxc/107/snapshot`).  

---

## **2. Работа со снепшотами через `pvesh`**
### **🔹 Просмотр всех снепшотов контейнера (LXC)**
```bash
pvesh get /nodes/pmx5/lxc/107/snapshot
```
Вывод (условно):
```
┌───────────────┬─────────┬────────┬─────────────────────┐
│ description   │ name    │ parent │ snaptime            │
╞═══════════════╪═════════╪════════╪═════════════════════╡
│ Автоснепшот   │ auto_1  │        │ 2024-05-10 00:00:00 │
│ Ручной        │ manual  │        │ 2024-05-05 12:30:00 │
└───────────────┴─────────┴────────┴─────────────────────┘
```

### **🔹 Создание снепшота**
```bash
pvesh create /nodes/pmx5/lxc/107/snapshot --snapname "auto_$(date +%Y%m%d)" \
  --description "Автоснепшот"
```
- `--snapname` — имя снепшота (лучше использовать дату).  
- `--description` — описание (необязательно).  

### **🔹 Удаление снепшота**
```bash
pvesh delete /nodes/pmx5/lxc/107/snapshot/auto_1
```
- Где `auto_1` — имя снепшота.  

### **🔹 Восстановление контейнера из снепшота**
```bash
pvesh create /nodes/pmx5/lxc/107/snapshot/auto_1/rollback
```
- Контейнер будет **перезагружен** с состоянием на момент снепшота.  

---

## **3. Примеры других полезных команд**
### **🔸 Просмотр всех контейнеров на ноде**
```bash
pvesh get /nodes/pmx5/lxc
```

### **🔸 Получение информации о контейнере**
```bash
pvesh get /nodes/pmx5/lxc/107/status
```
Вывод:
```
┌──────────────┬───────────────────────┐
│ key          │ value                 │
╞══════════════╪═══════════════════════╡
│ status       │ running               │
│ maxmem       │ 4096                  │
│ uptime       │ 123456                │
└──────────────┴───────────────────────┘
```

### **🔸 Запуск/остановка контейнера**
```bash
pvesh create /nodes/pmx5/lxc/107/status/start
pvesh create /nodes/pmx5/lxc/107/status/stop
```

### **🔸 Просмотр задач (Tasks)**
```bash
pvesh get /cluster/tasks
```

---

## **4. Фильтрация вывода (grep/jq)**
Так как `pvesh` возвращает данные в JSON или табличном формате, можно использовать:  
- **`grep`** — для простой фильтрации:  
  ```bash
  pvesh get /nodes/pmx5/lxc/107/snapshot | grep -oE 'auto_[^"]+'
  ```
- **`jq`** — для обработки JSON (установите через `apt install jq`):  
  ```bash
  pvesh get /nodes/pmx5/lxc/107/snapshot --output-format json | jq '.[].name'
  ```

---

## **5. Автоматизация (пример скрипта)**
```bash
#!/bin/bash
CTID=107
MAX_SNAPS=4

# Создать снепшот
pvesh create /nodes/pmx5/lxc/$CTID/snapshot \
  --snapname "auto_$(date +%Y%m%d_%H%M)" \
  --description "Автоснепшот"

# Удалить старые (оставить только MAX_SNAPS)
SNAPS=$(pvesh get /nodes/pmx5/lxc/$CTID/snapshot --output-format json | jq -r '.[].name' | grep 'auto_')
COUNT=$(echo "$SNAPS" | wc -l)

if [ $COUNT -gt $MAX_SNAPS ]; then
    echo "$SNAPS" | head -n $(($COUNT - $MAX_SNAPS)) | while read -r SNAP; do
        pvesh delete /nodes/pmx5/lxc/$CTID/snapshot/$SNAP
        echo "Удалён снепшот: $SNAP"
    done
fi
```

---

## **6. Где искать документацию?**
- Официальная документация:  
  ```bash
  man pvesh
  ```
- Список всех API-путей:  
  ```bash
  pvesh get / --output-format json-pretty
  ```

---
