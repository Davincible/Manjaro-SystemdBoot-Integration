#!/bin/bash -e

#
# Inted to overwrite the hook /usr/share/libalpm/hooks/90-mkinitcpio-install.hook by placing a custom hook in /etc/pacman.d
#

# Check for sudo rights
(( $(id -u) == 0 )) || { echo "install.sh must be run as sudo"; exit 1; }

# Set file and directory names
pacman_configd="/etc/pacman.d"
hooks_dir="${pacman_configd}/hooks"
scripts_dir="${pacman_configd}/scripts"

install_hook="90-mkinitcpio-install.hook"
install_script="mkinitcpio-install"
remove_hook="60-mkinitcpio-remove.hook"
remove_script="mkinitcpio-remove"
preset="hook.preset"

install_hook_dest="${hooks_dir}/${install_hook}"
install_script_dest="${scripts_dir}/${install_script}"
remove_hook_dest="${hooks_dir}/${remove_hook}"
remove_script_dest="${scripts_dir}/${remove_script}"
preset_dest="/usr/share/mkinitcpio/${preset}"

# Check if pcman.d exists
[[ -d $pacman_configd ]] || \
    { echo "Pacman config directory not found ($pacman_configd), are you sure you are using pacman?"; exit 1; }

# Install hook
# If file exists, ask to create backup, else just install
if [[ -e $install_hook_dest ]] && \
    { read -n1 -p "File ${install_hook_dest} exists, make makeup? [Y/n] " bk; echo; [[ $bk =~ ^[yY] ]]; }; then
    install -Dbm644 $install_hook $install_hook_dest
else
    install -Dm644 $install_hook $install_hook_dest
fi

if [[ -e $install_script_dest ]] && \
    { read -n1 -p "File ${install_script_dest} exists, make makeup? [Y/n] " bk; echo; [[ $bk =~ ^[yY] ]]; }; then
    install -Dbm755 $install_hook $install_hook_dest
else
    install -Dm755 $install_script $install_script_dest
fi

# Remove hook
if [[ -e $remove_hook_dest ]] && \
    { read -n1 -p "File ${remove_hook_dest} exists, make makeup? [Y/n] " bk; echo; [[ $bk =~ ^[yY] ]]; }; then
    install -Dbm644 $remove_hook $remove_hook_dest
else
    install -Dm644 $remove_hook $remove_hook_dest
fi

if [[ -e $remove_script_dest ]] && \
    { read -n1 -p "File ${remove_script_dest} exists, make makeup? [Y/n] " bk; echo; [[ $bk =~ ^[yY] ]]; }; then
    install -Dbm755 $remove_script $remove_script_dest
else
    install -Dm755 $remove_script $remove_script_dest
fi

$(install -D -m644 ucode-copy.hook "${hooks_dir}/ucode-copy.hook")
install -D -m755 ucode-copy "${scripts_dir}/ucode-copy"

# Only backup if file original
if grep -q "%INSTALL_PATH%" $preset_dest; then
    install -Dm644 $preset $preset_dest
else
    install -Dbm644 $preset $preset_dest
fi

# Install sdboot-manage
if { read -n1 -p "Do you want to install the custom sdboot-manage? [y/N]" sdboot_install; echo; [[ $sdboot_install =~ ^[yY] ]]; }; then
    if grep -q "CUSTOM" /usr/bin/sdboot-manage; then
        install -Dm755 sdboot-manage /usr/bin/sdboot-manage
    else
        install -Dbm755 sdboot-manage /usr/bin/sdboot-manage
    fi
fi

echo "Hooks and scripts installed successfully!"

if { read -n1 -p "Do you want to reinstall the kernel to the right location and create boot entries? [y/N]" install_kernel; [[ $install_kernel =~ ^[yY] ]]; }; then
    pacman -Syu --noconfirm $(pacman -Qq | grep -E "^linux[0-9]{1,3}")
fi

