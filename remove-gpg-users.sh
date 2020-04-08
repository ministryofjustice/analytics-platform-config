#!/usr/bin/env sh

set -ex

KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    GPG_KEY=".git-crypt/keys/default/0/$key"

    # Delete the .gpg key 
    if [[ -f $GPG_KEY ]]; then
        rm $GPG_KEY
    fi
    
done <$KEY_FILE 

git add .
git commit -m "Remove gpg keys"

