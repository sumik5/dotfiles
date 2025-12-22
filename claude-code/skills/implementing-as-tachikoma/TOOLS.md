# Developer Agent - ツール詳細リファレンス

このファイルでは、Developer Agentが使用できるすべてのツールとその使用方法を説明します。

## 📋 目次

- [基本ツール](#基本ツール実装用)
- [コマンド実行の原則](#コマンド実行の原則重要)
- [MCPツール](#mcpツール効率的実装用)
- [MCP活用の基本原則](#mcp活用の基本原則)

## ✅ 基本ツール（実装用）

### ファイル操作系
- **Write**: ファイル書き込み - 新規ファイル作成時に使用
- **Edit**: ファイル編集 - 既存ファイルの部分修正時に使用
- **MultiEdit**: 複数ファイル編集 - 複数ファイルの同時修正時に使用
- **NotebookEdit**: Jupyter編集 - Notebookファイルの編集時に使用
- **Read**: ファイル読み込み - ファイル内容の確認時に使用

### 検索・調査系
- **Glob**: ファイル検索 - パターンマッチングでファイルを検索
- **Grep**: テキスト検索 - ファイル内のテキストを検索
- **WebFetch**: Web情報取得 - Webページの情報を取得

### 実行・管理系
- **Bash**: コマンド実行 - シェルコマンドの実行（ただし専用ツール優先）
- **TodoWrite**: タスク管理 - タスクの進捗管理

## ⚡ コマンド実行の原則（重要）

### 専用ツールの優先使用

**基本原則**: Bashツールでコマンドを実行する前に、専用ツールが利用可能か確認してください。

| 操作 | ❌ 非推奨 | ✅ 推奨 | 理由 |
|------|----------|---------|------|
| テキスト検索 | `bash grep` | **Grep**ツール | ripgrep最適化済み |
| ファイル検索 | `bash find` | **Glob**ツール | パターンマッチング最適化 |
| ファイル読込 | `bash cat` | **Read**ツール | トークン効率最適化 |

### Bashツール使用時の注意

Bashツールでコマンドを実行する場合：
- **検索コマンド**: `grep`ではなく`rg`（ripgrep）を使用 - より高速
- **単純な操作**: 専用ツールが利用できない場合のみBashを使用

**理由**: 専用ツールはClaude Code用に最適化されており、より高速で効率的です。

## 🔧 MCPツール（効率的実装用）

以下のMCPツールが利用可能です。各ツールの詳細な使用方法は、対応するスキルを参照してください。

### コア開発ツール

#### serena MCP（最重要）
**用途**: コード編集、リファクタリング、構造分析
**スキル参照**: `using-serena`
**優先度**: 🔴 最優先 - コード編集は必ずserenaを使用

**主な機能**:
- シンボル（クラス、関数、変数）の検索と位置特定
- コードパターンの検出と影響範囲の分析
- リファクタリングと安全なコード変更
- プロジェクト固有の知識管理

#### next-devtools MCP（Next.js専用）
**用途**: Next.js開発の診断、アップグレード、最適化
**スキル参照**: `using-next-devtools`
**優先度**: 🔴 必須（Next.jsプロジェクトの場合）

**主な機能**:
- 開発サーバー診断とルート構造把握
- Next.jsアップグレード自動化
- Server Components最適化
- エラー検出と自動修正

#### shadcn MCP（UIコンポーネント）
**用途**: React/Next.js UIコンポーネント管理
**スキル参照**: `using-shadcn`
**優先度**: 🔴 必須（React/Next.jsプロジェクトの場合）

**主な機能**:
- shadcn/uiコンポーネントの検索・追加・管理
- components.json設定とレジストリ管理
- 使用例とデモコードの取得

### インフラ・環境構築ツール

#### docker MCP
**用途**: コンテナ管理、環境構築
**スキル参照**: `managing-docker`

**主な機能**:
- コンテナ操作（起動、停止、管理）
- イメージ管理
- Docker Composeプロジェクト管理
- ログ取得とデバッグ

#### awslabs.aws-documentation / terraform MCP
**用途**: AWSインフラ構築、Terraform設定
**スキル参照**: `mcp-aws`

**主な機能**:
- AWSサービスのドキュメント参照
- Terraformベストプラクティス
- Infrastructure as Code実装

### 情報検索ツール

#### 検索系MCP（kagi, firecrawl, deepwiki, docset等）
**用途**: 情報検索、技術調査
**スキル参照**: `mcp-search`

**主な機能**:
- Web検索と最新情報取得
- GitHubリポジトリ解析
- 技術ドキュメント検索
- 動画コンテンツ分析

### ファイル操作ツール

#### filesystem / markdownify / pandoc MCP
**用途**: ファイル操作、変換
**スキル参照**: `mcp-filesystem`

**主な機能**:
- ファイル読み書き、編集
- 形式変換（PDF、Markdown等）
- ディレクトリ操作

### ブラウザ自動化ツール

#### playwright / puppeteer / chrome-devtools MCP
**用途**: ブラウザ自動化、E2Eテスト
**スキル参照**: `mcp-browser-auto`

**主な機能**:
- Webアプリケーションの自動テスト
- スクリーンショット取得
- パフォーマンス測定

### その他のツール

#### claude-mem MCP
**用途**: セッション間コンテキスト管理
**主な機能**:
- 過去の会話履歴の永続化
- プロジェクト知識の長期保存
- セッションをまたいだ情報共有

#### sequentialthinking MCP
**用途**: 複雑な問題の段階的解決
**主な機能**:
- 問題の段階的分解
- 仮説の生成と検証
- 論理的推論サポート

## 🎯 MCP活用の基本原則

### タスク開始前の必須確認

**ステップ1**: 利用可能なMCPサーバーの確認
```
ListMcpResourcesToolで全MCPサーバーの一覧を取得
```

**ステップ2**: タスクに最適なMCPの選定
- タスクの性質を分析
- 最適なMCPツールを選択
- 複数のMCPを組み合わせて使用

### 最重要MCPの使用優先順位

開発タスクにおける優先順位：

1. **🔴 serena MCP** - コード編集（必須）
   - すべてのコード編集作業でserenaを使用
   - ファイル全体の読み込みではなく、シンボル単位で操作

2. **🔴 next-devtools MCP** - Next.js開発（Next.js専用、必須）
   - Next.jsプロジェクトでは必ず使用
   - アップグレード、診断、最適化に活用

3. **🔴 shadcn MCP** - React/Next.js UI実装（必須）
   - UIコンポーネント管理に必須
   - components.json設定を確認してから使用

4. **🟡 context7 MCP** - 最新仕様確認（推奨）
   - 実装前に必ず最新ドキュメントを確認
   - ライブラリのバージョン固有の情報を取得

### 効率的なMCP活用パターン

**パターン1**: コード実装の標準フロー
```
1. context7 MCPで最新仕様確認
2. serena MCPでコードベース分析
3. serena MCPで実装
4. テスト実行
5. securing-code スキルでCodeGuard実行
```

**パターン2**: Next.js開発の標準フロー
```
1. next-devtools MCPで開発サーバー診断
2. context7 MCPでNext.js最新仕様確認
3. shadcn MCPでUIコンポーネント追加
4. serena MCPでビジネスロジック実装
5. next-devtools MCPでエラーチェックと最適化
```

**パターン3**: インフラ構築の標準フロー
```
1. mcp-aws スキルでAWSドキュメント確認
2. docker MCPでコンテナ環境構築
3. mcp-aws スキルでTerraform設定
4. 動作確認
```

## 📊 ツール選択のフローチャート

```
タスク受信
    ↓
コード編集が必要？
    ├─ Yes → serena MCP（必須）
    └─ No → 次の判断へ
        ↓
        Next.jsプロジェクト？
        ├─ Yes → next-devtools MCP（必須）
        └─ No → 次の判断へ
            ↓
            UIコンポーネント？
            ├─ Yes → shadcn MCP
            └─ No → タスクに応じたMCP選択
```

## ⚠️ 重要な注意事項

### MCPツール使用時の禁止事項
- ❌ MCPが利用可能なのに、Bashツールで同等の操作を実行
- ❌ serena MCPを使わずにファイル全体を読み込んでから編集
- ❌ context7 MCPで最新仕様を確認せずに古い知識で実装

### 推奨される使用方法
- ✅ タスク開始時に必ずListMcpResourcesToolで確認
- ✅ コード編集は常にserena MCPを使用
- ✅ 実装前に必ずcontext7 MCPで最新仕様を確認
- ✅ 複数のMCPを組み合わせて効率的に作業

## 🔗 関連スキル

詳細な使用方法については、以下のスキルを参照してください：

- **using-serena** - serena MCP詳細ガイド
- **using-next-devtools** - Next.js開発ガイド
- **using-shadcn** - UIコンポーネント管理
- **managing-docker** - Docker環境管理
- **mcp-aws** - AWSインフラ構築
- **mcp-browser-auto** - ブラウザ自動化
- **mcp-search** - 情報検索戦略
- **mcp-filesystem** - ファイル操作
