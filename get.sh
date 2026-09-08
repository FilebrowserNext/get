#!/usr/bin/env bash
#
#           File Browser Next Installer Script
#
#   GitHub: https://github.com/FilebrowserNext/filebrowserNEXT
#   Issues: https://github.com/FilebrowserNext/filebrowserNEXT/issues
#   Requires: bash, mv, rm, tr, type, grep, sed, curl/wget, tar (or unzip on Windows)
#
#   This script installs File Browser Next to your path.
#   Usage:
#
#       $ curl -fsSL https://raw.githubusercontent.com/FilebrowserNext/get/main/get.sh | bash
#         or
#       $ wget -qO- https://raw.githubusercontent.com/FilebrowserNext/get/main/get.sh | bash
#

install_filemanager()
{
	trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; return 1' ERR
	filemanager_os="unsupported"
	filemanager_arch="unknown"
	install_path="/usr/local/bin"

	# Termux on Android compatibility
	if [[ -n "$ANDROID_ROOT" && -n "$PREFIX" ]]; then
		install_path="$PREFIX/bin"
	fi

	# Fall back to /usr/bin if /usr/local/bin is missing
	if [[ ! -d $install_path ]]; then
		install_path="/usr/bin"
	fi

	# Detect sudo requirement
	((EUID)) && [[ -z "$ANDROID_ROOT" ]] && sudo_cmd="sudo"

	#########################
	# Architecture detection#
	#########################

	filemanager_bin="filebrowser"
	filemanager_dl_ext=".tar.gz"

	unamem="$(uname -m)"
	case $unamem in
	*aarch64*|arm64)
		filemanager_arch="arm64";;
	*64*)
		filemanager_arch="amd64";;
	*)
		echo "Aborted, unsupported or unknown architecture: $unamem"
		return 2
		;;
	esac

	#################
	# OS detection  #
	#################

	unameu="$(tr '[:lower:]' '[:upper:]' <<<$(uname))"
	if [[ $unameu == *DARWIN* ]]; then
		filemanager_os="darwin"
	elif [[ $unameu == *LINUX* ]]; then
		filemanager_os="linux"
	elif [[ $unameu == *WIN* || $unameu == MSYS* || $unameu == MINGW* ]]; then
		sudo_cmd=""
		filemanager_os="windows"
		filemanager_bin="filebrowser.exe"
		filemanager_dl_ext=".zip"
	else
		echo "Aborted, unsupported OS: $unameu"
		return 6
	fi

	########################
	# Download and extract #
	########################

	echo "Downloading File Browser Next for $filemanager_os/$filemanager_arch..."
	if type -p curl >/dev/null 2>&1; then
		net_getter="curl -fsSL"
	elif type -p wget >/dev/null 2>&1; then
		net_getter="wget -qO-"
	else
		echo "Aborted, could not find curl or wget"
		return 7
	fi

	filemanager_file="filebrowser-${filemanager_os}-${filemanager_arch}${filemanager_dl_ext}"
	filemanager_url="https://github.com/FilebrowserNext/filebrowserNEXT/releases/latest/download/$filemanager_file"
	echo "Fetching: $filemanager_url"

	TMP_DIR="${PREFIX}/tmp"
	if [[ ! -d "$TMP_DIR" ]]; then
		TMP_DIR="/tmp"
	fi

	rm -rf "$TMP_DIR/$filemanager_file"
	${net_getter} "$filemanager_url" > "$TMP_DIR/$filemanager_file"

	echo "Extracting..."
	case "$filemanager_file" in
		*.zip)    unzip -o "$TMP_DIR/$filemanager_file" -d "$TMP_DIR/" ;;
		*.tar.gz) tar --no-same-owner -xzf "$TMP_DIR/$filemanager_file" -C "$TMP_DIR/" ;;
	esac

	# Handle binary filename flexibility
	if [[ -f "$TMP_DIR/filebrowser-${filemanager_os}-${filemanager_arch}" ]]; then
		mv "$TMP_DIR/filebrowser-${filemanager_os}-${filemanager_arch}" "$TMP_DIR/$filemanager_bin"
	elif [[ -f "$TMP_DIR/filebrowser-${filemanager_os}-${filemanager_arch}.exe" ]]; then
		mv "$TMP_DIR/filebrowser-${filemanager_os}-${filemanager_arch}.exe" "$TMP_DIR/$filemanager_bin"
	fi

	chmod +x "$TMP_DIR/$filemanager_bin"

	echo "Installing filebrowser in $install_path (may require sudo password)..."
	$sudo_cmd mv "$TMP_DIR/$filemanager_bin" "$install_path/$filemanager_bin"

	if setcap_cmd=$(PATH+=$PATH:/sbin type -p setcap); then
		$sudo_cmd $setcap_cmd cap_net_bind_service=+ep "$install_path/$filemanager_bin" 2>/dev/null || true
	fi
	rm -f "$TMP_DIR/$filemanager_file"

	if type -p $filemanager_bin >/dev/null 2>&1; then
		echo "File Browser Next installed successfully."
		echo "Run '$filemanager_bin -r /path/to/files' to start."
		trap ERR
		return 0
	else
		echo "Something went wrong, $filemanager_bin is not in PATH."
		trap ERR
		return 1
	fi
}

install_filemanager
