#!/usr/bin/env bash
# Baseline hardening for a fresh Ubuntu/Debian VPS. Run as root.
# IMPORTANT: make sure you can log in with an SSH key BEFORE running it,
# because password login is disabled at the end.
set -euo pipefail

apt-get update
apt-get install -y ufw fail2ban unattended-upgrades

# Firewall: only SSH, HTTP and HTTPS
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Brute-force protection for SSH
cat > /etc/fail2ban/jail.local <<'JAIL'
[sshd]
enabled  = true
maxretry = 5
bantime  = 1h
findtime = 10m
JAIL
systemctl enable --now fail2ban
systemctl restart fail2ban

# Automatic security updates
dpkg-reconfigure -f noninteractive unattended-upgrades

# SSH: keys only, no root password login
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
systemctl reload ssh || systemctl reload sshd

echo "Hardening done. Note: Docker publishes ports directly through iptables;"
echo "only publish what you need (this stack publishes 80/443 only)."
