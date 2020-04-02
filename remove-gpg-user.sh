#!/bin/bash

# Unlock the directory, we need the unencrypted versions of the files
git crypt unlock

# Re-initialize git crypt, generating a new key
rm .git/git-crypt/keys/default
git crypt init

# Make the key available to the current users
KEY_FILES=`ls .git-crypt/keys/default/0/`
for f in $KEY_FILES; do
  basename=`basename $f`
  key=${basename%.*}
  if [[ $key == $1 ]]; then
      continue;
  fi
  git crypt add-gpg-user $key
done

# Re-encrypt the files with the new key
ENCRYPTED_FILES=`git crypt status -e | colrm 1 14`
git rm --cached $ENCRYPTED_FILES
git add $ENCRYPTED_FILES