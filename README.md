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

### Rotating the master key 

# removed
0BC40E3E6462918D96DD1A68D5A4BCE161AC7DC8.gpg Olivier
0EA8A07F3B7A2DEFFC6A0C15A676D53809D8E9E5.gpg Josh
3F4B80740A8B8F16846B1DB38BE0D7BE38C373EA.gpg Clive
5910F958D8BBCE091D21352E7C54063FD401BB0A.gpg Mikael
7A9BA8145FCA0BB3675EE374D6D0FEAADC33449C.gpg Shojul
95D1D9337CFC1C0EB1EEE9FE78A7CD623E5F95BB.gpg Shojul
B27CE54542E4BA0FD145A430BD12FA5814004DB8.gpg James
F8E491B447659C8CA11C09A8A48B120FE8C81295.gpg  Ravi
7F6D3B095238754680D42F49886C4C04BB346D41.gpg Kerin
2FCDF694D890566F24FDCE07A1FCACE175E38C1C.gpg Dan
33656F68E1EE5B733EDCCD73F7F7899AA435E44F.gpg Lukasz
DFCB2DBA912C880D4CD9E143036B0A0B32275047.gpg Aldo
F1E9B0177F6709B5E230257D4EBF0E610D34C21C.gpg Andy D
0DBC860725A8932D1F13F587B1969E2CC64DAF89.gpg Dhiraj
E3504125F0B6B5195F55C341510F6A3C7EFBFE1D.gpg David

# added
B128BECB7499BC74D8E7E46B197EA2F3FAD89850.gpg analytics-platform-tech@digital.justice.gov.uk
21070F2CABCC1398159554E3F8379AB175E3131C David

# same public key
009C7A26AD50D948CD79F3DE53AEAEC09EBAB932.gpg Dhiraj
4A1EBAEBC0D7B1EB73C19D617D038E3B8AD145D9.gpg Andy L
3882536CDAF2F100F615C48F57E38D4C4897ED56.gpg analytics-platform-tech@digital.justice.gov.uk
89C83075908E8B349B0D26A90C16E8A4D0440FB4.gpg Robin
