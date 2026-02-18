#!/usr/bin/env bash
# System report data collector for Claude sysreport skill.
# Outputs structured sections that Claude summarizes into a readable report.

set -euo pipefail

section() { printf '\n=== %s ===\n' "$1"; }

# --- Hardware & OS ---
section "HARDWARE & OS"
echo "Hostname: $(hostname)"
uname -r
lscpu | grep -E 'Model name|CPU\(s\):|Core|Thread|Socket'
cat /etc/os-release 2>/dev/null | grep -E '^(NAME|VERSION)=' || true

# --- Uptime & Load ---
section "UPTIME & LOAD"
uptime

# --- Memory ---
section "MEMORY"
free -h

# --- Disk ---
section "DISK"
df -h / /home 2>/dev/null | sort -u

# --- Block devices ---
section "BLOCK DEVICES"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT 2>/dev/null

# --- Temperatures ---
section "TEMPERATURES"
sensors 2>/dev/null || echo "(sensors not available)"

# --- Network ---
section "NETWORK"
ip -br addr 2>/dev/null | head -10

# --- Top processes by memory ---
section "TOP PROCESSES (by memory)"
ps aux --sort=-%mem | head -11

# --- Top processes by CPU ---
section "TOP PROCESSES (by CPU)"
ps aux --sort=-%cpu | head -11

# --- Docker ---
section "DOCKER"
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
else
  echo "(docker not running or not installed)"
fi

# --- Listening ports ---
section "LISTENING PORTS"
ss -tlnp 2>/dev/null | head -20

# --- Systemd user services ---
section "SYSTEMD USER SERVICES"
systemctl --user list-units --state=running --type=service --no-pager 2>/dev/null | head -25

# --- Recent errors ---
section "RECENT ERRORS (last 2h)"
journalctl --user -p err --since "2 hours ago" --no-pager 2>/dev/null | tail -20 || echo "(no entries)"
journalctl --system -p err --since "2 hours ago" --no-pager 2>/dev/null | tail -10 || echo "(no system entries)"

# --- GPU (if available) ---
section "GPU"
if command -v nvidia-smi &>/dev/null; then
  nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null
elif command -v glxinfo &>/dev/null; then
  glxinfo 2>/dev/null | grep -E 'OpenGL renderer|OpenGL version' || echo "(no GPU info)"
else
  lspci 2>/dev/null | grep -i vga || echo "(no GPU info)"
fi
