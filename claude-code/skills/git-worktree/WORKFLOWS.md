# Worktreeワークフロー

## 📋 Worktree操作の全体像

Worktreeの操作は大きく3つのフェーズに分かれます：

1. **作成フェーズ**: 新規worktreeの作成
2. **作業フェーズ**: worktree内での開発作業
3. **管理フェーズ**: worktreeの削除とクリーンアップ

## 🚀 1. 新規Worktree作成

### 🎯 AskUserQuestion形式で確認（必須）

**すべてのworktree確認はAskUserQuestion形式の選択肢で行う**

#### Step 0: 作業場所の選択（最初に必ず確認）

```python
AskUserQuestion(
    questions=[{
        "question": "新しい作業を開始します。作業場所を選択してください",
        "header": "作業場所",
        "options": [
            {
                "label": "現在のブランチで作業",
                "description": f"現在のブランチ `{current_branch}` で直接作業を開始"
            },
            {
                "label": "新規worktreeを作成",
                "description": "独立したworktreeで作業（並行開発向け）"
            }
        ],
        "multiSelect": False
    }]
)
```

**ユーザーが「現在のブランチで作業」を選択した場合**: worktree作成をスキップして作業開始

**ユーザーが「新規worktreeを作成」を選択した場合**: 以下のステップに進む

### 事前確認

#### 🚨 Step 1: Submoduleの有無を最初に確認（必須）

```bash
# 現在のディレクトリを確認（メインリポジトリのルートであること）
pwd

# Submoduleの有無を確認（最初に必ず実行）
ls -la .gitmodules
git submodule status

# Submodule一覧の出力例:
# +abc1234567890abcdef1234567890abcdef12345678 submodule1 (heads/main)
# +def4567890abcdef1234567890abcdef123456789 submodule2 (heads/main)
```

#### Step 2: Submoduleの有無に応じた分岐

##### 【Submoduleがない場合】

```python
AskUserQuestion(
    questions=[{
        "question": f"worktree `wt-feat-{feature_name}` を作成しますか？",
        "header": "Worktree作成",
        "options": [
            {
                "label": "作成する",
                "description": f"ブランチ `feature/{feature_name}` を作成して作業開始"
            },
            {
                "label": "作成しない",
                "description": "現在のブランチで作業を継続"
            }
        ],
        "multiSelect": False
    }]
)
```

##### 【Submoduleがある場合】→ 🚨変更対象を厳密に判断

**⚠️ 絶対ルール: submodule内のコードを変更する場合、親gitにworktreeを作成してはいけない**

```python
AskUserQuestion(
    questions=[{
        "question": "変更対象を選択してください",
        "header": "変更対象",
        "options": [
            {
                "label": "親git側のコード",
                "description": "プロジェクトルートの設定ファイルや親gitのソースコード"
            },
            {
                "label": f"Submodule: {submodule_name}",
                "description": f"{submodule_name}内のコードを変更（親gitにはworktree作成しない）"
            }
        ],
        "multiSelect": False
    }]
)
```

**ユーザーが「親git側のコード」を選択**: 親gitルートにworktree作成
**ユーザーが「Submodule」を選択**: 対象submodule内にのみworktree作成（🚫親gitには作らない）

#### 既存のworktreeを確認

```bash
# 既存のworktreeを確認
git worktree list

# 出力例（親gitのworktree）:
# /Users/user/project              abc1234 [main]
# /Users/user/project/wt-feat-auth def5678 [feature/auth]
```

### 基本的な作成方法

#### ケース0: Submoduleがないプロジェクト（通常フロー）

```bash
# プロジェクトルートで実行
# 基本フォーマット
git worktree add -b <新規ブランチ名> <worktreeディレクトリ名> <元ブランチ>

# 実例: mainブランチから新機能ブランチを作成
git worktree add -b feature/payment-integration wt-feat-payment main

# 出力例:
# Preparing worktree (new branch 'feature/payment-integration')
# HEAD is now at abc1234 Latest commit message
```

#### ケース1: Submoduleあり・親git自体のコード変更

```bash
# 親gitルートで実行
# 基本フォーマット
git worktree add -b <新規ブランチ名> <worktreeディレクトリ名> <元ブランチ>

# 実例: mainブランチから新機能ブランチを作成
git worktree add -b feature/payment-integration wt-feat-payment main

# 出力例:
# Preparing worktree (new branch 'feature/payment-integration')
# HEAD is now at abc1234 Latest commit message
```

#### ケース2: Submoduleあり・Submodule内のコード変更

```bash
# 🚫 親gitにはworktreeを絶対に作らない

# 対象submodule内でのみworktreeを作成
cd submodule1
git worktree add -b feature/payment-integration wt-feat-payment main

# 出力例:
# Preparing worktree (new branch 'feature/payment-integration')
# HEAD is now at abc1234 Latest commit message

# worktreeに移動
cd wt-feat-payment

# worktree一覧確認（submodule内で実行）
git worktree list
# 出力例:
# /path/to/project/submodule1              abc1234 [main]
# /path/to/project/submodule1/wt-feat-payment def5678 [feature/payment-integration]

# ⚠️ 重要: worktreeパスは submodule1/wt-feat-payment
# ❌ 間違い: wt-feat-payment（親gitルート直下）
# ✅ 正しい: submodule1/wt-feat-payment（submodule内）
```

#### 既存ブランチからworktreeを作成

```bash
# ローカルブランチから作成
git worktree add wt-feat-existing feature/existing-branch

# リモートブランチから作成
git worktree add wt-feat-remote origin/feature/remote-branch
```

#### 特定のコミットから作成

```bash
# コミットハッシュを指定
git worktree add -b feature/bugfix wt-fix-issue abc1234
```

### 作成時のオプション

| オプション | 説明 | 使用例 |
|----------|------|--------|
| `-b <branch>` | 新規ブランチを作成 | `git worktree add -b feature/new wt-new main` |
| `-B <branch>` | ブランチを強制作成（既存を上書き） | `git worktree add -B feature/reset wt-reset main` |
| `--detach` | HEADをdetach状態で作成 | `git worktree add --detach wt-detached abc1234` |
| `-f, --force` | ディレクトリが存在する場合も作成 | `git worktree add -f wt-force feature/branch` |

### 作成後の確認

```bash
# worktreeが正しく作成されたか確認
git worktree list

# worktreeディレクトリに移動して確認
cd wt-feat-payment
git status
git branch
```

## 💻 2. Worktreeでの作業

### 環境設定のセットアップ

#### ケース1: 親git側のコード変更

```bash
# 親gitのworktreeに移動
cd wt-feat-payment

# 環境変数ファイルをコピー
cp ../.env .env

# Serena MCP設定をコピー（初期化不要で高速）
cp -r ../.serena .serena

# 依存パッケージのインストール（必要に応じて）
npm install
# または既存のnode_modulesへのシンボリックリンク
# ln -s ../node_modules node_modules

# 設定が正しくコピーされたか確認
ls -la .env .serena
```

#### ケース2: Submodule内のコード変更のみ

```bash
# 対象submoduleのworktreeに移動（既に移動済みの場合はスキップ）
cd submodule1/wt-feat-payment

# 環境変数ファイルをコピー（submodule自体の.env、必要に応じて）
cp ../.env .env 2>/dev/null || echo "No .env in submodule"

# Serena MCP設定をコピー（submodule自体の.serena、必要に応じて）
cp -r ../.serena .serena 2>/dev/null || echo "No .serena in submodule"

# 依存パッケージのインストール（必要に応じて）
npm install
# または既存のnode_modulesへのシンボリックリンク
# ln -s ../node_modules node_modules

# 設定が正しくコピーされたか確認
ls -la .env .serena 2>/dev/null || echo "Config files status checked"
```

### 開発作業の実施

```bash
# ブランチの状態を確認
git status
git branch

# ファイルの編集（serena MCPやエディタを使用）
# ...

# 変更の確認
git status
git diff

# ステージング（Gitコミットはユーザーが実行）
# git add <ファイル>
# git add .

# コミット（Gitコミットはユーザーが実行）
# git commit -m "feat: implement payment gateway integration"

# リモートへのプッシュ（Gitコミットはユーザーが実行）
# git push origin feature/payment-integration
```

### 他のworktreeとの切り替え

```bash
# 現在のworktreeでの作業を一時保存（必要に応じて）
git stash

# メインリポジトリに戻る
cd ..

# 別のworktreeに移動
cd wt-feat-auth

# または直接移動
cd ../wt-fix-bug-123
```

### メインブランチの最新変更を取り込む

```bash
# worktree内で実行
cd wt-feat-payment

# メインブランチの最新を取得
git fetch origin main

# リベース（推奨）
git rebase origin/main

# またはマージ
git merge origin/main
```

## 🗑️ 3. Worktreeの管理と削除

### Worktree一覧の確認

```bash
# すべてのworktreeを表示
git worktree list

# 詳細表示
git worktree list --porcelain

# 出力例:
# worktree /Users/user/project
# HEAD abc1234567890abcdef1234567890abcdef1234
# branch refs/heads/main
#
# worktree /Users/user/project/wt-feat-payment
# HEAD def4567890abcdef1234567890abcdef12345678
# branch refs/heads/feature/payment-integration
```

### Worktreeの削除

#### 通常の削除（安全）

##### ケース1: 親git側のコード変更

```bash
# 親gitルートに戻る
cd /path/to/main/project

# 親gitのworktreeを削除
git worktree remove wt-feat-payment

# 未コミットの変更がある場合はエラーが表示される
# error: 'wt-feat-payment' contains modified or untracked files, use --force to delete it
```

##### ケース2: Submodule内のコード変更のみ

```bash
# 対象submoduleのルートに移動
cd /path/to/main/project/submodule1

# submodule内のworktreeを削除
git worktree remove wt-feat-payment

# プロジェクトルートに戻る
cd ..

# 未コミットの変更がある場合はエラーが表示される
# error: 'wt-feat-payment' contains modified or untracked files, use --force to delete it
```

#### 強制削除（注意）

```bash
# 未コミットの変更を無視して削除
git worktree remove --force wt-feat-payment

# または
git worktree remove -f wt-feat-payment
```

#### ディレクトリを直接削除した場合

```bash
# ディレクトリを手動で削除した後
rm -rf wt-feat-payment

# Git側のworktree情報をクリーンアップ
git worktree prune

# または、削除前に確認
git worktree prune --dry-run
```

### Worktreeのロック

一時的にworktreeを保護したい場合：

```bash
# worktreeをロック
git worktree lock wt-feat-payment

# ロック理由を記録
git worktree lock wt-feat-payment --reason "作業中のため削除しないでください"

# ロックを解除
git worktree unlock wt-feat-payment
```

### Worktreeの移動

```bash
# worktreeを別の場所に移動
git worktree move wt-feat-payment ../new-location/wt-feat-payment

# または名前変更
git worktree move wt-feat-payment wt-feat-payment-v2
```

## 🔄 高度なワークフロー

### 複数worktreeでの並行作業

```bash
# 3つの異なる機能を同時に開発
git worktree add -b feature/auth wt-feat-auth main
git worktree add -b feature/payment wt-feat-payment main
git worktree add -b feature/analytics wt-feat-analytics main

# 各worktreeで異なる開発者（Developer Agent）が作業
# dev1: cd wt-feat-auth && ...
# dev2: cd wt-feat-payment && ...
# dev3: cd wt-feat-analytics && ...
```

### 緊急修正への対応

```bash
# 現在の作業（feature開発中）
cd wt-feat-payment
# 作業中...

# 緊急修正が必要になった
cd ..
git worktree add -b hotfix/critical-bug wt-hotfix-critical main

# 緊急修正を実施
cd wt-hotfix-critical
# 修正...
# git commit && git push

# 修正完了後、元の作業に戻る
cd ../wt-feat-payment
# 作業再開...
```

### リリースブランチの準備

```bash
# リリースブランチ用worktreeを作成
git worktree add -b release/v2.0.0 wt-release-v2.0.0 develop

# リリース準備作業
cd wt-release-v2.0.0
# バージョン番号更新、CHANGELOG作成など...

# 並行して次の開発を継続
cd ../wt-feat-new-feature
# 新機能開発...
```

### レビュー用worktreeの活用

```bash
# レビュー対象のブランチをworktreeとして展開
git worktree add wt-review-pr-123 origin/feature/pull-request-123

# レビュー実施
cd wt-review-pr-123
# コードレビュー、テスト実行...

# レビュー完了後に削除
cd ..
git worktree remove wt-review-pr-123
```

## 📊 Worktree状態の確認

### 各worktreeの状態確認

```bash
# すべてのworktreeのステータスを確認
for worktree in wt-*; do
  echo "=== $worktree ==="
  cd "$worktree"
  git status -s
  cd ..
done
```

### Worktreeのディスク使用量確認

```bash
# 各worktreeのサイズを確認
du -sh wt-*

# 出力例:
# 150M  wt-feat-auth
# 180M  wt-feat-payment
# 120M  wt-fix-bug-123
```

### 未プッシュのコミット確認

```bash
# 各worktreeで未プッシュのコミットを確認
for worktree in wt-*; do
  echo "=== $worktree ==="
  cd "$worktree"
  git log origin/$(git branch --show-current)..HEAD --oneline
  cd ..
done
```

## 🔧 メンテナンス

### 定期的なクリーンアップ

```bash
# 無効なworktreeエントリをクリーンアップ
git worktree prune

# クリーンアップ対象を事前確認
git worktree prune --dry-run

# 全worktreeの整合性をチェック
git worktree repair
git worktree repair --all
```

### 古いworktreeの一括削除

```bash
# すでにマージ済みのworktreeを削除するスクリプト例
for worktree in wt-*; do
  cd "$worktree"
  branch=$(git branch --show-current)

  # mainにマージ済みか確認
  if git branch --merged main | grep -q "$branch"; then
    cd ..
    echo "Removing merged worktree: $worktree"
    git worktree remove "$worktree"
  else
    cd ..
  fi
done
```

## 🔗 次のステップ

- [命名規則](./NAMING.md): worktreeの適切な命名方法
- [トラブルシューティング](./TROUBLESHOOTING.md): 問題が発生した場合

---

[← 基本概念](./CONCEPTS.md) | [SKILL.md](./SKILL.md) | [命名規則 →](./NAMING.md)
