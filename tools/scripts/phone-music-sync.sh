#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
NAS_MUSIC_PATH="/mnt/music_stack"
PHONE_MOUNT_POINT="$HOME/Phone"
PHONE_MUSIC_PATH="${PHONE_MOUNT_POINT}/disk/Music"
LOG_FILE="$HOME/.local/log/phone-music-sync.log"
MOUNT_WAIT_SECONDS=5

# --- Helpers ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

die() {
    log "ERROR: $*"
    exit 1
}

run_rsync() {
    rsync -av \
        --no-perms --no-owner --no-group \
        --ignore-existing \
        --ignore-errors \
        --partial \
        --info=name,stats2 \
        "${NAS_MUSIC_PATH}/" \
        "${PHONE_MUSIC_PATH}/" \
        2>&1 | tee -a "$LOG_FILE"
    return "${PIPESTATUS[0]}"
}

# --- Preflight checks ---
mkdir -p "$(dirname "$LOG_FILE")"

mountpoint -q "$NAS_MUSIC_PATH" \
    || die "NAS music path '$NAS_MUSIC_PATH' is not mounted"

if ! mountpoint -q "$PHONE_MOUNT_POINT"; then
    log "Phone not mounted, attempting to mount via MTP..."
    fusermount -uz "$PHONE_MOUNT_POINT" 2>/dev/null || true
    mkdir -p "$PHONE_MOUNT_POINT"
    jmtpfs "$PHONE_MOUNT_POINT" 2>&1 | tee -a "$LOG_FILE" \
        || die "jmtpfs failed — is the phone connected, unlocked, and in file transfer mode?"
    sleep "$MOUNT_WAIT_SECONDS"
    mountpoint -q "$PHONE_MOUNT_POINT" \
        || die "Mount appeared to succeed but '$PHONE_MOUNT_POINT' is still not a mountpoint"
fi

# --- Sync ---
log "Starting music sync"
log "  Source : $NAS_MUSIC_PATH"
log "  Dest   : $PHONE_MUSIC_PATH"

MAX_RETRIES=5
RETRY=0

until run_rsync; do
    RSYNC_EXIT=$?
    if [ "$RSYNC_EXIT" -eq 23 ]; then
        log "rsync partial transfer (exit 23): files with FAT-incompatible names will be handled by sanitized copy phase"
        break
    fi
    RETRY=$((RETRY + 1))
    if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
        die "rsync failed after $MAX_RETRIES attempts (exit code: $RSYNC_EXIT)"
    fi
    log "rsync failed (exit code: $RSYNC_EXIT), retry $RETRY of $MAX_RETRIES in 10 seconds..."
    sleep 10
done

# --- Sanitized copy ---
# FAT/exFAT rejects : ? < > * | " \ in filenames. Files whose paths contain these
# characters are skipped by rsync above; we copy them here with the illegal chars removed.
log "Starting sanitized copy phase..."
SANITIZED_COPIED=0
SANITIZED_SKIPPED=0

while IFS= read -r -d '' src_file; do
    rel_path="${src_file#${NAS_MUSIC_PATH}/}"
    sanitized_rel=$(printf '%s' "$rel_path" | sed 's/[:<>?*|"\\]//g')

    [ "$sanitized_rel" = "$rel_path" ] && continue

    dst_file="${PHONE_MUSIC_PATH}/${sanitized_rel}"

    if [ -f "$dst_file" ]; then
        SANITIZED_SKIPPED=$((SANITIZED_SKIPPED + 1))
        continue
    fi

    dst_dir="${dst_file%/*}"
    mkdir -p "$dst_dir" 2>&1 | tee -a "$LOG_FILE" || {
        log "WARNING: could not create '$dst_dir', skipping"
        continue
    }

    log "  sanitized: $rel_path"
    if cp "$src_file" "$dst_file" 2>&1 | tee -a "$LOG_FILE"; then
        SANITIZED_COPIED=$((SANITIZED_COPIED + 1))
    else
        log "WARNING: failed to copy '$rel_path'"
    fi
done < <(find "$NAS_MUSIC_PATH" -type f -print0)

log "Sanitized copy: $SANITIZED_COPIED copied, $SANITIZED_SKIPPED already present"
log "Sync complete"

