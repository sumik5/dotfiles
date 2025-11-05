---
name: mcp-filesystem
description: ファイル操作・変換 - 非コードファイルの大量処理、バックアップ、ドキュメント変換を支援。コード編集はserena優先。
---

# ファイル操作・変換

## 🎯 使用タイミング
- **大量ファイル処理時**
- **非コードファイル操作時**
- **バックアップ・コピー作業時**
- **ドキュメント形式変換時**

## ⚠️ serenaとの使い分け
- **serena優先**: コード解析・編集
- **filesystem優先**: 非コードファイル、大量処理

## 📋 基本操作

### 1. ファイル読み書き
```typescript
// 読み込み
mcp__filesystem__read_text_file({
  path: "/path/to/file.txt"
})

// 書き込み
mcp__filesystem__write_file({
  path: "/path/to/file.txt",
  content: "..."
})

// 編集（行ベース）
mcp__filesystem__edit_file({
  path: "/path/to/file.txt",
  edits: [
    { oldText: "old line", newText: "new line" }
  ]
})
```

### 2. ディレクトリ操作
```typescript
// ディレクトリ作成
mcp__filesystem__create_directory({
  path: "/path/to/new/dir"
})

// ディレクトリ一覧
mcp__filesystem__list_directory({
  path: "/path/to/dir"
})

// サイズ付き一覧
mcp__filesystem__list_directory_with_sizes({
  path: "/path/to/dir",
  sortBy: "size"  // または "name"
})

// ツリー表示
mcp__filesystem__directory_tree({
  path: "/path/to/dir"
})
```

### 3. ファイル検索・移動
```typescript
// ファイル検索
mcp__filesystem__search_files({
  path: "/path/to/search",
  pattern: "*.txt",
  excludePatterns: ["node_modules"]
})

// ファイル移動・リネーム
mcp__filesystem__move_file({
  source: "/path/to/source.txt",
  destination: "/path/to/dest.txt"
})

// ファイル情報取得
mcp__filesystem__get_file_info({
  path: "/path/to/file.txt"
})
```

## 📄 ドキュメント変換

### markdownify MCP（多様な形式対応）
```typescript
// Webページ → Markdown
mcp__markdownify__webpage_to_markdown({
  url: "https://example.com"
})

// PDF → Markdown
mcp__markdownify__pdf_to_markdown({
  filepath: "/path/to/document.pdf"
})

// Office文書 → Markdown
mcp__markdownify__docx_to_markdown({
  filepath: "/path/to/document.docx"
})
mcp__markdownify__xlsx_to_markdown({
  filepath: "/path/to/spreadsheet.xlsx"
})
mcp__markdownify__pptx_to_markdown({
  filepath: "/path/to/presentation.pptx"
})

// 画像 → Markdown（メタデータ付き）
mcp__markdownify__image_to_markdown({
  filepath: "/path/to/image.png"
})

// YouTube → Markdown
mcp__markdownify__youtube_to_markdown({
  url: "https://youtube.com/watch?v=..."
})
```

### pandoc MCP（ドキュメント形式変換）
```typescript
// Markdown → Word
mcp__pandoc__convert({
  input_file: "/path/to/input.md",
  output_file: "/path/to/output.docx",
  output_format: "docx"
})

// Markdown → PDF（TeX Live必須）
mcp__pandoc__convert({
  input_file: "/path/to/input.md",
  output_file: "/path/to/output.pdf",
  output_format: "pdf"
})

// Word → Markdown
mcp__pandoc__convert({
  input_file: "/path/to/input.docx",
  output_file: "/path/to/output.md",
  output_format: "markdown"
})
```

## 🎨 よくあるパターン

### プロジェクトバックアップ
```typescript
// 1. ディレクトリ構造確認
mcp__filesystem__directory_tree({ path: "/project" })

// 2. 重要ファイル検索
mcp__filesystem__search_files({
  path: "/project",
  pattern: "*.{ts,tsx,md}",
  excludePatterns: ["node_modules", ".next"]
})

// 3. バックアップディレクトリ作成
mcp__filesystem__create_directory({ path: "/backup" })

// 4. ファイルコピー（Bash経由）
// Bash: cp -r /project /backup/
```

### ドキュメント一括変換
```typescript
// PDFドキュメントを検索
mcp__filesystem__search_files({
  path: "/documents",
  pattern: "*.pdf"
})

// 各PDFをMarkdownに変換
// ループでmarkdownify使用
```

### ログファイル分析
```typescript
// ログファイル検索
mcp__filesystem__search_files({
  path: "/logs",
  pattern: "*.log"
})

// サイズ確認
mcp__filesystem__list_directory_with_sizes({
  path: "/logs",
  sortBy: "size"
})

// 大きなログファイルの一部読み込み
mcp__filesystem__read_text_file({
  path: "/logs/large.log",
  head: 100  // 最初の100行
})
```

## ⚠️ ベストプラクティス
1. **コード編集はserena**: filesystem は非コード専用
2. **excludePatterns活用**: node_modules等を除外
3. **サイズ確認**: 大きなファイルは head/tail で部分読込
4. **バックアップ**: 重要操作前にバックアップ
5. **パス検証**: 操作前にファイル存在確認

## 📚 主要ツール

**filesystem**:
- `read_text_file`, `write_file`, `edit_file`
- `create_directory`, `list_directory`
- `search_files`, `move_file`, `get_file_info`

**markdownify**:
- `webpage_to_markdown`, `pdf_to_markdown`
- `docx_to_markdown`, `xlsx_to_markdown`
- `image_to_markdown`, `youtube_to_markdown`

**pandoc**:
- `convert` - 多様な形式変換

## 🔗 関連スキル
- **mcp-serena**: コードファイル編集
- **mcp-search**: ドキュメント検索
