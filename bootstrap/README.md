# Homelab Bootstrap

This is the explanation on how to setup the minimum of my homelab, ...

---

## 1. Configure local machine

- Install needed packages: Terraform, Ansible, K8s packages, ...

- Create SSH Key:
```bash
ssh-keygen -t ed25519 -C "homelab"
```

- Add folowing line to ssh config file:
```bash
Host *
  IdentityFile ~/.ssh/homelab
  IdentitiesOnly yes
```

- ...

## 2. Install & Configure Proxmox

...

---

## 3. Configure a cloud-init vm template

...

---

## 4. Install a Pi-Hole LXC Container

...

---

## 5. Configure proxmox to use Pi-Hole as DNS

...

---

## 6. Install a GitLab VM (using Docker)

### 6.1 Provisioning / Deployting the VM

Terraform part ...

### 6.2 Configuring the VM

```bash
ansible-playbook site.yml
```

### 6.3 GitLab Post-Installation

##### 6.3.1 Access GitLab

Open your browser and navigate to your configured URL

##### 6.3.2 First Login

- **Username**: `root`
- **Password**: Displayed at the end of the playbook run

If you need to retrieve the initial password again (within 24 hours):

```bash
ssh your_ciuser@192.168.0.11
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

##### 6.3.3 Change Root Password

1) Go to the `User settings` and click `Password`
2) Change the password here

##### 6.3.4 Create GitLab Config Group and Project

1) Create a new `Group` with the Group name: `administration`
2) In that new `administration` group, create a new `gitlab_config` project

##### 6.3.5 Copy the code to the GitLab Repo

1) Copy the code from the [terraform-gitlab](/bootstrap/terraform-gitlab/) folder in this GitHub repo to the recently created `gitlab_config` repo in GitLab

##### 6.3.6

##### 6.3.7

##### 6.3.8

##### 6.3.9

### 6.4 Update GitLab

1. Update `gitlab_version` in `host_vars/gitlab.yml`
2. Re-run the playbook:
   ```bash
   ansible-playbook site.yml
   ```
