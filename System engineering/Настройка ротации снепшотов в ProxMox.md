В ProxMox можно настроить автоматическое создание и ротацию снимков (snapshots) для контейнера (LXC) с помощью **cron** и **pvesh** (CLI утилита ProxMox) или через **задачи (Tasks) в GUI**.  

### **Способ 1: Через Cron + CLI (pvesh)**
1. **Проверим снепшоты через PVESH**
   ```bash
     root@pmx5:/stg/8tb/timeshift/snapshots# pvesh get /nodes/pmx5/lxc/107/snapshot
    ┌───────────────┬─────────┬────────┬──────────┐
    │ description   │ name    │ parent │ snaptime │
    ╞═══════════════╪═════════╪════════╪══════════╡
    │ You are here! │ current │        │          │
    └───────────────┴─────────┴────────┴──────────┘
    root@pmx5:/stg/8tb/timeshift/snapshots# crontab -l
    no crontab for root
   ```

3. **Создайте скрипт для управления снепшотами** (например, `/usr/local/bin/rotate_lxc_snapshots.sh`):  
   ```bash
   #!/bin/bash
   CTID="100"  # ID вашего контейнера
   SNAP_NAME="auto_$(date +%Y%m%d_%H%M%S)"
   MAX_SNAPSHOTS=4

   # Создать новый снепшот
   pvesh create /nodes/$(hostname)/lxc/$CTID/snapshot --snapname $SNAP_NAME --description "Автоснепшот"

   # Получить список снепшотов и удалить старые, если их больше MAX_SNAPSHOTS
   SNAPSHOTS=$(pvesh get /nodes/$(hostname)/lxc/$CTID/snapshot | grep -oE 'auto_[^"]+' | sort)
   COUNT=$(echo "$SNAPSHOTS" | wc -l)

   if [ $COUNT -gt $MAX_SNAPSHOTS ]; then
       TO_DELETE=$((COUNT - MAX_SNAPSHOTS))
       echo "$SNAPSHOTS" | head -n $TO_DELETE | while read -r SNAP; do
           pvesh delete /nodes/$(hostname)/lxc/$CTID/snapshot/$SNAP
           echo "Удалён снепшот $SNAP"
       done
   fi
   ```
   - Замените `CTID="100"` на ID вашего контейнера.  
   - Дайте права на выполнение:  
     ```bash
     chmod +x /usr/local/bin/rotate_lxc_snapshots.sh
     ```

4. **Настройте Cron для выполнения каждую пятницу**  
   Откройте `crontab -e` и добавьте:  
   ```cron
   0 0 * * 5 /usr/local/bin/rotate_lxc_snapshots.sh
   ```
   - Это будет запускать скрипт **в 00:00 каждую пятницу**.

---

### **Способ 2: Через Proxmox VE Tasks (если не хотите использовать Cron)**
1.  **Создайте задачу в Proxmox GUI:**  
   - **Datacenter → Backup → Add → Scheduled Task**  
   - **Schedule:** `0 0 * * 5` (каждую пятницу в 00:00)  
   - **Command:**  
     ```bash
     /usr/local/bin/rotate_lxc_snapshots.sh
     ```


2.  **(Alt) Создайте задачу в Proxmox GUI:**  
   - **Datacenter → Tasks → Add → Scheduled Task**  
   - **Schedule:** `fri 20:00` (каждую пятницу в 20:00)  
   - **Command:**  
     ```bash
     /usr/local/bin/rotate_lxc_snapshots.sh
     ```

---

### **Проверка работы**
- Посмотреть снепшоты контейнера:  
  ```bash
  pvesh get /nodes/$(hostname)/lxc/100/snapshot
  ```
- Проверить cron-задачи:  
  ```bash
  crontab -l
  ```

Теперь каждую пятницу будет создаваться новый снепшот, а старые будут удаляться, чтобы оставалось только **4 последних**.  

Если нужно **проверять** снепшоты вручную, можно добавить уведомления (например, через `mail` или Telegram API).
