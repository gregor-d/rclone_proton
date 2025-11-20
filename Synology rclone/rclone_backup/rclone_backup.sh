#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONFIG_FILE="$SCRIPT_DIR/config"

# Load config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file missing: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Ensure log file exists
LOGDIR=$(dirname "$LOGFILE")
mkdir -p "$LOGDIR"
touch "$LOGFILE"

# Flags
[ -n "$BWLIMIT" ] && BWLIMIT="--bwlimit=$BWLIMIT"
[ "$VERBOSE" = true ] && VERBOSE_FLAG="-v"
[ "$DRY_RUN" = true ] && DRY_RUN_FLAG="--dry-run"
[ -t 0 ] && PROGRESS_FLAG="--progress"

ART="========"
echo "$ART Backup started at $(date '+%d.%m.%Y %T') $ART" | tee -a "$LOGFILE"

# Build command
RCLONE_CMD="rclone copy \"$REMOTEDIR\" \"$LOCALDIR\" \
    --log-level=$LOGLEVEL \
    --log-file=\"$LOGFILE\" \
    --transfers=$TRANSFER_LIMIT \
    --checkers=$CHECKERS \
    --retries=$RETRIES \
    --retries-sleep=${RETRY_DELAY}s \
    $BWLIMIT $CUSTOM_FLAGS $VERBOSE_FLAG $DRY_RUN_FLAG $PROGRESS_FLAG"

echo "Running: $RCLONE_CMD" | tee -a "$LOGFILE"

eval $RCLONE_CMD
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "Backup ERROR (code $STATUS). Check log." | tee -a "$LOGFILE"
else
    echo "Backup SUCCESS." | tee -a "$LOGFILE"
fi

echo "$ART Backup finished at $(date '+%d.%m.%Y %T') $ART" | tee -a "$LOGFILE"
