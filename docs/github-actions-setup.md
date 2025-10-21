# GitHub Actions用のセットアップガイド

このガイドでは、GitHub ActionsからGKEクラスターを管理するための設定手順を説明します。

## 1. Terraformで必要なリソースを作成

### 1.1 変数の設定

`terraform/workloads/terraform.tfvars`ファイルを作成し、以下を設定:

```hcl
base_project_id = "your-gcp-project-id"
region = "asia-northeast1"
prefix = "dev"
github_repository = "your-github-username/your-repo-name"  # 例: "ryotakose/googlecloud"
```

### 1.2 Terraformの実行

```bash
cd terraform/workloads
terraform init
terraform plan
terraform apply
```

### 1.3 出力値の確認

以下のコマンドで必要な情報を取得:

```bash
terraform output github_actions_workload_identity_provider
terraform output github_actions_service_account_email
```

## 2. GitHubシークレットの設定

GitHubリポジトリの Settings > Secrets and variables > Actions で以下のシークレットを追加:

| シークレット名 | 値 | 説明 |
|--------------|-----|------|
| `WIF_PROVIDER` | `terraform output`で取得した`github_actions_workload_identity_provider`の値 | Workload Identity Provider ID |
| `WIF_SERVICE_ACCOUNT` | `terraform output`で取得した`github_actions_service_account_email`の値 | サービスアカウントのメールアドレス |
| `GCP_PROJECT_ID` | GCPプロジェクトID | 例: `my-gcp-project` |
| `GCP_REGION` | GKEクラスターのリージョン | 例: `asia-northeast1` |

## 3. GKEバージョン設定ファイルの作成

`version/dev/gke-version.yaml`ファイルを作成:

```yaml
cluster_name: your-cluster-name
env: dev
controlplane:
  version: "1.29.1-gke.1425000"
nodes:
  version: "1.29.1-gke.1425000"
```

## 4. 動作確認

1. `version/dev/gke-version.yaml`を編集してバージョンを更新
2. mainまたはdevelopブランチにプッシュ
3. GitHub Actionsが自動的に実行され、GKEクラスターがアップグレードされる

## トラブルシューティング

### エラー: "Permission denied"

- サービスアカウントに必要な権限が付与されているか確認
- Workload Identity Federationの設定が正しいか確認

### エラー: "Cluster not found"

- `GCP_REGION`シークレットが正しいか確認
- クラスター名が`gke-version.yaml`と一致しているか確認

## セキュリティのベストプラクティス

1. **最小権限の原則**: サービスアカウントには必要最小限の権限のみを付与
2. **リポジトリの制限**: Workload Identity Federationで特定のリポジトリのみアクセス可能に設定
3. **ブランチ保護**: mainブランチには保護ルールを設定し、レビュープロセスを経てからマージ
