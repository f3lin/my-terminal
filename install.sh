#!/usr/bin/env sh

install_dir="/usr/local/bin"
themes_dir=""

error() {
    printf "\x1b[31m$1\e[0m\n"
    exit 1
}

info() {
    printf "$1\n"
}

warn() {
    printf "⚠️  \x1b[33m$1\e[0m\n"
}

SUPPORTED_TARGETS="linux-386 linux-amd64 linux-arm linux-arm64 darwin-amd64 darwin-arm64 freebsd-386 freebsd-amd64 freebsd-arm freebsd-arm64"

validate_dependency() {
    if ! command -v $1 >/dev/null; then
        error "$1 is required to install Oh My Posh. Please install $1 and try again.\n"
    fi
}

validate_dependencies() {
    validate_dependency curl
    validate_dependency unzip
    validate_dependency realpath
    validate_dependency dirname
}

set_install_directory() {
    if [ -n "$install_dir" ]; then
        # expand directory
        install_dir="${install_dir/#\~/$HOME}"
        return 0
    fi

    install_dir="/usr/local/bin"
}

validate_install_directory() {
    if [ ! -d "$install_dir" ]; then
        error "Directory ${install_dir} does not exist, set a different directory and try again."
    fi

    # check if the directory is in the PATH
    good=$(
        IFS=:
        for path in $PATH; do
        if [ "${path%/}" = "${install_dir}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        warn "Installation directory ${install_dir} is not in your \$PATH"
    fi
}

install_theme() {
    theme_name="dev"
    theme_file="${theme_name}.yaml"
    theme_url="https://raw.githubusercontent.com/f3lin/my-terminal/main/themes/${theme_file}"
    
    cache_dir="$install_dir/.oh-my-posh/themes"
    theme_dir="$cache_dir/$theme_name"

    info "🎨 Installing oh-my-posh theme: ${theme_name}\n"

    if [ ! -d "$theme_dir" ]; then
        mkdir -p $theme_dir
    fi

    http_response=$(curl -s -f -L $theme_url -o "${theme_dir}/${theme_file}" -w "%{http_code}")

    if [ $http_response == "200" ] && [ -f "${theme_dir}/${theme_file}" ]; then
        info "🎉 Theme ${theme_name} installed successfully."
    else
        error "Unable to download theme ${theme_name} from ${theme_url}"
    fi
}

install_victor_mono() {
    font_name="Victor Mono"
    font_url="https://rubjo.github.io/victor-mono/VictorMonoAll.zip"
    temp_dir=$(mktemp -d)

    info "🔤 Installing Font: ${font_name}\n"

    # Download and extract the font
    curl -s -f -L $font_url -o "${temp_dir}/font.zip"
    unzip -q "${temp_dir}/font.zip" -d "${temp_dir}"

    # Install the font
    mkdir -p "$HOME/.local/share/fonts"
    cp -r "${temp_dir}"/* "$HOME/.local/share/fonts/"

    # Refresh font cache
    fc-cache -f -v

    info "🎉 Font ${font_name} installed successfully."
}

install() {
    arch=$(detect_arch)
    platform=$(detect_platform)
    target="${platform}-${arch}"

    good=$(
        IFS=" "
        for t in $SUPPORTED_TARGETS; do
        if [ "${t}" = "${target}" ]; then
            printf 1
            break
        fi
        done
    )

    if [ "${good}" != "1" ]; then
        error "${arch} builds for ${platform} are not available for Oh My Posh"
    fi

    info "\nℹ️  Installing oh-my-posh for ${target} in ${install_dir}"

    executable="${install_dir}/oh-my-posh"
    url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-${target}"

    info "⬇️  Downloading oh-my-posh from ${url}"

    http_response=$(curl -s -f -L $url -o $executable -w "%{http_code}")

    if [ $http_response != "200" ] || [ ! -f $executable ]; then
        error "Unable to download executable at ${url}\nPlease validate your curl, connection and/or proxy settings"
    fi

    chmod +x $executable

    install_themes

    info "🚀 Installation complete.\n\nYou can follow the instructions at https://ohmyposh.dev/docs/installation/prompt"
    info "to setup your shell to use oh-my-posh."
    if [ $http_response == "200" ]; then
        info "\nIf you want to use a built-in theme, you can find them in the ${theme_dir} directory:"
        info "  oh-my-posh init {shell} --config ${theme_dir}/{theme}.omp.json\n"
    fi
}

detect_arch() {
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "${arch}" in
    x86_64) arch="amd64" ;;
    armv*) arch="arm" ;;
    arm64) arch="arm64" ;;
    aarch64) arch="arm64" ;;
    i686) arch="386" ;;
  esac

  if [ "${arch}" = "arm64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi

  printf '%s' "${arch}"
}


detect_platform() {
  platform="$(uname -s | awk '{print tolower($0)}')"

  case "${platform}" in
    linux) platform="linux" ;;
    darwin) platform="darwin" ;;
  esac

  printf '%s' "${platform}"
}

validate_dependencies
set_install_directory
validate_install_directory
install
