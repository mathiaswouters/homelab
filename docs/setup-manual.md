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

## 3.1 Deploy HashiCorp Vault

- Create VM with Terraform (192.168.0.20, 2 CPU, 4GB RAM, 20GB disk)
- Install Vault with Ansible
- Initialize Vault (save unseal keys securely!)
- Unseal Vault (need 3 of 5 keys)
- Enable KV v2 secrets engine
- Create test secret to verify

...

## 3.2 Deploy Harbor

- Create VM with Terraform (192.168.0.21, 4 CPU, 8GB RAM, 100GB disk)
- Install Docker with Ansible
- Install Harbor with Ansible
- Configure Harbor (enable vulnerability scanning)
- Create `homelab` project
- Create robot account for K8s
- Add DNS record in Pi-hole: `harbor.homelab.local`
- Test: Push image from GitLab Runner

...

## 3.3 Integrate Vault with GitLab

- Configure JWT auth in Vault for GitLab CI
- Create policy for CI/CD access
- Store Harbor credentials in Vault
- Store Proxmox credentials in Vault
- Test Vault integration in GitLab pipeline

...


# Phase 4: Deploy Kubernetes Clusters

**Proxmox cluster will use kubeadm (vanilla K8s). The pi-cluster will run k3s.**

## 4.1 Deploy Management Cluster (3 Control-Plane Nodes) --> kubeadm

### 4.1.1 Provision VMs
- Create 3 VMs with Terraform (192.168.0.30-32, 2 CPU, 4GB RAM each)
- Install Kubernetes prerequisites with Ansible --> kubeadm
- Initialize first control-plane with kubeadm
- Install Calico CNI
- Join other control-planes
- Remove control-plane taints (allow workloads)
- Copy kubeconfig to local machine

### 4.1.2 Install Core Services

**ArgoCD:**
- Create namespace: `argocd`
- Install ArgoCD with Helm
- Configure Traefik ingress
- Add DNS: `argocd.homelab.local`
- Get initial admin password
- Add GitLab repository to ArgoCD

**MetalLB:**
- Create namespace: `metallb-system`
- Install MetalLB with Helm
- Configure IP pool: `192.168.0.50-192.168.0.70`
- Apply L2Advertisement

**Traefik:**
- Create namespace: `ingress-system`
- Install Traefik with Helm
- Configure LoadBalancer IP: `192.168.0.50`
- Enable dashboard
- Add DNS: `traefik.homelab.local`

**Cert-Manager:**
- Create namespace: `cert-manager`
- Install Cert-Manager with Helm (with CRDs)
- Create self-signed ClusterIssuer (for now)

**External-DNS:**
- Create Cloudflare API token
- Store token in Vault
- Create namespace: `ingress-system` (reuse)
- Install External-DNS with Helm
- Configure for Cloudflare provider
- Test with sample ingress

**Cert-Manager + Let's Encrypt:**
- Create ClusterIssuer for Let's Encrypt (DNS-01 with Cloudflare)
- Create ClusterIssuer for Let's Encrypt staging
- Update Traefik/ArgoCD ingress to use TLS
- Verify certificates are issued

**Monitoring Stack:**
- Create namespace: `monitoring`
- Install kube-prometheus-stack with Helm (Prometheus + Grafana + Alertmanager)
- Configure persistent storage for Prometheus
- Add Traefik ingress for Grafana
- Add DNS: `grafana.homelab.local`
- Configure Alertmanager (Slack webhook)

**Loki + Promtail:**
- Install Loki-stack in `monitoring` namespace
- Configure persistent storage for Loki
- Promtail auto-deployed as DaemonSet
- Add Loki as datasource in Grafana

**Security Tools:**
- Create namespace: `security`
- Install Falco with Helm (runtime security)
- Install Trivy Operator with Helm (vulnerability scanning)
- Configure Falcosidekick for Slack alerts

**External Secrets Operator:**
- Create namespace: `vault-integration`
- Install External Secrets Operator with Helm
- Configure Vault Kubernetes auth
- Create SecretStore pointing to Vault
- Test with sample ExternalSecret

## 4.2 Deploy Workload Cluster (2 Control-Plane + 3 Workers) --> kubeadm

### 4.2.1 Provision VMs
- Create 5 VMs with Terraform (192.168.0.40-42)
  - Control-plane: 2 CPU, 4GB RAM
  - Workers: 4 CPU, 8GB RAM each
- Install Kubernetes with Ansible --> kubeadm
- Initialize control-plane with kubeadm
- Install Calico CNI
- Join worker nodes
- Copy kubeconfig to local machine

### 4.2.2 Add Cluster to ArgoCD
- Add workload cluster to ArgoCD from management cluster
- Verify cluster appears in ArgoCD UI

### 4.2.3 Deploy Services via ArgoCD

Create ArgoCD Applications for workload cluster:

**MetalLB:**
- Deploy MetalLB via ArgoCD
- Configure IP pool: `192.168.0.80-192.168.0.100`

**Traefik:**
- Deploy Traefik via ArgoCD
- Configure LoadBalancer IP: `192.168.0.51`

**Cert-Manager:**
- Deploy Cert-Manager via ArgoCD
- Deploy Let's Encrypt ClusterIssuers via ArgoCD

**External-DNS:**
- Deploy External-DNS via ArgoCD

**Longhorn:**
- Deploy Longhorn via ArgoCD
- Set as default StorageClass
- Configure 2 replicas per volume
- Add Traefik ingress for Longhorn UI
- Add DNS: `longhorn.homelab.local`

**Application Namespaces:**
- Create namespaces via ArgoCD: `dev`, `test`, `staging`, `production`
- Apply ResourceQuotas to each namespace
- Apply LimitRanges to each namespace
- Apply default-deny NetworkPolicies

**Service Mesh (Optional - Choose One):**

*Option A: Cilium (Recommended for beginners)*
- Deploy Cilium via ArgoCD (replaces Calico)
- Enable Hubble for observability
- Configure network policies

*Option B: Istio*
- Deploy Istio with istioctl
- Deploy Kiali for visualization
- Configure mTLS between services

*Option C: Linkerd*
- Deploy Linkerd CLI
- Install Linkerd control plane
- Enable auto-injection per namespace


## 4.3 Pi Cluster

This will run K3s

...


# Phase 5: Observability & Security Hardening

## 5.1 Configure Monitoring

**Prometheus:**
- Add scrape configs for workload cluster
- Create ServiceMonitors for applications
- Import Kubernetes dashboards in Grafana

**Grafana Dashboards:**
- Kubernetes Cluster Monitoring (ID: 15760)
- Node Exporter Full (ID: 1860)
- Traefik (ID: 12250)
- ArgoCD (ID: 14584)
- Longhorn (ID: 13032)

**Alerting:**
- Configure Prometheus alerts for:
  - Node down
  - Pod CrashLooping
  - High CPU/Memory
  - Disk space low
  - Certificate expiring
- Configure Alertmanager Slack integration

## 5.2 Configure Logging

**Loki + Promtail:**
- Verify Promtail is collecting logs from both clusters
- Create LogQL queries for common scenarios
- Add Loki dashboards in Grafana

## 5.3 Configure Tempo or Jaeger

**Tempo or Jaeger:**
- ...

## 5.4 Configre alerts

**Configre alerts:** 
- in Slack / Mail / ... 
- using Alertmanager or something else
- ...

## 5.5 Deploy Wazuh SIEM

**Wazuh Manager (VM):**
- Create VM with Terraform (192.168.0.25, 4 CPU, 8GB RAM)
- Install Wazuh Manager with Ansible
- Configure Wazuh agents for:
  - All K8s nodes (DaemonSet)
  - Infrastructure VMs (Vault, Harbor, GitLab)

## 5.6 Security Hardening

**Network Policies:**
- Apply default-deny policies to all namespaces
- Allow DNS traffic
- Allow Traefik ingress
- Allow Prometheus scraping
- Allow inter-service communication where needed

**Pod Security:**
- Enable Pod Security Standards (restricted)
- Configure PodDisruptionBudgets for critical apps
- Set resource limits on all pods

**Trivy (Image Security):**
- Enable Trivy scanning in Harbor
- Configure GitLab CI to scan images
- Block deployment of images with HIGH/CRITICAL vulnerabilities

**Runtime security (Like Falco):**
- ...

## 5.7 Backup Strategy

**Velero (K8s Backups):**
- Deploy MinIO in management cluster
- Install Velero in both clusters
- Configure S3 backend (MinIO)
- Create backup schedules:
  - Daily: All namespaces (30 day retention)
  - Weekly: Full cluster (90 day retention)
- Test restore procedure

**Longhorn Backups:**
- Configure Longhorn backup target (MinIO S3)
- Create recurring backup jobs (daily)
- Test volume restore

**Infrastructure Backups:**
- GitLab: Configure automated backups to MinIO (cron)
- Vault: Create snapshot script (cron)
- Harbor: Configure backup of registry data

**Backup Monitoring:**
- Create Prometheus alerts for backup failures
- Add Grafana dashboard for backup status

---


# Phase 6: Deploy Applications

## 6.1 Setup GitLab CI/CD Templates

**Create Shared Pipeline Templates:**
- Docker build & push to Harbor
- Trivy security scanning
- Update K8s manifests (GitOps approach)
- Helm chart deployment

## 6.2 Deploy Core Applications

**Homepage Dashboard:**
- Create GitLab project: `applications/homepage-dashboard`
- Create Dockerfile
- Create K8s manifests (Deployment, Service, Ingress)
- Create `.gitlab-ci.yml` using shared templates
- Deploy via ArgoCD to `production` namespace
- Configure ingress with TLS: `home.mathiaswouters.com`

**NetBox (CMDB):**
- ...

**Nextcloud:**
- Create GitLab project: `applications/nextcloud`
- Deploy via ArgoCD using Helm chart
- Configure Longhorn PVC for data
- Configure ingress: `cloud.mathiaswouters.com`
- Integrate with LDAP (optional)

**Jellyfin:**
- Create GitLab project: `applications/jellyfin`
- Deploy via ArgoCD
- Configure Longhorn PVC for media
- Configure ingress: `media.mathiaswouters.com`

**ARR Stack (Sonarr, Radarr, etc.):**
- Create GitLab project: `applications/arr-stack`
- Deploy each service via ArgoCD
- Configure shared PVC for downloads
- Internal ingress only (no external access)

## 6.3 Configure HPA & Auto-scaling

**For each application:**
- Create HorizontalPodAutoscaler
- Set min/max replicas
- Configure CPU/Memory thresholds
- Test scaling behavior

---


# Phase 7: Advanced Features

- **Things that look good at my CV**
- **To get more experience in these advanced things.**

## 7.1 Multi-Environment Setup

**Configure Environments:**
- Create branch protection rules in GitLab
- Configure ArgoCD for multi-environment:
  - `develop` branch → `staging` namespace
  - `main` branch → `production` namespace
- Implement promotion workflow

## 7.2 Canary Deployments

**Using Service Mesh:**
- Configure traffic splitting (90/10)
- Deploy canary version
- Monitor metrics
- Promote or rollback

**OR using Argo Rollouts:**
- Install Argo Rollouts
- Create Rollout resource instead of Deployment
- Define analysis templates
- Configure automated rollback

## 7.3 Cost Optimization

**Deploy OpenCost:**
- Install OpenCost in monitoring namespace
- Integrate with Prometheus
- Create cost dashboards in Grafana
- Set budget alerts

## 7.4 Infrastructure Documentation

**Create Runbooks:**
- Common troubleshooting procedures
- Disaster recovery steps
- Scaling procedures
- Update procedures

**Update Architecture Diagrams:**
- Complete network diagram
- Service dependency map
- Data flow diagrams

## 7.5 ...

**...:**
- ...

---


# Phase 8: Future Enhancements

## 8.1 Deploy Pi-Cluster (K3s)

- Flash Ubuntu on Raspberry Pis
- Install K3s (1 master + 3 workers)
- Add to ArgoCD
- Deploy edge workloads (Home Assistant, Node-RED)

## 8.2 Advanced GitOps

**Kustomize:**
- Refactor manifests to use Kustomize
- Create base + overlays (dev/staging/prod)

**Helm Chart Library:**
- Create custom Helm charts in GitLab
- Store in Harbor as OCI artifacts

## 8.3 Advanced Monitoring

**Distributed Tracing:**
- Deploy Jaeger or Tempo
- Configure OpenTelemetry
- Integrate with applications

**Chaos Engineering:**
- Deploy Chaos Mesh
- Create chaos experiments
- Validate system resilience

## 8.4 Multi-Cluster Service Mesh

- Connect management + workload + pi clusters
- Enable cross-cluster service discovery
- Configure multi-cluster mTLS

## 8.5 ...

- ...

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

## Maintenance Checklist

### Daily
- Check Grafana for anomalies
- Review ArgoCD sync status
- Check Falco/Wazuh alerts

### Weekly
- Verify backup success
- Review vulnerability scan reports
- Check certificate expiration dates
- Update documentation

### Monthly
- Update Kubernetes versions (staging → production)
- Rotate secrets and credentials
- Review resource usage and quotas
- Test disaster recovery (in staging)

### Quarterly
- Full DR test (restore from backups)
- Security audit
- Cost optimization review
- Infrastructure capacity planning

---