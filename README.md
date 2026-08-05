# Woow_k3s_nginxpm — Nginx Proxy Manager Helm Chart for K3s/Kubernetes

[繁體中文](README_zh-TW.md)

Helm chart deploying [Nginx Proxy Manager](https://nginxproxymanager.com/) (NPM) on
K3s/Kubernetes — a web-based reverse proxy with automatic Let's Encrypt SSL
certificate management. Uses NPM's built-in SQLite database, so no external
database container is required.

> **Looking for another platform?**
> Docker/Podman Compose → [Woow_podman_nginxpm](https://github.com/WOOWTECH/Woow_podman_nginxpm) ·
> Home Assistant add-on → [Woow_ha_nginxpm](https://github.com/WOOWTECH/Woow_ha_nginxpm)

## Architecture

| Component | Image | Service | NodePorts |
|---|---|---|---|
| Nginx Proxy Manager | `jc21/nginx-proxy-manager:latest` | `nginxpm` | `30080` (HTTP), `30443` (HTTPS), `30081` (Admin UI) |

- Storage: two PVCs on `local-path` — `nginxpm-data` (5Gi, config + SQLite DB) and `nginxpm-letsencrypt` (1Gi, SSL certificates)
- Deployment strategy: `Recreate` (single writer for SQLite)
- No ConfigMap or Secret — NPM is configured entirely through its web UI

## Quick start

```bash
# Install straight from the repo tarball (no clone needed)
helm install nginxpm https://github.com/WOOWTECH/Woow_k3s_nginxpm/archive/refs/heads/main.tar.gz

# Or from a local clone
git clone https://github.com/WOOWTECH/Woow_k3s_nginxpm.git
cd Woow_k3s_nginxpm
helm install nginxpm .
```

Then open `http://<node-ip>:30081` and log in with the NPM default credentials:

| Field | Value |
|---|---|
| Email | `admin@example.com` |
| Password | `changeme` |

**Change these immediately after first login.**

## Key values

| Value | Default | Description |
|---|---|---|
| `namespace.create` / `namespace.name` | `true` / `nginxpm` | Target namespace |
| `nginxpm.image.tag` | `latest` | NPM version |
| `nginxpm.service.type` | `NodePort` | Service exposure |
| `nginxpm.service.http.nodePort` | `30080` | HTTP proxy NodePort |
| `nginxpm.service.https.nodePort` | `30443` | HTTPS proxy NodePort |
| `nginxpm.service.admin.nodePort` | `30081` | Admin UI NodePort |
| `nginxpm.persistence.data.size` | `5Gi` | NPM data PVC (config + SQLite) |
| `nginxpm.persistence.letsencrypt.size` | `1Gi` | Let's Encrypt PVC |

Full list: [`values.yaml`](values.yaml)

## Verify

```bash
kubectl get pods -n nginxpm                     # pod Running/Ready
curl -sI http://<node-ip>:30081                 # HTTP 200 from the admin UI
```

## Setting up proxy hosts

After logging in to the admin panel (`http://<node-ip>:30081`), you can add
Proxy Hosts that forward external domains to cluster services. Common
in-cluster targets (adjust to your own namespaces / services):

| Service | Forward URL |
|---------|-------------|
| Nextcloud | `http://nextcloud.nextcloud.svc.cluster.local:80` |
| Home Assistant | `http://homeassistant.homeassistant.svc.cluster.local:8123` |
| Immich | `http://immich-server.immich.svc.cluster.local:2283` |
| n8n | `http://n8n.n8n.svc.cluster.local:5678` |
| Odoo | `http://odoo.odoo.svc.cluster.local:8069` |

Remember to enable **Websockets Support** for services like Home Assistant, n8n,
and Immich.

## Uninstall

```bash
helm uninstall nginxpm
# PVCs are kept by Helm; remove them (and your data!) with:
kubectl delete pvc -n nginxpm nginxpm-data nginxpm-letsencrypt
```

## Migrating from the old Kustomize deployment

This repository replaces the `k3s` branch of the archived
[Woow_nginxpm_docker_compose_all](https://github.com/WOOWTECH/Woow_nginxpm_docker_compose_all)
repo. The chart's default rendering is resource-equivalent to those manifests
(same names, namespace, labels, ports, PVCs); the only intentional differences
are:

- `imagePullPolicy: Always` is now explicit on the NPM container (previously
  implicit because the image tag is `:latest`).
- The namespace carries an extra `managed-by: helm` label.

An existing Kustomize deployment can therefore be adopted by Helm or simply
left in place. The original Kustomize files remain available in this repo's
git history.

## License

MIT
