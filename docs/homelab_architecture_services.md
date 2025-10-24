# Homelab Architecture

| Type                      | Tool/Service                             |
|---------------------------|------------------------------------------|
| Hypervisor                | Proxmox                                  |
| DNS                       | Pi-Hole                                  |
| IaC & CaC                 | Terraform + Ansible (+ Chef --> to learn it, because never used it before) |
| Version Control & CI/CD   | GitLab and GitLab CI/CD pipelines (using GitLab Runners) + Jenkins (to learn it, because never used it before)|
| GitOps                    | ArgoCD                                   |
| Reverse Proxy             | Traefik                                   |
| Certs / TLS management    | Cert-Manager + Let's Encrypt             |
| Load Balancing            | MetalLB                                  |
| Service Mesh              | Cilium / Istio / Linkerd / ...           |
| Persistent Volumes        | Longhorn                                 |
| K8s DNS                   | External-DNS                             |
| Registry                  | Harbor + JFrog Artifactory               |
| Secrets Management        | HashiCorp Vault                          |
| Monitoring                | Prometheus + Grafana                     |
| Logs monitoring           | Loki & Promtail                          |
| VPN / Remote Access       | Tailscale / Twingate / WireGuard / ...   |
| CMDB                      | NetBox                                   |
| S3 Compatible storage     | MinIO                                    |
| Backup Solution           | Proxmox Backup Server / Velero (for K8s) |
| ...                       | ...                                      |

Infrastructure Testing:

    - Terratest - Automated Terraform testing
    - Molecule - Ansible testing framework
    - Checkov - IaC security scanning in CI/CD


# Homelab Security Tools / Services:

| Type                                          | Tool/Service                              |
|-----------------------------------------------|-------------------------------------------|
| SIEM                                          | Wazuh                                     |
| Policy Engine                                 | OPA (Open Policy Agent) / Kyverno         |
| Container/IaC/filesystem vulnerability scanner | Trivy (Integrate with Harbor / GitLab CI) |
| Container vulnerability scanner               | Clair                                     |
| Vulnerability scanner                         | Grype                                     |
| Security scanning                             | Snyk (has free tier)                      |
| ...                                           | ...                                       |

Other security tools / services:

    - Runtime Security
        - Falco - Runtime security detection (alerts on suspicious behavior)
        - Tetragon - eBPF-based security observability
        - KubeArmor - Container runtime security

    - Network Security
        - Suricata / Zeek - Network IDS/IPS
        - CrowdSec - Collaborative security, like fail2ban on steroids
        - ModSecurity - Web application firewall

    - Secrets & PKI
        - Smallstep - Private certificate authority
        - External Secrets Operator - Sync secrets from Vault to K8s
        - Sealed Secrets - Encrypted secrets in Git

    - Policy & Compliance
        - Open Policy Agent (OPA) - Policy enforcement
        - Kyverno - Kubernetes policy engine (easier than OPA)
        - Falco - Runtime threat detection
        - Kubescape - K8s security compliance scanner
        - Polaris - K8s best practices checker

    - Security Scanning in CI/CD
        - GitLab SAST/DAST - Built-in security scanning
        - SonarQube - Code quality & security
        - Dependency-Track - Software supply chain component analysis
        - Anchore Engine - Container analysis

    - Access Control
        - Teleport - Identity-aware access proxy (SSH/K8s/databases)
        - Boundary - HashiCorp's secure remote access
        - StrongSwan / OpenVPN - VPN alternatives to Tailscale

    - Certificate Management
        - step-ca - Private CA
        - Boulder - Let's Encrypt server (run your own!)


# Homelab Services

| Type                      | Tool/Service                     |
|---------------------------|----------------------------------|
| Dashboard                 | Homepage                         |
| ...                       | n8n                              |
| File Hosting Services     | Nextcloud                        |
| Torrent                   | qBittorent                       |
| Media Stack               | ARR Stack                        |
| Media Player              | Jellyfin                          |
| Tdarr                     | Media transcoding automation.    |
| Ad-blocking               | Pi-hole                          |
| Smart Home                | Home Assistant                   |
| Smart Home                | Node-RED                         |
| URL Shortener             | Shlink                           |
| Linktree Alternative      | Littlelink                       |
| Bitwarden / Vaultwarden   | Bitwarden Server                 |
| Immich / Photoprism       | Photo management / backup        |
| ...                       | ...                              |
