# 基本概念と制約

## 📋 Git Worktreeとは

Git Worktreeは、**複数のブランチを同時に異なるディレクトリで作業できる**仕組みです。1つのリポジトリで複数の作業を並行して進められます。

### 主な利点

1. **並行開発**: 複数の機能やバグ修正を同時に進められる
2. **コンテキストスイッチの削減**: ブランチ切り替えでファイルが変更されない
3. **効率的なテスト**: 複数のブランチでテストを同時実行可能
4. **緊急対応**: 現在の作業を中断せず緊急修正に対応

### 通常のGit操作との違い

| 操作 | 通常のGit | Git Worktree |
|-----|----------|-------------|
| ブランチ切り替え | `git checkout` | ディレクトリ移動 |
| 複数ブランチ作業 | stash/commit必須 | 並行作業可能 |
| ファイル状態 | 切り替え時に変更 | 常に独立 |
| ディスク使用量 | 最小限 | worktree分増加 |

## ⚠️ Claude Codeの制約と解決策

### 制約の詳細

Claude Codeには以下の制約があります：

1. **親ディレクトリアクセス不可**: `../`へのアクセスができない
2. **相対パスの制限**: 親を経由するパスは使用不可
3. **セキュリティサンドボックス**: プロジェクト外へのアクセス制限

### 解決策：プロジェクト内worktree

通常のworktree運用では親ディレクトリに作成しますが、Claude Codeでは**プロジェクトフォルダ直下**に作成します：

```bash
# ❌ 通常の方法（Claude Codeでは不可）
cd ~/projects/myproject
git worktree add ../myproject-feature feature/new

# ✅ Claude Code対応の方法
cd ~/projects/myproject
git worktree add wt-feat-new feature/new
```

### 命名規則の重要性

`wt-`プレフィックスを使用することで：
- worktreeディレクトリを視覚的に識別可能
- `.gitignore`で一括除外可能（`wt-*/`）
- ツール（gwq）との連携がスムーズ

## 📁 推奨ディレクトリ構造

### 基本構造

```
your-project/              # メインリポジトリ（main/masterブランチ）
├── src/                   # ソースコード
├── tests/                 # テスト
├── .env                   # 環境変数（必要に応じてworktreeにコピー）
├── .serena/               # Serena MCP設定（worktreeにコピー）
├── node_modules/          # 依存パッケージ（共有または個別）
├── .git/                  # Gitリポジトリ本体
│   └── worktrees/         # worktree管理情報
├── wt-feat-auth/         # 認証機能開発用worktree
├── wt-feat-payment/      # 決済機能開発用worktree
├── wt-fix-bug-123/       # バグ修正用worktree
└── wt-hotfix-security/   # 緊急セキュリティ修正用worktree
```

### Worktree内部の構造

各worktreeは独立したブランチとして完全なプロジェクト構造を持ちます：

```
wt-feat-auth/             # 認証機能worktree
├── src/                  # ソースコード（独立）
├── tests/                # テスト（独立）
├── .env                  # 環境変数（親からコピー）
├── .serena/              # Serena設定（親からコピー）
├── node_modules/         # 依存パッケージ（リンクまたはコピー）
└── .git                  # メインの.gitへのリンク
```

### .gitignoreへの追加

worktreeディレクトリをGit管理から除外：

```gitignore
# Git Worktree directories
wt-*/
```

## 🤖 Agent階層との統合

Git Worktreeは、PO→Manager→Developerのエージェント階層と密接に連携します。

### PO Agentの責任（Worktree管理者）

**役割**:
- 新規作業の判断
- Worktree作成の提案とユーザー確認
- Worktree名の決定
- Manager Agentへのworktree情報伝達

**実行例**:
```
PO: 新しい認証機能の実装が必要です。
    worktree `wt-feat-user-auth` を作成しますか？

ユーザー: はい

PO: Managerに指示を送ります：
    「worktree wt-feat-user-auth で認証機能を実装」
```

### Manager Agentの責任（Worktree情報伝達者）

**役割**:
- POからworktree情報を受信
- タスク分割とDeveloper配分計画
- DeveloperへのWorktree情報伝達

**実行例**:
```
Manager: タスク配分計画：
  - worktree: wt-feat-user-auth
  - dev1: ログインUI実装
  - dev2: 認証API実装
  - dev3: テスト作成
```

### Developer Agentの責任（Worktree作業者）

**役割**:
- 指定されたworktree配下で作業
- 環境設定のコピー（.env, .serena）
- 実装とコミット
- Managerへの完了報告

**実行例**:
```bash
# Developer Agent dev1の作業

# 1. worktreeに移動
cd wt-feat-user-auth

# 2. 環境設定をコピー
cp ../.env .env
cp -r ../.serena .serena

# 3. 実装作業
# ... コード編集 ...

# 4. コミット（Gitコミットはユーザーが実行）
# git add .
# git commit -m "feat: implement login UI"
```

### Worktree作成の権限

| Agent | Worktree作成 | Worktree削除 | 作業実行 |
|-------|------------|------------|---------|
| PO | ✅（ユーザー確認後） | ❌ | ❌ |
| Manager | ❌ | ❌ | ❌ |
| Developer | ❌ | ❌ | ✅ |
| ユーザー | ✅ | ✅ | ✅ |

### ワークフロー統合図

```
ユーザー要求
    ↓
PO Agent: 新規作業判断
    ├─ 新規 → ユーザー確認 → Worktree作成
    └─ 既存 → 既存worktree名を把握
    ↓
Manager Agent: タスク配分計画 + Worktree情報
    ↓
Developer Agents: Worktree配下で並列実装
    ├─ dev1: worktree移動 → 環境設定 → 実装
    ├─ dev2: worktree移動 → 環境設定 → 実装
    └─ dev3: worktree移動 → 環境設定 → 実装
    ↓
作業完了報告
    ↓
ユーザー: Worktree削除判断
```

## 💡 ベストプラクティス

### 環境変数の管理

```bash
# メインリポジトリの.envをworktreeにコピー
cd wt-feat-payment
cp ../.env .env

# または、worktree専用の設定を使用
cp ../.env.example .env
# .envを編集して適切な値を設定
```

### Serena MCPの設定

```bash
# 親の.serenaをコピー（初期化不要）
cd wt-feat-payment
cp -r ../.serena .serena

# これにより、serenaの初期化時間を節約
# 親プロジェクトで既にserenaが初期化されている必要あり
```

### 依存パッケージの管理

#### オプション1: 個別インストール（安全）
```bash
cd wt-feat-payment
npm install  # 各worktreeで個別にインストール
```

#### オプション2: シンボリックリンク（高速）
```bash
cd wt-feat-payment
ln -s ../node_modules node_modules
# 注意: バージョン衝突の可能性あり
```

## 🔗 次のステップ

- [ワークフロー](./WORKFLOWS.md): 実際の操作手順
- [命名規則](./NAMING.md): worktreeの命名方法
- [トラブルシューティング](./TROUBLESHOOTING.md): 問題解決

---

[← SKILL.md に戻る](./SKILL.md) | [ワークフロー →](./WORKFLOWS.md)
