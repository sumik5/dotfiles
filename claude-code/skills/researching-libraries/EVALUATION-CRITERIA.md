# ライブラリ評価基準

## 📊 評価マトリクス

### 必須チェック項目

| 項目 | 最低基準 | 推奨基準 | 確認方法 |
|------|----------|----------|----------|
| ⭐ GitHub Stars | 500+ | 2,000+ | GitHub |
| 📅 最終更新 | 6ヶ月以内 | 3ヶ月以内 | GitHub/npm |
| 📦 週間DL数 | 10,000+ | 100,000+ | npm/PyPI Stats |
| 🔒 既知の脆弱性 | 0件 | 0件 | npm audit / pip-audit |
| 📝 TypeScript対応 | 型定義あり | ネイティブTS | package.json |
| 📖 ドキュメント | README充実 | 専用サイト | GitHub |

### スコアリング例

```
zod:
  Stars:        32,000 ✅ (2000+)
  最終更新:     2週間前 ✅ (3ヶ月以内)
  週間DL:       8,000,000 ✅ (100k+)
  脆弱性:       0件 ✅
  TypeScript:   ネイティブ ✅
  ドキュメント: 専用サイト ✅

  総合評価: ⭐⭐⭐⭐⭐ 採用推奨
```

---

## 🔒 セキュリティチェック

### npm

```bash
# プロジェクト全体の監査
npm audit

# 特定パッケージの確認
npm audit --package-lock-only

# 自動修正
npm audit fix
```

### Python

```bash
# pip-auditのインストール
pip install pip-audit

# 監査実行
pip-audit

# 特定パッケージ
pip-audit -r requirements.txt
```

### Go

```bash
# 脆弱性チェック
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

### Snykによるチェック

```bash
# Snyk CLI
snyk test
snyk monitor
```

---

## 📜 ライセンス確認

### 許可ライセンス（商用利用OK）

| ライセンス | 特徴 |
|-----------|------|
| MIT | 最も寛容、ほぼ制限なし |
| Apache 2.0 | 特許条項あり、MIT類似 |
| BSD-3-Clause | MIT類似 |
| ISC | MIT類似 |

### 注意が必要なライセンス

| ライセンス | 注意点 |
|-----------|--------|
| GPL-3.0 | コピーレフト、派生物も同一ライセンス必須 |
| LGPL | 動的リンクなら許容される場合あり |
| AGPL | ネットワーク越しの利用も対象 |

### ライセンス確認コマンド

```bash
# npm
npm info <package> license

# 依存関係のライセンス一覧
npx license-checker --summary

# Python
pip show <package> | grep License
```

---

## 📦 依存関係の評価

### 依存の深さ確認

```bash
# npm依存ツリー
npm ls --all

# 直接依存のみ
npm ls --depth=0

# 特定パッケージの依存
npm explain <package>
```

### 依存関係の問題パターン

| パターン | リスク | 対策 |
|----------|--------|------|
| 深い依存ツリー | メンテナンス困難 | 代替を検討 |
| 放置された依存 | セキュリティリスク | npm audit確認 |
| 重複依存 | バンドルサイズ増加 | npm dedupe |
| ピア依存の不一致 | 実行時エラー | バージョン調整 |

### バンドルサイズ確認

```bash
# Bundlephobia
WebFetch: https://bundlephobia.com/package/<package>@<version>

# 結果例
{
  "size": 12345,        // 圧縮前
  "gzip": 4567,         // gzip後
  "dependencyCount": 3  // 依存数
}
```

---

## 🔄 メンテナンス状況

### チェックポイント

1. **コミット頻度**
   - 最新コミット日を確認
   - 直近3ヶ月のコミット数

2. **Issue対応**
   - オープンIssue数
   - 平均クローズ時間
   - メンテナーの反応速度

3. **リリース頻度**
   - セマンティックバージョニング遵守
   - 破壊的変更の頻度
   - CHANGELOGの充実度

4. **コミュニティ**
   - コントリビューター数
   - フォーク数
   - スポンサー/資金援助状況

### 警告サイン 🚩

- 最終コミットが1年以上前
- オープンIssueが100件以上放置
- メンテナーが1人のみ
- ドキュメントが古い/不完全
- テストカバレッジが低い

---

## 🎯 決定フレームワーク

### 採用判断フローチャート

```
機能要件を満たす？
    ↓ Yes
セキュリティ問題なし？
    ↓ Yes
ライセンスOK？
    ↓ Yes
メンテナンス状況良好？
    ↓ Yes
依存関係が許容範囲？
    ↓ Yes
→ 採用 ✅

どこかでNo → 代替を検索 or 自作検討
```

### 複数候補の比較テンプレート

```markdown
## ライブラリ比較: バリデーション

| 項目 | zod | yup | joi |
|------|-----|-----|-----|
| Stars | 32k | 22k | 21k |
| 週間DL | 8M | 6M | 9M |
| TypeScript | ネイティブ | 後付け | 後付け |
| バンドルサイズ | 13KB | 26KB | 大きい |
| 学習コスト | 低 | 中 | 中 |
| メンテナンス | 活発 | 普通 | 普通 |

**結論**: zod を採用
- 理由: TypeScriptネイティブ、軽量、活発なメンテナンス
```

---

## 📝 選定ドキュメントテンプレート

```markdown
# ライブラリ選定: [機能名]

## 要件
- [要件1]
- [要件2]

## 検討したライブラリ

### 採用: `<library-name>`
- バージョン: x.y.z
- ライセンス: MIT
- Stars: XXX
- 週間DL: XXX
- 最終更新: YYYY-MM-DD

**採用理由**:
1. [理由1]
2. [理由2]

### 見送り: `<other-library>`
**見送り理由**:
- [理由]

## セキュリティ確認
- [ ] npm audit 実施
- [ ] ライセンス確認
- [ ] 依存関係確認

## 導入方法
\`\`\`bash
npm install <library-name>
\`\`\`
```
