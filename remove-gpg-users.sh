#!/usr/bin/env sh

set -ex

KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    # Delete the .gpg key in the entire git repository including all branches and all folders
    bfg --delete-files $key ../analytics-platform-config.git
    
done <$KEY_FILE 

git add .
git commit -m "Remove gpg keys"
git push

