# Phase 1: Manual Setup

## 1.1 Configure local machine

- Install required packages:
    ```bash
    # macOS
    brew install terraform ansible kubectl helm git

    # Verify installations
    terraform version
    ansible --version
    kubectl version --client
    ```

- Create SSH Key:
    ```bash
    ssh-keygen -t ed25519 -C "homelab"
    ```

- Add folowing line to ssh config file:
    ```bash
    Host *
    IdentityFile ~/.ssh/homelab
    IdentitiesOnly yes
    SetEnv TERM=xterm-256color
    ```

...

## 1.2 Proxmox installation & configuration

### 1.2.1 Install Proxmox on server

Link video

### 1.2.2 OPTION: HP Z440 NIC Fix

Follow this guide: [HP Z440 NIC Fix](/docs/hp_z440-NIC-fix.md)

### 1.2.3 Disable enterprise repos:

1) Disable enterprise debian pve repo
2) Disable enterprise ceph-squid repo
3) Enable No-Subscription repo
4) Enable Ceph Squid No-Subscription repo

### 1.2.4 Update proxmox

- Update in GUI or run `apt update & upgrade` in cli

### 1.2.5 Set correct time

1) Select time menu
2) Set the correct time zone and time

### 1.2.6 Add new storage

1) Access the Shell
2) Prepare and Create Physical Volumes (PV)
    - `wipefs -a /dev/sda`
    - `wipefs -a /dev/sdb`
    - `pvcreate /dev/sda /dev/sdb`
    - `pvs`
3) Create the Volume Group (VG)
    - `vgcreate vg-data /dev/sda /dev/sdb`
    - `vgs`
4) Create the LVM-Thin Pool
    - `lvcreate -l 100%FREE -n thin-data vg-data --type thin-pool`
    - `lvs`
5) Add Storage to Proxmox (Web UI)
    - Navigate to Datacenter --> Storage
    - Click Add --> LVM-Thin
    - Configure the settings:
        - ID: lvm-thin-storage
        - Volume Group: Select vg-data
        - Thin Pool: Select thin-data
        - Content: Check Disk Image and Container
    - Click Create

### 1.2.7 Configure Notifications

1) Go to Notifications
2) Add SMTP Notification
3) Configure SMTP Notification
4) Modify Notification Matcher

### 1.2.8 ...

...

## 1.3 Deploy Pi-Hole in LXC container

### 1.3.1 Create a container template

1) Go to your local storage of your proxmox node

2) Select `CT Templates` then select `Templates`

3) Pick the latest Debian or Ubuntu template and download it

### 1.3.2 Create the LXC Container and install Pi-Hole

1) Select `Create CT` and fill in the information:
    - Fill in password
    - Disk size: 2GB
    - CPU: 1 core
    - Memory: 512 MB and 512 MB swap
    - Fill in a static ip
    - DNS: user host settings

2) Create the LXC container and login with username `root` and the password you chose earlier

### 1.3.3 Install Pi-Hole

1) Update all packages:
    ```bash
    apt update && apt upgrade
    ```

2) Install curl package:
    ```bash
    apt install curl
    ```

3) Install Pi-Hole:
    ```bash
    curl -sSL https://install.pi-hole.net | bash
    ```

4) Fill in all the asked information:
    - Upstream DNS Provider: Cloudflare
    - Use the default blacklists
    - De-select IPv6 form the protocols

5) Change the admin password:
    ```bash
    pihole -a -p
    ```

### 1.3.4 Configure proxmox to use Pi-Hole as DNS

1) Go to your node and sleect `DNS`

2) Add your Pi-Hole IP address to the DNS server, change it to your first DNS server


## 1.4 Configure a cloud-init vm template

Follow this YouTube video: [Cloud-Init on Proxmox: The VM Automation You’ve Been Missing - Tech-TheLazyAutomator](https://youtu.be/1Ec0Vg5be4s?si=QfNyq6vm1dKfqfj0)


## 1.5 GitLab & GitLab Runner Deployment

Execute the `bootstrap.sh` script. This script will run the Terraform code to provision the GitLab VM and the GitLab Runner VM in Proxmox and then it will run the Ansible code to configure and install GitLab and the GitLab Runner on those VMs.

```bash
git clone https://github.com/mathiaswouters/homelab.git
cd homelab/bootstrap
chmod +x bootstrap.sh
./bootstrap.sh
```


## 1.6 GitLab Post-Installation

### 1.6.1 Access GitLab

Open your browser and navigate to your configured URL

### 1.6.2 First Login

- **Username**: `root`
- **Password**: Displayed at the end of the playbook run

If you need to retrieve the initial password again (within 24 hours):

```bash
ssh your_ciuser@192.168.0.11
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

### 1.6.3 Change Root Password

1) Go to the `User settings` and click `Password`
2) Change the password here

### 1.6.4 Create personal user account

- Create your personal user account (manual)
- Make your user an admin
- Log in as your personal user

1) Go to `Admin area` (add /admin to the url)
2) Go to `Overview` --> `Users` and select `New user`
3) Enter the new user's details (Name, Username and Email)
4) At `Access level` choose `Administrator`
5) Select `Create user`
6) Then back in the `Users` page of the `Admin area` select the new user
7) Edit the new user and enter a password
8) Sign out of the root user and log back in with the new user

### 1.6.6 Create ssh key and add to GitLab

Generate an SSh Key pair on the master-vm:

1) `ssh-keygen -t ed25519 -C "gitlab"`
2) At `Enter file in which to save the key (/home/mathias/.ssh/id_ed25519):` enter: `gitlab`
3) At `Enter passphrase (empty for no passphrase):` just press enter
4) `vi .ssh/config`
  - Enter the following:
    ```
    Host <ip-gitlab>
      PreferredAuthentications publickey
      IdentityFile ~/.ssh/gitlab
    ```

Add the SSH Key to your GitLab account:

1) Copy this output: `cat ~/.ssh/gitlab.pub`
2) Sign in to GitLab
3) Select your avatar
4) Select Edit profile
5) Select SSH Keys
6) Select `Add new key`
7) Enter your copied key
8) At `Expiration date` press the `x` for no expiration date
9) Test the connection: `ssh -T git@<ip-gitlab>`

### 1.6.7 Create personal access token

...

????

### 1.6.8 Create Runner in GitLab UI & Store Token

1) Navigate to: `Admin Area` → `CI/CD` → `Runners`
2) Click `Create instance runner`
3) Configure runner settings:
    - Tags: `docker`
    - Enable `Run untagged jobs`
    - Description: `docker-runner`
4) Click `Create runner`
5) Copy the token (starts with `glrt-`)
6) Store token in Ansible Vault:
    ```bash
    cd ansible/

    # Create vault file for gitlab-runner group
    mkdir -p group_vars/gitlab-runner
    ansible-vault create group_vars/gitlab-runner/vault.yml
    ```
7) Enter vault password, then add:
    ```bash
    ---

    vault_gitlab_runner_token: "glrt-your-copied-token-here"
    ```
8) Create non-encrypted vars file:
    ```bash
    vi group_vars/gitlab-runner/vars.yml
    ```
9) Add:
    ```bash
    ---
    
    gitlab_runner_token: "{{ vault_gitlab_runner_token }}"
    ```

## 1.7 Register GitLab Runner

```bash
cd homelab/bootstrap/ansible
ansible-playbook register-runner.yml --ask-vault-pass
```

## 1.8 OPTIONAL: Test Runner

Create a test pipeline in GitLab `.gitlab-ci.yml`:

```yaml
test-runner:
  tags:
    - docker
  script:
    - echo "Hello from GitLab Runner!"
    - echo "Running on: $(uname -a)"
    - docker --version
```


---

# Phase 2: GitLab-as-Code

## 2.1 Create gitlab-infrastructure project

Create a new project: `yourusername/gitlab-infrastructure`

## 2.2 Copy the code to the gitlab-infrastructure repo in GitLab

Copy the code from the [terraform-gitlab](/bootstrap/gitlab-infrastructure/) folder in this GitHub repo to the recently created `gitlab-infrastructure` repo in GitLab

## 2.3 GitLab Terraform Access Token

### 2.3.1 Create Access Token
In GitLab UI:

1) User Settings → Access Tokens
2) Name: `terraform-gitlab-infra`
3) Scopes: `api`, `read_repository`, `write_repository`
4) Create token

### 2.3.2 Fill in Access Token in tfvars file

1) Create `terraform.tfvars` file:
    ```bash
    cd ~/path/to/gitlab-infrastructure/terraform
    cp terraform.tfvars.example terraform.tfvars
    vi terraform.tfvars
    ```

2) Fill in:
    ```bash
    gitlab_token       = "glpat-xxxxxxxxxxxxxxxxxxxx"  # ← You need to create this
    gitlab_base_url    = "http://192.168.0.11/api/v4"  # ← Already correct for you
    default_visibility = "private"                      # ← Already correct
    admin_user_id      = 2                              # ← You need to find this
    ```

## 2.4 Add CI/CD Variables in GitLab

1) Go to your `<username>/gitlab-infrastructure` project:
    -> Settings -> CI/CD -> Variables -> Expan -> Add variable

2) Add these variables:
    - GITLAB_TOKEN: glpat-xxxx...
    - TF_VAR_gitlab_token: glpat-xxxx...
    - TF_VAR_admin_user_id: <user-id>

## 2.5 Run the gitlab-infrastructure pipeline

Push code to the `gitlab-infrastructure` repo and this will trigger the pipeline

Or manually trigger the pipeline in the UI

---

# Phase 3: Deploy Foundational Services on VMs

In this phase deploy following services:

- MetalLB
- Cert-Manager (+ Let's Encrypt)
- Traefik (Maybe in K8s --> lookup how it is done )
- Hashicorp Vault  (On VM)
- ArgoCD
- Harbor (On VM)
- Service Mesh ???
- Longhorn
- External-DNS

--> **Deploy all K8s services with ArgoCD !!!!!!!!!!!!!**

---
---
---






















# Homelab Phase 3-5: Complete Deployment Plan

## Overview

This document provides a step-by-step guide for deploying a production-grade homelab infrastructure with proper separation of concerns, high availability, and GitOps practices.

---

## Architecture Summary

### Infrastructure VMs (Deployed in Phase 3)
- **HashiCorp Vault** (192.168.0.20) - Secrets management
- **Harbor** (192.168.0.21) - Container registry

### Management Cluster (Phase 4.1)
- **3 control-plane nodes** (192.168.0.30-32)
- Runs: ArgoCD, Traefik, MetalLB, Cert-Manager, Monitoring, Security tools

### Workload Cluster (Phase 4.2)
- **1 control-plane + 2-3 workers** (192.168.0.40-43)
- Runs: Applications (dev/test/staging/prod namespaces), Longhorn

### Network Allocation
- MetalLB IP Pool: `192.168.0.50-192.168.0.70`
- Traefik LoadBalancer: `192.168.0.50` (management), `192.168.0.51` (workload)

---

# Phase 3: Deploy Foundational Infrastructure VMs

## 3.1 Deploy HashiCorp Vault

### 3.1.1 Create Vault VM with Terraform

Create `homelab/infrastructure/vault/terraform/main.tf`:

```hcl
variable "vm_configs" {
  default = {
    "vault" = {
      vm_id       = 120
      name        = "vault"
      tags        = "vm,infrastructure,security"
      memory      = 4096
      vm_state    = "running"
      onboot      = true
      startup     = "order=1"
      ipconfig    = "ip=192.168.0.20/24,gw=192.168.0.1"
      cores       = 2
      bridge      = "vmbr0"
      network_tag = 0
      disk_size   = "20G"
    }
  }
}
```

Deploy:
```bash
cd homelab/infrastructure/vault/terraform
terraform init
terraform apply
```

### 3.1.2 Install Vault with Ansible

Create `homelab/infrastructure/vault/ansible/playbook.yml`:

```yaml
---
- name: Install HashiCorp Vault
  hosts: vault
  become: yes
  tasks:
    - name: Install required packages
      apt:
        name:
          - wget
          - unzip
          - jq
        state: present
        update_cache: yes

    - name: Download Vault
      get_url:
        url: https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
        dest: /tmp/vault.zip

    - name: Unzip Vault
      unarchive:
        src: /tmp/vault.zip
        dest: /usr/local/bin/
        remote_src: yes
        mode: '0755'

    - name: Create Vault user
      user:
        name: vault
        system: yes
        shell: /bin/false

    - name: Create Vault directories
      file:
        path: "{{ item }}"
        state: directory
        owner: vault
        group: vault
        mode: '0750'
      loop:
        - /etc/vault.d
        - /opt/vault/data

    - name: Deploy Vault configuration
      template:
        src: vault.hcl.j2
        dest: /etc/vault.d/vault.hcl
        owner: vault
        group: vault
        mode: '0640'

    - name: Deploy Vault systemd service
      template:
        src: vault.service.j2
        dest: /etc/systemd/system/vault.service
        mode: '0644'

    - name: Start and enable Vault
      systemd:
        name: vault
        state: started
        enabled: yes
        daemon_reload: yes
```

Create `vault.hcl.j2`:
```hcl
ui = true
api_addr = "http://192.168.0.20:8200"
cluster_addr = "https://192.168.0.20:8201"

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}
```

Create `vault.service.j2`:
```ini
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

Run:
```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

### 3.1.3 Initialize and Unseal Vault

SSH to Vault VM:
```bash
ssh mathias@192.168.0.20
export VAULT_ADDR='http://192.168.0.20:8200'

# Initialize Vault (do this ONCE)
vault operator init -key-shares=5 -key-threshold=3

# Save the output! You'll get 5 unseal keys and 1 root token
# Store these in a SECURE location (1Password, KeePass, etc.)

# Unseal Vault (needs 3 of 5 keys)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>

# Login with root token
vault login <root-token>

# Enable KV v2 secrets engine
vault secrets enable -path=homelab kv-v2

# Create a test secret
vault kv put homelab/test password=test123
vault kv get homelab/test
```

### 3.1.4 Configure Vault Auto-Unseal (Optional but Recommended)

This prevents needing to manually unseal after restarts.

**Option A: Transit Auto-Unseal** (requires another Vault instance)
**Option B: Cloud KMS** (GCP, AWS, Azure)
**Option C: Keep manual unseal** (simpler for homelab)

For now, keep manual unseal and document the process.

---

## 3.2 Deploy Harbor Container Registry

### 3.2.1 Create Harbor VM with Terraform

Add to `homelab/infrastructure/harbor/terraform/main.tf`:

```hcl
variable "vm_configs" {
  default = {
    "harbor" = {
      vm_id       = 121
      name        = "harbor"
      tags        = "vm,infrastructure,registry"
      memory      = 8192
      vm_state    = "running"
      onboot      = true
      startup     = "order=2"
      ipconfig    = "ip=192.168.0.21/24,gw=192.168.0.1"
      cores       = 4
      bridge      = "vmbr0"
      network_tag = 0
      disk_size   = "100G"
    }
  }
}
```

Deploy:
```bash
cd homelab/infrastructure/harbor/terraform
terraform init
terraform apply
```

### 3.2.2 Install Harbor with Ansible

Create `homelab/infrastructure/harbor/ansible/playbook.yml`:

```yaml
---
- name: Install Harbor Registry
  hosts: harbor
  become: yes
  vars:
    harbor_version: "v2.9.0"
    harbor_hostname: "harbor.homelab.local"
    harbor_admin_password: "{{ vault_harbor_admin_password }}"
    
  tasks:
    - name: Install Docker
      include_role:
        name: docker

    - name: Install Docker Compose
      apt:
        name: docker-compose-plugin
        state: present

    - name: Download Harbor installer
      get_url:
        url: "https://github.com/goharbor/harbor/releases/download/{{ harbor_version }}/harbor-offline-installer-{{ harbor_version }}.tgz"
        dest: /tmp/harbor.tgz

    - name: Extract Harbor
      unarchive:
        src: /tmp/harbor.tgz
        dest: /opt/
        remote_src: yes

    - name: Copy Harbor configuration
      template:
        src: harbor.yml.j2
        dest: /opt/harbor/harbor.yml

    - name: Run Harbor installer
      command: /opt/harbor/install.sh
      args:
        chdir: /opt/harbor
        creates: /opt/harbor/harbor_install_log.txt

    - name: Ensure Harbor is running
      docker_compose:
        project_src: /opt/harbor
        state: present
```

Create `harbor.yml.j2`:
```yaml
hostname: {{ harbor_hostname }}

http:
  port: 80

harbor_admin_password: {{ harbor_admin_password }}

database:
  password: root123
  max_idle_conns: 100
  max_open_conns: 900

data_volume: /data

trivy:
  ignore_unfixed: false
  skip_update: false
  insecure: false

jobservice:
  max_job_workers: 10

notification:
  webhook_job_max_retry: 10

chart:
  absolute_url: disabled

log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    location: /var/log/harbor

_version: 2.9.0
```

Store Harbor password in Ansible Vault:
```bash
ansible-vault create group_vars/harbor/vault.yml
# Add: vault_harbor_admin_password: "YourSecurePassword"
```

Run:
```bash
ansible-playbook -i inventory/hosts.ini playbook.yml --ask-vault-pass
```

### 3.2.3 Configure Harbor

Access Harbor UI: `http://192.168.0.21`
- Username: `admin`
- Password: (from Ansible vault)

**Configure Harbor:**
1. Create project: `homelab`
2. Make it private
3. Enable vulnerability scanning
4. Create robot account for K8s image pulls:
   - Go to: Projects → homelab → Robot Accounts
   - Name: `k8s-image-puller`
   - Permissions: Pull only
   - Copy the token (save to Vault!)

### 3.2.4 Add DNS Record in Pi-hole

SSH to Pi-hole:
```bash
# Add to /etc/hosts
echo "192.168.0.21 harbor.homelab.local" >> /etc/hosts

# Restart dnsmasq
pihole restartdns
```

### 3.2.5 Test Harbor from GitLab Runner

SSH to GitLab Runner VM:
```bash
# Login to Harbor
docker login harbor.homelab.local -u admin

# Tag a test image
docker pull alpine:latest
docker tag alpine:latest harbor.homelab.local/homelab/alpine:test

# Push to Harbor
docker push harbor.homelab.local/homelab/alpine:test
```

---

## 3.3 Integrate Vault with GitLab

### 3.3.1 Configure Vault for GitLab JWT Auth

```bash
export VAULT_ADDR='http://192.168.0.20:8200'
vault login <root-token>

# Enable JWT auth
vault auth enable jwt

# Configure JWT with GitLab
vault write auth/jwt/config \
  jwks_url="http://192.168.0.11/-/jwks" \
  bound_issuer="192.168.0.11"

# Create policy for CI/CD
vault policy write gitlab-ci - <<EOF
path "homelab/data/ci/*" {
  capabilities = ["read", "list"]
}
EOF

# Create role for GitLab CI
vault write auth/jwt/role/gitlab-ci \
  role_type="jwt" \
  bound_audiences="192.168.0.11" \
  user_claim="user_email" \
  policies="gitlab-ci" \
  ttl="1h"
```

### 3.3.2 Store Secrets in Vault for CI/CD

```bash
# Store Harbor credentials
vault kv put homelab/ci/harbor \
  username=admin \
  password=<harbor-password>

# Store Proxmox credentials  
vault kv put homelab/ci/proxmox \
  api_url=https://192.168.0.1:8006/api2/json \
  user=terraform@pam \
  password=<proxmox-password>
```

### 3.3.3 Test Vault Integration in GitLab Pipeline

Create `.gitlab-ci.yml` in a test project:
```yaml
test-vault:
  image: vault:latest
  tags:
    - docker
  script:
    - export VAULT_ADDR=http://192.168.0.20:8200
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=gitlab-ci jwt=$CI_JOB_JWT)"
    - vault kv get homelab/ci/harbor
```

---

# Phase 4: Deploy Kubernetes Clusters

## 4.1 Deploy Management Cluster (3 Control-Plane Nodes)

### 4.1.1 Provision VMs with Terraform

Create `homelab/infrastructure/k8s-management/terraform/main.tf`:

```hcl
variable "vm_configs" {
  default = {
    "k8s-mgmt-cp1" = {
      vm_id       = 130
      name        = "k8s-mgmt-cp1"
      tags        = "vm,k8s,control-plane"
      memory      = 4096
      vm_state    = "running"
      onboot      = true
      startup     = "order=3"
      ipconfig    = "ip=192.168.0.30/24,gw=192.168.0.1"
      cores       = 2
      bridge      = "vmbr0"
      network_tag = 0
      disk_size   = "40G"
    }
    "k8s-mgmt-cp2" = {
      vm_id       = 131
      name        = "k8s-mgmt-cp2"
      tags        = "vm,k8s,control-plane"
      memory      = 4096
      vm_state    = "running"
      onboot      = true
      startup     = "order=3"
      ipconfig    = "ip=192.168.0.31/24,gw=192.168.0.1"
      cores       = 2
      bridge      = "vmbr0"
      network_tag = 0
      disk_size   = "40G"
    }
    "k8s-mgmt-cp3" = {
      vm_id       = 132
      name        = "k8s-mgmt-cp3"
      tags        = "vm,k8s,control-plane"
      memory      = 4096
      vm_state    = "running"
      onboot      = true
      startup     = "order=3"
      ipconfig    = "ip=192.168.0.32/24,gw=192.168.0.1"
      cores       = 2
      bridge      = "vmbr0"
      network_tag = 0
      disk_size   = "40G"
    }
  }
}
```

### 4.1.2 Install Kubernetes with Kubeadm (Ansible)

Create `homelab/infrastructure/k8s-management/ansible/inventory/hosts.ini`:
```ini
[k8s_control_plane]
k8s-work-cp1 ansible_host=192.168.0.40

[k8s_workers]
k8s-work-w1 ansible_host=192.168.0.41
k8s-work-w2 ansible_host=192.168.0.42

[k8s_all:children]
k8s_control_plane
k8s_workers

[k8s_all:vars]
ansible_user=mathias
ansible_ssh_private_key_file=~/.ssh/homelab
```

Run playbook:
```bash
cd homelab/infrastructure/k8s-workload/terraform
terraform init && terraform apply

cd ../ansible
ansible-playbook -i inventory/hosts.ini playbook.yml
```

### 4.3.3 Add Workload Cluster to ArgoCD

```bash
# Get workload cluster kubeconfig
scp mathias@192.168.0.40:~/.kube/config ~/.kube/config-workload

# Add cluster to ArgoCD
argocd cluster add workload-cluster \
  --kubeconfig ~/.kube/config-workload \
  --name workload-cluster

# Verify
argocd cluster list
```

### 4.3.4 Install Core Services via ArgoCD

Create GitLab project: `infrastructure/argocd-apps`

Create `apps/workload-cluster/metallb.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metallb
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://metallb.github.io/metallb
    targetRevision: 0.13.12
    chart: metallb
    helm:
      values: |
        controller:
          enabled: true
        speaker:
          enabled: true
  destination:
    server: https://192.168.0.40:6443
    namespace: metallb-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Create `apps/workload-cluster/traefik.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: traefik
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://traefik.github.io/charts
    targetRevision: 26.0.0
    chart: traefik
    helm:
      values: |
        service:
          type: LoadBalancer
          annotations:
            metallb.universe.tf/loadBalancerIPs: 192.168.0.51
        ports:
          web:
            port: 80
          websecure:
            port: 443
            tls:
              enabled: true
  destination:
    server: https://192.168.0.40:6443
    namespace: ingress-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Create `apps/workload-cluster/longhorn.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: longhorn
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.longhorn.io
    targetRevision: 1.5.3
    chart: longhorn
    helm:
      values: |
        persistence:
          defaultClass: true
          defaultClassReplicaCount: 2
        defaultSettings:
          backupTarget: s3://longhorn-backups@us-east-1/
          backupTargetCredentialSecret: longhorn-s3-secret
  destination:
    server: https://192.168.0.40:6443
    namespace: storage-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Create `apps/workload-cluster/namespaces.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: application-namespaces
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://192.168.0.11/infrastructure/k8s-manifests.git
    targetRevision: main
    path: workload-cluster/namespaces
  destination:
    server: https://192.168.0.40:6443
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

In `k8s-manifests` repo, create `workload-cluster/namespaces/namespaces.yaml`:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    environment: development
---
apiVersion: v1
kind: Namespace
metadata:
  name: test
  labels:
    environment: testing
---
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    environment: staging
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
```

Apply all ArgoCD apps:
```bash
kubectl apply -f apps/workload-cluster/ -n argocd
```

---

# Phase 5: Observability & Security

## 5.1 Deploy Monitoring Stack (Management Cluster)

### 5.1.1 Install kube-prometheus-stack via ArgoCD

Create `apps/management-cluster/monitoring.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://prometheus-community.github.io/helm-charts
    targetRevision: 55.0.0
    chart: kube-prometheus-stack
    helm:
      values: |
        prometheus:
          prometheusSpec:
            retention: 30d
            storageSpec:
              volumeClaimTemplate:
                spec:
                  accessModes: ["ReadWriteOnce"]
                  resources:
                    requests:
                      storage: 50Gi
            additionalScrapeConfigs:
              - job_name: 'workload-cluster-metrics'
                kubernetes_sd_configs:
                  - role: endpoints
                    api_server: https://192.168.0.40:6443
                    tls_config:
                      insecure_skip_verify: true
        
        grafana:
          enabled: true
          adminPassword: admin
          ingress:
            enabled: true
            ingressClassName: traefik
            hosts:
              - grafana.homelab.local
          
          datasources:
            datasources.yaml:
              apiVersion: 1
              datasources:
                - name: Prometheus
                  type: prometheus
                  url: http://prometheus-operated:9090
                  isDefault: true
                - name: Loki
                  type: loki
                  url: http://loki:3100

        alertmanager:
          enabled: true
          config:
            global:
              resolve_timeout: 5m
            route:
              group_by: ['alertname', 'cluster']
              group_wait: 10s
              group_interval: 10s
              repeat_interval: 12h
              receiver: 'slack'
            receivers:
              - name: 'slack'
                slack_configs:
                  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
                    channel: '#homelab-alerts'
                    title: 'Homelab Alert'
                    text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply:
```bash
kubectl apply -f apps/management-cluster/monitoring.yaml -n argocd
```

Add DNS:
```bash
echo "192.168.0.50 grafana.homelab.local" >> /etc/hosts  # On Pi-hole
pihole restartdns
```

Access Grafana: `http://grafana.homelab.local`

### 5.1.2 Install Loki for Log Aggregation

Create `apps/management-cluster/loki.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: loki
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://grafana.github.io/helm-charts
    targetRevision: 5.41.0
    chart: loki-stack
    helm:
      values: |
        loki:
          enabled: true
          persistence:
            enabled: true
            size: 50Gi
        
        promtail:
          enabled: true
          config:
            clients:
              - url: http://loki:3100/loki/api/v1/push
        
        grafana:
          enabled: false  # Already installed
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply:
```bash
kubectl apply -f apps/management-cluster/loki.yaml -n argocd
```

### 5.1.3 Configure Grafana Dashboards

Import these dashboard IDs in Grafana:
- **Kubernetes Cluster Monitoring**: 15760
- **Node Exporter Full**: 1860
- **Traefik Dashboard**: 12250
- **ArgoCD Dashboard**: 14584
- **Longhorn Dashboard**: 13032

Or store as code in GitLab:

Create `infrastructure/grafana-dashboards/kubernetes-overview.json` (export from Grafana)

Create ArgoCD app to sync dashboards:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grafana-dashboards
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://192.168.0.11/infrastructure/grafana-dashboards.git
    targetRevision: main
    path: dashboards
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 5.2 Deploy Security Stack

### 5.2.1 Install Falco (Runtime Security)

Create `apps/management-cluster/falco.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: falco
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://falcosecurity.github.io/charts
    targetRevision: 3.8.0
    chart: falco
    helm:
      values: |
        driver:
          kind: ebpf
        
        falco:
          grpc:
            enabled: true
          grpcOutput:
            enabled: true
        
        falcosidekick:
          enabled: true
          config:
            slack:
              webhookurl: "YOUR_SLACK_WEBHOOK"
              minimumpriority: "warning"
  destination:
    server: https://kubernetes.default.svc
    namespace: security
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### 5.2.2 Install Trivy Operator (Vulnerability Scanning)

Create `apps/management-cluster/trivy.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: trivy-operator
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://aquasecurity.github.io/helm-charts/
    targetRevision: 0.20.0
    chart: trivy-operator
    helm:
      values: |
        trivy:
          severity: CRITICAL,HIGH,MEDIUM
        
        operator:
          scanJobTimeout: 5m
          vulnerabilityScannerScanOnlyCurrentRevisions: true
  destination:
    server: https://kubernetes.default.svc
    namespace: security
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 5.2.3 Install Wazuh Agent on K8s Nodes

First, deploy Wazuh Manager on a VM:

Terraform (`infrastructure/wazuh/terraform/main.tf`):
```hcl
variable "vm_configs" {
  default = {
    "wazuh" = {
      vm_id       = 125
      name        = "wazuh"
      tags        = "vm,security,siem"
      memory      = 8192
      cores       = 4
      ipconfig    = "ip=192.168.0.25/24,gw=192.168.0.1"
      disk_size   = "100G"
      # ...
    }
  }
}
```

Ansible playbook to install Wazuh Manager (simplified):
```yaml
---
- name: Install Wazuh Manager
  hosts: wazuh
  become: yes
  tasks:
    - name: Install dependencies
      apt:
        name:
          - curl
          - apt-transport-https
          - lsb-release
        state: present

    - name: Add Wazuh repository
      shell: |
        curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
        echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
      args:
        creates: /etc/apt/sources.list.d/wazuh.list

    - name: Install Wazuh Manager
      apt:
        name: wazuh-manager
        state: present
        update_cache: yes

    - name: Start Wazuh Manager
      systemd:
        name: wazuh-manager
        state: started
        enabled: yes
```

Then deploy Wazuh agent as DaemonSet in K8s:

Create `apps/management-cluster/wazuh-agent.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wazuh-agent
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://192.168.0.11/infrastructure/k8s-manifests.git
    targetRevision: main
    path: security/wazuh-agent
  destination:
    server: https://kubernetes.default.svc
    namespace: security
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

In `k8s-manifests` repo, create `security/wazuh-agent/daemonset.yaml`:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: wazuh-agent
  namespace: security
spec:
  selector:
    matchLabels:
      app: wazuh-agent
  template:
    metadata:
      labels:
        app: wazuh-agent
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: wazuh-agent
        image: wazuh/wazuh-agent:4.7.0
        env:
        - name: WAZUH_MANAGER
          value: "192.168.0.25"
        - name: WAZUH_AGENT_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        securityContext:
          privileged: true
        volumeMounts:
        - name: rootfs
          mountPath: /rootfs
          readOnly: true
      volumes:
      - name: rootfs
        hostPath:
          path: /
```

---

## 5.3 Configure External-DNS with Cloudflare

### 5.3.1 Create Cloudflare API Token

1. Login to Cloudflare
2. Go to: My Profile → API Tokens → Create Token
3. Use template: "Edit zone DNS"
4. Permissions:
   - Zone → DNS → Edit
   - Zone → Zone → Read
5. Zone Resources: Include → Specific zone → mathiaswouters.com
6. Copy the token

### 5.3.2 Store Token in Vault

```bash
vault kv put homelab/cloudflare api_token=<your-token>
```

### 5.3.3 Install External-DNS via ArgoCD

Create `apps/management-cluster/external-dns.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: external-dns
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://kubernetes-sigs.github.io/external-dns/
    targetRevision: 1.14.0
    chart: external-dns
    helm:
      values: |
        provider: cloudflare
        
        env:
        - name: CF_API_TOKEN
          valueFrom:
            secretKeyRef:
              name: cloudflare-api-token
              key: api-token
        
        extraArgs:
        - --cloudflare-proxied
        - --annotation-filter=external-dns.alpha.kubernetes.io/cloudflare=true
        
        domainFilters:
        - mathiaswouters.com
        
        policy: sync
        registry: txt
        txtPrefix: "k8s-"
  destination:
    server: https://kubernetes.default.svc
    namespace: ingress-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Create secret manually first:
```bash
kubectl create secret generic cloudflare-api-token \
  --from-literal=api-token=<your-token> \
  -n ingress-system
```

Or use External Secrets Operator (better approach - see next section).

### 5.3.4 Test External-DNS

Create a test ingress:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-external-dns
  namespace: default
  annotations:
    external-dns.alpha.kubernetes.io/hostname: test.mathiaswouters.com
    external-dns.alpha.kubernetes.io/cloudflare: "true"
spec:
  ingressClassName: traefik
  rules:
  - host: test.mathiaswouters.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

Check DNS:
```bash
dig test.mathiaswouters.com
# Should resolve to your Traefik LoadBalancer IP
```

---

## 5.4 Configure Cert-Manager with Let's Encrypt (Cloudflare DNS-01)

### 5.4.1 Create ClusterIssuer for Let's Encrypt

Create secret for Cloudflare API token:
```bash
kubectl create secret generic cloudflare-api-token-cert \
  --from-literal=api-token=<your-token> \
  -n cert-manager
```

Create `infrastructure/k8s-manifests/cert-manager/letsencrypt-prod.yaml`:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-cert
            key: api-token
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-cert
            key: api-token
```

Apply:
```bash
kubectl apply -f letsencrypt-prod.yaml
```

### 5.4.2 Test Certificate Generation

Update Grafana ingress to use TLS:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    external-dns.alpha.kubernetes.io/hostname: grafana.mathiaswouters.com
    external-dns.alpha.kubernetes.io/cloudflare: "true"
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - grafana.mathiaswouters.com
    secretName: grafana-tls
  rules:
  - host: grafana.mathiaswouters.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 80
```

Check certificate:
```bash
kubectl get certificate -n monitoring
kubectl describe certificate grafana-tls -n monitoring

# Test access
curl -I https://grafana.mathiaswouters.com
```

---

## 5.5 Install External Secrets Operator (Vault Integration)

### 5.5.1 Install ESO via ArgoCD

Create `apps/management-cluster/external-secrets.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: external-secrets
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.external-secrets.io
    targetRevision: 0.9.11
    chart: external-secrets
  destination:
    server: https://kubernetes.default.svc
    namespace: vault-integration
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### 5.5.2 Configure SecretStore for Vault

Create `infrastructure/k8s-manifests/vault-integration/secretstore.yaml`:
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: vault-integration
spec:
  provider:
    vault:
      server: "http://192.168.0.20:8200"
      path: "homelab"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "external-secrets"
          serviceAccountRef:
            name: external-secrets-sa
```

Configure Vault for Kubernetes auth:
```bash
export VAULT_ADDR='http://192.168.0.20:8200'
vault login <root-token>

# Enable Kubernetes auth
vault auth enable kubernetes

# Configure Kubernetes auth
vault write auth/kubernetes/config \
  kubernetes_host="https://192.168.0.30:6443" \
  kubernetes_ca_cert=@/path/to/ca.crt \
  token_reviewer_jwt=@/path/to/jwt

# Create policy
vault policy write external-secrets - <<EOF
path "homelab/data/*" {
  capabilities = ["read", "list"]
}
EOF

# Create role
vault write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets-sa \
  bound_service_account_namespaces=vault-integration \
  policies=external-secrets \
  ttl=24h
```

### 5.5.3 Create ExternalSecret Example

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: cloudflare-api-token
  namespace: ingress-system
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: cloudflare-api-token
    creationPolicy: Owner
  data:
  - secretKey: api-token
    remoteRef:
      key: homelab/cloudflare
      property: api_token
```

Now all your secrets come from Vault automatically!

---

# Phase 6: Deploy Applications

## 6.1 Create Application Structure in GitLab

Create these projects in GitLab (`applications` group):
- `homepage-dashboard`
- `nextcloud`
- `jellyfin`
- `arr-stack` (Sonarr, Radarr, etc.)

## 6.2 Deploy Homepage Dashboard

Create `apps/workload-cluster/homepage.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: homepage
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://192.168.0.11/applications/homepage-dashboard.git
    targetRevision: main
    path: k8s
  destination:
    server: https://192.168.0.40:6443
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

In `homepage-dashboard` repo, create `k8s/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: homepage
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: homepage
  template:
    metadata:
      labels:
        app: homepage
    spec:
      containers:
      - name: homepage
        image: ghcr.io/gethomepage/homepage:latest
        ports:
        - containerPort: 3000
        volumeMounts:
        - name: config
          mountPath: /app/config
      volumes:
      - name: config
        configMap:
          name: homepage-config
---
apiVersion: v1
kind: Service
metadata:
  name: homepage
  namespace: production
spec:
  selector:
    app: homepage
  ports:
  - port: 80
    targetPort: 3000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: homepage
  namespace: production
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    external-dns.alpha.kubernetes.io/hostname: home.mathiaswouters.com
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - home.mathiaswouters.com
    secretName: homepage-tls
  rules:
  - host: home.mathiaswouters.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: homepage
            port:
              number: 80
```

---

# Summary & Next Steps

## What You've Accomplished

✅ **Phase 3**: Vault, Harbor, and foundational infrastructure
✅ **Phase 4**: Management + Workload K8s clusters with full GitOps
✅ **Phase 5**: Monitoring, logging, security, and secrets management
✅ **Phase 6 (Started)**: Application deployment framework

## Recommended Order of Execution

1. **Week 1**: Deploy Vault + Harbor (Phase 3.1-3.2)
2. **Week 2**: Management K8s cluster + core services (Phase 4.1-4.2)
3. **Week 3**: Workload K8s cluster (Phase 4.3)
4. **Week 4**: Monitoring stack (Phase 5.1)
5. **Week 5**: Security tools (Phase 5.2)
6. **Week 6**: DNS/TLS automation (Phase 5.3-5.4)
7. **Week 7+**: Deploy applications (Phase 6)

## Key Decisions You Still Need to Make

1. **Backup Strategy**: Where will Longhorn backups go? (MinIO S3, Proxmox Backup Server?)
2. **Disaster Recovery**: How will you backup Vault unseal keys?
3. **Public Access**: Which services (if any) should be publicly accessible?
4. **Service Mesh**: Do you want Istio/Linkerd? (Probably Phase 7)
5. **Pi-Cluster**: When to deploy? (Probably Phase 8)

## GitLab Repository Structure (Final)

```
infrastructure/
├── terraform-modules/
├── ansible-playbooks/
├── proxmox-automation/
├── k8s-manifests/
└── argocd-apps/

kubernetes/
├── argocd-apps/
├── helm-charts/
└── k8s-manifests/

services/
├── monitoring/
│   ├── prometheus-config/
│   └── grafana-dashboards/
├── security/
│   ├── vault-config/
│   └── wazuh-config/
├── storage/
│   ├── longhorn-config/
│   └── minio-config/
└── networking/
    ├── traefik-config/
    ├── cert-manager-config/
    └── metallb-config/

applications/
├── homelab-dashboard/
├── nextcloud/
├── jellyfin/
└── arr-stack/

pipelines/
├── ci-templates/
└── scripts/
```

---

# Phase 7: Advanced Features & Optimization

## 7.1 Configure Automated Backups

### 7.1.1 Deploy Velero for K8s Backups

Velero backs up Kubernetes resources and persistent volumes.

**Install MinIO for S3-compatible storage:**

Create `apps/management-cluster/minio.yaml`:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: minio
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.min.io/
    targetRevision: 5.0.14
    chart: minio
    helm:
      values: |
        mode: standalone
        
        persistence:
          enabled: true
          size: 100Gi
        
        resources:
          requests:
            memory: 2Gi
        
        users:
          - accessKey: minio-admin
            secretKey: minio-secret-key
            policy: consoleAdmin
        
        buckets:
          - name: velero-backups
            policy: none
            purge: false
          - name: longhorn-backups
            policy: none
            purge: false
        
        ingress:
          enabled: true
          ingressClassName: traefik
          hosts:
            - minio.homelab.local
  destination:
    server: https://kubernetes.default.svc
    namespace: storage-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**Install Velero:**

```bash
# Download Velero CLI
wget https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz
tar -xvf velero-v1.12.0-linux-amd64.tar.gz
sudo mv velero-v1.12.0-linux-amd64/velero /usr/local/bin/

# Create credentials file
cat > credentials-velero <<EOF
[default]
aws_access_key_id = minio-admin
aws_secret_access_key = minio-secret-key
EOF

# Install Velero
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.8.0 \
  --bucket velero-backups \
  --secret-file ./credentials-velero \
  --use-volume-snapshots=false \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.storage-system.svc:9000
```

**Create backup schedules:**

```yaml
# Daily backup of all namespaces
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
  namespace: velero
spec:
  schedule: "0 2 * * *"  # 2 AM daily
  template:
    includedNamespaces:
    - "*"
    excludedNamespaces:
    - kube-system
    - kube-public
    - kube-node-lease
    ttl: 720h0m0s  # 30 days retention
---
# Weekly full cluster backup
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: weekly-full-backup
  namespace: velero
spec:
  schedule: "0 3 * * 0"  # 3 AM every Sunday
  template:
    includedNamespaces:
    - "*"
    includeClusterResources: true
    ttl: 2160h0m0s  # 90 days retention
```

Apply:
```bash
kubectl apply -f velero-schedules.yaml
```

**Test backup and restore:**

```bash
# Create a test backup
velero backup create test-backup --wait

# Check backup status
velero backup describe test-backup

# Simulate disaster and restore
kubectl delete namespace test
velero restore create --from-backup test-backup
```

### 7.1.2 Configure Longhorn Backups to MinIO

In your Longhorn ArgoCD app, update values:

```yaml
defaultSettings:
  backupTarget: s3://longhorn-backups@us-east-1/
  backupTargetCredentialSecret: longhorn-s3-secret
```

Create secret:
```bash
kubectl create secret generic longhorn-s3-secret \
  --from-literal=AWS_ACCESS_KEY_ID=minio-admin \
  --from-literal=AWS_SECRET_ACCESS_KEY=minio-secret-key \
  --from-literal=AWS_ENDPOINTS=http://minio.storage-system.svc:9000 \
  -n storage-system
```

**Create recurring backup job in Longhorn:**
1. Access Longhorn UI: `http://longhorn.homelab.local`
2. Go to: Volume → Select volume → Create Recurring Job
3. Type: Backup
4. Schedule: `0 1 * * *` (1 AM daily)
5. Retain: 7 backups

### 7.1.3 Backup Vault Data

Create a cronjob to backup Vault:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: vault-backup
  namespace: vault-integration
spec:
  schedule: "0 0 * * *"  # Daily at midnight
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: vault:1.15.0
            env:
            - name: VAULT_ADDR
              value: "http://192.168.0.20:8200"
            - name: VAULT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: vault-token
                  key: token
            command:
            - /bin/sh
            - -c
            - |
              # Snapshot Vault data
              vault operator raft snapshot save /tmp/vault-snapshot.snap
              
              # Upload to MinIO (using rclone or aws cli)
              # TODO: Add upload logic
          restartPolicy: OnFailure
```

**CRITICAL**: Store Vault unseal keys securely offline (e.g., encrypted USB drive, password manager).

### 7.1.4 Backup GitLab

SSH to GitLab VM and configure automated backups:

```bash
# Edit GitLab config
sudo nano /etc/gitlab/gitlab.rb

# Add backup settings
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_keep_time'] = 604800  # 7 days
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'minio-admin',
  'aws_secret_access_key' => 'minio-secret-key',
  'endpoint' => 'http://192.168.0.50:9000',
  'path_style' => true
}
gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups'

# Reconfigure GitLab
sudo gitlab-ctl reconfigure

# Create backup cron
sudo crontab -e
# Add:
0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1
```

---

## 7.2 Implement Network Policies

Secure your clusters with NetworkPolicies.

### 7.2.1 Enable Calico Network Policies

Already using Calico, so policies are supported.

### 7.2.2 Default Deny Policy (Best Practice)

Create `infrastructure/k8s-manifests/network-policies/default-deny.yaml`:

```yaml
# Deny all ingress by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
# Deny all egress by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

### 7.2.3 Allow Necessary Traffic

```yaml
# Allow DNS
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
---
# Allow Ingress from Traefik
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-ingress
  namespace: production
spec:
  podSelector:
    matchLabels:
      expose: "true"
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-system
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
---
# Allow metrics scraping by Prometheus
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus-scraping
  namespace: production
spec:
  podSelector:
    matchLabels:
      prometheus.io/scrape: "true"
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9090
```

Apply to all application namespaces:
```bash
for ns in dev test staging production; do
  kubectl apply -f default-deny.yaml -n $ns
  kubectl apply -f allow-dns.yaml -n $ns
  kubectl apply -f allow-from-ingress.yaml -n $ns
done
```

---

## 7.3 Configure Resource Quotas & Limits

Prevent resource exhaustion with proper limits.

### 7.3.1 Namespace Resource Quotas

Create `infrastructure/k8s-manifests/workload-cluster/quotas/production.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.cpu: "20"
    requests.memory: 40Gi
    limits.cpu: "40"
    limits.memory: 80Gi
    persistentvolumeclaims: "10"
    services.loadbalancers: "5"
---
# Limit number of objects
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
  namespace: production
spec:
  hard:
    pods: "50"
    services: "20"
    configmaps: "30"
    secrets: "30"
```

Similar quotas for other namespaces:
- **dev**: Lower limits (10 CPU, 20Gi RAM)
- **test**: Medium limits (15 CPU, 30Gi RAM)
- **staging**: Same as production

### 7.3.2 LimitRange for Default Limits

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
  - max:
      cpu: "4"
      memory: 8Gi
    min:
      cpu: 100m
      memory: 128Mi
    default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    type: Container
  - max:
      storage: 10Gi
    min:
      storage: 1Gi
    type: PersistentVolumeClaim
```

---

## 7.4 Setup CI/CD Pipeline for Applications

### 7.4.1 Create Shared CI/CD Pipeline Template

In GitLab, create project: `infrastructure/ci-templates`

Create `.gitlab-ci-templates/docker-build-push.yml`:
```yaml
.docker-build:
  image: docker:24-dind
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  before_script:
    # Login to Harbor
    - echo $HARBOR_PASSWORD | docker login harbor.homelab.local -u $HARBOR_USER --password-stdin
  script:
    - docker build -t $IMAGE_TAG .
    - docker tag $IMAGE_TAG $CI_REGISTRY_IMAGE:latest
    - docker push $IMAGE_TAG
    - docker push $CI_REGISTRY_IMAGE:latest
  tags:
    - docker

.trivy-scan:
  image: aquasec/trivy:latest
  script:
    - trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE_TAG
  tags:
    - docker

.k8s-deploy:
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/$APP_NAME $APP_NAME=$IMAGE_TAG -n $NAMESPACE
    - kubectl rollout status deployment/$APP_NAME -n $NAMESPACE
  tags:
    - docker
```

### 7.4.2 Example Application Pipeline

In your `homepage-dashboard` project, create `.gitlab-ci.yml`:

```yaml
include:
  - project: 'infrastructure/ci-templates'
    file: '.gitlab-ci-templates/docker-build-push.yml'

variables:
  CI_REGISTRY_IMAGE: harbor.homelab.local/homelab/homepage
  APP_NAME: homepage
  NAMESPACE: production

stages:
  - build
  - security
  - deploy

build-image:
  extends: .docker-build
  stage: build

scan-image:
  extends: .trivy-scan
  stage: security
  needs:
    - build-image

deploy-production:
  extends: .k8s-deploy
  stage: deploy
  needs:
    - scan-image
  only:
    - main
  environment:
    name: production
    url: https://home.mathiaswouters.com

deploy-staging:
  extends: .k8s-deploy
  stage: deploy
  needs:
    - scan-image
  variables:
    NAMESPACE: staging
  only:
    - develop
  environment:
    name: staging
    url: https://home-staging.homelab.local
```

### 7.4.3 GitOps Flow with ArgoCD

Instead of kubectl deploy in CI/CD, update manifests:

```yaml
update-manifests:
  image: alpine/git:latest
  stage: deploy
  script:
    # Clone k8s-manifests repo
    - git clone http://${CI_USERNAME}:${CI_TOKEN}@192.168.0.11/infrastructure/k8s-manifests.git
    - cd k8s-manifests
    
    # Update image tag in deployment
    - sed -i "s|image:.*|image: $IMAGE_TAG|g" workload-cluster/production/homepage/deployment.yaml
    
    # Commit and push
    - git config user.email "gitlab@homelab.local"
    - git config user.name "GitLab CI"
    - git add .
    - git commit -m "Update homepage image to $CI_COMMIT_SHORT_SHA"
    - git push origin main
    
    # ArgoCD will automatically deploy the change
  only:
    - main
```

---

## 7.5 High Availability & Disaster Recovery

### 7.5.1 Document Recovery Procedures

Create `docs/disaster-recovery.md` in your repo:

```markdown
# Disaster Recovery Procedures

## Scenario 1: Single Node Failure

### Management Cluster
- 3 control-plane nodes provide HA
- Cluster continues running with 2/3 nodes
- Replace failed node:
  1. Deploy new VM with Terraform
  2. Run Ansible playbook to join cluster
  3. Verify: `kubectl get nodes`

### Workload Cluster
- If control-plane fails:
  1. Restore from Velero backup
  2. Or rebuild cluster and let ArgoCD redeploy
- If worker fails:
  1. Longhorn replicates data automatically
  2. Pods reschedule to healthy nodes
  3. Deploy new worker node

## Scenario 2: Complete Cluster Loss

### Recovery Steps:
1. Rebuild clusters with Terraform + Ansible (Phase 4)
2. Restore Velero backups:
   ```bash
   velero restore create --from-backup weekly-full-backup
   ```
3. ArgoCD will sync applications automatically
4. Verify all services

## Scenario 3: Vault Data Loss

**CRITICAL**: This is why you must backup unseal keys!

1. Restore Vault from snapshot:
   ```bash
   vault operator raft snapshot restore vault-snapshot.snap
   ```
2. Unseal Vault with keys (need 3 of 5)
3. Verify secrets: `vault kv list homelab/`

## Scenario 4: GitLab Data Loss

1. Restore GitLab from backup:
   ```bash
   sudo gitlab-backup restore BACKUP=<timestamp>
   ```
2. Reconfigure: `sudo gitlab-ctl reconfigure`
3. Restart: `sudo gitlab-ctl restart`

## RTO/RPO Targets

- **RTO** (Recovery Time Objective): 4 hours
- **RPO** (Recovery Point Objective): 24 hours
  - Daily backups provide 24hr RPO
  - Consider more frequent backups for critical data
```

### 7.5.2 Monitoring Backup Health

Create Prometheus alerts for backup failures:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-backup-alerts
  namespace: monitoring
data:
  backup-alerts.yaml: |
    groups:
    - name: backup-alerts
      interval: 1h
      rules:
      - alert: VeleroBackupFailed
        expr: velero_backup_failure_total > 0
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "Velero backup failed"
          description: "Backup {{ $labels.schedule }} has failed"
      
      - alert: VeleroBackupTooOld
        expr: time() - velero_backup_last_successful_timestamp > 86400
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Velero backup outdated"
          description: "Last successful backup was > 24h ago"
      
      - alert: LonghornBackupFailed
        expr: longhorn_volume_backup_status{status="error"} > 0
        for: 30m
        labels:
          severity: warning
        annotations:
          summary: "Longhorn backup failed"
          description: "Volume {{ $labels.volume }} backup failed"
```

---

## 7.6 Performance Optimization

### 7.6.1 Enable Horizontal Pod Autoscaling

For applications like Homepage:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: homepage-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: homepage
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
```

### 7.6.2 Configure Pod Disruption Budgets

Prevent too many pods from being evicted during maintenance:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: homepage-pdb
  namespace: production
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: homepage
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: argocd-server-pdb
  namespace: argocd
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-server
```

### 7.6.3 Node Affinity for Critical Services

Spread replicas across nodes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: homepage
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: homepage
              topologyKey: kubernetes.io/hostname
```

---

## 7.7 Documentation & Knowledge Base

### 7.7.1 Create Runbooks

Create `docs/runbooks/` directory with common procedures:

**`restart-stuck-pod.md`:**
```markdown
# Runbook: Restart Stuck Pod

## Symptoms
- Pod in CrashLoopBackOff
- Pod stuck in Pending
- Application not responding

## Diagnosis
```bash
kubectl get pod <pod-name> -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

## Resolution
```bash
# Force delete pod
kubectl delete pod <pod-name> -n <namespace> --grace-period=0 --force

# If deployment, trigger rollout restart
kubectl rollout restart deployment/<deployment-name> -n <namespace>
```

## Prevention
- Check resource limits
- Review application logs
- Ensure health checks are configured
```

**`scale-application.md`:**
```markdown
# Runbook: Scale Application

## Manual Scaling
```bash
# Scale replicas
kubectl scale deployment/<name> --replicas=5 -n <namespace>

# Verify
kubectl get pods -n <namespace>
```

## Via ArgoCD
1. Update replica count in Git manifest
2. Push changes
3. ArgoCD syncs automatically
```

### 7.7.2 Architecture Diagrams

Update your architecture diagram with all components:

```
┌─────────────────────────────────────────────────────────────┐
│                        Homelab Network                       │
│                      192.168.0.0/24                          │
└─────────────────────────────────────────────────────────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
┌───────▼────────┐   ┌─────────▼────────┐   ┌────────▼────────┐
│  Infrastructure │   │   Management K8s  │   │  Workload K8s   │
│      VMs        │   │     Cluster       │   │    Cluster      │
├─────────────────┤   ├──────────────────┤   ├─────────────────┤
│ GitLab (.11)    │   │ 3x Control-Plane │   │ 1x Control-Plane│
│ Vault (.20)     │   │   (.30-.32)      │   │    (.40)        │
│ Harbor (.21)    │   │                  │   │ 2x Workers      │
│ Wazuh (.25)     │   │ Components:      │   │   (.41-.42)     │
│ Pi-hole (.10)   │   │ - ArgoCD         │   │                 │
└─────────────────┘   │ - Traefik        │   │ Components:     │
                      │ - MetalLB        │   │ - Traefik       │
                      │ - Cert-Manager   │   │ - MetalLB       │
                      │ - Prometheus     │   │ - Longhorn      │
                      │ - Grafana        │   │ - Applications  │
                      │ - Loki           │   │                 │
                      │ - Falco          │   └─────────────────┘
                      │ - External-DNS   │
                      │ - Velero         │
                      └──────────────────┘
```

---

# Phase 8: Future Enhancements

## 8.1 Pi-Cluster with K3s

When ready to deploy your Raspberry Pi cluster:

### 8.1.1 Prepare Raspberry Pis
- Flash Ubuntu Server 22.04 LTS
- Static IPs: 192.168.0.60-64
- SSH key authentication

### 8.1.2 Install K3s
```bash
# On first Pi (master)
curl -sfL https://get.k3s.io | sh -s - server \
  --cluster-init \
  --disable traefik \
  --write-kubeconfig-mode 644

# Get token
sudo cat /var/lib/rancher/k3s/server/node-token

# On worker Pis
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.60:6443 \
  K3S_TOKEN=<token> sh -
```

### 8.1.3 Add to ArgoCD
```bash
scp pi@192.168.0.60:/etc/rancher/k3s/k3s.yaml ~/.kube/config-pi
argocd cluster add pi-cluster --kubeconfig ~/.kube/config-pi
```

Use for: IoT workloads, edge computing, home automation

---

## 8.2 Service Mesh (Istio or Linkerd)

For advanced traffic management:

### Benefits:
- mTLS between services
- Traffic splitting (canary deployments)
- Advanced observability
- Circuit breaking

### Recommendation:
- **Linkerd**: Simpler, lower resource usage
- **Istio**: More features, steeper learning curve

---

## 8.3 GitOps for Infrastructure (Crossplane)

Manage cloud/infrastructure resources via K8s:

```yaml
apiVersion: compute.gcp.crossplane.io/v1beta1
kind: Instance
metadata:
  name: my-instance
spec:
  forProvider:
    machineType: n1-standard-1
    zone: us-central1-a
```

---

## 8.4 Advanced Monitoring

### Add distributed tracing:
- **Jaeger** or **Tempo** for request tracing
- **OpenTelemetry** for metrics/logs/traces

### Add cost monitoring:
- **OpenCost** for Kubernetes cost analysis

---

# Maintenance Checklist

## Daily
- [ ] Check Grafana dashboards for anomalies
- [ ] Review ArgoCD sync status
- [ ] Check Falco security alerts

## Weekly
- [ ] Review backup success in Velero
- [ ] Check Longhorn volume health
- [ ] Review Trivy vulnerability scan reports
- [ ] Update cluster documentation

## Monthly
- [ ] Update Kubernetes versions (test in staging first)
- [ ] Review and update resource quotas
- [ ] Test disaster recovery procedures
- [ ] Rotate secrets and tokens
- [ ] Review and cleanup unused resources

## Quarterly
- [ ] Full disaster recovery test
- [ ] Security audit (OWASP, CIS benchmarks)
- [ ] Review and update documentation
- [ ] Evaluate new technologies/tools

---

This plan is comprehensive but flexible. Feel free to adjust the order based on your learning goals and available time!

## Quick Reference Commands

### Kubectl Essentials
```bash
# Switch contexts
kubectl config use-context management-cluster
kubectl config use-context workload-cluster

# Check cluster health
kubectl get nodes
kubectl get pods -A
kubectl top nodes
kubectl top pods -A

# Troubleshooting
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --tail=100
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
```

### ArgoCD CLI
```bash
# Login
argocd login argocd.homelab.local --username admin --insecure

# App management
argocd app list
argocd app get <app-name>
argocd app sync <app-name>
argocd app diff <app-name>

# Manual sync
argocd app sync <app-name> --force --prune
```

### Velero Backups
```bash
# Create backup
velero backup create manual-backup --wait

# List backups
velero backup get

# Restore
velero restore create --from-backup <backup-name>

# Check logs
velero backup logs <backup-name>
```

### Vault Operations
```bash
export VAULT_ADDR='http://192.168.0.20:8200'

# Login
vault login <token>

# Read secret
vault kv get homelab/ci/harbor

# Write secret
vault kv put homelab/ci/test key=value

# List secrets
vault kv list homelab/ci/
```

---

Good luck with your homelab journey! 🚀
k8s-mgmt-cp1 ansible_host=192.168.0.30
k8s-mgmt-cp2 ansible_host=192.168.0.31
k8s-mgmt-cp3 ansible_host=192.168.0.32

[k8s_control_plane:vars]
ansible_user=mathias
ansible_ssh_private_key_file=~/.ssh/homelab
```

Create `playbook.yml`:
```yaml
---
- name: Prepare all nodes
  hosts: k8s_control_plane
  become: yes
  roles:
    - common
    - docker
    - kubernetes-prereqs

- name: Initialize first control plane
  hosts: k8s-mgmt-cp1
  become: yes
  roles:
    - kubernetes-init

- name: Join additional control planes
  hosts: k8s-mgmt-cp2,k8s-mgmt-cp3
  become: yes
  roles:
    - kubernetes-join-control-plane
```

**Role: common** (`roles/common/tasks/main.yml`):
```yaml
---
- name: Disable swap
  command: swapoff -a
  when: ansible_swaptotal_mb > 0

- name: Remove swap from fstab
  lineinfile:
    path: /etc/fstab
    regexp: '.*swap.*'
    state: absent

- name: Load kernel modules
  modprobe:
    name: "{{ item }}"
    state: present
  loop:
    - overlay
    - br_netfilter

- name: Set kernel parameters
  sysctl:
    name: "{{ item.name }}"
    value: "{{ item.value }}"
    state: present
    reload: yes
  loop:
    - { name: 'net.bridge.bridge-nf-call-iptables', value: '1' }
    - { name: 'net.bridge.bridge-nf-call-ip6tables', value: '1' }
    - { name: 'net.ipv4.ip_forward', value: '1' }
```

**Role: kubernetes-prereqs** (`roles/kubernetes-prereqs/tasks/main.yml`):
```yaml
---
- name: Install required packages
  apt:
    name:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
    state: present
    update_cache: yes

- name: Add Kubernetes GPG key
  apt_key:
    url: https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key
    state: present

- name: Add Kubernetes repository
  apt_repository:
    repo: deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
    state: present

- name: Install Kubernetes packages
  apt:
    name:
      - kubelet=1.28.0-1.1
      - kubeadm=1.28.0-1.1
      - kubectl=1.28.0-1.1
    state: present
    update_cache: yes

- name: Hold Kubernetes packages
  dpkg_selections:
    name: "{{ item }}"
    selection: hold
  loop:
    - kubelet
    - kubeadm
    - kubectl
```

**Role: kubernetes-init** (`roles/kubernetes-init/tasks/main.yml`):
```yaml
---
- name: Initialize Kubernetes cluster
  command: >
    kubeadm init
    --control-plane-endpoint "192.168.0.30:6443"
    --upload-certs
    --pod-network-cidr=10.244.0.0/16
  args:
    creates: /etc/kubernetes/admin.conf

- name: Create .kube directory
  file:
    path: /home/mathias/.kube
    state: directory
    owner: mathias
    group: mathias

- name: Copy kubeconfig
  copy:
    src: /etc/kubernetes/admin.conf
    dest: /home/mathias/.kube/config
    owner: mathias
    group: mathias
    remote_src: yes

- name: Install Calico CNI
  become_user: mathias
  command: kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml

- name: Get join command for control plane
  command: kubeadm token create --print-join-command
  register: join_command

- name: Get certificate key
  command: kubeadm init phase upload-certs --upload-certs
  register: cert_key_output

- name: Set join command fact
  set_fact:
    control_plane_join_command: "{{ join_command.stdout }} --control-plane --certificate-key {{ cert_key_output.stdout_lines[-1] }}"

- name: Save join command
  copy:
    content: "{{ control_plane_join_command }}"
    dest: /tmp/k8s-join-control-plane.sh
    mode: '0755'
```

**Role: kubernetes-join-control-plane** (`roles/kubernetes-join-control-plane/tasks/main.yml`):
```yaml
---
- name: Copy join command from first control plane
  fetch:
    src: /tmp/k8s-join-control-plane.sh
    dest: /tmp/k8s-join-control-plane.sh
    flat: yes
  delegate_to: k8s-mgmt-cp1

- name: Join control plane
  command: "{{ lookup('file', '/tmp/k8s-join-control-plane.sh') }}"
  args:
    creates: /etc/kubernetes/kubelet.conf
```

Run:
```bash
cd homelab/infrastructure/k8s-management/terraform
terraform init && terraform apply

cd ../ansible
ansible-playbook -i inventory/hosts.ini playbook.yml
```

### 4.1.3 Configure kubectl on Local Machine

```bash
# Copy kubeconfig from first control plane
scp mathias@192.168.0.30:~/.kube/config ~/.kube/config-mgmt

# Set KUBECONFIG
export KUBECONFIG=~/.kube/config-mgmt

# Test
kubectl get nodes
kubectl get pods -A
```

### 4.1.4 Taint Control Plane Nodes (Allow Workloads)

Since you're not using dedicated workers:
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

---

## 4.2 Install Core Infrastructure on Management Cluster

### 4.2.1 Install MetalLB

Create `homelab/kubernetes/management/metallb/values.yaml`:
```yaml
controller:
  enabled: true

speaker:
  enabled: true
  frr:
    enabled: false
```

Create `homelab/kubernetes/management/metallb/ipaddresspool.yaml`:
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: homelab-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.50-192.168.0.70
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: homelab-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - homelab-pool
```

Install:
```bash
# Create namespace
kubectl create namespace metallb-system

# Install MetalLB with Helm
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb -n metallb-system -f values.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=metallb -n metallb-system --timeout=300s

# Apply IP pool
kubectl apply -f ipaddresspool.yaml
```

Test:
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port=80
kubectl get svc nginx

# Should show EXTERNAL-IP: 192.168.0.50
curl 192.168.0.50
```

### 4.2.2 Install Cert-Manager

Create `homelab/kubernetes/management/cert-manager/values.yaml`:
```yaml
installCRDs: true

prometheus:
  enabled: true
  servicemonitor:
    enabled: true
```

Install:
```bash
kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --values values.yaml
```

Configure Let's Encrypt (we'll add DNS challenge later with Cloudflare):
```bash
# For now, create self-signed issuer for internal services
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF
```

### 4.2.3 Install Traefik

Create `homelab/kubernetes/management/traefik/values.yaml`:
```yaml
deployment:
  kind: DaemonSet

service:
  type: LoadBalancer
  annotations:
    metallb.universe.tf/loadBalancerIPs: 192.168.0.50

ports:
  web:
    port: 80
    expose: true
  websecure:
    port: 443
    expose: true
    tls:
      enabled: true
  traefik:
    port: 9000
    expose: true

ingressRoute:
  dashboard:
    enabled: true

additionalArguments:
  - "--api.insecure=true"
  - "--providers.kubernetescrd"
  - "--providers.kubernetesingress"

logs:
  general:
    level: INFO
  access:
    enabled: true
```

Install:
```bash
kubectl create namespace ingress-system

helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik \
  --namespace ingress-system \
  --values values.yaml

# Check LoadBalancer IP
kubectl get svc traefik -n ingress-system
```

Add DNS in Pi-hole:
```bash
# SSH to Pi-hole
echo "192.168.0.50 traefik.homelab.local" >> /etc/hosts
pihole restartdns
```

Access Traefik dashboard: `http://traefik.homelab.local:9000/dashboard/`

### 4.2.4 Install ArgoCD

Create `homelab/kubernetes/management/argocd/values.yaml`:
```yaml
server:
  ingress:
    enabled: true
    ingressClassName: traefik
    hostname: argocd.homelab.local
    tls: false

configs:
  params:
    server.insecure: true
```

Install:
```bash
kubectl create namespace argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --values values.yaml

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Add DNS:
```bash
# On Pi-hole
echo "192.168.0.50 argocd.homelab.local" >> /etc/hosts
pihole restartdns
```

Access: `http://argocd.homelab.local`
- Username: `admin`
- Password: (from command above)

### 4.2.5 Configure ArgoCD with GitLab

```bash
# Login to ArgoCD CLI
argocd login argocd.homelab.local --username admin --insecure

# Add GitLab repository
argocd repo add http://192.168.0.11/infrastructure/k8s-manifests.git \
  --username <your-gitlab-username> \
  --password <your-gitlab-token>

# Verify
argocd repo list
```

---

## 4.3 Deploy Workload Cluster

### 4.3.1 Provision VMs

Similar to management cluster, but with 1 control-plane + 2 workers:

```hcl
# terraform/main.tf
variable "vm_configs" {
  default = {
    "k8s-work-cp1" = {
      vm_id       = 140
      name        = "k8s-work-cp1"
      tags        = "vm,k8s,control-plane"
      memory      = 4096
      cores       = 2
      ipconfig    = "ip=192.168.0.40/24,gw=192.168.0.1"
      disk_size   = "40G"
      # ... other settings
    }
    "k8s-work-w1" = {
      vm_id       = 141
      name        = "k8s-work-w1"
      tags        = "vm,k8s,worker"
      memory      = 8192
      cores       = 4
      ipconfig    = "ip=192.168.0.41/24,gw=192.168.0.1"
      disk_size   = "60G"
      # ...
    }
    "k8s-work-w2" = {
      vm_id       = 142
      name        = "k8s-work-w2"
      tags        = "vm,k8s,worker"
      memory      = 8192
      cores       = 4
      ipconfig    = "ip=192.168.0.42/24,gw=192.168.0.1"
      disk_size   = "60G"
      # ...
    }
  }
}
```

### 4.3.2 Install Kubernetes (Kubeadm)

Reuse the same Ansible playbooks with different inventory:

`inventory/hosts.ini`:
```ini
[k8s_control_plane]












































---
---
---

# Phase 4: Deploy K8s

**K8s Namespaces**:
    - dev ???
    - test ???
    - staging ???
    - acc ???
    - prd ???
    - ... ???

## 4.1 Management Cluster

- What OS ???

...

## 4.2 Workload Cluster

- What OS ???

...

## 4.3 Pi Cluster (using K3s)

...


# Phase 5: Observability & Security

## 5.1 Deploy Monitoring Stack

- Prometheus + Grafana
- Loki + Promtail
- Tempo or Jaeger

- Configre alerts (in Slack / Mail / ...) using Alertmanager or something else

...

## 5.2 Deploy Security Stack

- Wazuh
- Scanning tool (like Trivy)
- Runtime security (Like Falco)
- ...

...

## 5.3 Deploy NetBox

...

---

# Phase 6: Other Services

## 6.1

...

---

# Phase 5: Advanced impresive things to do ...

- Things that look good at my CV
- To get more experience in these advanced things.

...

---

# Phase 6: Homelab Maintenance

## 6.1 Automatic maintenance jobs

...

## 6.2 Update GitLab

1. Update `gitlab_version` in `host_vars/gitlab.yml`
2. Re-run the playbook:
   ```bash
   ansible-playbook site.yml
   ```

...

## 6.3 ...

...
