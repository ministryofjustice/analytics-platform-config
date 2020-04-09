# analytics-platform-config
Encrypted configuration, files can be decrypted by following [instructions below](#git-crypt).

## Repository structure

Each environment has its own set of configuration files under the [`/chart-env-config` directory](/chart-env-config), for example the configuration for the `dev` environment is the [`/chart-env-config/dev` directory](/chart-env-config/dev).

Most of these files contain the configuration (helm values) for the corresponding helm release, many of these helm charts are maintained by us (see [`ministryofjustice/analytics-platform-helm-charts` repository](https://github.com/ministryofjustice/analytics-platform-helm-charts)).


## Git-crypt

This repo contains secrets stored with git-crypt. These need decrypting before use. You need to have your GPG key added to this repo before you are able to do this.

### Adding someone's gpg key to this repo

1. Ask the person to export their GPG public key like this:

       gpg --armor --export alice@cyb.org

2. Once you receive the file, save it on your disk e.g. /tmp/alice.asc

3. Import it into your GPG keyring:

       gpg --import /tmp/alice.asc

4. Tell GPG that you trust the key and sign it:

       gpg --edit-key "alice@cyb.org" trust
         # 4
         # save
         # quit
       gpg --edit-key "alice@cyb.org" sign
         # you will need to type your own passphrase
         # save

5. Confirm that '[  full  ]' is shown when you list it:

       gpg --list-keys
       pub   rsa4096 2015-02-05 [SC]
             17818CFB47FFFC384F0CC
       uid           [  full  ] alice  <alice@cyb.org>
       sub   rsa4096 2015-02-05 [E]

5. In this repo, make sure you're on a master branch, with no outstanding changes, and add the key to the .git-crypt directory:

       cd analytics-platform-config
       git status
       git-crypt add-gpg-user alice@cyb.org

6. The change is already committed, so simply:

       git push

### Decrypting the secrets

1. Get your gpg key added to this repo - see above.

2. Install git-crypt. On MacOS:

       brew install git-crypt

3. Get the commit with your gpg key that has been added.

       cd data-science-sandbox-infrastucture
       git pull

4. Decrypt the files

       git-crypt unlock

   If this fails, it might be because your gpg key requires a pass-phrase, but there is a problem with the pinentry-program. Check your gpg-agent daemon. I had to correct `~/.gnupg/gpg-agent.conf` to point to the correct `pinentry` binary, then killed the gpg-agent process and restarted it with: `gpg-agent --daemon /bin/sh`.

### Removing users

To remove access to users you need to:

1. Remove a user's .gpg file
2. Rotate the root key

#### Remove a user's .gpg file (Run this in the master branch)

You need to remove an old user's .gpg file from the repo, not just from master, but all previous commits, including branches. This prevents them from checking out this repo, getting their .gpg file, which they can decrypt to give them the repo's (symmetric) root key, which could decrypt the rest of the repo.

 1. Run `ls -alh .git-crypt/keys/default/0`. Identify any users you want to delete and add the filename as a line in `keys.txt`. 

    Existing users' GPG files:

        4F695620194C67495C8EFD2B9502AA070E5ED9A8.gpg David Read
        DFCB2DBA912C880D4CD9E143036B0A0B32275047.gpg Aldo
        009C7A26AD50D948CD79F3DE53AEAEC09EBAB932.gpg Dhiraj
        4A1EBAEBC0D7B1EB73C19D617D038E3B8AD145D9.gpg Andy L
        3882536CDAF2F100F615C48F57E38D4C4897ED56.gpg analytics-platform-tech@digital.justice.gov.uk 
        89C83075908E8B349B0D26A90C16E8A4D0440FB4.gpg Robin

 2. Make sure you're on the `master` branch. Run `remove-gpg-users.sh` to delete the keys for a list of users. Make sure bfg is installed on your machine `brew install bfg`. This will remove the keys from all branches, folders commits.
 3. Check that the commits have been removed by running e.g: 

       `git log -- .git-crypt/keys/default/0/0BC40E3E6462918D96DD1A68D5A4BCE161AC7DC8.gpg` to see the commits have been removed for old users

       `git log -- .git-crypt/keys/default/0/4F695620194C67495C8EFD2B9502AA070E5ED9A8.gpg` to see the commits are still there for current users 


#### Rotate the root key

Having deleted old users in the previous section, you can now create a fresh root key. The "root key" is the symmetric encryption key that the encrypted files in this repo are encrypted with. The script will create the .gpg files for each user, which is the root key encrypted with a user's public key.

1. Ensure you have all the current users' public GPG keys on your personal GPG keyring. If you don't you'll get an error adding them in a moment. The fingerprints of the GPG keys that you need are listed in the filenames:

       $ ls .git-crypt/keys/default/0/
   
   The keys you have on your GPG keyring are listed:

       $ gpg --list-keys
       
   To add someone, you need to ask them for their public GPG key (they are not stored in this repo) and then see the above section "Adding someone's gpg key to this repo".
   
2. Create a branch for this change.
3. Rotate the root key by running `rotate-gpg-keys.sh`. The script will create a temp directory in `/tmp/`, re-initialise .git-crypt with the new root key, re-encrypt the files with the new master key and refresh the user .gpg files with the new root key.
4. These changes will be commited back to the original repostory. So just run `git push` to your new branch and create a PR as normal. Every encrypted file is touched.
