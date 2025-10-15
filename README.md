# GKE Infrastructure Management

このリポジトリは Google Kubernetes Engine (GKE) インフラの管理を行います。

## 📁 プロジェクト構成

```
.
├── gke-version.yaml                      # GKEバージョン管理
├── check-gke-version.sh                  # バージョン検証スクリプト
├── terraform/                            # Terraformインフラコード
├── .github/workflows/
│   ├── ci.yml                           # ビルド & デプロイワークフロー
│   └── gke-version-analysis.yml         # GKEバージョン分析ワークフロー
└── scripts/                              # 運用スクリプト
```

## 🤖 Claude Code による自動分析

このプロジェクトでは、GKEバージョンを変更すると自動的にClaude Codeがリリースノートを分析し、影響分析レポートを作成します。

### セットアップ

#### 1. Claude Code GitHub App のインストール

1. [Claude Code GitHub App](https://github.com/apps/claude-code-official) にアクセス
2. "Install" をクリック
3. このリポジトリを選択してインストール
4. 以下の権限を付与:
   - **Contents**: Read and write
   - **Issues**: Read and write
   - **Pull requests**: Read and write

#### 2. Anthropic API Key の設定

1. [Anthropic Console](https://console.anthropic.com/) でAPIキーを取得
2. GitHubリポジトリの Settings → Secrets and variables → Actions
3. "New repository secret" をクリック
4. 以下のシークレットを追加:
   - Name: `ANTHROPIC_API_KEY`
   - Value: `sk-ant-...` (取得したAPIキー)

#### 3. GCP認証の設定（バージョン検証用）

バージョン検証スクリプトでGCP APIを使用する場合:

1. GCPサービスアカウントを作成
2. 必要な権限を付与（Kubernetes Engine Viewer）
3. Workload Identity Federation を設定
4. ワークフローの環境変数を更新

### 使い方

#### GKEバージョンの変更

1. `gke-version.yaml` を編集してバージョンを変更
2. 変更をコミットしてプッシュ
3. PRを作成

#### 自動で実行される処理

PRを作成すると、以下が自動実行されます：

1. **バージョン変更検知**
   - 変更前後のバージョンを自動抽出

2. **リリースノート取得**
   - Kubernetes公式CHANGELOGをダウンロード
   - GKEリリースノートを取得

3. **Claude Codeによる分析**
   - PRに `@claude` メンション付きコメントが投稿される
   - Claude Codeが以下を分析:
     - Breaking Changes
     - 非推奨化された機能
     - セキュリティアップデート
     - プロジェクトへの影響
     - 必要なアクション

4. **バージョン検証**
   - GKE APIで指定バージョンが利用可能かチェック

#### 分析レポートの例

```markdown
## 🔄 GKE Version Change Detected

### Version Changes
- Old Controlplane Version: 1.31.11-gke.1036000
- New Controlplane Version: 1.32.9-gke.1072000

---

@claude 上記のコンテキストとリリースノートを分析して、
このGKEバージョンアップの詳細な影響分析レポートを作成してください。

[Kubernetes Release Notes...]
```

Claude Codeが分析を完了すると、同じPR内に詳細なレポートが返信されます。

## 🔧 手動バージョン検証

ローカルでバージョンを検証する場合:

```bash
# スクリプトに実行権限を付与
chmod +x check-gke-version.sh

# バージョンを検証
./check-gke-version.sh
```

出力例:
```
Checking GKE versions...
Controlplane version: 1.32.9-gke.1072000
Nodes version: 1.32.9-gke.1072000

Fetching available versions from GKE...

Valid versions in REGULAR channel:
1.33.5-gke.1080000
1.33.4-gke.1350000
1.32.9-gke.1072000
1.32.9-gke.1010000
1.31.12-gke.1265000
1.31.12-gke.1220000

✓ Controlplane version 1.32.9-gke.1072000 is valid
✓ Nodes version 1.32.9-gke.1072000 is valid

All versions are valid!
```

## 📊 ワークフロー詳細

### GKE Version Analysis Workflow

[.github/workflows/gke-version-analysis.yml](.github/workflows/gke-version-analysis.yml)

#### トリガー条件
- `gke-version.yaml` が変更されたPR

#### ジョブ構成

1. **detect-version-change**
   - 変更前後のバージョンを検出
   - 差分がある場合のみ後続ジョブを実行

2. **fetch-release-notes**
   - Kubernetes CHANGELOGをダウンロード
   - GKEリリースノートを取得
   - 分析用コンテキストファイルを生成

3. **analyze-with-claude**
   - PRに分析依頼コメントを投稿
   - `@claude` メンションでClaude Codeを起動
   - リリースノートと分析コンテキストを添付

4. **validate-version**
   - GKE APIでバージョンの利用可能性を検証
   - 無効なバージョンの場合はPRをブロック

## 🔐 セキュリティ

### 保護されるべき情報

以下はGitにコミットしないでください：
- Anthropic APIキー
- GCPサービスアカウントキー
- 環境変数ファイル (`.env`)
- 認証トークン

### GitHub Secrets

以下のシークレットが必要です：
- `ANTHROPIC_API_KEY`: Claude API キー（必須）
- `GITHUB_TOKEN`: 自動で利用可能（権限設定のみ必要）

## 🚀 ベストプラクティス

### バージョンアップの手順

1. **計画段階**
   - 新しいバージョンのリリースノートを確認
   - Breaking Changesをチェック
   - メンテナンスウィンドウを計画

2. **テスト環境で検証**
   - dev環境で先にアップグレード
   - アプリケーションの動作確認
   - パフォーマンステスト

3. **本番環境へのロールアウト**
   - ロールバック計画を準備
   - 段階的にアップグレード
   - モニタリング強化

### Claude Codeの活用

Claude Codeの分析レポートには以下が含まれます：
- 技術的に正確な情報
- 実行可能なアクションアイテム
- 優先度付けされた対応リスト
- テストチェックリスト

これらを参考に、安全なアップグレード計画を立ててください。

## 📚 参考リンク

- [Kubernetes Release Notes](https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG)
- [GKE Release Notes](https://cloud.google.com/kubernetes-engine/docs/release-notes)
- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🆘 トラブルシューティング

### Claude Codeが応答しない

1. Claude Code GitHub Appがインストールされているか確認
2. `ANTHROPIC_API_KEY` が正しく設定されているか確認
3. APIの利用制限に達していないか確認

### バージョン検証が失敗する

1. gcloud CLIが正しく設定されているか確認
2. GCP認証情報が有効か確認
3. 指定したリージョン（asia-northeast1）でバージョンが利用可能か確認

### ワークフローが起動しない

1. PRで `gke-version.yaml` が変更されているか確認
2. ワークフローファイルの構文エラーがないか確認
3. GitHub Actionsが有効になっているか確認

## 🤝 コントリビューション

改善提案やバグ報告は Issue で受け付けています。
