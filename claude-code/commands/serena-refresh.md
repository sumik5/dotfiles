---
allowed-tools:
  - mcp__serena__activate_project
  - mcp__serena__get_current_config
  - mcp__serena__check_onboarding_performed
  - mcp__serena__onboarding
  - mcp__serena__get_symbols_overview
  - Bash
  - Read
description: 現在のプロジェクトのserenaデータを最新化
---

## 概要
プロジェクトのコードが大きく変更された後、serenaのシンボルデータベースが古くなることがあります。
このコマンドはserena MCPを使用してプロジェクトデータを最新化し、正確なコード分析を可能にします。

以下のような状況で使用します：

- 大規模なリファクタリング後
- 多数のファイル追加・削除後
- シンボル検索で期待した結果が得られない場合
- .serenaディレクトリのデータを最新状態にしたい場合

## 使い方
```bash
/serena-refresh
```

## 実行内容
1. 現在のディレクトリを確認
2. .serenaディレクトリの存在確認
3. serena MCPでプロジェクトを再アクティベート
4. オンボーディング状態の確認
5. シンボル情報の再スキャン
6. データベースの最新化完了を確認

## タスク実行
以下の手順を実行してください：

1. **現在のディレクトリとプロジェクト状態を確認**
   ```bash
   pwd
   ls -la .serena
   ```

2. **serena MCPの現在の設定を確認**
   - `mcp__serena__get_current_config`を使用

3. **プロジェクトを再アクティベート**
   - `mcp__serena__activate_project(project=".")`を実行

4. **オンボーディング状態を確認**
   - `mcp__serena__check_onboarding_performed`を実行
   - 未実施の場合は`mcp__serena__onboarding`を実行

5. **主要ファイルのシンボル概要を取得（サンプル）**
   - いくつかの主要ファイルで`mcp__serena__get_symbols_overview`を実行
   - これによりシンボルデータベースが更新される

6. **完了報告**
   - 「serenaのデータを最新化しました。」と応答
   - 更新されたファイル数やシンボル数の概要を表示

**重要な注意事項：**
- このコマンドは読み取り専用の操作のみを行います
- コードファイルの内容は一切変更しません
- .serenaディレクトリのデータベースのみを更新します
- 大規模プロジェクトでは数秒から数分かかる場合があります
