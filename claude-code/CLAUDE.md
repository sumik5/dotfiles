# CLAUDE.md - Claude Code 設定

## 📍 プラグイン環境

### Marketplaceプラグイン一覧

#### 🔷 公式プラグイン (claude-plugins-official)
| プラグイン | 説明 |
|-----------|------|
| **code-review** | PRコードレビュー（複数エージェント使用） |
| **frontend-design** | UI/UX実装スキル |
| **figma** | Figmaデザイン→コード統合 |
| **security-guidance** | セキュリティ警告フック（自動検出） |
| **github** | GitHub MCP（Issue/PR管理） |
| **feature-dev** | 機能開発ワークフロー（探索・設計・レビューAgent） |
| **plugin-dev** | プラグイン開発支援 |
| **ralph-loop** | 反復開発ループ（while-true technique） |
| **context7** | Context7 MCP（ライブラリドキュメント検索） |
| **code-simplifier** | コード簡素化・リファクタリングAgent |

#### 🔷 LSPプラグイン (言語サーバー)
| プラグイン | 言語 |
|-----------|------|
| **typescript-lsp** | TypeScript |
| **pyright-lsp** | Python |
| **gopls-lsp** | Go |

#### 🔷 セキュリティ
| プラグイン | 説明 |
|-----------|------|
| **codeguard-security** | CodeGuardセキュリティチェック（🔴実装後必須） |

#### 🔷 Storybook
| プラグイン | 説明 |
|-----------|------|
| **storybook-assistant** | Storybook 9対応（Vision AI、ダークモード、a11y、RSC） |

#### 🔷 インフラ・プラットフォーム
| プラグイン | 説明 |
|-----------|------|
| **mcp-toolkit** | Docker Desktop MCP Toolkit統合（Docker 4.28+） |

#### 🔷 awesome-claude-skills
| カテゴリ | プラグイン |
|---------|-----------|
| **ドキュメント** | document-skills-docx, document-skills-pdf, document-skills-pptx, document-skills-xlsx |
| **コンテンツ** | content-research-writer, internal-comms, meeting-insights-analyzer |
| **開発支援** | artifacts-builder, changelog-generator, webapp-testing, skill-creator |
| **ユーティリティ** | file-organizer, image-enhancer, video-downloader, theme-factory |
| **ビジネス** | domain-name-brainstormer, lead-research-assistant, tailored-resume-generator |
| **コミュニケーション** | slack-gif-creator |

---

## 🌐 言語設定（絶対遵守）

**CRITICAL: すべての応答は必ず日本語で行う**
- Claude Code本体、全Agentの応答
- タスク報告、エラーメッセージ、コード内コメント
- 例外: 技術用語、ライブラリ名、プログラミングキーワード

---

## 🚨 絶対ルール

### コード修正
- **Claude Code本体は絶対にコードを直接修正しない**
- コード修正は必ずTachikomaに委譲
- 例外: ファイル読み込み、質問回答、計画・設計ドキュメント作成のみ

### Git操作禁止
- **絶対禁止**: `git add`, `commit`, `push`, `merge`, `rebase`
- 許可: `git status`, `diff`, `log`, `branch`, `worktree list`, `submodule status`

### Worktree管理（🔴 最重要）
- **新規作業時**: 必ずユーザー確認してworktree作成提案
- **勝手な作成・削除禁止**
- **Submodule環境での注意**:
  1. 最初に `ls -la .gitmodules` と `git submodule status` で確認
  2. 親git側コード変更 → 親gitルートにworktree作成
  3. **Submodule内コード変更 → 対象submodule内にのみworktree作成**
  4. ❌ **Submodule内変更なのに親gitにworktree作成は絶対禁止**

### ライブラリ優先（車輪の再発明禁止）
- **実装前に必ず既存ライブラリを調査**
- `researching-libraries` スキル参照して事前調査をおこなうこと
- Context7 MCP でライブラリドキュメント検索
- 自作は「適切なライブラリが存在しない」場合のみ
- 調査せずに実装を始めることは禁止

### 質問・確認（曖昧さの排除）
- **不明点があれば必ずAskUserQuestionツールで質問**
- 曖昧さがなくなるまで質問を重ねて理解をクリアにする
- 推測で作業を進めない

### ドキュメント先行開発（Documentation-First Development）
- **作業開始前に必ず`docs/`フォルダにMarkdown形式で計画をまとめる**
- 以下の内容を含める:
  - 変更の目的・背景
  - 変更対象ファイル・コンポーネント一覧
  - 具体的な変更内容（コード例含む）
  - 移行手順・実行順序
  - 注意事項・リスク
- ドキュメント作成後、ユーザー確認を経てから実装開始
- 例外: 1ファイル内の軽微な修正（typo修正、1行変更など）
- **ドキュメントは将来の参照用として残す**（作業完了後も削除しない）

---

## 🎯 Quick Start

### プロジェクト開始手順
1. `.serena`確認 → なければ`serena`初期化・オンボーディング
2. `git submodule status` でSubmodule有無確認
3. プロジェクト構造把握

---

## 📚 MCP使用ガイド

### 最優先MCP（必須）
| MCP | 用途 |
|-----|------|
| **serena** | コード分析・編集・メモリ管理（プロジェクト作業前に必ず初期化） |
| **next-devtools** | Next.js専用（診断・アップグレード・Cache Components） |

### カテゴリ別MCP
| カテゴリ | MCP | 用途 |
|---------|-----|------|
| 🔥 **開発** | serena, next-devtools, shadcn | コード編集、Next.js、UIコンポーネント |
| 🔍 **検索** | context7, deepwiki | ライブラリドキュメント、GitHub Wiki |
| 🛠️ **インフラ** | terraform, docker | IaC、コンテナ管理 |
| 🤖 **ブラウザ** | puppeteer, chrome-devtools | ブラウザ自動化、DevTools統合 |
| 📂 **変換** | mcp-pandoc | ドキュメント形式変換 |
| 🧠 **思考** | sequentialthinking | 複雑な問題の構造化思考 |
| 🎨 **デザイン** | figma | Figmaデザイン→コード実装 |

### 優先順位
1. **プロジェクト作業開始**: `.serena`確認 → serena初期化・オンボーディング
2. **情報検索**: serena (コード) > context7 (ライブラリ) > deepwiki (GitHub)
3. **開発タスク**: serena必須、Next.jsはnext-devtools最優先
4. **ブラウザ自動化**: puppeteer (軽量) > chrome-devtools (分析)

---

## 🤖 Tachikomaシステム

### 概要
| Agent | モデル | 役割 | 禁止事項 |
|-------|--------|------|----------|
| **Tachikoma** | Sonnet | 実装（worktree配下で作業）、軽微〜複雑なすべての実装タスク | ❌worktree勝手作成、❌Git書込、❌指定外worktreeでの作業 |
| **Serena Expert** | Sonnet | トークン効率化した開発（`/serena`活用） | - |

**補足:**
- Claude Code本体が計画・設計を担当（docs/に計画ドキュメント作成）
- Tachikomaが実際の実装を担当
- 並列実行時はtachikoma1-4として複数起動可能

### 🚀 /serenaコマンド（トークン効率化ツール）

**構造化開発コマンド**

**使用タイミング**:
- コンポーネント開発（UI作成、状態管理、ライブラリ統合）
- API開発（REST/GraphQL、認証、スキーマ設計）
- システム実装（アーキテクチャ、デザインパターン、リアルタイム機能）
- テスト（テストスイート、モック、E2E、CI/CD）
- バグ修正・最適化
- 複雑な問題の段階的解決

**基本コマンド**:
```bash
/serena "ログインバグ修正"           # シンプルな問題解決
/serena "検索フィルター追加" -q      # 高速実装（40%トークン削減）
/serena "クエリ最適化" -c            # コード重視
/serena "認証システム設計" -d -r     # 詳細分析+リサーチ
```

### 必須使用ケース
コード修正はTachikomaに委譲:
- **複雑なマルチファイル変更**: Claude Code本体が計画作成 → Tachikoma1-4（並列）
- **軽微な修正**: Tachikoma直接起動（worktree情報渡す）
- **トークン効率重視**: `/serena`コマンドを積極活用

### 例外（Claude Code本体で実行可能）
ファイル読み込み（1-2ファイル）、質問回答、ファイル一覧表示、計画・設計ドキュメント作成

### 並列実行
- 複数タスクの場合、Tachikoma1-4を1メッセージで同時起動
- 独立タスクは並列化
- Agent定義ファイルは最初に1回だけ読み込む

### 実装フロー
```
ユーザー要求
    ↓
Claude Code（状況判断）
    ↓
【コード修正が必要？】
    ├─ Yes → 計画をdocs/に作成（複雑な場合）
    │   ↓ ユーザー確認（必要に応じてWorktree作成）
    │   ↓ Tachikoma起動（複数タスク時は並列）
    │   ↓ /serena で効率的実装
    │   ↓ CodeGuard実行（必須）
    │   ↓ 完了報告
    │
    └─ No → 直接実行（読み込み・質問・設計等）
```

---

## 📜 スラッシュコマンド一覧

### sumikプラグイン
| コマンド | 説明 |
|---------|------|
| `/serena "問題" [options]` | トークン効率的な構造化開発 |
| `/serena-refresh` | Serenaデータ最新化 |
| `/reload` | CLAUDE.md再読み込み（compaction後のコンテキスト復元） |
| `/pull-request` | PR自動作成 |
| `/git-tag` | Gitタグ付け自動化 |
| `/changelog` | CHANGELOG自動生成 |
| `/generate-user-story` | ユーザーストーリー生成 |
| `/e2e-chrome-devtools-mcp` | Chrome DevTools MCP E2Eテスト |

### 公式プラグイン
| コマンド | 説明 |
|---------|------|
| `/code-review` | PRコードレビュー |
| `/frontend-design` | フロントエンドUI実装 |
| `/feature-dev` | 機能開発ワークフロー |
| `/ralph-loop` | 反復開発ループ起動 |
| `/cancel-ralph` | Ralph Loop停止 |

### Storybook Assistant
| コマンド | 説明 |
|---------|------|
| `/setup-storybook` | Storybook 9セットアップ |
| `/generate-stories` | コンポーネントのストーリー生成 |
| `/create-component` | コンポーネントスキャフォールド |
| `/design-to-code` | デザイン→コード変換 |
| `/fix-accessibility` | アクセシビリティ修正 |
| `/generate-dark-mode` | ダークモード生成 |

### セキュリティ
| コマンド | 説明 |
|---------|------|
| `/codeguard-security:software-security` | 🔴 セキュリティチェック（実装後必須） |

---

## 📚 スキル一覧

### 🔴 Tachikoma関連
| スキル | 用途 |
|--------|------|
| `implementing-as-tachikoma` | Tachikoma Agent運用ガイド |

### 🟡 Worktree・Git管理
| スキル | 用途 |
|--------|------|
| `managing-git-worktrees` | Git Worktree並行開発（Submodule対応含む） |

### 🟡 コード品質・セキュリティ
| スキル | 用途 |
|--------|------|
| `applying-solid-principles` | SOLID原則とクリーンコード（全実装で必須） |
| `enforcing-type-safety` | 型安全性強制（any/Any禁止） |
| `securing-code` | セキュアコーディング（CodeGuard実行必須） |
| `testing` | テストファースト（Vitest/RTL/Playwright） |

### 🟡 開発効率化
| スキル | 用途 |
|--------|------|
| `using-serena` | Serena MCP活用（`/serena`コマンド） |
| `researching-libraries` | ライブラリ調査（車輪の再発明禁止） |

### 🟢 フレームワーク別
| スキル | 用途 |
|--------|------|
| `developing-nextjs` | Next.js 16 / React 19開発 |
| `developing-go` | Go開発ガイド |
| `developing-python` | Python開発ガイド |
| `react-best-practices` | React性能最適化 |

### 🟢 ツール・インフラ
| スキル | 用途 |
|--------|------|
| `using-next-devtools` | Next.js DevTools活用 |
| `using-shadcn` | shadcn/ui コンポーネント管理 |
| `managing-docker` | Docker開発環境 |
| `writing-dockerfiles` | Dockerfile作成 |

### 🟢 ブラウザ自動化
| スキル | 用途 |
|--------|------|
| `agent-browser` | 高度なブラウザ自動化（状態管理、セマンティック検索） |
| `playwright` | Playwright詳細ガイド |

### 🟢 デザイン・ドキュメント
| スキル | 用途 |
|--------|------|
| `design-guidelines` | UI/UXデザイン設計 |
| `designing-frontend` | フロントエンド実装 |
| `implement-design` | Figmaデザイン→コード |
| `storybook-guidelines` | Storybook story作成 |
| `writing-technical-docs` | 技術ドキュメント作成（7つのC原則） |

### 🟢 その他
| スキル | 用途 |
|--------|------|
| `authoring-skills` | 効果的なスキル作成 |
| `searching-web` | Web検索（gemini） |

---

## ✅ コード品質ルール

### SOLID原則（全実装で必須）
- **S**: 単一責任（1クラス/関数 = 1責務）
- **O**: 開放閉鎖（拡張に開く、修正に閉じる）
- **L**: リスコフ置換（派生クラスは基底クラスと置換可能）
- **I**: インターフェース分離（必要なメソッドのみ）
- **D**: 依存関係逆転（抽象に依存）

### 型安全性（絶対遵守）
- ❌ **`any`（TypeScript）、`Any`（Python）使用禁止**
- ✅ 明示的な型定義
- ✅ `unknown` + 型ガード
- ✅ ジェネリクス
- ✅ Utility Types

### テストファースト
- Red（失敗テスト）→ Green（実装）→ Refactor
- **AAAパターン必須**: Arrange → Act → Assert
- `actual`/`expected`変数の明示的使用
- **カバレッジ目標**: ビジネスロジック100%、ユーティリティ100%

### セキュリティ（🔴 実装完了後必須）
```bash
# 実装完了後に必ず実行
/codeguard-security:software-security
```
- 全外部入力を検証
- SQLインジェクション対策（プリペアドステートメント）
- XSS対策（エスケープ処理）
- 機密情報は環境変数管理

---

## 🔄 メンテナンス

### 日次
- serena再アクティベート

### 週次
- serenaメモリ整理
- worktree一覧確認（`git worktree list`）
- 不要なworktree削除

### コンテキスト復元
- compaction後は `/reload` でCLAUDE.md再読み込み
