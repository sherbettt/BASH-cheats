# Установка и настройка корпоративного мессенджера eXpress в Arch Linux / EndeavourOS

## 📥 1. Скачивание AppImage

Скачайте последнюю версию AppImage с официального сайта:
- **Ссылка**: https://express.ms/download/appimage
- Или через терминал:
```bash
wget -O ~/Загрузки/eXpress.AppImage https://express.ms/download/appimage
```

---

## 🚀 2. Подготовка к запуску

### Сделайте файл исполняемым:
```bash
chmod +x ~/Загрузки/eXpress.AppImage
```

### Проверьте, что AppImage работает:
```bash
~/Загрузки/eXpress.AppImage
```
Если окно открылось — всё хорошо. Закройте приложение и продолжайте настройку.

---

## 🖥️ 3. Интеграция в систему (запуск без терминала)

### Вариант А: Создание .desktop файла (рекомендуемый)

Создайте файл для интеграции в меню приложений:
```bash
mcedit ~/.local/share/applications/express.desktop
```

Вставьте следующее содержимое (подставьте свой путь к файлу):
```ini
[Desktop Entry]
Version=1.0
Name=eXpress
Comment=Корпоративный мессенджер
Exec=/home/kkorablin/Загрузки/eXpress.AppImage
Icon=/home/kkorablin/Загрузки/eXpress.AppImage
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
StartupNotify=true
StartupWMClass=eXpress
```

**Важно**: 
- Если у вас другая версия (например, `eXpress-3.67.45.AppImage`), укажите полное имя файла
- Путь должен быть абсолютным (от корня `/`)

Сохраните (F2 → Enter) и выйдите (F10).

Обновите базу приложений:
```bash
update-desktop-database ~/.local/share/applications/
```

Проверьте синтаксис .desktop файла:
```bash
desktop-file-validate ~/.local/share/applications/express.desktop
```
Если команда не выдала ошибок — всё сделано правильно.

Теперь eXpress появится в меню приложений (поиск по Alt+F2 → "eXpress").

---

### Вариант Б: Перенос AppImage в постоянное место

Хранить AppImage в папке `Загрузки` неудобно — можно случайно удалить. Перенесите в специальную папку:

```bash
mkdir -p ~/.local/bin
mv ~/Загрузки/eXpress.AppImage ~/.local/bin/express.AppImage
chmod +x ~/.local/bin/express.AppImage
```

После этого обновите путь в `.desktop` файле:
```bash
mcedit ~/.local/share/applications/express.desktop
```
Замените строку `Exec=` на:
```
Exec=/home/kkorablin/.local/bin/express.AppImage
```

И так же для `Icon=`:
```
Icon=/home/kkorablin/.local/bin/express.AppImage
```

Обновите базу:
```bash
update-desktop-database ~/.local/share/applications/
```

---

### Вариант В: Запуск из терминала в фоне

Если хотите запускать из терминала без блокировки:

```bash
~/Загрузки/eXpress.AppImage &
```

Или с полным отвязыванием от терминала (процесс не завершится при закрытии терминала):
```bash
nohup ~/Загрузки/eXpress.AppImage > /dev/null 2>&1 &
```

---

### Вариант Г: Алиас для быстрого запуска

Добавьте в `~/.bashrc` или `~/.zshrc`:
```bash
echo 'alias express="nohup ~/.local/bin/express.AppImage > /dev/null 2>&1 &"' >> ~/.bashrc
source ~/.bashrc
```
Теперь можно запускать просто командой `express` в терминале.

---

## 📂 5. Где хранятся данные

Данные eXpress хранятся в скрытых папках в домашней директории:
```bash
~/.config/express/          # Настройки приложения
~/.local/share/express/     # Кэш, логи, сохраненные файлы
```

Если нужно сбросить настройки или очистить кэш — удалите эти папки (приложение пересоздаст их при следующем запуске).

---

## 🔄 6. Обновление приложения

AppImage не обновляется автоматически. Для обновления:

1. Скачайте новый `.AppImage` с официального сайта
2. Замените старый файл:
```bash
mv ~/Загрузки/eXpress-новый.AppImage ~/.local/bin/express.AppImage
chmod +x ~/.local/bin/express.AppImage
```
3. **Не нужно** пересоздавать `.desktop` файл, если путь не изменился
4. Если изменилось имя файла, обновите только `Exec=` и `Icon=` в `.desktop`

---

## 🗑️ 7. Удаление eXpress

Если приложение больше не нужно:

```bash
# Удалить AppImage
rm ~/.local/bin/express.AppImage   # или откуда вы его запускаете

# Удалить .desktop файл
rm ~/.local/share/applications/express.desktop

# Обновить базу
update-desktop-database ~/.local/share/applications/

# Удалить настройки и данные (опционально)
rm -rf ~/.config/express/ ~/.local/share/express/
```

---

## 🛠️ 8. Устранение неполадок

### Проблема: Приложение не запускается из меню

1. **Проверьте пути** в `.desktop` файле — они должны быть абсолютными:
```bash
cat ~/.local/share/applications/express.desktop
```

2. **Проверьте права** на AppImage:
```bash
chmod +x ~/.local/bin/express.AppImage
```

3. **Проверьте синтаксис**:
```bash
desktop-file-validate ~/.local/share/applications/express.desktop
```

4. **Пересоздайте .desktop файл** (удалите и создайте заново)

5. **Проверьте видимость в системе**:
```bash
xdg-desktop-menu list | grep express
```

### Проблема: Ошибки GTK в терминале

Ошибки вида:
```
Gtk: gtk_widget_get_scale_factor: assertion 'GTK_IS_WIDGET (widget)' failed
```

Это **не критично** — это предупреждения библиотек GTK, на работу приложения они не влияют. Можно игнорировать.

### Проблема: Не работает микрофон/камера

Проверьте, что система видит устройства:
```bash
pactl list sources          # для PulseAudio
pactl list short sources    # краткий список
```

Если используется Wayland, попробуйте запустить с флагом:
```bash
~/Загрузки/eXpress.AppImage --ozone-platform=x11
```

---

## 💎 9. Краткая памятка

| Действие | Команда / способ |
|----------|------------------|
| **Скачать** | `wget -O ~/Загрузки/eXpress.AppImage https://express.ms/download/appimage` |
| **Сделать исполняемым** | `chmod +x ~/Загрузки/eXpress.AppImage` |
| **Проверить** | `~/Загрузки/eXpress.AppImage` |
| **Запуск из меню** | Alt+F2 → `eXpress` |
| **Закрепить на панели** | ПКМ по иконке → "Закрепить" |
| **Обновить** | Скачать новый AppImage → заменить старый |
| **Удалить** | `rm ~/.local/share/applications/express.desktop` + `rm ~/.local/bin/express.AppImage` |

---

## 📝 Примечания

- Приложение работает на **X11** и **Wayland** (но могут быть мелкие особенности)
- Для корпоративной версии потребуется доступ к серверу компании
- Публичная версия работает через регистрацию по номеру телефона
- Все настройки сохраняются между перезапусками

---

<br/>





## 📋 Инструкция: Переключение метода регистрации между Email и OpenID

---

### 🔍 **1. Проверка текущего метода регистрации**

```bash
# Проверка активного метода
docker exec cts-etcd-1 etcdctl get /cts/ad_integration/registration_method
```

**Ожидаемый ответ:** `email` или `openid`

---

### 🔄 **2. Переключение на OpenID**

#### **Шаг 2.1: Изменение метода**

```bash
# Установка метода регистрации
docker exec cts-etcd-1 etcdctl put /cts/ad_integration/registration_method "openid"

# Включение OpenID
docker exec cts-etcd-1 etcdctl put /cts/ad_integration/openid_enabled "true"
```

#### **Шаг 2.2: Перезапуск сервиса**

```bash
cd /opt/express
/usr/local/bin/dpl -d ad_integration
```

#### **Шаг 2.3: Проверка статуса**

```bash
# Проверка логов на ошибки
docker logs cts-ad_integration-1 --tail 20

# Проверка метода в etcd
docker exec cts-etcd-1 etcdctl get /cts/ad_integration/registration_method
```

**Ожидаемый ответ:** `openid`

#### **Шаг 2.4: Проверка пользователей**

```bash
# Список всех пользователей
docker exec cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod -c \"SELECT login, source FROM users;\""

# Проверка конкретного пользователя
docker exec cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod -c \"SELECT login, source, block_at FROM users WHERE login='k@runtel.ru';\""
```

#### **Шаг 2.5: Проверка доступности OpenID провайдера**

```bash
# Проверка доступности Keycloak
curl -v https://sso.runtel.ru:8443/realms/runtel/.well-known/openid-configuration
```

**Ожидаемый ответ:** JSON с конфигурацией OpenID

#### **Шаг 2.6: Проверка методов регистрации через API**

```bash
# Получение списка методов
curl -X GET https://exchat.runtel.ru/api/v2/ad_integration/register_methods \
  -H "Content-Type: application/json"
```

**Ожидаемый ответ:** `"register_methods":["openid"]`

---

### 🔄 **3. Переключение на Email**

#### **Шаг 3.1: Изменение метода**

```bash
# Установка метода регистрации
docker exec cts-etcd-1 etcdctl put /cts/ad_integration/registration_method "email"

# Отключение OpenID
docker exec cts-etcd-1 etcdctl del /cts/ad_integration/openid_enabled
```

#### **Шаг 3.2: Перезапуск сервиса**

```bash
cd /opt/express
/usr/local/bin/dpl -d ad_integration
```

#### **Шаг 3.3: Проверка статуса**

```bash
# Проверка логов на ошибки
docker logs cts-ad_integration-1 --tail 20

# Проверка метода в etcd
docker exec cts-etcd-1 etcdctl get /cts/ad_integration/registration_method
```

**Ожидаемый ответ:** `email`

#### **Шаг 3.4: Проверка пользователей**

```bash
# Список всех пользователей
docker exec cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod -c \"SELECT login, source FROM users;\""

# Проверка паролей у пользователей
docker exec cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod -c \"SELECT login, password_hash FROM users WHERE login IN ('k@runtel.ru', 'admin@runtel.ru', 'i@runtel.ru', 'npetuhov@runtel.ru');\""

# Проверка конкретного пользователя
docker exec cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod -c \"SELECT login, source, block_at FROM users WHERE login='k@runtel.ru';\""
```

#### **Шаг 3.5: Проверка методов регистрации через API**

```bash
# Получение списка методов
curl -X GET https://exchat.runtel.ru/api/v2/ad_integration/register_methods \
  -H "Content-Type: application/json"
```

**Ожидаемый ответ:** `"register_methods":["email"]`

---

### 🛠 **4. Дополнительные проверки**

#### **Проверка настроек OpenID в Express**

```bash
# Проверка всех настроек OpenID в etcd
docker exec cts-etcd-1 etcdctl get /cts/ad_integration/openid --prefix
```

**Ожидаемый ответ:** 
```
/cts/ad_integration/openid_enabled
true
/cts/ad_integration/openid_redirect_uri
https://exchat.runtel.ru/admin/openid/callback
```

#### **Проверка статуса сервиса ad_integration**

```bash
# Проверка статуса
docker ps | grep ad_integration

# Проверка логов в реальном времени
docker logs -f cts-ad_integration-1
```

#### **Проверка пользователей в PostgreSQL**

```bash
# Подключение к PostgreSQL
docker exec -it cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod"

# Запросы внутри psql:
SELECT login, source, block_at FROM users;
SELECT login, source FROM users WHERE source='admin';
\q
```

---

### 📝 **5. Чек-лист для проверки работоспособности**

| Проверка | Команда | Ожидаемый результат |
|----------|---------|---------------------|
| Метод регистрации | `docker exec cts-etcd-1 etcdctl get /cts/ad_integration/registration_method` | `email` или `openid` |
| Статус OpenID | `docker exec cts-etcd-1 etcdctl get /cts/ad_integration/openid_enabled` | `true` или ключ отсутствует |
| Сервис работает | `docker ps \| grep ad_integration` | `Up` |
| Ошибок нет | `docker logs cts-ad_integration-1 --tail 10` | Нет `error` или `crash` |
| API методы | `curl -X GET https://exchat.runtel.ru/api/v2/ad_integration/register_methods` | `["openid"]` или `["email"]` |
| Пользователь существует | `docker exec cts-postgres-1 sh -c "PGPASSWORD='Vst2yO8N6gowyFyd' psql -U postgres -d admin_prod -c \"SELECT login FROM users WHERE login='k@runtel.ru';\""` | `k@runtel.ru` |

---

### ⚠️ **6. Если что-то пошло не так**

1. **Проверьте логи:**
   ```bash
   docker logs cts-ad_integration-1 --tail 50
   ```

2. **Перезапустите сервис принудительно:**
   ```bash
   docker restart cts-ad_integration-1
   ```

3. **Если ошибка с OpenID сохраняется — проверьте доступность Keycloak:**
   ```bash
   curl -v https://sso.runtel.ru:8443/realms/runtel/.well-known/openid-configuration
   ```

4. **Если сервис не запускается — верните email:**
   ```bash
   docker exec cts-etcd-1 etcdctl put /cts/ad_integration/registration_method "email"
   docker exec cts-etcd-1 etcdctl del /cts/ad_integration/openid_enabled
   cd /opt/express && /usr/local/bin/dpl -d ad_integration
   ```

---

### 🎯 **7. Итоговый чек-лист для входа через OpenID**

1. ✅ Сервер возвращает `register_methods: ["openid"]`
2. ✅ В веб-клиенте есть кнопка **«Войти через OpenID»** или **«Корпоративный вход»**
3. ✅ Пользователь существует в Keycloak и имеет email
4. ✅ Keycloak доступен с сервера (`sso.runtel.ru:8443`)
5. ✅ В настройках клиента в Keycloak указан правильный Redirect URI

**Если кнопка не появляется — обновите веб-клиент или используйте десктопное приложение.** 🚀
