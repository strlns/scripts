#!/usr/bin/env sh

# Set up a script-local alias for keepassxc-cli
alias keepassxc-cli='/Applications/KeePassXC.app/Contents/MacOS/keepassxc-cli'

cd /Users/moritz || {
  echo 'Could not enter home directory.'
  exit 1;
}

# Set up a script-local alias for this, we might call it repeatedly.
alias confirm=/Users/moritz/scripts/confirm.sh

confirm 'Start backup?' || exit

confirm 'Also sync keepass databases?' && KEE=1

#.aliases and .zshrc live in my home directory,
#but is copied into scripts directory for backup purposes.
#It is obligatory to mention that .zshrc MUST NOT contain any personal information such as credentials.
cp .aliases .zshrc scripts

# Sync some GDrive and iCloud documents, also backup scripts there
#
# Please note that the cvs-exclude option only ignore .git in newer versions, as of March 2023 this
# requires to install rsync via homebrew. 
rsync -autzvh --cvs-exclude /Users/moritz/Google\ Drive/Meine\ Ablage/Dokumente/ /Users/moritz/Documents/Persönlich/
rsync -autzvh --cvs-exclude /Users/moritz/Documents/Persönlich/ /Users/moritz/Google\ Drive/Meine\ Ablage/Dokumente/
rsync -autzvh --cvs-exclude /Users/moritz/scripts/ /Users/moritz/Documents/scripts/
rsync -autzvh --cvs-exclude /Users/moritz/scripts/ /Users/moritz/Google\ Drive/Meine\ Ablage/scripts/

if [ "$KEE" = 1 ]; then {
    #Synchronize and update KeePass DBs between iCloud and GDrive
    cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/ || { echo 'Could not change to iCloud drive directory.'; exit 1; }
    cp MoritzDB.kdbx MoritzDB-"$(date +%F)".kdbx && \
    echo "Backuped KeePass DB. Now merging Google Drive and iCloud"
    keepassxc-cli merge -s /Users/moritz/Google\ Drive/Meine\ Ablage/MoritzDB.kdbx MoritzDB.kdbx 
    keepassxc-cli merge -s MoritzDB.kdbx /Users/moritz/Google\ Drive/Meine\ Ablage/MoritzDB.kdbx
}
fi


if [ -f /Volumes/USB-Stick/MoritzDB.kdbx ]; then {
        echo "Found file /Volumes/USB-Stick/MoritzDB.kdbx'. 
Copying current DB to flash stick. A backup of the original file will be preserved on the flash drive.
Please check manually to clean up."
        cd /Volumes/USB-Stick || return;
        cp MoritzDB.kdbx MoritzDB-"$(date +%F)".kdbx && \
        cp /Users/moritz/Google\ Drive/Meine\ Ablage/MoritzDB.kdbx .
    }
fi

if [ -f /Volumes/FRITZ.NAS/Elements/MoritzDB.kdbx ]; then {
        echo "Found file /Volumes/FRITZ.NAS/Elements/MoritzDB.kdbx'. 
Copying current DB to flash stick. A backup of the original file will be preserved on the flash drive.
Please check manually to clean up."
        cd /Volumes/FRITZ.NAS/Elemenets || return;
        cp MoritzDB.kdbx MoritzDB-"$(date +%F)".kdbx && \
        cp /Users/moritz/Google\ Drive/Meine\ Ablage/MoritzDB.kdbx .
    }
fi

cd /Users/moritz/scripts || exit 1;
./forcepusher.sh 'My scripts';
