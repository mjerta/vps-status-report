#!/usr/bin/env bash
# Telegram Bot Status Report Script

# Show help and exit if -h or --help is passed
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat << EOF
Usage: $(basename "$0") [options]

Sends a system status report to a Telegram chat via bot.

Options:
  -h, --help      Show this help message and exit

Environment variables required:
  TELEGRAM_TOKEN    Your Telegram bot token
  TELEGRAM_CHAT_ID  The chat ID to send the message to

What the script reports:
  - Hostname
  - System uptime
  - Load average
  - Disk usage of /
  - Memory usage

Example:
  TELEGRAM_TOKEN=xxx TELEGRAM_CHAT_ID=yyy $(basename "$0")

EOF
  exit 0
fi

HOSTNAME=$(hostname)

# Function to send a message to Telegram
send_report() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
       -d chat_id="${TELEGRAM_CHAT_ID}" \
       -d text="$message" \
       -d parse_mode="Markdown"
}

# Gather system info
UPTIME=$(uptime -p)
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
DISK=$(df -h / | awk 'NR==2 {print $5 " used"}')
MEMORY=$(free -m | awk '/Mem:/ { printf("%sMB used / %sMB total (%.0f%%)", $3, $2, $3/$2*100) }')

# Create report with emojis
REPORT="*📊 Telegram Bot Report*
🏷️ Host: \`$HOSTNAME\`
⏳ Uptime: $UPTIME
⚙️ Load Average: $LOAD
💾 Disk Usage: $DISK
🧠 Memory Usage: $MEMORY"

# Send the report
send_report "$REPORT"
