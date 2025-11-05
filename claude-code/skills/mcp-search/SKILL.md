---
name: mcp-search
description: 情報検索・調査 - ライブラリドキュメント、Web検索、GitHub分析、動画分析での情報収集を支援。用途に応じて複数のMCPを使い分け。
---

# 情報検索・調査

## 🎯 検索タイプ別MCP選択

### 1. ライブラリドキュメント → context7 MCP（最優先）
**用途**: プログラミングライブラリの最新仕様確認

```typescript
// ライブラリID解決
mcp__context7__resolve_library_id("next.js")

// ドキュメント取得
mcp__context7__get_library_docs({
  libraryId: "...",
  topic: "app router"
})
```

**重要**: React、Next.js、Vue等は必ず実装前に確認

### 2. 最新情報・時事問題 → kagi MCP
**用途**: Web検索、最新トレンド調査

```typescript
// Web検索
mcp__kagi__kagi_search_fetch({
  queries: ["Next.js 14 best practices"]
})

// コンテンツ要約
mcp__kagi__kagi_summarizer({
  url: "https://example.com/article",
  summary_type: "summary"  // または "takeaway"
})
```

### 3. 複数ページ調査 → firecrawl MCP
**用途**: Webクロール、競合分析、ディープリサーチ

```typescript
// 単一ページスクレイピング
mcp__firecrawl__scrape({
  url: "https://example.com",
  formats: ["markdown"]
})

// 複数ページクロール
mcp__firecrawl__crawl({
  url: "https://example.com",
  limit: 50,
  maxDiscoveryDepth: 3
})

// キーワード検索
mcp__firecrawl__search({
  query: "React best practices"
})
```

### 4. GitHubリポジトリ → deepwiki MCP
**用途**: オープンソース分析

```typescript
// リポジトリ構造理解
mcp__deepwiki__read_wiki_structure({
  repoName: "facebook/react"
})

// ドキュメント取得
mcp__deepwiki__read_wiki_contents({
  repoName: "facebook/react"
})

// 質問
mcp__deepwiki__ask_question({
  repoName: "facebook/react",
  question: "How does React Server Components work?"
})
```

### 5. 動画コンテンツ → youtube MCP
**用途**: 技術解説動画、カンファレンス分析

```typescript
// 字幕取得
mcp__youtube__download_youtube_url({
  url: "https://youtube.com/watch?v=..."
})

// 要約（Kagi経由）
mcp__kagi__kagi_summarizer({
  url: "https://youtube.com/watch?v=...",
  summary_type: "takeaway"
})
```

### 6. 言語仕様・チートシート → docset MCP
**用途**: プログラミング言語リファレンス

```typescript
// ドキュメント検索
mcp__docset__search_docs({
  query: "Array.map",
  docset: "javascript"
})

// チートシート参照
mcp__docset__fetch_cheatsheet({
  cheatsheet: "git"
})
```

## 🔄 情報収集ワークフロー

### 新機能実装時
```
1. 最新仕様確認
   context7 MCP → ライブラリドキュメント

2. ベストプラクティス調査
   kagi MCP → 最新記事・サンプルコード

3. 詳細調査（必要に応じて）
   firecrawl MCP → 複数記事を包括的に調査
   youtube MCP → カンファレンス動画分析
```

### 技術選定時
```
1. 公式ドキュメント確認
   context7 MCP / deepwiki MCP

2. 比較記事・トレンド調査
   kagi MCP / firecrawl MCP

3. コミュニティ動向
   deepwiki MCP → GitHub Issues/Discussions
```

## 🎨 よくあるパターン

### React/Next.js実装前
```typescript
// 1. 最新仕様（最優先）
mcp__context7__get_library_docs({
  libraryId: "next.js",
  topic: "server components"
})

// 2. ベストプラクティス
mcp__kagi__kagi_search_fetch({
  queries: ["Next.js 14 server components best practices"]
})

// 3. 実装例
mcp__firecrawl__search({
  query: "Next.js server components example code"
})
```

### ライブラリ選定
```typescript
// 1. 公式ドキュメント
mcp__context7__get_library_docs({ ... })

// 2. GitHub分析
mcp__deepwiki__ask_question({
  repoName: "owner/repo",
  question: "What are the main use cases?"
})

// 3. 比較記事
mcp__kagi__kagi_search_fetch({
  queries: ["library A vs library B comparison 2024"]
})
```

## ⚠️ 検索の優先順位
```
1. context7 - ライブラリ公式（最新仕様）
2. deepwiki - GitHub公式（プロジェクト理解）
3. kagi - Web検索（最新情報）
4. firecrawl - 複数ページ調査（詳細分析）
5. youtube - 動画コンテンツ（学習）
6. docset - 言語仕様（リファレンス）
```

## 📚 主要ツール

**context7**:
- `resolve_library_id`, `get_library_docs`

**kagi**:
- `kagi_search_fetch`, `kagi_summarizer`

**firecrawl**:
- `scrape`, `crawl`, `search`

**deepwiki**:
- `read_wiki_structure`, `ask_question`

**youtube**:
- `download_youtube_url`

**docset**:
- `search_docs`, `fetch_cheatsheet`

## 🔗 関連スキル
- **mcp-serena**: 実装前のコード構造理解
- **mcp-next-devtools**: Next.js公式ドキュメント検索
