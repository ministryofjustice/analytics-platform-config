#!/usr/bin/env sh

set -ex

KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    GPG_KEY=".git-crypt/keys/default/0/$key"

    # Delete the .gpg key 
    if [[ -f $GPG_KEY ]]; then
        rm $GPG_KEY
        git add .
        git commit -m "Remove $key"
    fi

    # Remove git history for this specific file path to prevent users accessing their old key
    git filter-branch -f --index-filter "git rm --cached --ignore-unmatch $GPG_KEY" HEAD 

done <$KEY_FILE 
