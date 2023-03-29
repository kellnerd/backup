#!/bin/bash

printf "Working directory: "
pwd

# configure your SMB server and the shares you want to backup below
remote="//synology-ds115"
shares=("video" "music" "audio" "web")
user="backup"
mountPath="/mnt/synology-ds115"

printf "Password for $user@$remote: "
read -s password
echo

# source and target directories
sourcePath="$mountPath"
targetPath="."

# mount all required SMB shares
for share in "${shares[@]}"
do
	echo "Mounting '$remote/$share' under '$mountPath/$share'"
	PASSWD="$password" sudo -E mount.cifs "$remote/$share" "$mountPath/$share" -o "user=$user"
done

# perform an incremental backup for all shares
./backup-rsync-inc-snapshot-hardlink.sh "$sourcePath" "$targetPath" "${shares[@]}"

# unmount all previously mounted SMB shares
for share in "${shares[@]}"
do
	echo "Unmounting '$mountPath/$share'"
	sudo umount "$mountPath/$share"
done

read -p "Finished! Press enter to continue..."
