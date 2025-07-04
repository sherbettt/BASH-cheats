### 1. Установка Node.js+yarn
На [официальной странице](https://nodejs.org/en/download) можно посмотреть как это правильно сделать, создав sh скрипт.
А также смотри [cli команды yarn](https://classic.yarnpkg.com/en/docs/cli/).

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



### 2. Подготовка проекта
Имея проект, написанный на Angular, имея готовый package.json, можно выполнить базовые действия:

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

Перед началом работы установите все зависимости проекта, после чего появится папка **node_modules** в корне проекта: 
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





