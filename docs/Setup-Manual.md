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

Create your first repo `gitlab-infrastructure` with this structure:
```
gitlab-infrastructure/
├── terraform/
│   ├── groups.tf
│   ├── projects.tf
│   ├── users.tf
│   ├── runners.tf
│   ├── variables.tf
│   └── providers.tf
├── .gitlab-ci.yml
└── README.md
```

### 2. Create gitlab-infrastructure project

1) Create a new project: `yourusername/gitlab-infrastructure`

### 2. Copy the code to the gitlab-infrastructure repo in GitLab

Copy the code from the [terraform-gitlab](/bootstrap/gitlab-infrastructure/) folder in this GitHub repo to the recently created `gitlab-infrastructure` repo in GitLab

### 2. Run the gitlab-infrastructure code locally

...

## 2.1 Deploy the GitLab Terraform Code

...

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

## 3.1

...

## 3.2

...

## 3.3

...

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
