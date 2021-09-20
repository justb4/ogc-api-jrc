---
title: Setup
---

# Setup

Describes how this instance  has been
setup from the [Geonovum OGC API Testbed platform](https://github.com/Geonovum/ogc-api-testbed) GitHub Template.
Below all steps are documented. 

## 1. Ubuntu Server

Info:

* JRC acquired a Linux Ubuntu server Virtual Machine (VM), with Ubuntu 21.4 
* Specs: 4CPU, 16RAM, 100GB
* IP address `135.125.219.254`

Prepare server steps:

* DNS: create A-record `jrc.map5.nl` for IP address `135.125.219.254`
* local user with full sudo rights e.g. `sudo su -`
* Upgrade server to latest: `apt-get update && apt-get -y upgrade`
* uninstall Docker (will be reinstalled later in bootstrap)
* provide local user direct SSH root access via `authorized_keys` (needed for Ansible)

## 2. Generate GitHub Repo

Create a GitHub repository from the Template 
repo [github.com/Geonovum/ogc-api-sandbox](https://github.com/Geonovum/ogc-api-sandbox).

Creating a repository from a Template is similar to forking a repository, but there are important differences:

* A new fork includes the entire commit history of the parent repository, while a repository created from a template starts with a single commit.
* Commits to a fork don't appear in your contributions graph, while commits to a repository created from a template do appear in your contribution graph.
* A fork can be a temporary way to contribute code to an existing project, while creating a repository from a template starts a new project quickly.

Steps (see also [here](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/creating-a-repository-from-a-template):

* login on GitHub
* go to [github.com/Geonovum/ogc-api-testbed](https://github.com/Geonovum/ogc-api-testbed)
* above file list press green button "Use this template"
* follow the steps indicated, if you want to serve docs on a separate domain indicate "Include all branches"
* the newly created repo here is: https://github.com/justb4/ogc-api-jrc

## 3. Prepare Local System

On your local system you mainly need to have `Ansible` and `Git` (client) installed:

### Install Ansible:

* have Python 3 (3.7 or better) installed
* OPTIONAL (but recommended) create a Python Virtualenv (for Ansible)  
* install [Ansible](https://www.ansible.com/) with `pip install ansible` 2.9.* or higher
* test: `ansible --version` - shows *ansible 2.9.19 ...*
* test: `ansible-vault --version` shows *ansible-vault 2.9.19 ...*
 
More on Ansible below.

### Install `Git` client.
 
Depends on your system. Make sure you have a command line `git` (CLI).

## 4. Prepare New GitHub Repo

Clone the Git repo locally: `git clone https://github.com/justb4/ogc-api-jrc.git`

We will call the root dir of the cloned git repo on your system just `git/` from here.

## 5. Setup Ansible

Most of the configuration that is specific to your new server 
is stored under:

* `git/ansible/hosts` (Ansible inventories)
* `git/ansible/vars` (variables and SSH keys). 

Files under `git/ansible/vars` need to be always encrypted with `Ansible Vault`. You will need to 
create your own (encrypted) version of these encrypted files. 
For many files an example file is given. 

### Install Ansible Modules

Called "Roles" these are third-party Ansible components that help with specific tasks.
Install these as follows:

```
cd git/ansible
ansible-galaxy install --roles-path ./roles -r requirements.yml
```

### Ansible Hosts
The hostname is crucial to services functioning. Two steps:

* set content of `git/ansible/hosts/prod.yml` (Inventory) to

```
ogcapi:
  hosts:
    apisandbox:
       ansible_port: 22
       ansible_host: jrc.map5.nl
       ansible_user: root

```

* set content of `git/services/env.sh` (common environment Docker-based services) to:

```
#!/bin/bash
# Sets global env vars based on host-name
# Needed for various host-dependent configs, especiallly Traefik SSL-certs.

# Export and Defaults

# Assume a local deployment
export DEPLOY_ENV="local"
export TRAEFIK_DOMAIN="localhost"
export TRAEFIK_SSL_ENDPOINT=
export TRAEFIK_SSL_DOMAIN="jrc.map5.nl"
export TRAEFIK_SSL_CERT_RESOLVER=
export TRAEFIK_USE_TLS="false"
export HOST_UID=$(id -u)
export HOST_GID=$(id -g)
export HOST_UID_GID="${HOST_UID}:${HOST_GID}"

# Set host-dependent vars
case "${HOSTNAME}" in
    "OGCAPIJRC")
        DEPLOY_ENV="prod"
        ;;
    "jrc.map5.nl")
        DEPLOY_ENV="prod"
        ;;
    *)
        echo "Default Local Host ${HOSTNAME}"
esac

if [[ ${DEPLOY_ENV} = "prod" ]]
then
	source /etc/environment
    TRAEFIK_SSL_ENDPOINT="https"
    TRAEFIK_SSL_CERT_RESOLVER="le"
    TRAEFIK_USE_TLS="true"
    TRAEFIK_DOMAIN="${TRAEFIK_SSL_DOMAIN}"
fi

```
 
So `DEPLOY_ENV=prod` here is to discern with a deployment on `localhost` (`DEPLOY_ENV=local`, where .e.g. no https/SSL is used).

### Create SSH Keys

These are used to invoke actions on the server both from GitHub Actions (via GitHub Sercrets) 
and from your local Ansible setup. Plus a set of authorized_keys for the admin SSH user.

* cd `git/ansible/vars`
* create new SSH keypair (no password): `ssh-keygen -t rsa -q -N "" -f gh-key.rsa`

### Create authorized_keys

Create new `git/ansible/vars/authorized_keys` with your public key and for others you want to give access to the admin SSH account,
plus `gh-key.rsa.pub` .

```
cat gh-key.rsa.pub > authorized_keys
cat ~/.ssh/id_rsa.pub >> authorized_keys
cat id.rsa.pub.of.joe >> authorized_keys   # etc

```

### Adapt vars.yml

Create new `git/ansible/vars/vars.yml` from example `vars.example.yml` in that dir.

The first part of `vars.yml` contains generix, less-secret, values. 
Use variables where possible. Format is Python-Jinja2 template-like:


```
my_ssh_pubkey_file: ~/.ssh/id_rsa.pub
my_email: my@email.nl
my_admin_user: the_admin_username
my_admin_home: "/home/{{ my_admin_user }}"
my_git_home: "{{ my_admin_home }}/git"
my_github_repo: https://github.com/Geonovum/ogc-api-sandbox.git
var_dir: /var/ogcapi
logs_dir: "{{ var_dir }}/log"
services_home: "{{ my_git_home }}/services"
platform_home: "{{ my_git_home }}/platform"
pip_install_packages:
  - name: docker
timezone: Europe/Amsterdam
ufw_open_ports: ['22', '80', '443', '5432']
```
  
The second part deals with more secret values, like usernames and passwords for services.
For most services indicated below with comment after `#`. `GHC_` denotes GeoHealthCheck (GHC) vars.
If you don't use GHC you can skip those.


```
etc_environment:
  PG_DB: the_db  # PostGIS service
  PG_USER: the_user  # PostGIS service
  PG_PASSWORD: the_pw  # PostGIS service
  PGADMIN_EMAIL: the_user@the_user.nl # PGadmin service
  PGADMIN_PASSWORD: the_pw  # PGadmin service
  GHC_SQLALCHEMY_DATABASE_URI: postgresql://the_user:the_pw@the_db:5432/the_db  # PGadmin service
  GHC_ADMIN_USER_NAME: the_user
  GHC_ADMIN_USER_PASSWORD: the_pw
  GHC_ADMIN_USER_EMAIL: the_user@the_user.nl
  GHC_NOTIFICATIONS_EMAIL: the_user@the_user.com
  GHC_SMTP_EMAIL: the_user@the_user.com
  GHC_SMTP_SERVER: smtp.gmail.com
  GHC_SMTP_PORT: 587
  GHC_SMTP_TLS: True
  GHC_SMTP_SSL: False
  GHC_SMTP_USERNAME: the_user@the_user.com
  GHC_SMTP_PASSWORD: the_pw

```

### Create Ansible Vault Password

* global replace `~/.ssh/ansible-vault/ogc-api-testbed.txt` with `~/.ssh/ansible-vault/ogc-api-jrc.txt` in `git/ansible/README.md`
* create strong password  
* store in `~/.ssh/ansible-vault/ogc-api-jrc.txt` for convenience

### Set GitHub Secrets

Three secrets need to be set:

Go to GH repo Settings|Secrets and create these three secrets

* ANSIBLE_INVENTORY_PROD - copy/paste complete inventory file contents from `git/ansible/hosts/prod.yml`
* ANSIBLE_SSH_PRIVATE_KEY - with value from `git/ansible/vars/gh-key.rsa`
* ANSIBLE_VAULT_PASSWORD - value from `~/.ssh/ansible-vault/ogc-api-sandbox.txt` 


### Encrypt Ansible Files

VERY IMPORTANT. UNENCRYPTED FILES SHOULD NEVER BE CHECKED IN!!!

Using `ansible-vault` with password encrypt these:

```
ansible-vault encrypt --vault-password-file ~/.ssh/ansible-vault/ogc-api-jrc.txt  vars.yml
ansible-vault encrypt --vault-password-file ~/.ssh/ansible-vault/ogc-api-jrc.txt  gh-key.rsa
ansible-vault encrypt --vault-password-file ~/.ssh/ansible-vault/ogc-api-jrc.txt  gh-key.rsa.pub 
ansible-vault encrypt --vault-password-file ~/.ssh/ansible-vault/ogc-api-jrc.txt  authorized_keys 

```

### Globally Replace apitestbed.geonovum.nl

Under `git/services` replace all occurrences of `apitestbed.geonovum.nl` with `jrc.map5.nl`
 
### Disable GitHub Workflows

We do not want that workflows take effect immediately. 
So disable them temporary by renaming the dir.

```
cd git/.github/workflows
git mv workflows workflows.not
git add .
git commit -m "disable workflows"
git push

```

## 6 Remove Unneeded Services

Remove all unneeded services by removing their folders and supporting Ansible and GitHub Actions files:

* remove `git//docs` (using [home service](https://github.com/justb4/ogc-api-jrc/services/home) as landing page and documentation).
* under `/services/` remove: `/ldproxy`, `/geoserver`, `/qgis`, `/goaf`, `/pycsw`
* under `.github/workflows/` remove `deploy.<service>.yml` for these services
* in `ansible/deploy.yml` remove all `task`s for these services
 
Add/commit/push all your above changes to the GitHub repo.

## 7 Bootstrap/provision Server

Moment of truth! Bootstrap (provision the server) in single playbook.

* `ansible-playbook -v --vault-password-file ~/.ssh/ansible-vault/ogc-api-sandbox.txt bootstrap.yml -i hosts/prod.yml`

If all goes well, this output should be shown at end:

```
PLAY RECAP ***********************************************************************************************************
apisandbox                 : ok=58   changed=22   unreachable=0    failed=0    skipped=8    rescued=0    ignored=0   

```

Observe output for errors (better is to save output in file via `.. > bootstrap.log 2>&1`).

In cases of errors and after fixes, simply rerun the above Playbook.

Site should be running at: [https://jrc.map5.nl](https://jrc.map5.nl)
Check with portainer [https://jrc.map5.nl/portainer/](https://jrc.map5.nl/portainer/).

## 8 Resolve Issues

These are typical issues found and resolved:

* `/home/oadmin/git` is owned by root, change to `oadmin` 
* delete (or change) CNAME `git/docs/docs`
* permissions in services/qgis/data , make datadir writeable for all: `chmod 777 services/qgis/data`

## 9. Enable GitHub Workflows

Enable by renaming:

```
git mv workflows.not workflows 
git add .
git commit -m "enable workflows"
git push

```
