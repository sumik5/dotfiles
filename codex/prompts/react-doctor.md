---
description: react-doctorを実行してReactコードのセキュリティ・パフォーマンス・正確性・アーキテクチャの問題を診断（0-100ヘルススコア付き）
argument-hint: "[directory] [--verbose] [--diff base] [--no-lint] [--no-dead-code] [--score]"
---

# React Doctor - React コード品質診断

react-doctor CLI を実行して、Reactプロジェクトのセキュリティ・パフォーマンス・正確性・アーキテクチャの問題を検出する。

## 使い方

```
/prompts:react-doctor                     # カレントディレクトリをスキャン
/prompts:react-doctor .                   # 同上
/prompts:react-doctor --verbose           # ファイル詳細・行番号付き
/prompts:react-doctor --diff main         # mainブランチとの差分のみ
/prompts:react-doctor --score             # スコアのみ出力
/prompts:react-doctor --no-lint           # lint チェックをスキップ
/prompts:react-doctor --no-dead-code      # dead code 検出をスキップ
/prompts:react-doctor src/                # 特定ディレクトリをスキャン
```

## 手順

### 1. 引数の解析

`$ARGUMENTS` を解析する。引数が空または不明確な場合、ユーザーにスキャンモードを確認する:

- **Standard**: 全ファイルを標準スキャン（推奨）
- **Verbose**: ファイル詳細・行番号付きで詳細スキャン
- **Diff only**: 変更ファイルのみスキャン（`--diff main`）
- **Score only**: スコアのみ出力

### 2. react-doctor 実行

```bash
npx -y react-doctor@latest <directory> <options>
```

**デフォルト**: `npx -y react-doctor@latest . --verbose`

### 3. 結果の分析

出力を解析し、以下の構造で報告:

1. **スコア**: 0-100
2. **カテゴリ別の問題**: state & effects, performance, architecture, bundle size, security, correctness, accessibility
3. **修正提案**: 各診断に対する具体的な修正方法

### 4. 修正の提案

スコアが75未満の場合、severity: error の問題から優先的に修正提案を行う。
ユーザーが修正を希望する場合、該当するReactのベストプラクティスに基づいて修正を実施する。

## スコア基準

| スコア | ラベル | アクション |
|--------|--------|-----------|
| 75-100 | Great | 維持。マイナー改善のみ |
| 50-74 | Needs work | 優先度の高い問題から修正 |
| 0-49 | Critical | 即座に対応が必要 |

## 設定ファイル

プロジェクトに `react-doctor.config.json` がある場合、自動的に適用される:

```json
{
  "ignore": {
    "rules": ["react/no-danger"],
    "files": ["src/generated/**"]
  }
}
```
