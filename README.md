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
