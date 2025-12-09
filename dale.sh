#!/bin/sh
set -e

echo "Minimal Sway setup for Alpine. Press RETURN."
read _

# Enable community repo
sed -i '/community/s/^#//g' /etc/apk/repositories

apk update
apk upgrade

# Minimal packages
apk add alpine-base sway swaylock foot eudev udev-init-scripts dbus dbus-openrc

# Detect user with UID 1000
SUSER=$(awk -F: '$3==1000{print $1}' /etc/passwd)
[ -z "$SUSER" ] && exit 1

# Services
setup-devd udev
rc-update add dbus

# XDG_RUNTIME_DIR para sway
cat << EOF > /home/${SUSER}/.profile
if [ -z "\$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR="/tmp/\$(id -u)-runtime"
  mkdir -pm 0700 "\$XDG_RUNTIME_DIR"
fi
export TERMINAL=foot

# Start sway on login
[ -z "\$DISPLAY" ] && exec sway
EOF
chown "$SUSER":"$SUSER" /home/${SUSER}/.profile

# Copy default sway config
mkdir -p /home/${SUSER}/.config/sway
cp /etc/sway/config /home/${SUSER}/.config/sway/
chown -R "$SUSER":"$SUSER" /home/${SUSER}/.config/sway

echo "Setup done. Log in as $SUSER to start Sway."
