#!/bin/bash
# Incremental file-based backup that provides full snapshots with hard links

if [ $# -lt 2 ]
then
	printf "Usage: $0 sourcePath targetPath [sourceDirs...]\n"
	exit 1
fi

# configuration of source and target directories
sourcePath="$1"
targetPath="$2"
sourceDirs=(".")

shift 2
if [ $# -gt 0 ]
then
	sourceDirs=("$@")
fi

# create the directory for the latest backup if not already existing
backupDir="$targetPath/latest"
mkdir -p "$backupDir"

# create a new directory for the current snapshot
snapshotDate=$(date +%F)
# snapshotDate=$(date "+%F %H-%M") # for testing
snapshotDir="$targetPath/$snapshotDate"
mkdir -p "$snapshotDir"
logFile="$snapshotDir/backup.log"

# write stdout and stderr of the given command to a logfile too
log() {
	"$@" |& tee -a "$logFile"
}

# try to line buffer output to see live updates despite the usage of a pipe
# https://stackoverflow.com/questions/42938106/modifying-tee-a-out-txt-to-stream-output-live-rather-than-on-completio
if hash unbuffer 2> /dev/null
then
	log() {
		unbuffer "$@" |& tee -a "$logFile"
	}
elif hash stdbuf 2> /dev/null
then
	log() {
		stdbuf -oL "$@" |& tee -a "$logFile"
	}
fi

# log the given line with a leading timestamp
logtime() {
	log printf "\n[$(date +%T)] $1\n"
}

# only write log header once for each snapshot
if [ ! -f "$logFile" ]
then
	log printf "Backup of '$sourcePath' -- Snapshot from $(date +%x)\n"
fi

# copy files that have been created/updated since the last backup
for dir in "${sourceDirs[@]}"
do
	logtime "Copying new and changed files from '$dir'"
	log cp -avu "$sourcePath/$dir" "$backupDir"
	# -u update files only (do not remove and re-copy files, this destroys the hard links!), without deletion
done

# create the new snapshot using hard links
logtime "Creating snapshot under '$snapshotDir'"
cp -al "$backupDir/." "$snapshotDir"
