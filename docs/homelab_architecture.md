# Homelab Architecture

| Layer                      | Tool/Service                |
|---------------------------|------------------------------|
| Hypervisor                | Proxmox                      |
| DNS                       | ...                          |
| IaC & CaC                 | Terraform + Ansible          |
| Version Control & CI/CD   | GitLab                       |
| GitOps                    | ArgoCD                       |
| Persistent Volumes        | Longhorn                     |
| Registry                  | Harbor + JFrog Artifactory   |
| Certs / TLS management    | Cert-Manager + Let's Encrypt |
| Secrets Management        | HashiCorp Vault / OpenBao    |
| Load Balancing            | MetalLB                      |
| Monitoring                | Prometheus + Grafana         |
| Logs monitoring           | Loki & Promtail.             |
| ...                       | ...                          |
