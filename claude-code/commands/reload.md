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
CLAUDE.mdファイルを読み込んで内容を表示してください。
