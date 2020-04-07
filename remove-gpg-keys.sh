#!/usr/bin/env sh

set -ex

GPG_KEY=".git-crypt/keys/default/0/$key"
KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    # Delete the .gpg key 
    if [[ -f $GPG_KEY ]]; then
        rm $GPG_KEY
    fi

done <$KEY_FILE 

git add .
git commit -m "Remove gpg keys"

KEY_FILE=$PWD/keys.txt
while IFS= read -r key; do

    # Remove git history for this specific file path to prevent users accessing their old key
    git filter-branch -f --index-filter "git rm --cached --ignore-unmatch $GPG_KEY" HEAD 

done <$KEY_FILE 

    


