---
allowed-tools: Read
description: CLAUDE.mdを再読み込みしてcompaction後のコンテキストを復元
---

## 概要
compaction（会話の圧縮）が走った後、CLAUDE.mdに記載された重要な指示やガイドラインが失われることがあります。
このコマンドはCLAUDE.mdを再読み込みして、以下のコンテキストを復元します：

- Agent System利用ガイド（PO→Manager→Developerの階層）
- MCPサーバー利用ガイドライン
- コード設計の原則（SOLID原則、クリーンコード）
- プロジェクト運用ルール

## 使い方
```bash
/reload
```

## 実行内容
CLAUDE.mdファイル（`$HOME/.claude/CLAUDE.md`）を読み込み、その内容を表示します。
これにより、compaction後も重要な指示とガイドラインを再確認できます。

## タスク実行
以下の手順を実行してください：

1. CLAUDE.mdファイル（`$HOME/.claude/CLAUDE.md`）を読み込む
2. 読み込んだ内容を理解し、以降の作業で厳密に遵守する

**特に重要な遵守事項：**
- **Agent System**: コード修正は必ずPO→Manager→Developerの階層で実行
- **Worktree管理**: 新規作業時はユーザー確認後にworktree作成。PO AgentがWorktree管理を担当
- **Git操作絶対禁止**: git add/commit/push等のGit操作は絶対に実行しない。Agentに任せる
- **MCP使用**: serena優先、context7でライブラリ調査、専用ツール使用
- **コマンド実行**: grep/find/cat等はBashツールではなく専用ツール（Grep/Glob/Read）を使用
- **設計原則**: SOLID原則、クリーンコード、テストファーストを徹底

読み込み後、「CLAUDE.mdの指示を確認しました。以降これに従って動作します。」と応答してください。
