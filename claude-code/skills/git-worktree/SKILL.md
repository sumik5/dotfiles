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

## 🚨 最重要ルール：新規作業時のWorktree使用

### 必須の確認フロー

**新しい、今までの作業と関係ない作業だと判断した場合：**

1. **Worktreeを作成して作業を開始すること**
2. **ただし、必ずユーザーに確認を取ってから実行すること**
   - どういう名前のworktreeで作業するか提案
   - ユーザーの承認を得てから作成
   - **勝手にworktreeを作成して作業開始してはいけない**
3. **現在作業しているworktreeでの作業であれば確認不要**
4. **このworktreeを使った作業フローは絶対に遵守すること**

### 判断基準フローチャート

```
新しいタスク受信
    ↓
現在の作業と関連？
    ├─ Yes → 現在のworktreeで作業継続（確認不要）
    └─ No → 新規worktree必要
        ↓
        ユーザーに確認
        「新しい作業のため、worktree `wt-feat/機能名` を作成しますか？」
        ↓
        承認後に作成・作業開始
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

### 1. 新規Worktree作成
```bash
# 既存worktreeを確認
git worktree list

# 新規worktreeを作成（ユーザー確認後）
git worktree add -b feature/new-feature wt-feat-new-feature main
```

### 2. Worktreeで作業
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

### 3. 作業完了後
```bash
# メインリポジトリに戻る
cd ..

# Worktree削除（ユーザーまたはManagerが実行）
git worktree remove wt-feat-new-feature
```

## ⚠️ 重要な注意事項

### DO（必須事項）
- ✅ 新規worktree作成時は**必ずユーザー確認**
- ✅ `wt-`プレフィックスを使用
- ✅ プロジェクト直下に作成
- ✅ `.env`と`.serena`をコピー

### DON'T（禁止事項）
- ❌ 勝手にworktreeを作成
- ❌ 勝手にworktreeを削除
- ❌ 親ディレクトリ（`../`）への作成
- ❌ serenaの再初期化

## 🔗 関連スキル

- **mcp-serena**: Worktree内でのコード分析・編集
- **agent-hierarchy**: PO AgentによるWorktree管理、Developer AgentによるWorktree作業

## 📋 チェックリスト

新規worktree作成時：
- [ ] ユーザーに確認を取得
- [ ] `wt-`プレフィックスで命名
- [ ] `git worktree add`で作成
- [ ] worktreeに移動
- [ ] `.env`をコピー（必要に応じて）
- [ ] `.serena`をコピー
- [ ] 作業開始

作業完了時：
- [ ] すべての変更をコミット
- [ ] リモートにプッシュ
- [ ] メインリポジトリに戻る
- [ ] Worktree削除（ユーザーまたはManagerが実行）

---

**次のステップ**: [基本概念と制約](./CONCEPTS.md)で詳細を確認してください。
