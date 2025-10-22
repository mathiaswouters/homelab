# Homelab Bootstrap

This is the explanation on how to setup the minimum of my homelab, ...

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

## 2. Configure a cloud-init vm template

...

## 3. Install a Pi-Hole LXC Container

...

## 4. Install a GitLab VM (using Docker)

...
