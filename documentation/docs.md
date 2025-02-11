# Homelab Documentation

## Overview

This repository contains the infrastructure and automation code for my home lab environment. The primary goal is to create a scalable and manageable system for hosting Kubernetes clusters, applications, and related services. While the provisioning of Proxmox VMs is handled manually, automation tools like Ansible and Kubernetes are utilized to streamline configuration, deployment, and management processes.

## Goals

- Manually provision and configure staging and production VMs on Proxmox.
- Automate Kubernetes cluster setup and management using Ansible.
- Implement GitOps principles for declarative and version-controlled infrastructure and applications.
- Enable CI/CD pipelines to ensure smooth deployments and updates for both infrastructure and applications.
- Securely manage sensitive data like secrets and credentials.

## Key Features

- **Ansible**:
    - Automate the installation and configuration of Kubernetes components, container runtimes, and dependencies.
    - Manage VM-level configuration (e.g., OS setup, security hardening).

- **Kubernetes (K3S)**:
    - Deploy staging and production clusters.
    - Utilize manifests and Helm charts for workload deployments.

- **GitOps**:
    - Leverage ArgoCD or Flux to synchronize cluster state from this repository.

- **CI/CD Pipelines**:
    - Automate Kubernetes cluster configuration.
    - Deploy applications seamlessly with minimal downtime.

## Structure

```plaintext
homelab/
├── ansible/                    # Ansible playbooks for cluster setup and configuration
├── kubernetes/                 # Kubernetes manifests and Helm charts for workloads
├── pipelines/                  # CI/CD pipeline configurations
├── gitops/                     # GitOps configurations for ArgoCD/Flux
├── .gitignore                  # Ignore sensitive files and generated state
├── README.md                   # Documentation
└── LICENSE                     # Project license
```

## Manual VM Provisioning

While the rest of the homelab infrastructure is automated, VMs on Proxmox are manually created and configured. This decision simplifies initial setup and allows greater control over VM provisioning while relying on Ansible to automate subsequent configuration and deployment tasks.

### Steps for Manual VM Provisioning:
1. Log in to the Proxmox web interface.
2. Create a new virtual machine for staging or production purposes.
3. Configure hardware resources (CPU, memory, storage) according to requirements.
4. Install the desired operating system and ensure network connectivity.
5. Apply a baseline configuration for the VM (e.g., SSH access, updates).
6. Use Ansible to further configure and deploy Kubernetes components.

### Architecture

You have on Ansible control node that manages all the vm's. This is going to be just my desktop pc.

Then there is for each cluster one master node and 2 worker nods.

### Steps

#### Configure Cluster VM's

1) ...

#### Configure SSH Access Manually

1) Generate an SSH key pair (if you don't already have one) on your local machine:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

2) Copy the public key (~/.ssh/id_rsa.pub) to each VM:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_staging_master
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_staging_worker1
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_staging_worker2
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_production_master
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_production_worker1
ssh-copy-id -i ~/.ssh/id_rsa.pub username@ip_production_worker2
```

#### Install Ansible

```bash
sudo apt update
sudo apt install ansible -y
ansible --version
```

#### Set up Ansible Control node

```bash
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install cloud.common

sudo apt install python3-pip
pip install kubernetes

mkdir -pv ~/ansible/playbook ~/ansible/inventory
```

#### Configure Ansible Inventory

- Create an inventory file:

```bash
cd ~/ansible/inventory
nano inventory.ini
```

- Put your vm details in the inventory file:

```ini
[staging]
ip_staging_master
ip_staging_worker1
ip_staging_worker2

[production]
ip_production_master
ip_production_worker1
ip_production_worker2
```

---

This documentation will continue to evolve as the project grows. Feel free to contribute or suggest improvements!
