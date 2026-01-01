#!/bin/sh

# We exclude:
# - .cache/ , because we don't care about cache
# - */cache/ , anything from Flatpaks that need a cache aren't needed
# - */Cache/ , anything from Flatpaks that need a cache aren't needed
# - */CacheStorage/ , cache from chrome
# - .cargo/registry/ , we don't need this, it'll be rebuilt
# - .local/share/Trash/ , it's in there for a reason
# - .local/share/containers/ , we will rebuild containers later
    # --dry-run \
    # --progress \

sudo rsync \
    -aAXH --numeric-ids \
    --stats \
    --info=progress2 \
    --exclude='**/.cache/**' \
    --exclude='**/cache/**' \
    --exclude='**/Cache/**' \
    --exclude='**/CacheStorage/**' \
    --exclude='.cargo/registry/**' \
    --exclude='.local/share/Trash/**' \
    --exclude='.local/share/containers/**' \
    "$HOME/" /run/media/rbrue/d_drive/backup-1-1/