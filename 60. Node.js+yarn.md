### 1. Установка Node.js+yarn
На **[официальной странице](https://nodejs.org/en/download)** можно посмотреть как это правильно сделать, создав sh скрипт. 
А также смотри **[cli команды yarn](https://classic.yarnpkg.com/en/docs/cli/)**.



<details>
<summary>Install.sh</summary>

```bash
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.17.0".
nvm current # Should print "v22.17.0".

# Download and install Yarn:
corepack enable yarn

# Verify Yarn version:
yarn -v
```
```bash
└─ $ yarn --version
1.22.22
```
</details> 

```bash
# Возможно придётся выполнить

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 24
nvm use 24

corepack enable

node -v
npm -v
yarn -v
```

### 2. Подготовка проекта
Имея проект, написанный на Angular, имея готовый **`package.json`**, можно выполнить базовые действия:

<details>
<summary>package.json</summary>
  
```json
{
  "name": "rt",
  "version": "2.21.0",
  "license": "MIT",
  "scripts": {
    "ng": "ng",
    "rt-v2": "ng serve --project rt-v2",
    "start-kept": "ng serve --project rt-v2 --configuration=kept",
    "cti-panel": "ng serve --project cti-panel",
    "build-cti-panel": "ng build --project cti-panel --configuration production --output-hashing none",
    "start-kept-dev": "ng serve --project rt-v2 --configuration=kept-dev",
    "pre-build-options": "NODE_OPTIONS=--max-old-space-size=4096 ng build --configuration production --project rt-v2",
    "pre-build": "ng build --configuration production --project rt-v2",
    "bundle-report": "ng build --project rt-v2 --stats-json && webpack-bundle-analyzer dist/stats.json -p 8090",
    "bundle-report-kept": "ng build --project rt-v2 --configuration=kept --stats-json && webpack-bundle-analyzer dist/stats.json -p 8070",
    "build": "yarn pre-build-options && yarn build-cti-panel",
    "build-win": "yarn pre-build && yarn build-cti-panel",
    "build-kept": "ng build --project rt-v2 --configuration=kept",
    "test": "ng test",
    "lint": "eslint . --ext .js,.ts",
    "e2e": "ng e2e"
  },
  "private": true,
  "dependencies": {
    "@angular-devkit/core": "^12.2.18",
    "@angular-material-components/datetime-picker": "^8.0.0",
    "@angular-material-components/moment-adapter": "^8.0.0",
    "@angular-material-extensions/fab-menu": "^5.1.0",
    "@angular/animations": "^14.2.6",
    "@angular/cdk": "^14.2.6",
    "@angular/common": "^14.2.6",
    "@angular/compiler": "^14.2.6",
    "@angular/core": "^14.2.6",
    "@angular/flex-layout": "^14.0.0-beta.39",
    "@angular/forms": "^14.2.6",
    "@angular/material": "^14.2.6",
    "@angular/material-moment-adapter": "^14.2.6",
    "@angular/platform-browser": "^14.2.6",
    "@angular/platform-browser-dynamic": "^14.2.6",
    "@angular/router": "^14.2.6",
    "@antfu/utils": "^9.2.0",
    "@katoid/angular-grid-layout": "^1.2.0",
    "@khajegan/ngx-audio-player": "^14.0.5",
    "@kolkov/angular-editor": "^2.1.0",
    "@material/button": "^12.0.0",
    "@material/fab": "^12.0.0",
    "@material/snackbar": "^14.0.0",
    "@material/textfield": "^14.0.0",
    "@mediapipe/selfie_segmentation": "^0.1.1675465747",
    "@ng-select/ng-select": "^9.0.0",
    "@ngx-pwa/local-storage": "^13.0.6",
    "@ngx-translate/core": "^14.0.0",
    "@ngx-translate/http-loader": "^7.0.0",
    "@rxweb/reactive-form-validators": "^2.1.7",
    "@rxweb/sanitizers": "^0.0.1",
    "ajv": "^6.12.5",
    "angular-calendar": "^0.30.0",
    "angular2-qrcode": "^2.0.3",
    "apexcharts": "^3.52.0",
    "c3": "^0.7.20",
    "chart.js": "^3.2.0",
    "chartjs-plugin-zoom": "1.2.1",
    "comlink": "^4.4.2",
    "core-js": "^3.6.5",
    "crypto-js": "^4.0.0",
    "d3": "^7.9.0",
    "date-fns": "^1.30.1",
    "extend": "^3.0.2",
    "faker": "^5.5.3",
    "flag-icon-css": "^3.4.6",
    "fontfaceobserver": "^2.1.0",
    "hammerjs": "^2.0.8",
    "handlebars": "^4.7.3",
    "jquery": "^3.6.0",
    "jsonpath-plus": "^7.2.0",
    "lodash": "^4.17.20",
    "marked": "14.0.0",
    "material-icons": "^1.11.3",
    "mermaid": "9.2.0",
    "moment-timezone": "^0.5.48",
    "ng-apexcharts": "~1.7.7",
    "ng-multiselect-dropdown": "^0.2.10",
    "ng2-charts": "^4.1.1",
    "ngx-avatar-2": "4.1.8",
    "ngx-device-detector": "^4.0.1",
    "ngx-gravatar": "^11.0.0",
    "ngx-json-viewer": "^2.4.0",
    "ngx-markdown": "^14.0.1",
    "ngx-mat-select-search": "^5.0.0",
    "ngx-material-timepicker": "^5.5.3",
    "ngx-perfect-scrollbar": "^10.1.1",
    "ngx-pipes": "^3.2.0",
    "ngx-quill": "^18.0.0",
    "ngx-skeleton-loader": "^5.0.0",
    "ngx-translate-multi-http-loader": "^3.0.0",
    "quill": "^1.3.7",
    "rrule": "^2.7.2",
    "rxjs": "~7.5.0",
    "secure-web-storage": "^1.0.2",
    "tinycolor2": "^1.4.2",
    "tslib": "^2.4.0",
    "worker-loader": "^3.0.8",
    "xlsx": "^0.18.5",
    "zone.js": "~0.11.8"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^14.2.6",
    "@angular-devkit/schematics": "^12.2.18",
    "@angular/cli": "^14.2.6",
    "@angular/compiler-cli": "^14.2.6",
    "@angular/language-service": "^12.2.17",
    "@types/jasmine": "4.3.0",
    "@types/jasminewd2": "^2.0.10",
    "@types/jquery": "^3.5.2",
    "@types/mermaid": "^9.2.0",
    "@types/node": "^18.11.0",
    "angular-cli-ghpages": "^2.0.0",
    "angular-router-loader": "^0.8.5",
    "angular2-template-loader": "~0.6.2",
    "css-loader": "^5.0.1",
    "file-loader": "~6.2.0",
    "html-loader": "^1.3.2",
    "html-webpack-plugin": "4.5.2",
    "jasmine-core": "^3.8.0",
    "jasmine-spec-reporter": "~5.0.0",
    "karma": "^6.3.2",
    "karma-chrome-launcher": "~3.1.0",
    "karma-cli": "~2.0.0",
    "karma-coverage-istanbul-reporter": "^3.0.3",
    "karma-jasmine": "~4.0.0",
    "karma-jasmine-html-reporter": "^1.7.0",
    "mini-css-extract-plugin": "^1.6.2",
    "protractor": "^7.0.0",
    "sass": "^1.42.1",
    "sass-loader": "^10.4.1",
    "to-string-loader": "^1.2.0",
    "ts-loader": "^9.5.1",
    "ts-node": "^10.9.2",
    "typescript": "4.8.4",
    "url-loader": "^4.1.1",
    "webpack": "^5.93.0",
    "webpack-bundle-analyzer": "^4.10.2",
    "webpack-cli": "^5.1.4",
    "yarn": "^1.22.22"
  },
  "browser": {
    "crypto": false
  }
}

```
</details> 

Перед началом работы установите все зависимости проекта, после чего появится папки **.angular** и **node_modules** в корне проекта: 
```bash
┌─ kirill ~/Projects/GIT/rt-v2 
└─ $ yarn install   # или yarn
yarn install v1.22.22
[1/4] Resolving packages...
.....
warning " > @angular/material-moment-adapter@14.2.7" has unmet peer dependency "moment@^2.18.1".
[4/4] Building fresh packages...
success Saved lockfile.
Done in 88.99s.
```

### 3. Запуск проекта в режиме разработки
Для запуска проекта в dev-режиме используйте одну из команд из вашего `package.json`:
```bash
yarn rt-v2          # Обычный запуск
yarn start-kept     # Запуск с конфигурацией "kept"
yarn start-kept-dev # Запуск с конфигурацией "kept-dev"
yarn cti-panel      # Запуск проекта cti-panel
```
Сборка может закончится с ошибкой из-за нехватка памяти
```bash
└─ $ yarn rt-v2
yarn run v1.22.22
$ ng serve --project rt-v2
⠙ Generating browser application bundles (phase: setup)...Processing legacy "View Engine" libraries:
.......
FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory
----- Native stack trace -----

 1: 0xe16044 node::OOMErrorHandler(char const*, v8::OOMDetails const&) [ng serve --project rt-v2]
 2: 0x11e0dd0 v8::Utils::ReportOOMFailure(v8::internal::Isolate*, char const*, v8::OOMDetails const&) [ng serve --project rt-v2]
 3: 0x11e10a7 v8::internal::V8::FatalProcessOutOfMemory(v8::internal::Isolate*, char const*, v8::OOMDetails const&) [ng serve --project rt-v2]
 4: 0x140e985  [ng serve --project rt-v2]
 5: 0x140e9b3  [ng serve --project rt-v2]
 6: 0x1427a8a  [ng serve --project rt-v2]
 7: 0x142ac58  [ng serve --project rt-v2]
 8: 0x1c90921  [ng serve --project rt-v2]
error Command failed with signal "SIGABRT".
```

В этом случае требуется увеличить лимит и перезапустить. В результате будет сформирована ссылка в бразуер для отладки `http://localhost:4200/`
```bash
export NODE_OPTIONS=--max-old-space-size=8192
```
Или попробвать очистить кеш
```bash
rm -rf .angular/ node_modules/   # Linux/macOS
yarn install                     # Переустановка зависимостей
```

```bash
┌─ kirill ~/Projects/GIT/rt-v2 
└─ $ yarn rt-v2
yarn run v1.22.22
$ ng serve --project rt-v2
✔ Browser application bundle generation complete.

Initial Chunk Files   | Names                                                                           |   Raw Size
main.js               | main                                                                            |   15.94 MB | 
scripts.js            | scripts                                                                         | 1009.94 kB | 
styles.css, styles.js | styles                                                                          |  530.65 kB | 
.......
Warning: /home/kirill/Projects/GIT/rt-v2/node_modules/mermaid/dist/mermaid.core.mjs depends on 'moment-mini'. CommonJS or AMD dependencies can cause optimization bailouts.
For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies

** Angular Live Development Server is listening on localhost:4200, open your browser on http://localhost:4200/ **

✔ Compiled successfully.
```

Если сборка всё равно падает, то можно обновить зависимости или добавить в `angular.json` в раздел `projects → rt-v2 → architect → build`:
```json
"optimization": false,
"buildOptimizer": false,
"aot": false
```
*(Это временное решение для дебага, но не для прода)*



### 4. Сборка проекта
```bash
yarn build      # Основная сборка (с увеличенным лимитом памяти)
yarn build-win  # Сборка для Windows (без увеличенного лимита памяти)
yarn build-kept # Сборка с конфигурацией "kept"
```
В результате будет создан файл `yarn.lock`.

#### Посмотреть собранное и запустить сервер для отладки
```bash
cd dist/web-ui
python3 -m http.server 8080

# перейти в бразуере по http://127.0.0.1:8090
```

### 5. Анализ бандлов
```bash
yarn bundle-report      # Обычный анализ
yarn bundle-report-kept # Анализ для конфигурации "kept"
```

### 6. Тестирование
```bash
yarn test  # Запуск unit-тестов
yarn e2e   # Запуск end-to-end тестов
yarn lint  # Проверка кода с помощью ESLint
```
И будет сформирован отчёт: Webpack Bundle Analyzer is started at http://127.0.0.1:8090

### 7. Добавление новых зависимостей
Чтобы добавить новую зависимость:
```bash
yarn add package-name           # Добавить в dependencies
yarn add -D package-name        # Добавить в devDependencies
yarn add package-name@version   # Указать версию
```

### 8. **Обновление зависимостей**
```bash
yarn upgrade          # Обновить все зависимости
yarn upgrade package-name # Обновить конкретный пакет
##
yarn upgrade @rxweb/reactive-form-validators@latest
yarn upgrade ngx-perfect-scrollbar@latest
yarn upgrade ngx-material-timepicker@latest
```

### 9. **Удаление зависимостей**
```bash
yarn remove package-name
```


### Советы:
1. **Если сборка падает из-за нехватки памяти** – попробуйте увеличить лимит:
   ```bash
   export NODE_OPTIONS=--max-old-space-size=8192
   yarn build
   ```
2. **Используйте `npx ngcc` для анализа проблемных библиотек**:
   Установите глобально:
   ```bash
   npx ngcc --properties es2015 browser module main --first-only --create-ivy-entry-points
   ```
   *(Это проверит node_modules на наличие проблемных библиотек)*
   
3. **Для очистки кеша Yarn** (если есть проблемы с зависимостями):
   ```bash
   yarn cache clean
   ```
4. **Для проверки актуальности зависимостей**:
   ```bash
   yarn outdated
   ```
     1. Проверить, какие версии Angular поддерживает библиотека: `npm view <package> engines`
        ```bash
        npm view @rxweb/reactive-form-validators engines
        ```
     2. `ng update` – попробуйте обновить Angular и библиотеки:
        ```bash
        ng update @angular/core @angular/cli
        ```
5. **Отображает расположение папки bin**:
   ```bash
   yarn bin
   yarn bin gettext-compile
   ```
-----------

Ошибки, которые могут возникнуть в момент работы `yarn test`, связаны с несколькими проблемами в настройке Angular-проекта и окружения. 

### **1. Отсутствует файл `test.ts`**
**Ошибка:**
```
Error: ENOENT: no such file or directory, open '/home/kirill/Projects/GIT/rt-v2/src/test.ts'
```
**Решение:**
- Файл `src/test.ts` используется для настройки тестовой среды Angular. Если его нет, создайте его со следующим содержимым:
  ```typescript
  // test.ts
  import 'zone.js/testing';
  import { getTestBed } from '@angular/core/testing';
  import { BrowserDynamicTestingModule, platformBrowserDynamicTesting } from '@angular/platform-browser-dynamic/testing';

  getTestBed().initTestEnvironment(
    BrowserDynamicTestingModule,
    platformBrowserDynamicTesting(),
  );
  ```
- Убедитесь, что он указан в `angular.json` в секции `test`:
  ```json
  "test": {
    "main": "src/test.ts",
    ...
  }
  ```



### **2. Проблема с NGCC (Angular Compatibility Compiler)**
**Ошибка:**
```
Error: Failed to initialize Angular compilation - NGCC failed.
```
**Решение:**
- Удалите `node_modules` и `package-lock.json`/`yarn.lock`, затем переустановите зависимости:
  ```bash
  rm -rf node_modules yarn.lock
  yarn install
  ```
- Если проблема остаётся, попробуйте явно запустить NGCC:
  ```bash
  yarn ngcc
  ```


### **3. Не установлен Chrome для Karma**
**Ошибка:**
```
ERROR [launcher]: No binary for Chrome browser on your platform.
Please, set "CHROME_BIN" env variable.
```
**Решение:**
#### Для Linux (Ubuntu/Debian):
1. Установите Chrome:
   ```bash
   sudo apt-get install google-chrome-stable
   ```
2. Укажите путь к Chrome в переменной окружения:
   ```bash
   export CHROME_BIN=$(which google-chrome-stable)
   ```
   (Добавьте эту строку в `~/.bashrc` или `~/.zshrc` для постоянного эффекта.)

#### Альтернатива: Используйте Headless Chrome
В `karma.conf.js` измените настройки браузера:
```javascript
browsers: ['ChromeHeadless'], // вместо 'Chrome'
```


### **4. Предупреждение о deprecated ES5**
**Сообщение:**
```
DEPRECATED: ES5 output is deprecated. Please update TypeScript `target` compiler option to ES2015 or later.
```
**Решение:**
Обновите `target` в `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2017",
    ...
  }
}
```



### **5. Проблема с `polyfills.ts`**
**Ошибка:**
```
./src/polyfills.ts - Error: Emit attempted before Angular Webpack plugin initialization.
```
**Решение:**
- Убедитесь, что `polyfills.ts` существует и содержит стандартные импорты (например, `zone.js`).
- Пересоберите проект:
  ```bash
  yarn build
  ```

---
  ```typescript
  // test.ts
  import 'zone.js/testing';
  import { getTestBed } from '@angular/core/testing';
  import { BrowserDynamicTestingModule, platformBrowserDynamicTesting } from '@angular/platform-browser-dynamic/testing';

  getTestBed().initTestEnvironment(
    BrowserDynamicTestingModule,
    platformBrowserDynamicTesting(),
  );
  ```
 это типовой (стандартный) скрипт для настройки тестового окружения в Angular с использованием Jasmine или других тестовых фреймворков.

Разберём его по частям:

1. `import 'zone.js/testing';` - Импорт Zone.js, который необходим Angular для работы с асинхронными операциями в тестах.

2. `import { getTestBed } from '@angular/core/testing';` - Импорт функции getTestBed, которая предоставляет доступ к Angular TestBed.

3. `import { BrowserDynamicTestingModule, platformBrowserDynamicTesting }` - Импорт необходимых модулей для тестирования в браузерном окружении.

4. `getTestBed().initTestEnvironment(...)` - Инициализация тестового окружения с указанием:
   - `BrowserDynamicTestingModule` - модуль для динамического тестирования в браузере
   - `platformBrowserDynamicTesting()` - платформа для запуска тестов

Это стандартная конфигурация, которая обычно находится в файле `test.ts` (или `test-setup.ts` в новых версиях Angular) и используется Karma или другими тестовыми раннерами для настройки окружения перед запуском тестов.

В современных версиях Angular (версии 12+) этот файл может выглядеть немного иначе или даже быть автоматически сгенерированным с другими настройками, но основная концепция остаётся той же.

--------------

Ошибка в результает выполнения yarn e2e. Ошибка возникает из-за того, что Protractor не может найти Chrome браузер на вашей системе. Вот как это можно решить:

### Основное решение:
```bash
[16:37:58] E/launcher - unknown error: cannot find Chrome binary
```

1. **Установите Google Chrome** (если ещё не установлен):
   ```bash
   # Для Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install google-chrome-stable

   # Для CentOS/RHEL
   sudo yum install google-chrome-stable
   ```

2. **Проверьте путь к Chrome**:
   Protractor ищет Chrome в стандартных местах. Если Chrome установлен в нестандартном месте, укажите путь в конфиге Protractor (`protractor.conf.js`):
   ```js
   capabilities: {
     browserName: 'chrome',
     chromeOptions: {
       binary: '/path/to/your/chrome' // Например, '/usr/bin/google-chrome'
     }
   }
   ```

### Альтернативные решения:

3. **Используйте ChromeDriver напрямую**:
   Убедитесь, что ChromeDriver соответствует версии Chrome:
   ```bash
   npm install -g webdriver-manager
   webdriver-manager update
   ```

4. **Перейдите на современные альтернативы Protractor** (рекомендуется):
   Так как Protractor устарел, рассмотрите:
   - **Cypress** (проще в настройке)
   - **Playwright** или **WebdriverIO** (более мощные аналоги)

   Angular CLI уже поддерживает эти альтернативы.

5. **Если Chrome установлен, но не распознаётся**:
   Проверьте симлинк:
   ```bash
   which google-chrome
   # Если не найден, создайте симлинк
   sudo ln -s /usr/bin/google-chrome-stable /usr/bin/google-chrome
   ```

### Дополнительные замечания:
- Предупреждения о `mermaid.core.mjs` не влияют на запуск, но для оптимизации сборки добавьте в `angular.json`:
  ```json
  "allowedCommonJsDependencies": [
    "@braintree/sanitize-url",
    "dagre",
    "dagre-d3",
    "dompurify",
    "graphlib",
    "moment-mini"
  ]
  ```

После установки Chrome перезапустите тесты:
```bash
yarn e2e
```

Если проблема сохраняется, попробуйте явно указать путь к Chrome в конфигурации Protractor.



