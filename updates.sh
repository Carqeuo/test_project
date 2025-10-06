#!/bin/bash
# Installatie-script voor automatische updates via cron

SCRIPT_PATH="/usr/local/bin/auto-update.sh"
CRON_JOB="0 3 * * * $SCRIPT_PATH"
CRON_MARKER="# AUTO-UPDATE-SCRIPT"

# Check of script als root draait
if [ "$(id -u)" -ne 0 ]; then
    echo "Dit script moet als root draaien. Gebruik:"
    echo "sudo $0"
    exit 1
fi

echo "Schrijf auto-update.sh naar $SCRIPT_PATH"

# --- auto-update.sh wordt hier direct weggeschreven ---
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash
LOGFILE="/var/log/auto-update.log"

echo "===== $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOGFILE"

apt-get update -y >> "$LOGFILE" 2>&1
apt-get upgrade -y >> "$LOGFILE" 2>&1
apt-get autoremove -y >> "$LOGFILE" 2>&1
apt-get autoclean -y >> "$LOGFILE" 2>&1

echo "Updates voltooid." >> "$LOGFILE"
echo "" >> "$LOGFILE"
EOF

chmod +x "$SCRIPT_PATH"

# --- Cronjob toevoegen (vervangt oude marker als die er al was) ---
( crontab -l 2>/dev/null | grep -v "$CRON_MARKER" ; echo "$CRON_MARKER"; echo "$CRON_JOB" ) | crontab -

echo "✅ Automatisch update-script geïnstalleerd!"
echo "ℹ️  Updates draaien nu elke dag om 03:00 uur."
echo "📜 Log: /var/log/auto-update.log"