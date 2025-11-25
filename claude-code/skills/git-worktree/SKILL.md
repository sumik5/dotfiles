---
name: git-worktree
description: Git Worktree並行開発 - 新規作業開始時に必須。wt-プレフィックスでworktreeを作成し、並行開発を実現。ユーザー確認必須。
---

# Git Worktree並行開発ガイド

## 📖 このスキルについて

Git Worktreeを使用した並行開発の完全ガイドです。複数のブランチを同時に作業でき、Claude Codeの制約を考慮した実用的な運用方法を提供します。

## 🎯 使用タイミング

- **新規作業開始時（必須確認）**
- **並行開発が必要な時**
- **PO Agentのworktree管理時**
- **Developer Agentのworktree作業時**
- **Submoduleを含むプロジェクトでの並行開発**

## 🚨 最重要ルール：新規作業時のWorktree使用

### 必須の確認フロー

**新しい、今までの作業と関係ない作業だと判断した場合：**

1. **Submoduleの有無を確認すること**
   - `.gitmodules`ファイルの存在確認
   - `git submodule status`で submodule一覧を確認
2. **Worktreeを作成して作業を開始すること**
   - **Submoduleがない場合**: プロジェクトルートでworktree作成
   - **Submoduleがある場合**: 各submodule内でworktree作成
3. **ただし、必ずユーザーに確認を取ってから実行すること**
   - どういう名前のworktreeで作業するか提案
   - Submoduleがある場合は、どのsubmoduleにworktreeを作成するか提案
   - ユーザーの承認を得てから作成
   - **勝手にworktreeを作成して作業開始してはいけない**
4. **現在作業しているworktreeでの作業であれば確認不要**
5. **このworktreeを使った作業フローは絶対に遵守すること**

### 判断基準フローチャート

```
新しいタスク受信
    ↓
現在の作業と関連？
    ├─ Yes → 現在のworktreeで作業継続（確認不要）
    └─ No → 新規worktree必要
        ↓
        Submoduleの確認
        `.gitmodules`ファイルと`git submodule status`をチェック
        ↓
        ├─ Submoduleなし → ユーザーに確認
        │   「新しい作業のため、worktree `wt-feat/機能名` を作成しますか？」
        │   ↓
        │   プロジェクトルートでworktree作成・作業開始
        │
        └─ Submoduleあり → ユーザーに確認
            「新しい作業のため、以下のsubmoduleにworktree `wt-feat/機能名` を作成しますか？
             - submodule1/wt-feat/機能名
             - submodule2/wt-feat/機能名」
            ↓
            各submodule内でworktree作成・作業開始
```

## 📚 詳細ドキュメント

### [基本概念と制約](./CONCEPTS.md)
- Git Worktreeとは
- Claude Codeの制約と解決策
- 推奨ディレクトリ構造
- Agent階層との統合

### [ワークフロー](./WORKFLOWS.md)
- Worktreeの作成方法
- Worktreeでの作業手順
- Worktreeの管理と削除
- 実践的な操作コマンド

### [命名規則](./NAMING.md)
- 基本フォーマット
- カテゴリ別の命名例
- パラメータの詳細説明
- 命名のベストプラクティス

### [トラブルシューティング](./TROUBLESHOOTING.md)
- よくある問題と解決方法
- ベストプラクティス（DO/DON'T）
- serena連携の設定
- gwqツールの活用

## 🚀 クイックスタート

### 0. Submodule確認（必須）
```bash
# .gitmodulesファイルの存在確認
ls -la .gitmodules

# submodule一覧を確認
git submodule status
```

### 1. 新規Worktree作成

#### Submoduleがない場合
```bash
# 既存worktreeを確認
git worktree list

# 新規worktreeを作成（ユーザー確認後）
git worktree add -b feature/new-feature wt-feat-new-feature main
```

#### Submoduleがある場合
```bash
# 各submodule内でworktreeを作成（ユーザー確認後）
cd submodule1
git worktree add -b feature/new-feature wt-feat-new-feature main

cd ../submodule2
git worktree add -b feature/new-feature wt-feat-new-feature main

# 作業対象のsubmoduleに移動
cd ../submodule1/wt-feat-new-feature
```

### 2. Worktreeで作業

#### Submoduleがない場合
```bash
# worktreeに移動
cd wt-feat-new-feature

# 環境設定をコピー
cp ../.env .env
cp -r ../.serena .serena

# 開発作業
git status
git add .
git commit -m "feat: implement new feature"
```

#### Submoduleがある場合
```bash
# 対象submoduleのworktreeに移動（既に移動済みの場合はスキップ）
cd submodule1/wt-feat-new-feature

# 環境設定をコピー（submoduleの親ディレクトリから）
cp ../../.env .env 2>/dev/null || echo "No .env to copy"
cp -r ../.serena .serena 2>/dev/null || echo "No .serena to copy"

# 開発作業
git status
git add .
git commit -m "feat: implement new feature"
```

### 3. 作業完了後

#### Submoduleがない場合
```bash
# メインリポジトリに戻る
cd ..

# Worktree削除（ユーザーまたはManagerが実行）
git worktree remove wt-feat-new-feature
```

#### Submoduleがある場合
```bash
# submoduleのルートに戻る
cd ../..  # submodule1/wt-feat-new-feature から submodule1 へ

# 各submoduleのWorktree削除（ユーザーまたはManagerが実行）
git worktree remove wt-feat-new-feature

# 他のsubmoduleも同様に削除
cd ../submodule2
git worktree remove wt-feat-new-feature

# プロジェクトルートに戻る
cd ..
```

## ⚠️ 重要な注意事項

### DO（必須事項）
- ✅ 新規worktree作成時は**必ずユーザー確認**
- ✅ **作業開始前にsubmoduleの有無を確認**
- ✅ `wt-`プレフィックスを使用
- ✅ Submoduleがない場合：プロジェクト直下に作成
- ✅ Submoduleがある場合：各submodule内に作成
- ✅ `.env`と`.serena`をコピー

### DON'T（禁止事項）
- ❌ 勝手にworktreeを作成
- ❌ 勝手にworktreeを削除
- ❌ Submodule確認をスキップ
- ❌ Submoduleがあるのにプロジェクトルートでworktree作成
- ❌ 親ディレクトリ（`../`）への作成
- ❌ serenaの再初期化

## 🔗 関連スキル

- **mcp-serena**: Worktree内でのコード分析・編集
- **agent-hierarchy**: PO AgentによるWorktree管理、Developer AgentによるWorktree作業

## 📋 チェックリスト

新規worktree作成時：
- [ ] **Submoduleの有無を確認**（`.gitmodules`と`git submodule status`）
- [ ] ユーザーに確認を取得（submoduleがある場合は作成場所も提案）
- [ ] `wt-`プレフィックスで命名
- [ ] `git worktree add`で作成
  - Submoduleなし：プロジェクトルートで実行
  - Submoduleあり：各submodule内で実行
- [ ] worktreeに移動
- [ ] `.env`をコピー（必要に応じて）
- [ ] `.serena`をコピー
- [ ] 作業開始

作業完了時：
- [ ] すべての変更をコミット
- [ ] リモートにプッシュ
- [ ] 元のディレクトリに戻る
- [ ] Worktree削除（ユーザーまたはManagerが実行）
  - Submoduleなし：プロジェクトルートで削除
  - Submoduleあり：各submodule内で削除

---

**次のステップ**: [基本概念と制約](./CONCEPTS.md)で詳細を確認してください。
