# プラグイン・MCP・コマンド リファレンス

## Marketplaceプラグイン一覧

### 公式プラグイン (claude-plugins-official)
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

### LSPプラグイン (言語サーバー)
| プラグイン | 言語 |
|-----------|------|
| **typescript-lsp** | TypeScript |
| **pyright-lsp** | Python |
| **gopls-lsp** | Go |

### セキュリティ
| プラグイン | 説明 |
|-----------|------|
| **codeguard-security** | CodeGuardセキュリティチェック（🔴実装後必須） |

### Storybook
| プラグイン | 説明 |
|-----------|------|
| **storybook-assistant** | Storybook 9対応（Vision AI、ダークモード、a11y、RSC） |

### インフラ・プラットフォーム
| プラグイン | 説明 |
|-----------|------|
| **mcp-toolkit** | Docker Desktop MCP Toolkit統合（Docker 4.28+） |

### awesome-claude-skills
| カテゴリ | プラグイン |
|---------|-----------|
| **ドキュメント** | document-skills-docx, document-skills-pdf, document-skills-pptx, document-skills-xlsx |
| **コンテンツ** | content-research-writer, internal-comms, meeting-insights-analyzer |
| **開発支援** | artifacts-builder, changelog-generator, webapp-testing, skill-creator |
| **ユーティリティ** | file-organizer, image-enhancer, video-downloader, theme-factory |
| **ビジネス** | domain-name-brainstormer, lead-research-assistant, tailored-resume-generator |
| **コミュニケーション** | slack-gif-creator |

---

## MCP使用ガイド

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

## スラッシュコマンド一覧

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
