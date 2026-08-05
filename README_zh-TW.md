# Woow_k3s_nginxpm — Nginx Proxy Manager K3s/Kubernetes Helm Chart

[English](README.md)

在 K3s/Kubernetes 上部署 [Nginx Proxy Manager](https://nginxproxymanager.com/)（NPM）的 Helm chart。
NPM 是一套具備網頁管理介面的反向代理，並可自動申請/續約 Let's Encrypt SSL 憑證。
使用 NPM 內建的 SQLite 資料庫，不需要外部資料庫容器。

> **其他平台？**
> Docker/Podman Compose → [Woow_podman_nginxpm](https://github.com/WOOWTECH/Woow_podman_nginxpm) ·
> Home Assistant add-on → [Woow_ha_nginxpm](https://github.com/WOOWTECH/Woow_ha_nginxpm)

## 架構

| 元件 | 映像檔 | Service | NodePort |
|---|---|---|---|
| Nginx Proxy Manager | `jc21/nginx-proxy-manager:latest` | `nginxpm` | `30080`（HTTP）、`30443`（HTTPS）、`30081`（管理介面） |

- 儲存：兩個 PVC 使用 `local-path` — `nginxpm-data`（5Gi，設定 + SQLite 資料庫）、`nginxpm-letsencrypt`（1Gi，SSL 憑證）
- 部署策略：`Recreate`（SQLite 單一寫入者）
- 沒有 ConfigMap 或 Secret — NPM 完全透過網頁介面設定

## 快速開始

```bash
# 直接從 repo tarball 安裝（不需 clone）
helm install nginxpm https://github.com/WOOWTECH/Woow_k3s_nginxpm/archive/refs/heads/main.tar.gz

# 或先 clone 到本機
git clone https://github.com/WOOWTECH/Woow_k3s_nginxpm.git
cd Woow_k3s_nginxpm
helm install nginxpm .
```

安裝後開啟 `http://<node-ip>:30081`，使用 NPM 預設帳密登入：

| 欄位 | 值 |
|---|---|
| Email | `admin@example.com` |
| 密碼 | `changeme` |

**首次登入後請立即更改。**

## 主要 values

| Value | 預設值 | 說明 |
|---|---|---|
| `namespace.create` / `namespace.name` | `true` / `nginxpm` | 目標命名空間 |
| `nginxpm.image.tag` | `latest` | NPM 版本 |
| `nginxpm.service.type` | `NodePort` | Service 對外類型 |
| `nginxpm.service.http.nodePort` | `30080` | HTTP 代理 NodePort |
| `nginxpm.service.https.nodePort` | `30443` | HTTPS 代理 NodePort |
| `nginxpm.service.admin.nodePort` | `30081` | 管理介面 NodePort |
| `nginxpm.persistence.data.size` | `5Gi` | NPM 資料 PVC（設定 + SQLite） |
| `nginxpm.persistence.letsencrypt.size` | `1Gi` | Let's Encrypt PVC |

完整列表：[`values.yaml`](values.yaml)

## 驗證

```bash
kubectl get pods -n nginxpm                     # pod Running/Ready
curl -sI http://<node-ip>:30081                 # 管理介面回應 HTTP 200
```

## 設定 Proxy Hosts

登入管理介面（`http://<node-ip>:30081`）後，可新增 Proxy Host，將外部網域
轉發到叢集內服務。常見的叢集內目標（依你自己的命名空間 / 服務調整）：

| 服務 | 轉發 URL |
|------|----------|
| Nextcloud | `http://nextcloud.nextcloud.svc.cluster.local:80` |
| Home Assistant | `http://homeassistant.homeassistant.svc.cluster.local:8123` |
| Immich | `http://immich-server.immich.svc.cluster.local:2283` |
| n8n | `http://n8n.n8n.svc.cluster.local:5678` |
| Odoo | `http://odoo.odoo.svc.cluster.local:8069` |

Home Assistant、n8n、Immich 等服務記得啟用 **Websockets Support**。

## 移除

```bash
helm uninstall nginxpm
# Helm 不會刪除 PVC；若要一併刪除資料：
kubectl delete pvc -n nginxpm nginxpm-data nginxpm-letsencrypt
```

## 從舊 Kustomize 部署遷移

本倉庫取代已封存的
[Woow_nginxpm_docker_compose_all](https://github.com/WOOWTECH/Woow_nginxpm_docker_compose_all)
的 `k3s` 分支。Chart 預設渲染結果與原 manifests 資源等價
（相同名稱、命名空間、標籤、連接埠、PVC）；唯二蓄意差異：

- NPM 容器現在明寫 `imagePullPolicy: Always`
  （原本因為 `:latest` tag 為隱性行為）
- 命名空間額外帶了 `managed-by: helm` 標籤

因此既有的 Kustomize 部署可以直接由 Helm 接管，或保留原樣。
原本的 Kustomize 檔案在本 repo 的 git 歷史中仍可查閱。

## 授權

MIT
