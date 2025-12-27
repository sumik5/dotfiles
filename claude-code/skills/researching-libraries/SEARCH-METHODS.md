# 言語別ライブラリ検索方法

## 🔍 MCP優先アプローチ

### Context7（ドキュメント取得）

```bash
# Step 1: ライブラリIDを解決
context7: resolve-library-id
  libraryName: "react-hook-form"

# Step 2: ドキュメント取得
context7: get-library-docs
  context7CompatibleLibraryID: "/react-hook-form/react-hook-form"
  topic: "validation"
```

**対応パターン**:
- `/npm/パッケージ名` - npm packages
- `/pypi/パッケージ名` - Python packages
- `/crates/クレート名` - Rust crates

### DeepWiki（GitHub調査）

```bash
# リポジトリの概要取得
deepwiki: read_wiki_contents
  repoName: "colinhacks/zod"

# 特定の質問
deepwiki: ask_question
  repoName: "vercel/next.js"
  question: "認証に推奨されるライブラリは？"
```

---

## 📦 JavaScript / TypeScript

### npm検索

```bash
# 基本検索
npm search <keyword>

# 詳細表示
npm search <keyword> --long

# パッケージ情報
npm info <package-name>

# 依存関係確認
npm explain <package-name>
```

### npms.io スコア確認

```bash
# WebFetchで品質スコア確認
WebFetch: https://api.npms.io/v2/package/<package-name>
```

**スコア基準**:
- `quality`: コード品質（テスト、型定義）
- `popularity`: 使用率
- `maintenance`: メンテナンス状況

### Bundlephobia（バンドルサイズ）

```bash
# バンドルサイズ確認
WebFetch: https://bundlephobia.com/package/<package-name>
```

### 検索キーワード例

| 目的 | 検索クエリ |
|------|-----------|
| バリデーション | `npm search validation schema typescript` |
| 日付処理 | `npm search date time manipulation` |
| HTTP client | `npm search http client fetch` |
| 状態管理 | `npm search state management react` |

---

## 🐍 Python

### PyPI検索

```bash
# pipでの検索（非推奨・機能制限）
pip index versions <package-name>

# より良い方法: WebFetchでPyPI API
WebFetch: https://pypi.org/pypi/<package-name>/json
```

### 推奨ツール

```bash
# pipxでの一時実行
pipx run <package-name> --help

# uvでの高速インストール
uv pip install <package-name>
```

### ライブラリ発見サイト

| サイト | 用途 |
|--------|------|
| [awesome-python](https://github.com/vinta/awesome-python) | カテゴリ別リスト |
| [PyPI Stats](https://pypistats.org/) | ダウンロード統計 |

### 検索キーワード例

| 目的 | 検索クエリ |
|------|-----------|
| API作成 | `fastapi async web framework` |
| データ処理 | `pandas polars dataframe` |
| CLI作成 | `typer click cli` |
| バリデーション | `pydantic validation` |

---

## 🦀 Go

### pkg.go.dev検索

```bash
# 公式パッケージ検索
WebFetch: https://pkg.go.dev/search?q=<keyword>
```

### go listでの確認

```bash
# インストール済みモジュール検索
go list -m all | grep <keyword>

# モジュール情報取得
go list -m -json <module-path>
```

### 検索キーワード例

| 目的 | 検索クエリ |
|------|-----------|
| HTTPルーター | `http router middleware` |
| ログ | `structured logging slog` |
| DB操作 | `database sql orm` |
| テスト | `testing mock assertion` |

### 標準ライブラリ優先

Go では標準ライブラリが充実しているため、まず標準を確認:

```go
// ❌ 外部ライブラリ不要な例
import "github.com/some/json-lib"

// ✅ 標準ライブラリで十分
import "encoding/json"
```

---

## 🦀 Rust

### crates.io検索

```bash
# Cargo検索
cargo search <keyword>

# 詳細情報
cargo info <crate-name>
```

### crates.io API

```bash
WebFetch: https://crates.io/api/v1/crates/<crate-name>
```

### 検索キーワード例

| 目的 | 検索クエリ |
|------|-----------|
| 非同期ランタイム | `async runtime tokio` |
| シリアライズ | `serde serialize` |
| CLI | `clap cli argument` |
| HTTP | `reqwest http client` |

---

## 💎 Ruby

### RubyGems検索

```bash
# Gem検索
gem search <keyword>

# 詳細情報
gem info <gem-name>

# 依存関係
gem dependency <gem-name>
```

### 検索キーワード例

| 目的 | 検索クエリ |
|------|-----------|
| Web | `rails sinatra` |
| テスト | `rspec minitest` |
| 認証 | `devise authentication` |

---

## 🔧 汎用検索戦略

### GitHub検索

```bash
# トピック検索
WebFetch: https://github.com/topics/<topic-name>

# 言語フィルター
GitHub検索: language:typescript <keyword>
```

### Awesome Lists

各言語の「awesome-xxx」リポジトリを参照:
- [awesome-nodejs](https://github.com/sindresorhus/awesome-nodejs)
- [awesome-python](https://github.com/vinta/awesome-python)
- [awesome-go](https://github.com/avelino/awesome-go)
- [awesome-rust](https://github.com/rust-unofficial/awesome-rust)

### 検索のコツ

1. **具体的なキーワード**: `validation` より `schema validation typescript`
2. **類似プロジェクト参照**: 有名OSSのpackage.json/go.modを確認
3. **複数ソース比較**: npm + GitHub + awesome list
