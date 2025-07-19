#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Vorrac
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/caronc/apprise

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  git \
  python3-pip
msg_ok "Installed Dependencies"

# Setup App
msg_info "Setup ${APPLICATION}"
RELEASE=$(curl -fsSL https://api.github.com/repos/caronc/apprise/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
curl -fsSL -o "${RELEASE}.zip" "https://github.com/caronc/apprise/archive/refs/tags/${RELEASE}.zip"
unzip -q "${RELEASE}.zip"
mv "${APPLICATION}-${RELEASE}/" "/opt/${APPLICATION}"
#
#
#
echo "${RELEASE}" >/opt/"${APPLICATION}"_version.txt
msg_ok "Setup ${APPLICATION}"

# Creating Service (if needed)
msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/"${APPLICATION}".service
[Unit]
Description=${APPLICATION} Service
After=network.target

[Service]
ExecStart=[START_COMMAND]
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now "${APPLICATION}"
msg_ok "Created Service"

motd_ssh
customize

# Cleanup
msg_info "Cleaning up"
rm -f "${RELEASE}".zip
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
