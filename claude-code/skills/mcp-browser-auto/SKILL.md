---
name: mcp-browser-auto
description: ブラウザ自動化 - E2Eテスト、Webスクレイピング、パフォーマンス分析でのブラウザ自動化を支援。用途に応じて3つのMCPを使い分け。
---

# ブラウザ自動化

## 🎯 3つのMCPの使い分け

### 1. Puppeteer MCP（軽量・高速）
**用途**: 軽量タスク、Chrome専用
- スクリーンショット取得
- PDF生成
- 簡単なWebスクレイピング
- 単一ブラウザテスト

### 2. Playwright MCP（高機能・マルチブラウザ）
**用途**: 複雑なE2Eテスト
- クロスブラウザテスト（Chrome, Firefox, Safari）
- 複雑なフォーム操作
- 高度なテストシナリオ
- 並列実行

### 3. Chrome DevTools MCP（詳細分析）
**用途**: パフォーマンス分析、デバッグ
- パフォーマンス計測
- ネットワーク分析
- Chrome特有の機能
- リアルタイムデバッグ

## 📋 選択フローチャート
```
ブラウザ自動化タスク
    ↓
軽量・高速？
    ├─ Yes → Puppeteer
    └─ No → マルチブラウザ？
            ├─ Yes → Playwright
            └─ No → 詳細分析？
                    ├─ Yes → Chrome DevTools
                    └─ No → Puppeteer/Playwright
```

## 🎨 Puppeteer使用例

### スクリーンショット取得
```typescript
mcp__puppeteer__navigate({ url: "https://example.com" })
mcp__puppeteer__screenshot({ filename: "screenshot.png" })
```

### PDF生成
```typescript
mcp__puppeteer__navigate({ url: "https://example.com" })
mcp__puppeteer__pdf({ filename: "document.pdf" })
```

### 簡単なスクレイピング
```typescript
mcp__puppeteer__navigate({ url: "https://example.com" })
mcp__puppeteer__evaluate({
  script: "() => document.querySelector('h1').textContent"
})
```

## 🎨 Playwright使用例

### クロスブラウザテスト
```typescript
// Chrome
mcp__playwright__browser_start({ browser: "chrome" })
mcp__playwright__browser_navigate({ url: "https://example.com" })
mcp__playwright__browser_snapshot()  // ページ状態確認

// Firefox
mcp__playwright__browser_start({ browser: "firefox" })
mcp__playwright__browser_navigate({ url: "https://example.com" })
```

### フォーム入力
```typescript
mcp__playwright__browser_fill_form({
  fields: [
    { selector: "#email", value: "user@example.com" },
    { selector: "#password", value: "password123" }
  ]
})
mcp__playwright__browser_click({ selector: "button[type='submit']" })
```

### E2Eテストシナリオ
```typescript
// ログイン → ダッシュボード → データ確認
mcp__playwright__browser_navigate({ url: "/login" })
mcp__playwright__browser_fill_form({ fields: [...] })
mcp__playwright__browser_click({ selector: "#submit" })
mcp__playwright__browser_wait_for({ text: "Dashboard" })
mcp__playwright__browser_snapshot()  // 結果確認
```

## 🎨 Chrome DevTools使用例

### パフォーマンス計測
```typescript
mcp__chrome-devtools__performance_start_trace({
  reload: true,
  autoStop: true
})
// → Core Web Vitals、パフォーマンス指標取得
```

### ネットワーク分析
```typescript
mcp__chrome-devtools__list_network_requests()
// → APIリクエスト、リソース読み込み確認
```

### ページ分析
```typescript
mcp__chrome-devtools__take_snapshot()
// → ページのa11yツリー取得、要素分析
```

## 🏗️ 推奨ワークフロー

### E2Eテスト実装
```
段階1: テストシナリオ設計
- dev1: ユーザーフロー定義

段階2: テスト実装（並列可能）
- dev2: Playwrightでメインシナリオ
- dev3: Playwrightでエッジケース
- dev4: パフォーマンス計測（Chrome DevTools）
```

### Webスクレイピング
```
段階1: 調査
- dev1: Chrome DevToolsでページ構造分析

段階2: 実装
- dev2: Puppeteerでスクレイピング実装
```

## ⚠️ ベストプラクティス
1. **適切なMCP選択**: 用途に応じて最適なツール選択
2. **待機処理**: `wait_for`で要素の読み込み待機
3. **スナップショット活用**: `snapshot`で現在状態確認
4. **エラーハンドリング**: タイムアウト設定、リトライ処理
5. **並列実行**: 独立したテストは並列化

## 📚 主要ツール

**Puppeteer**:
- `navigate`, `screenshot`, `pdf`
- `click`, `type`, `evaluate`

**Playwright**:
- `browser_navigate`, `browser_click`
- `browser_fill_form`, `browser_snapshot`
- `browser_take_screenshot`

**Chrome DevTools**:
- `performance_start_trace`
- `list_network_requests`
- `take_snapshot`

## 🔗 関連ツール
- **serena MCP**: テストコード編集
- **next-devtools MCP**: Next.jsアプリのE2Eテスト
