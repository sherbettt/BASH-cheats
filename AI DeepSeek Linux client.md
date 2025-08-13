**Для Linux доступен клиент (среда запуска) модели DeepSeek** — нейросети, разработанной для обработки естественного языка. Это позволяет запускать DeepSeek локально на компьютере или сервере, что удобно для автономной работы.
<br/> **Инструмент для запуска — Ollama.** Он предоставляет инструменты для управления и взаимодействия с моделями DeepSeek, включая DeepSeek-R1.

### Требования:
- Операционная система: Ubuntu 22.04 или другой дистрибутив Linux (Ximper/ALT подойдёт). 
- Оперативная память: не менее 16 ГБ (зависит от выбранной модели DeepSeek, для крупных моделей потребуется больше). 
- Свободное дисковое пространство: не менее 10 ГБ для небольших моделей, для крупных моделей — значительно больше. 
- Предустановленный Python 3.8 или выше и Git. 
- Рекомендуется использовать GPU для лучшей производительности — чем больше vRAM у графического процессора, тем быстрее будет работать модель. 

### Инструкция по установке:
- Открыть терминал и выполнить команду: **`curl -fsSL https://ollama.com/install.sh | sh`**, - это автоматически установит необходимые пакеты Ollama и выполнит настройки. 
- После установки проверить версию Ollama: **`ollama --version`**. 
- Убедиться, что служба Ollama запущена: systemctl is-active ollama.service. Если служба не активна, запустить её вручную: **`sudo systemctl start ollama.service`**. 
- Добавить службу Ollama в автозагрузку: **`sudo systemctl enable ollama.service`**.

Запуск модели DeepSeek:
- Например, для DeepSeek-R1 7B ввести в терминале: **`ollama run deepseek-r1:7b`**. Ollama автоматически скачает модель и запустит её. Если нужна другая модель, вместо ***`«7b»`*** прописать соответствующую. 

Добавление пользователя в группы render и video
```bash
┌─ kirill kiko0217
└─ ~/scripts/bash_scpits $ getent group | grep render
render:x:978:ollama
┌─ kirill kiko0217
└─ ~/scripts/bash_scpits $ getent group | grep video
video:x:979:kirill,ollama
┌─ kirill kiko0217
```

Файл `/usr/local/bin/ollama` с содержимым **ELF** — это исполняемый бинарный файл в формате ELF (Executable and Linkable Format). ELF — стандартный формат исполняемых файлов, ELF при выводе cat или ccat — это означает, что файл бинарный, и его нельзя прочитать как текстовый. 
<br/> Именно по этой причине в ExecStart прописан путь для запуска /usr/local/bin/ollama serve т.о.


Сервисный юнит `/etc/systemd/system/ollama.service`
```ini
### /etc/systemd/system/ollama.service 
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=/home/kirill/.nvm/versions/node/v22.17.0/bin:/usr/local/bin:/home/kirill/.nvm/versions/node/v22.17.0/bin:/usr/local/bin:/home/kirill/.nvm/versions/node/v22.17.0/bin:/home/kirill/.sdkman/candidates/groovy/current/bin:/usr/local/bin:/home/kirill/bin:/usr/bin:/bin:/usr/local/bin:/usr/games:/var/lib/snapd/snap/bin:/home/kirill/.local/bin:/home/kirill/.local/bin:/home/kirill/.local/bin"
#Environment="PATH=/usr/local/bin:/usr/bin:/bin"

[Install]
WantedBy=default.target
#WantedBy=multi-user.target
```
---------------------------------

Ollama поддерживает множество языковых моделей, включая официальные (Llama, Mistral, Gemma и др.) и пользовательские. Вот подробное руководство по работе с моделями:

### 🔍 Доступные модели (на август 2024)

**Популярные официальные модели:**
```
ollama run llama2         # Meta Llama 2 (7B параметров)
ollama run llama2:13b     # Llama 2 13B
ollama run llama2:70b     # Llama 2 70B (требует >64GB RAM)

ollama run mistral        # Mistral 7B
ollama run mixtral        # Mixtral 8x7B MoE

ollama run gemma          # Google Gemma 2B/7B
ollama run codellama      # Code Llama (специализирован для программирования)
ollama run phi            # Microsoft Phi-2 (2.7B)
```

**Специализированные модели:**
```
ollama run neural-chat    # Fine-tuned для диалогов
ollama run starling-lm    # Этичная модель от Berkeley
ollama run dolphin-mistral # Нецензурированная версия
```

### ⚙️ Управление моделями

1. **Поиск моделей:**
   ```bash
   ollama list
   ```

2. **Загрузка новой модели:**
   ```bash
   ollama pull llama2:13b  # Скачать 13B версию
   ```

3. **Запуск модели:**
   ```bash
   ollama run mistral
   ```
   После запуска можно сразу общаться в интерактивном режиме.

4. **Удаление модели:**
   ```bash
   ollama rm llama2
   ```

### 🛠️ Продвинутые возможности

**Контекст и параметры:**
```bash
ollama run llama2 --num_ctx 4096  # Увеличить контекст
ollama run mistral --temperature 0.7  # Контроль "креативности"
```

**Собственные модификации:**
1. Создайте файл `Modelfile`:
   ```dockerfile
   FROM llama2
   SYSTEM "Ты - русскоязычный ассистент Пушкин"
   ```
2. Соберите свою модель:
   ```bash
   ollama create pushkin -f Modelfile
   ```

### 💾 Размеры моделей (примерные)
| Модель       | Размер  | Требования RAM |
|--------------|---------|----------------|
| llama2       | 3.8GB   | 8GB+           |
| llama2:13b   | 7.3GB   | 16GB+          |
| mistral      | 4.1GB   | 8GB+           |
| mixtral      | 26GB    | 32GB+          |

### 🔄 Обновление
```bash
ollama update   # Обновить Ollama
ollama pull --latest llama2  # Обновить конкретную модель
```

### 💡 Советы
1. Для слабых ПК начинайте с `phi` или `gemma:2b`
2. Используйте `:13b` или `:70b` суффиксы для разных размеров
3. Для программирования лучше `codellama`
4. Все модели автоматически кешируются в `~/.ollama/models`


---------------------------------
<details>
<summary>❗ollama.com/install.sh❗</summary>

```bash
#!/bin/sh
# This script installs Ollama on Linux.
# It detects the current operating system architecture and installs the appropriate version of Ollama.

set -eu

red="$( (/usr/bin/tput bold || :; /usr/bin/tput setaf 1 || :) 2>&-)"
plain="$( (/usr/bin/tput sgr0 || :) 2>&-)"

status() { echo ">>> $*" >&2; }
error() { echo "${red}ERROR:${plain} $*"; exit 1; }
warning() { echo "${red}WARNING:${plain} $*"; }

TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf $TEMP_DIR; }
trap cleanup EXIT

available() { command -v $1 >/dev/null; }
require() {
    local MISSING=''
    for TOOL in $*; do
        if ! available $TOOL; then
            MISSING="$MISSING $TOOL"
        fi
    done

    echo $MISSING
}

[ "$(uname -s)" = "Linux" ] || error 'This script is intended to run on Linux only.'

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

IS_WSL2=false

KERN=$(uname -r)
case "$KERN" in
    *icrosoft*WSL2 | *icrosoft*wsl2) IS_WSL2=true;;
    *icrosoft) error "Microsoft WSL1 is not currently supported. Please use WSL2 with 'wsl --set-version <distro> 2'" ;;
    *) ;;
esac

VER_PARAM="${OLLAMA_VERSION:+?version=$OLLAMA_VERSION}"

SUDO=
if [ "$(id -u)" -ne 0 ]; then
    # Running as root, no need for sudo
    if ! available sudo; then
        error "This script requires superuser permissions. Please re-run as root."
    fi

    SUDO="sudo"
fi

NEEDS=$(require curl awk grep sed tee xargs)
if [ -n "$NEEDS" ]; then
    status "ERROR: The following tools are required but missing:"
    for NEED in $NEEDS; do
        echo "  - $NEED"
    done
    exit 1
fi

for BINDIR in /usr/local/bin /usr/bin /bin; do
    echo $PATH | grep -q $BINDIR && break || continue
done
OLLAMA_INSTALL_DIR=$(dirname ${BINDIR})

if [ -d "$OLLAMA_INSTALL_DIR/lib/ollama" ] ; then
    status "Cleaning up old version at $OLLAMA_INSTALL_DIR/lib/ollama"
    $SUDO rm -rf "$OLLAMA_INSTALL_DIR/lib/ollama"
fi
status "Installing ollama to $OLLAMA_INSTALL_DIR"
$SUDO install -o0 -g0 -m755 -d $BINDIR
$SUDO install -o0 -g0 -m755 -d "$OLLAMA_INSTALL_DIR/lib/ollama"
status "Downloading Linux ${ARCH} bundle"
curl --fail --show-error --location --progress-bar \
    "https://ollama.com/download/ollama-linux-${ARCH}.tgz${VER_PARAM}" | \
    $SUDO tar -xzf - -C "$OLLAMA_INSTALL_DIR"

if [ "$OLLAMA_INSTALL_DIR/bin/ollama" != "$BINDIR/ollama" ] ; then
    status "Making ollama accessible in the PATH in $BINDIR"
    $SUDO ln -sf "$OLLAMA_INSTALL_DIR/ollama" "$BINDIR/ollama"
fi

# Check for NVIDIA JetPack systems with additional downloads
if [ -f /etc/nv_tegra_release ] ; then
    if grep R36 /etc/nv_tegra_release > /dev/null ; then
        status "Downloading JetPack 6 components"
        curl --fail --show-error --location --progress-bar \
            "https://ollama.com/download/ollama-linux-${ARCH}-jetpack6.tgz${VER_PARAM}" | \
            $SUDO tar -xzf - -C "$OLLAMA_INSTALL_DIR"
    elif grep R35 /etc/nv_tegra_release > /dev/null ; then
        status "Downloading JetPack 5 components"
        curl --fail --show-error --location --progress-bar \
            "https://ollama.com/download/ollama-linux-${ARCH}-jetpack5.tgz${VER_PARAM}" | \
            $SUDO tar -xzf - -C "$OLLAMA_INSTALL_DIR"
    else
        warning "Unsupported JetPack version detected.  GPU may not be supported"
    fi
fi

install_success() {
    status 'The Ollama API is now available at 127.0.0.1:11434.'
    status 'Install complete. Run "ollama" from the command line.'
}
trap install_success EXIT

# Everything from this point onwards is optional.

configure_systemd() {
    if ! id ollama >/dev/null 2>&1; then
        status "Creating ollama user..."
        $SUDO useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama
    fi
    if getent group render >/dev/null 2>&1; then
        status "Adding ollama user to render group..."
        $SUDO usermod -a -G render ollama
    fi
    if getent group video >/dev/null 2>&1; then
        status "Adding ollama user to video group..."
        $SUDO usermod -a -G video ollama
    fi

    status "Adding current user to ollama group..."
    $SUDO usermod -a -G ollama $(whoami)

    status "Creating ollama systemd service..."
    cat <<EOF | $SUDO tee /etc/systemd/system/ollama.service >/dev/null
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=$BINDIR/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=$PATH"

[Install]
WantedBy=default.target
EOF
    SYSTEMCTL_RUNNING="$(systemctl is-system-running || true)"
    case $SYSTEMCTL_RUNNING in
        running|degraded)
            status "Enabling and starting ollama service..."
            $SUDO systemctl daemon-reload
            $SUDO systemctl enable ollama

            start_service() { $SUDO systemctl restart ollama; }
            trap start_service EXIT
            ;;
        *)
            warning "systemd is not running"
            if [ "$IS_WSL2" = true ]; then
                warning "see https://learn.microsoft.com/en-us/windows/wsl/systemd#how-to-enable-systemd to enable it"
            fi
            ;;
    esac
}

if available systemctl; then
    configure_systemd
fi

# WSL2 only supports GPUs via nvidia passthrough
# so check for nvidia-smi to determine if GPU is available
if [ "$IS_WSL2" = true ]; then
    if available nvidia-smi && [ -n "$(nvidia-smi | grep -o "CUDA Version: [0-9]*\.[0-9]*")" ]; then
        status "Nvidia GPU detected."
    fi
    install_success
    exit 0
fi

# Don't attempt to install drivers on Jetson systems
if [ -f /etc/nv_tegra_release ] ; then
    status "NVIDIA JetPack ready."
    install_success
    exit 0
fi

# Install GPU dependencies on Linux
if ! available lspci && ! available lshw; then
    warning "Unable to detect NVIDIA/AMD GPU. Install lspci or lshw to automatically detect and install GPU dependencies."
    exit 0
fi

check_gpu() {
    # Look for devices based on vendor ID for NVIDIA and AMD
    case $1 in
        lspci)
            case $2 in
                nvidia) available lspci && lspci -d '10de:' | grep -q 'NVIDIA' || return 1 ;;
                amdgpu) available lspci && lspci -d '1002:' | grep -q 'AMD' || return 1 ;;
            esac ;;
        lshw)
            case $2 in
                nvidia) available lshw && $SUDO lshw -c display -numeric -disable network | grep -q 'vendor: .* \[10DE\]' || return 1 ;;
                amdgpu) available lshw && $SUDO lshw -c display -numeric -disable network | grep -q 'vendor: .* \[1002\]' || return 1 ;;
            esac ;;
        nvidia-smi) available nvidia-smi || return 1 ;;
    esac
}

if check_gpu nvidia-smi; then
    status "NVIDIA GPU installed."
    exit 0
fi

if ! check_gpu lspci nvidia && ! check_gpu lshw nvidia && ! check_gpu lspci amdgpu && ! check_gpu lshw amdgpu; then
    install_success
    warning "No NVIDIA/AMD GPU detected. Ollama will run in CPU-only mode."
    exit 0
fi

if check_gpu lspci amdgpu || check_gpu lshw amdgpu; then
    status "Downloading Linux ROCm ${ARCH} bundle"
    curl --fail --show-error --location --progress-bar \
        "https://ollama.com/download/ollama-linux-${ARCH}-rocm.tgz${VER_PARAM}" | \
        $SUDO tar -xzf - -C "$OLLAMA_INSTALL_DIR"

    install_success
    status "AMD GPU ready."
    exit 0
fi

CUDA_REPO_ERR_MSG="NVIDIA GPU detected, but your OS and Architecture are not supported by NVIDIA.  Please install the CUDA driver manually https://docs.nvidia.com/cuda/cuda-installation-guide-linux/"
# ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#rhel-7-centos-7
# ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#rhel-8-rocky-8
# ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#rhel-9-rocky-9
# ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#fedora
install_cuda_driver_yum() {
    status 'Installing NVIDIA repository...'
    
    case $PACKAGE_MANAGER in
        yum)
            $SUDO $PACKAGE_MANAGER -y install yum-utils
            if curl -I --silent --fail --location "https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m | sed -e 's/aarch64/sbsa/')/cuda-$1$2.repo" >/dev/null ; then
                $SUDO $PACKAGE_MANAGER-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m | sed -e 's/aarch64/sbsa/')/cuda-$1$2.repo
            else
                error $CUDA_REPO_ERR_MSG
            fi
            ;;
        dnf)
            if curl -I --silent --fail --location "https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m | sed -e 's/aarch64/sbsa/')/cuda-$1$2.repo" >/dev/null ; then
                $SUDO $PACKAGE_MANAGER config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m | sed -e 's/aarch64/sbsa/')/cuda-$1$2.repo
            else
                error $CUDA_REPO_ERR_MSG
            fi
            ;;
    esac

    case $1 in
        rhel)
            status 'Installing EPEL repository...'
            # EPEL is required for third-party dependencies such as dkms and libvdpau
            $SUDO $PACKAGE_MANAGER -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$2.noarch.rpm || true
            ;;
    esac

    status 'Installing CUDA driver...'

    if [ "$1" = 'centos' ] || [ "$1$2" = 'rhel7' ]; then
        $SUDO $PACKAGE_MANAGER -y install nvidia-driver-latest-dkms
    fi

    $SUDO $PACKAGE_MANAGER -y install cuda-drivers
}

# ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu
# ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#debian
install_cuda_driver_apt() {
    status 'Installing NVIDIA repository...'
    if curl -I --silent --fail --location "https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m | sed -e 's/aarch64/sbsa/')/cuda-keyring_1.1-1_all.deb" >/dev/null ; then
        curl -fsSL -o $TEMP_DIR/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/$1$2/$(uname -m | sed -e 's/aarch64/sbsa/')/cuda-keyring_1.1-1_all.deb
    else
        error $CUDA_REPO_ERR_MSG
    fi

    case $1 in
        debian)
            status 'Enabling contrib sources...'
            $SUDO sed 's/main/contrib/' < /etc/apt/sources.list | $SUDO tee /etc/apt/sources.list.d/contrib.list > /dev/null
            if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
                $SUDO sed 's/main/contrib/' < /etc/apt/sources.list.d/debian.sources | $SUDO tee /etc/apt/sources.list.d/contrib.sources > /dev/null
            fi
            ;;
    esac

    status 'Installing CUDA driver...'
    $SUDO dpkg -i $TEMP_DIR/cuda-keyring.deb
    $SUDO apt-get update

    [ -n "$SUDO" ] && SUDO_E="$SUDO -E" || SUDO_E=
    DEBIAN_FRONTEND=noninteractive $SUDO_E apt-get -y install cuda-drivers -q
}

if [ ! -f "/etc/os-release" ]; then
    error "Unknown distribution. Skipping CUDA installation."
fi

. /etc/os-release

OS_NAME=$ID
OS_VERSION=$VERSION_ID

PACKAGE_MANAGER=
for PACKAGE_MANAGER in dnf yum apt-get; do
    if available $PACKAGE_MANAGER; then
        break
    fi
done

if [ -z "$PACKAGE_MANAGER" ]; then
    error "Unknown package manager. Skipping CUDA installation."
fi

if ! check_gpu nvidia-smi || [ -z "$(nvidia-smi | grep -o "CUDA Version: [0-9]*\.[0-9]*")" ]; then
    case $OS_NAME in
        centos|rhel) install_cuda_driver_yum 'rhel' $(echo $OS_VERSION | cut -d '.' -f 1) ;;
        rocky) install_cuda_driver_yum 'rhel' $(echo $OS_VERSION | cut -c1) ;;
        fedora) [ $OS_VERSION -lt '39' ] && install_cuda_driver_yum $OS_NAME $OS_VERSION || install_cuda_driver_yum $OS_NAME '39';;
        amzn) install_cuda_driver_yum 'fedora' '37' ;;
        debian) install_cuda_driver_apt $OS_NAME $OS_VERSION ;;
        ubuntu) install_cuda_driver_apt $OS_NAME $(echo $OS_VERSION | sed 's/\.//') ;;
        *) exit ;;
    esac
fi

if ! lsmod | grep -q nvidia || ! lsmod | grep -q nvidia_uvm; then
    KERNEL_RELEASE="$(uname -r)"
    case $OS_NAME in
        rocky) $SUDO $PACKAGE_MANAGER -y install kernel-devel kernel-headers ;;
        centos|rhel|amzn) $SUDO $PACKAGE_MANAGER -y install kernel-devel-$KERNEL_RELEASE kernel-headers-$KERNEL_RELEASE ;;
        fedora) $SUDO $PACKAGE_MANAGER -y install kernel-devel-$KERNEL_RELEASE ;;
        debian|ubuntu) $SUDO apt-get -y install linux-headers-$KERNEL_RELEASE ;;
        *) exit ;;
    esac

    NVIDIA_CUDA_VERSION=$($SUDO dkms status | awk -F: '/added/ { print $1 }')
    if [ -n "$NVIDIA_CUDA_VERSION" ]; then
        $SUDO dkms install $NVIDIA_CUDA_VERSION
    fi

    if lsmod | grep -q nouveau; then
        status 'Reboot to complete NVIDIA CUDA driver install.'
        exit 0
    fi

    $SUDO modprobe nvidia
    $SUDO modprobe nvidia_uvm
fi

# make sure the NVIDIA modules are loaded on boot with nvidia-persistenced
if available nvidia-persistenced; then
    $SUDO touch /etc/modules-load.d/nvidia.conf
    MODULES="nvidia nvidia-uvm"
    for MODULE in $MODULES; do
        if ! grep -qxF "$MODULE" /etc/modules-load.d/nvidia.conf; then
            echo "$MODULE" | $SUDO tee -a /etc/modules-load.d/nvidia.conf > /dev/null
        fi
    done
fi

status "NVIDIA GPU ready."
install_success
```
</details>
