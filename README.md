# analytics-platform-config

All Kubernetes resources are managed as Helm charts, the Kubernetes package manager. Analytics-specific charts are served via our Helm repository - source code is in the ministryofjustice/analytics-platform-helm-charts repository, and chart values for each environment are stored in this reposirory


Encrypted configuration. Files can be decrypted by following [Git-crypt instructions below](#git-crypt).

## Repository structure

Each environment has its own set of configuration files under the [`/chart-env-config` directory](/chart-env-config), for example the configuration for the `dev` environment is the [`/chart-env-config/dev` directory](/chart-env-config/dev).

Most of these files contain the configuration (helm values) for the corresponding helm release, many of these helm charts are maintained by us (see [`ministryofjustice/analytics-platform-helm-charts` repository](https://github.com/ministryofjustice/analytics-platform-helm-charts)).


## Usage 

**NOTE** helm is run from your workstation. There is no CI/CD for this repo. 

### Install helm2 

- Install helm v2 as per (Install Helm3 & Helm2 on macOS)[https://joachim8675309.medium.com/install-helm3-helm2-on-macos-d65f61509799]

### Install and configure kubectl

- need kubectl installed and configured and working on your workstation. if the alpha cluster alpha.mojanalytics.xyz is config in a file called say alpha specify:
```
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/alpha
kubectl config use-context alpha.mojanalytics.xyz
```

### Modify chart config 

- cd to chart-env-config/alpha and modify the appropriate yaml file. For eample filebeat-node.yml

### Run helm

- setup and dry run helm2 to upgrade chart. For example the filebeats chart:
```
helm2 init --upgrade
helm2 repo add elastic https://helm.elastic.co
helm2 upgrade --debug filebeats-node elastic/filebeat --version 7.10.0 -f ./filebeat-node.yaml --namespace kube-system --install --dry-run
```

-finally run 
```
helm2 upgrade --debug filebeats-node elastic/filebeat --version 7.10.0 -f ./filebeat-node.yaml --namespace kube-system --install --dry-run
```

## Git-crypt

This repo contains secrets stored with git-crypt. These need decrypting before use. You need to have your GPG key added to this repo before you are able to do this.

See [git-crypt for Analytical Platform](https://github.com/ministryofjustice/analytics-platform-ops/tree/master/git-crypt) for usage instructions.

**NB Specifically for this repo**: when you rotate the root key you must also [Supply Concourse with the new key](#supply-concourse-with-the-new-key). This crops up when you remove a user.

### Supply Concourse with the new key

Concourse needs access to this config, and rotating the root key will have locked it out until you supply the new one.

1. Get the hash of the new key:

    base64 < .git/git-crypt/keys/default

2. Replace the value in 4 places in this repo (search for `gitcrypt` & `gitCrypt`)
3. Re-deploy charts: [concourse-org-pipeline](https://github.com/ministryofjustice/analytics-platform-helm-charts/tree/master/charts/concourse-org-pipeline) & [concourse-admin-team](https://github.com/ministryofjustice/analytics-platform-helm-charts/tree/master/charts/concourse-admin-team). Example commands:

       # dev initially
       ENV=dev
       export KUBECONFIG=~/.kube/$ENV.mojanalytics.xyz-oidc  # or however you switch to the dev cluster
       cd ~/ap  # or wherever your repos are checked out

       helm upgrade --install org-pipeline-moj-analytical-services mojanalytics/concourse-org-pipeline --values    analytics-platform-config/chart-env-config/$ENV/concourse-org-pipeline.yaml
       helm history org-pipeline-moj-analytical-services  # check it looks right

       helm upgrade --install concourse-admin-team mojanalytics/concourse-admin-team  --values analytics-platform-config/   chart-env-config/$ENV/concourse-admin-team.yaml
       helm history concourse-admin-team  # check it looks right

       # Now repeat the above, but with ENV=alpha

       # Monitor the next few builds:
       # (See https://github.com/ministryofjustice/analytics-platform/wiki/Concourse#fly-tool )
       fly -t mojap-alpha builds -c 5

       # Run a test build, e.g. https://concourse.services.alpha.mojanalytics.xyz/teams/main/pipelines/kpi-s3-proxy
