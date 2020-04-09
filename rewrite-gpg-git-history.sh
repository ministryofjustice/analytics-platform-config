#!/usr/bin/env sh

set -ex

KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    # Remove git history for this specific file path to prevent users accessing old keys
    git filter-branch --force --index-filter "git rm --cached --ignore-unmatch .git-crypt/keys/default/0/$key" \
    --prune-empty --tag-name-filter cat -- --all

    git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin

    git reflog expire --expire=now --all

    git gc --prune=now

    git push origin --force --all
    git push origin --force --tags

done <$KEY_FILE 
