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

#### Prerequisites

1. **Terraform deployment completed**: VM should be provisioned and accessible at `192.168.0.11`
2. **SSH access configured**: Your SSH key (`~/.ssh/homelab`) should be set up
3. **Ansible installed** on your local machine:
   ```bash
   pip install ansible
   ```
4. **Ansible Docker community collection**:
   ```bash
   ansible-galaxy collection install community.docker
   ```

#### File Structure

```
bootstrap/ansible/
├── ansible.cfg
├── site.yml
├── inventory/
│   └── hosts.ini
└── host_vars/
    └── gitlab.yml
```

#### Configuration Steps

##### 1. Update Configuration Files

###### `ansible.cfg`
- Replace `your_ciuser` with your actual CI user from Terraform variables

###### `inventory/hosts.ini`
- Replace `your_ciuser` with your actual CI user
- Verify the IP address matches your Terraform configuration (192.168.0.11)

###### `host_vars/gitlab.yml`
- **Required changes**:
  - `gitlab_hostname`: Set your actual hostname/domain
  - `gitlab_external_url`: Set your actual URL (must match hostname)
  - `gitlab_version`: Choose your desired GitLab version (check [GitLab tags](https://hub.docker.com/r/gitlab/gitlab-ee/tags))
  - `gitlab_edition`: Choose `"ee"` (Enterprise) or `"ce"` (Community)

- **Optional changes**:
  - Custom ports (if not using defaults)
  - SMTP settings for email notifications

##### 2. Test Connectivity

```bash
cd bootstrap/ansible
ansible gitlab -m ping
```

Expected output:
```
gitlab | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

##### 3. Run the Playbook

```bash
ansible-playbook site.yml
```

This will:
1. Install Docker and required dependencies
2. Create directory structure for GitLab data
3. Deploy GitLab using Docker Compose
4. Wait for GitLab to initialize
5. Display the initial root password

**Note**: Initial deployment takes 5-10 minutes. The playbook will wait for GitLab to become healthy.

#### Post-Installation

##### 1. Access GitLab

Open your browser and navigate to your configured URL (e.g., `https://gitlab.homelab.local`)

##### 2. First Login

- **Username**: `root`
- **Password**: Displayed at the end of the playbook run
- **Important**: Change the root password immediately after first login

##### 3. Retrieve Password Later (if needed)

If you need to retrieve the initial password again (within 24 hours):

```bash
ssh your_ciuser@192.168.0.11
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

#### Useful Commands

##### Monitor GitLab Startup
```bash
sudo docker logs -f gitlab
```

##### Check GitLab Status
```bash
sudo docker exec -it gitlab gitlab-ctl status
```

##### Restart GitLab
```bash
sudo docker restart gitlab
```

##### Access GitLab Console
```bash
sudo docker exec -it gitlab /bin/bash
```

##### Stop GitLab
```bash
cd /srv/gitlab
sudo docker compose down
```

##### Start GitLab
```bash
cd /srv/gitlab
sudo docker compose up -d
```

#### Customization Examples

##### Using Custom Ports

In `host_vars/gitlab.yml`:

```yaml
gitlab_http_port: 8929
gitlab_https_port: 443
gitlab_ssh_port: 2424
gitlab_external_url: "http://gitlab.homelab.local:8929"
```

##### Enabling SMTP for Email

In `host_vars/gitlab.yml`, uncomment and configure:

```yaml
gitlab_smtp_enabled: true
gitlab_smtp_address: "smtp.gmail.com"
gitlab_smtp_port: 587
gitlab_smtp_user: "your-email@gmail.com"
gitlab_smtp_password: "your-app-password"
gitlab_smtp_domain: "smtp.gmail.com"
gitlab_smtp_authentication: "login"
gitlab_smtp_enable_starttls: true
gitlab_email_from: "gitlab@homelab.local"
```

Then re-run the playbook to apply changes.

#### Troubleshooting

##### GitLab Not Starting

Check logs:
```bash
sudo docker logs gitlab
```

##### Connection Refused

Wait longer - GitLab initialization can take 10+ minutes on first run.

##### SSH Port Conflicts

If port 22 is already in use, configure a custom SSH port in `host_vars/gitlab.yml`.

##### Memory Issues

GitLab requires at least 8GB RAM. Your Terraform config allocates 16GB which should be sufficient.

#### Backup and Maintenance

##### Backup GitLab Data

```bash
sudo docker exec -t gitlab gitlab-backup create
```

Backups are stored in `/srv/gitlab/data/backups/`

##### Update GitLab

1. Update `gitlab_version` in `host_vars/gitlab.yml`
2. Re-run the playbook:
   ```bash
   ansible-playbook site.yml
   ```

#### Integration with Your Workflow

Once GitLab is running:

1. Create your first project
2. Push your infrastructure code (including this bootstrap)
3. Set up GitLab CI/CD for automated deployments
4. Deploy the rest of your homelab services from GitLab

#### Security Recommendations

1. **Change the root password** immediately after first login
2. **Enable 2FA** for the root account
3. **Configure HTTPS** with valid certificates (Let's Encrypt recommended)
4. **Set up regular backups** using GitLab's built-in backup functionality
5. **Restrict network access** using Proxmox firewall or iptables
6. **Keep GitLab updated** regularly

