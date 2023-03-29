# backup

Collection of bash scripts that can be used to create unencrypted backups which are easy to browse and restore without dedicated backup software

## Features

- **File-based**: Backups consist of plain file copies which can be restored by any software
- **Full Snapshots**: Each run creates a complete directory tree which includes all current files
- **Incremental**: Unchanged files will not be copied again
- **[Hard Links](https://en.wikipedia.org/wiki/Hard_link)**: No duplicates of unchanged files, snapshots share the same files on disk

## Usage

Create a snapshot of your full home directory (`~`) in the `backup` folder of the current directory (using [`rsync`](https://en.wikipedia.org/wiki/Rsync) under the hood):

```sh
./backup-rsync-inc-snapshot-hardlink.sh ~ ./backup
```

Alternatively you can include only the `~/Documents` and the `~/Pictures` folder:

```sh
./backup-rsync-inc-snapshot-hardlink.sh ~ ./backup Documents Pictures
```

## Directory Structure

Using the last command above might result in the following backup structure (example):

```
backup/
├── 2022-12-31/
│   ├── Documents/
│   │   └── example.txt
│   ├── Pictures/
│   │   └── christmas-2022.jpg
│   └── backup.log
├── 2023-01-07/
│   ├── Documents/
│   │   └── example.txt
│   ├── Pictures/
│   │   ├── christmas-2022.jpg
│   │   └── new-year-2023.jpg
│   └── backup.log
└── latest/
    ├── Documents/
    │   └── example.txt
    └── Pictures/
        ├── christmas-2022.jpg
        └── new-year-2023.jpg
```

Each snapshot folder is named after the date of the backup and contains an additional log file which documents the changes since the previous snapshot.

The contents of the `latest` folder are identical to the latest snapshot (here: `2023-01-07`), which means that they are all hard-linked to the same set of files.

Since the `christmas-2022.jpg` picture probably has not changed since 2022, the latest snapshots of it will still point to the same file.

Assuming that `example.txt` has been changed between the two snapshots, `2022-12-31` will still be linked to the old version, while the newer snapshots will link to the updated version.

**Attention**: Never edit files inside one of the snapshots (unless you clearly know what you are doing)!
Touching a file in one of the snapshots also affects all other snapshots which are hard-linked to the same file, which is usually not what you want.

## Other Scripts

If you want to backup multiple shares from an **SMB server** you can have a look at [`backup-smb-shares.sh`](backup-smb-shares.sh):

- Pre-configured (example) paths and SMB user (please modify these to match your setup)
- Asks for the SMB user's password
- Mounts all required SMB shares before performing the backup
- Unmounts all previously mounted SMB shares after the backup has finished

Additionally, there is also an [**older version**](backup-cp-inc-snapshot-hardlink.sh) of the script which uses `cp` instead of `rsync`.
The main difference is that it will not delete files from the latest snapshot which have been deleted in the source.
