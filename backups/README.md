# Backup scripts

These scripts have been used for me to back up my `$HOME`, and restore from it.

## Usage

```sh
./rsync-backup.sh /path/to/backup/dir
```

```sh
./rsync-restore.sh /path/to/backup/dir
```

> **NOTE:** You may need to restore selinux labels when restoring the backup:

```sh
sudo restorecon -Rv /home/youruser
```