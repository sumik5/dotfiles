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

1. **変更対象を明確化すること（最重要）**
   - 何を変更するのか分析（親git側のコード vs submodule内のコード）
   - Submoduleの有無を確認（`.gitmodules`と`git submodule status`）
2. **変更対象に基づいてworktree作成場所を判断**
   - **親git側のコード変更**: 親gitのルートでworktree作成
   - **Submodule内のコード変更のみ**: そのsubmodule内でのみworktree作成（**親gitには作らない**）
3. **ただし、必ずユーザーに確認を取ってから実行すること**
   - どういう名前のworktreeで作業するか提案
   - Submodule内変更の場合は、どのsubmoduleにworktreeを作成するか明記
   - **重要**: Submodule内変更の場合、親gitにはworktreeを作らないことを明示
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
        変更対象を分析（最重要）
        「何を変更するか？」を明確化
        ↓
        ├─ 親git側のコード変更 → ユーザーに確認
        │   「新しい作業のため、親gitに worktree `wt-feat/機能名` を作成しますか？」
        │   ↓
        │   親gitルートでworktree作成・作業開始
        │
        └─ Submodule内のコード変更のみ → ユーザーに確認
            「新しい作業のため、submodule1に worktree `wt-feat/機能名` を作成しますか？
             ※親gitにはworktreeを作成しません」
            ↓
            対象submodule内でのみworktree作成・作業開始
            ⚠️ 親gitにはworktreeを作らない
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

### 0. 変更対象の確認（最重要）
```bash
# 何を変更するか明確化
# - 親git側のコード変更？
# - Submodule内のコード変更のみ？

# Submoduleの有無を確認
ls -la .gitmodules
git submodule status
```

### 1. 新規Worktree作成

#### ケース1: 親git側のコード変更
```bash
# 親gitルートで実行
# 既存worktreeを確認
git worktree list

# 新規worktreeを作成（ユーザー確認後）
git worktree add -b feature/new-feature wt-feat-new-feature main
```

#### ケース2: Submodule内のコード変更のみ
```bash
# ⚠️ 重要: 親gitにはworktreeを作らない

# 対象submodule内でworktreeを作成（ユーザー確認後）
cd submodule1
git worktree add -b feature/new-feature wt-feat-new-feature main

# 作業対象のsubmoduleのworktreeに移動
cd wt-feat-new-feature
```

### 2. Worktreeで作業

#### ケース1: 親git側のコード変更
```bash
# 親gitのworktreeに移動
cd wt-feat-new-feature

# 環境設定をコピー
cp ../.env .env
cp -r ../.serena .serena

# 開発作業
git status
git add .
git commit -m "feat: implement new feature"
```

#### ケース2: Submodule内のコード変更のみ
```bash
# 対象submoduleのworktreeに移動（既に移動済みの場合はスキップ）
cd submodule1/wt-feat-new-feature

# 環境設定をコピー（submoduleの親ディレクトリから、必要に応じて）
cp ../.env .env 2>/dev/null || echo "No .env in submodule"
cp -r ../.serena .serena 2>/dev/null || echo "No .serena in submodule"

# 開発作業
git status
git add .
git commit -m "feat: implement new feature in submodule"
```

### 3. 作業完了後

#### ケース1: 親git側のコード変更
```bash
# 親gitルートに戻る
cd ..

# Worktree削除（ユーザーまたはManagerが実行）
git worktree remove wt-feat-new-feature
```

#### ケース2: Submodule内のコード変更のみ
```bash
# submoduleのルートに戻る
cd ..  # submodule1/wt-feat-new-feature から submodule1 へ

# submodule内のWorktree削除（ユーザーまたはManagerが実行）
git worktree remove wt-feat-new-feature

# プロジェクトルートに戻る
cd ..
```

## ⚠️ 重要な注意事項

### DO（必須事項）
- ✅ 新規worktree作成時は**必ずユーザー確認**
- ✅ **変更対象を明確化**（親git側 vs submodule内）
- ✅ `wt-`プレフィックスを使用
- ✅ 親git側のコード変更：親gitルートに作成
- ✅ Submodule内のコード変更のみ：対象submodule内にのみ作成
- ✅ `.env`と`.serena`をコピー

### DON'T（禁止事項）
- ❌ 勝手にworktreeを作成
- ❌ 勝手にworktreeを削除
- ❌ 変更対象の確認をスキップ
- ❌ **Submodule内のコード変更のみなのに親gitにworktree作成**（最重要）
- ❌ 親ディレクトリ（`../`）への作成
- ❌ serenaの再初期化

## 🔗 関連スキル

- **mcp-serena**: Worktree内でのコード分析・編集
- **agent-hierarchy**: PO AgentによるWorktree管理、Developer AgentによるWorktree作業

## 📋 チェックリスト

新規worktree作成時：
- [ ] **変更対象を明確化**（親git側 vs submodule内）
- [ ] Submoduleの有無を確認（`.gitmodules`と`git submodule status`）
- [ ] ユーザーに確認を取得（作成場所を明記）
- [ ] `wt-`プレフィックスで命名
- [ ] `git worktree add`で作成
  - 親git側変更：親gitルートで実行
  - Submodule内変更のみ：対象submodule内でのみ実行（**親gitには作らない**）
- [ ] worktreeに移動
- [ ] `.env`をコピー（必要に応じて）
- [ ] `.serena`をコピー
- [ ] 作業開始

作業完了時：
- [ ] すべての変更をコミット
- [ ] リモートにプッシュ
- [ ] 元のディレクトリに戻る
- [ ] Worktree削除（ユーザーまたはManagerが実行）
  - 親git側変更：親gitルートで削除
  - Submodule内変更：対象submodule内で削除

---

**次のステップ**: [基本概念と制約](./CONCEPTS.md)で詳細を確認してください。
