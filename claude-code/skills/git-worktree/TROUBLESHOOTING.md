# トラブルシューティングとベストプラクティス

## 🔍 よくある問題と解決方法

### 1. Worktreeが作成できない

#### 問題: ブランチが既に別のworktreeで使用中

```bash
# エラーメッセージ例
fatal: 'feature/auth' is already checked out at '/path/to/project/wt-feat-auth'
```

**解決方法**:

```bash
# 既存のworktreeを確認
git worktree list

# 不要なworktreeを削除
git worktree remove wt-feat-auth

# または、既存worktreeの場所に移動して作業
cd wt-feat-auth
```

#### 問題: ディレクトリが既に存在

```bash
# エラーメッセージ例
fatal: 'wt-feat-auth' already exists
```

**解決方法**:

```bash
# 既存ディレクトリの内容を確認
ls -la wt-feat-auth

# 不要な場合は削除
rm -rf wt-feat-auth

# Worktreeを作成
git worktree add -b feature/auth wt-feat-auth main

# または、別の名前で作成
git worktree add -b feature/auth wt-feat-auth-v2 main
```

#### 問題: 親ディレクトリへのアクセスエラー

```bash
# Claude Codeで親ディレクトリに作成しようとした場合
git worktree add ../project-feature feature/new
# エラー: 親ディレクトリにアクセスできない
```

**解決方法**:

```bash
# プロジェクトフォルダ直下に作成
git worktree add wt-feat-new feature/new
```

### 2. Worktreeが削除できない

#### 問題: 未コミットの変更がある

```bash
# エラーメッセージ例
error: 'wt-feat-payment' contains modified or untracked files, use --force to delete it
```

**解決方法**:

```bash
# オプション1: 変更をコミット
cd wt-feat-payment
git status
git add .
git commit -m "WIP: save current work"
cd ..
git worktree remove wt-feat-payment

# オプション2: 変更を一時保存
cd wt-feat-payment
git stash
cd ..
git worktree remove wt-feat-payment

# オプション3: 変更を破棄（注意！）
git worktree remove --force wt-feat-payment
```

#### 問題: Worktreeがロックされている

```bash
# エラーメッセージ例
error: 'wt-feat-payment' is locked
```

**解決方法**:

```bash
# ロックを解除
git worktree unlock wt-feat-payment

# ロック状態を確認
git worktree list

# ロック理由を確認（--porcelainオプション）
git worktree list --porcelain
```

### 3. Worktreeの状態がおかしい

#### 問題: Worktreeディレクトリを手動で削除した

```bash
# 手動削除後の状態
rm -rf wt-feat-payment
git worktree list
# → wt-feat-paymentがリストに残っている
```

**解決方法**:

```bash
# Git側のworktree情報をクリーンアップ
git worktree prune

# クリーンアップ対象を事前確認
git worktree prune --dry-run

# 全worktreeの整合性をチェック
git worktree list
```

#### 問題: Worktreeへのパスが壊れている

```bash
# エラーメッセージ例
error: 'wt-feat-payment' is not a working tree
```

**解決方法**:

```bash
# worktreeの修復を試行
git worktree repair

# 特定のworktreeを修復
git worktree repair wt-feat-payment

# 全worktreeを検証・修復
git worktree repair --all

# 修復できない場合は削除して再作成
git worktree remove wt-feat-payment --force
git worktree add -b feature/payment wt-feat-payment main
```

### 4. 環境設定の問題

#### 問題: .envファイルが見つからない

```bash
# worktree内で.envが無い
cd wt-feat-payment
cat .env
# cat: .env: No such file or directory
```

**解決方法**:

```bash
# 親リポジトリから.envをコピー
cp ../.env .env

# または、テンプレートから作成
cp ../.env.example .env
# エディタで必要な値を設定

# .envの存在を確認
ls -la .env
```

#### 問題: .serenaが初期化されていない

```bash
# serenaツールが動作しない
```

**解決方法**:

```bash
# オプション1: 親の.serenaをコピー（推奨・高速）
cp -r ../.serena .serena

# オプション2: 新規に初期化（時間がかかる）
mcp__serena__activate_project(project=".")

# .serenaの存在を確認
ls -la .serena
```

#### 問題: 依存パッケージが無い

```bash
# node_modulesが無い
npm start
# Error: Cannot find module '...'
```

**解決方法**:

```bash
# オプション1: 個別にインストール（安全）
npm install

# オプション2: 親のnode_modulesへシンボリックリンク（高速）
ln -s ../node_modules node_modules

# オプション3: 親のnode_modulesをコピー（大きい）
cp -r ../node_modules node_modules
```

## ⚡ ベストプラクティス

### DO（推奨事項）

#### 1. ユーザー確認を必ず取る

```bash
# ✅ 正しい手順
# Agent: 「新しい機能開発のため、worktree `wt-feat-payment` を作成しますか？」
# User: 「はい」
# Agent: worktree作成を実行

# ❌ 間違った手順
# Agent: 勝手にworktreeを作成
```

#### 2. wt-プレフィックスを使用

```bash
# ✅ 良い例
git worktree add -b feature/auth wt-feat-auth main

# ❌ 悪い例
git worktree add -b feature/auth auth-feature main
```

#### 3. プロジェクト直下に作成

```bash
# ✅ 良い例（プロジェクト内）
cd /path/to/project
git worktree add wt-feat-new feature/new

# ❌ 悪い例（親ディレクトリ）
git worktree add ../project-new feature/new
```

#### 4. 環境設定を適切にコピー

```bash
# ✅ 良い例（必要な設定をすべてコピー）
cd wt-feat-payment
cp ../.env .env
cp -r ../.serena .serena
npm install  # または ln -s ../node_modules

# ❌ 悪い例（設定をコピーしない）
cd wt-feat-payment
# .envや.serenaをコピーせずに開発開始
```

#### 5. 作業前に既存worktreeを確認

```bash
# ✅ 良い例
git worktree list  # 既存worktreeを確認してから作成

# ❌ 悪い例
git worktree add wt-feat-new feature/new  # 確認せずに作成
```

#### 6. 定期的なクリーンアップ

```bash
# ✅ 良い例（定期的にクリーンアップ）
git worktree list
git worktree remove wt-feat-completed  # 完了したworktreeを削除
git worktree prune  # 無効なエントリをクリーンアップ

# ❌ 悪い例
# worktreeを放置してディスク容量を圧迫
```

#### 7. serenaは親からコピー（初期化不要）

```bash
# ✅ 良い例（コピーで高速）
cp -r ../.serena .serena

# ❌ 悪い例（毎回初期化で時間がかかる）
mcp__serena__activate_project(project=".")
mcp__serena__onboarding()
```

### DON'T（避けるべき事項）

#### 1. 勝手にworktreeを作成

```bash
# ❌ 絶対NG
# ユーザー確認なしでworktree作成

# ✅ 正しい方法
# 必ずユーザーに確認してから作成
```

#### 2. 勝手にworktreeを削除

```bash
# ❌ 絶対NG（Agentは削除しない）
git worktree remove wt-feat-payment

# ✅ 正しい方法
# ユーザーまたはManagerが削除を判断
```

#### 3. 親ディレクトリへの作成

```bash
# ❌ 悪い例（Claude Codeでアクセス不可）
git worktree add ../project-feature feature/new

# ✅ 良い例
git worktree add wt-feat-new feature/new
```

#### 4. Worktree内にWorktreeを作成

```bash
# ❌ 悪い例（ネスト構造）
cd wt-feat-payment
git worktree add wt-feat-nested feature/nested

# ✅ 良い例（フラット構造）
cd /path/to/project
git worktree add wt-feat-new feature/new
```

#### 5. 同じブランチの複数worktree

```bash
# ❌ 悪い例（同じブランチを複数で使用）
git worktree add wt-feat-payment-1 feature/payment
git worktree add wt-feat-payment-2 feature/payment
# エラー: ブランチが既に使用中

# ✅ 良い例（1ブランチ1worktree）
git worktree add wt-feat-payment feature/payment
```

#### 6. Worktree外での作業

```bash
# ❌ 悪い例（worktree指定時にメインで作業）
# 指示: wt-feat-paymentで作業
cd /path/to/project  # メインリポジトリで作業してしまう

# ✅ 良い例
cd /path/to/project/wt-feat-payment  # 指定されたworktreeで作業
```

#### 7. serenaの再初期化

```bash
# ❌ 悪い例（時間がかかる）
cd wt-feat-new
mcp__serena__activate_project(project=".")
mcp__serena__onboarding()

# ✅ 良い例（コピーで高速）
cd wt-feat-new
cp -r ../.serena .serena
```

## 📊 serena連携のベストプラクティス

### Worktree作業時のserena設定

```bash
# 標準的なセットアップ手順

# 1. worktreeに移動
cd wt-feat-new-feature

# 2. 必要に応じて環境変数をコピー
cp ../.env .env

# 3. 親フォルダの.serenaをコピー（初期化不要で高速）
cp -r ../.serena .serena

# 4. .serenaのコピーが成功したか確認
ls -la .serena

# 5. serenaが正常に動作するか確認（オプション）
# mcp__serena__get_symbols_overview を実行してテスト

# 6. 開発作業を開始
# ... コード編集 ...
```

### serena使用時の注意点

| 項目 | 詳細 |
|-----|------|
| **コピー元** | 親プロジェクトで既にserenaが初期化されている必要あり |
| **独立性** | worktree内で`.serena`を変更しても親には影響しない |
| **更新頻度** | 親の`.serena`が大幅に更新された場合は再コピー検討 |
| **ディスク容量** | `.serena`は比較的小さいため、コピーによる容量増は限定的 |

## 🛠️ gwq（Git Worktree Quick）ツールの活用

gwqは、git worktreeをより効率的に管理するためのツールです。利用可能な場合は積極的に使用してください。

### gwqとは

- **公式リポジトリ**: https://github.com/rthewitt/gwq
- **目的**: worktreeの作成・管理を簡略化
- **特徴**: 一貫した命名規則、Fuzzy Finder統合、効率的な操作

### 基本的な使い方

#### 1. Worktreeの作成

```bash
# 自動的にwt-プレフィックスとfeature/プレフィックスを付与
gwq add -b auth-refactor

# 実行結果:
# - ブランチ: feature/auth-refactor
# - Worktree: wt-auth-refactor
```

#### 2. Worktreeへのアクセス

```bash
# Fuzzy Finderで全worktreeから選択
cd $(gwq get)

# 部分マッチで素早くアクセス
cd $(gwq get auth)  # 'auth'を含むworktreeを検索

# 実行例:
# $ cd $(gwq get pay)
# → wt-feat-payment-integration に移動
```

#### 3. Worktreeの一覧表示

```bash
# すべてのworktreeを表示
gwq list

# 出力例:
# wt-feat-auth
# wt-feat-payment
# wt-fix-bug-123
```

#### 4. Worktreeの削除

```bash
# Fuzzy Finderで削除対象を選択
gwq remove

# または部分マッチで指定
gwq remove auth
```

### gwqの利点

| 利点 | 説明 |
|-----|------|
| **一貫性** | 自動的にwt-プレフィックスを付与 |
| **効率性** | Fuzzy Finderで素早く選択 |
| **ミス防止** | 命名規則の自動適用でエラー削減 |
| **生産性** | タイピング量の削減 |

### gwqが利用できない場合

gwqがインストールされていない環境では、通常の`git worktree`コマンドを使用してください：

```bash
# gwqが無い場合の代替コマンド
git worktree list
git worktree add -b feature/auth wt-feat-auth main
cd wt-feat-auth
git worktree remove wt-feat-auth
```

### gwqのインストール（参考）

```bash
# Homebrewでインストール（macOS/Linux）
brew install gwq

# または、GitHubから直接ダウンロード
# https://github.com/rthewitt/gwq
```

## 🔧 メンテナンスタスク

### 日次メンテナンス

```bash
# 使用済みworktreeの削除チェック
git worktree list
# 完了したworktreeを削除（ユーザーまたはManagerが実行）

# 無効なworktreeエントリのクリーンアップ
git worktree prune
```

### 週次メンテナンス

```bash
# すべてのworktreeのステータス確認
for worktree in wt-*; do
  echo "=== $worktree ==="
  cd "$worktree"
  git status -s
  cd ..
done

# 未プッシュのコミット確認
for worktree in wt-*; do
  echo "=== $worktree ==="
  cd "$worktree"
  git log origin/$(git branch --show-current)..HEAD --oneline
  cd ..
done

# ディスク使用量確認
du -sh wt-*
```

### 月次メンテナンス

```bash
# マージ済みworktreeの削除
for worktree in wt-*; do
  cd "$worktree"
  branch=$(git branch --show-current)
  if git branch --merged main | grep -q "$branch"; then
    cd ..
    echo "Merged worktree: $worktree"
    # ユーザーまたはManagerが削除を判断
  else
    cd ..
  fi
done

# 全worktreeの整合性チェック
git worktree repair --all
git worktree prune
```

## 🔗 関連情報

- [基本概念](./CONCEPTS.md): worktreeの仕組みと制約
- [ワークフロー](./WORKFLOWS.md): 操作手順の詳細
- [命名規則](./NAMING.md): 適切な命名方法

---

[← 命名規則](./NAMING.md) | [SKILL.md](./SKILL.md) | [基本概念](./CONCEPTS.md)
