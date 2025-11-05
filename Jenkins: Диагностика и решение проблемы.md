# Инструкция: Диагностика и решение проблемы с Jenkins

## Проблема
Jenkins выдавал ошибку:
```
java.io.IOException: Failed to create a temporary file in /var/lib/jenkins/jobs/runtelpbx_eapi_liga/indexing
```

## Последовательность диагностики

### 1. Первичная проверка статуса Jenkins
```bash
systemctl status jenkins.service -l --no-pager
```
**Результат**: Сервис активен, но есть ошибки создания временных файлов

### 2. Проверка прав доступа и места на диске
```bash
ll /var/lib/jenkins/jobs/runtelpbx_eapi_liga/indexing
df -h /var/lib/jenkins/
df -h
```
**Результат**: Права доступа корректные, места на диске достаточно (66G свободно)

### 3. Проверка inodes (ключевая диагностика)
```bash
df -i /var/lib/jenkins/
sudo -u jenkins touch /var/lib/jenkins/jobs/runtelpbx_eapi_liga/indexing/test.tmp
```
**Результат**: 
- Inodes использованы на **100%** (7208960/7208960)
- Нельзя создать временные файлы - "No space left on device"

### 4. Поиск источника проблемы
```bash
# Поиск директорий с наибольшим количеством файлов
sudo find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -nr | head -20
sudo find / -mount -type f | awk -F/ 'NF<=3{print $2} NF>3{print $3}' | sort | uniq -c | sort -rn | head -10

# Проверка файлов в Jenkins
find /var/lib/jenkins/ -type f | wc -l
```
**Результат**: 
- 7,002,414 файлов в `/var`
- 6,996,048 файлов в `/var/lib/jenkins/`

### 5. Детальный анализ структуры Jenkins
```bash
# Анализ по директориям внутри Jenkins
sudo find /var/lib/jenkins -type f | awk -F/ '{print $5}' | sort | uniq -c | sort -rn | head -20

# Поиск проблемных job'ов
for job in /var/lib/jenkins/jobs/*; do
    count=$(sudo find "$job" -type f | wc -l)
    echo "$count - $job"
done | sort -rn | head -10
```
**Результат**: Job `pbx_v2_deb11_dev60` создал **6,573,518 файлов**

### 6. Очистка временных файлов системы
```bash
# Быстрая очистка системных временных файлов
find /var/tmp -type f -name "*.tmp" -delete
find /tmp -type f -name "*.tmp" -delete
find /var/log -name "*.log.*" -type f -mtime +7 -delete
find /var/log -name "*.gz" -type f -delete
apt-get clean
```
**Результат**: Inodes освобождены до 92% использования

### 7. Очистка старых сборок Jenkins
```bash
# Остановка Jenkins
sudo systemctl stop jenkins

# Удаление старых сборок (оставить последние 50)
find /var/lib/jenkins/jobs/pbx_v2_deb11_dev60/builds -mindepth 1 -maxdepth 1 -type d | sort -rn | tail -n +51 | xargs sudo rm -rf

# Проверка результатов
df -i /
find /var/lib/jenkins/ -type f | wc -l
```
**Результат**: 
- Inodes: с 100% до 30% использования
- Файлов в Jenkins: с ~7M до 2.1M
- Файлов в проблемной job'е: с 6.5M до 1.7M

## Выявленная проблема
**Job `pbx_v2_deb11_dev60`** создавал огромное количество файлов в своих сборках, что полностью исчерпывало доступные inodes в файловой системе.

