---
description: 前回のgitタグから現在までの変更履歴を分析し、Keep a Changelog形式でCHANGELOG.mdエントリーを自動生成
argument-hint: <新しいバージョン> (例: v1.2.0)
---

# Changelog Command

前回のgitタグから現在までの変更履歴を分析し、Keep a Changelog形式でCHANGELOG.mdエントリーを自動生成する。

## 引数

- `$1`: **必須**。リリースするバージョン番号（例: `v1.2.0`）

## バージョン番号のフォーマット規則

- **形式**: `v` + セマンティックバージョニング（`MAJOR.MINOR.PATCH`）
- **例**: `v1.0.0`, `v2.1.3`, `v0.5.0`
- **オプション**: プレリリース版やビルドメタデータ（例: `v1.0.0-beta.1`, `v2.0.0+20250104`）

## エラー条件

以下の場合はエラーメッセージを表示して処理を終了する:

- 引数が指定されていない場合: `エラー: バージョン番号が指定されていません。使用方法: /prompts:changelog <新しいバージョン>`
- バージョン番号の形式が不正な場合: `エラー: バージョン番号の形式が不正です。正しい形式: v1.0.0`

## 手順

### ステップ0: 引数の検証

1. **引数の存在確認**: `$1` が空の場合はエラーで終了
2. **形式検証**: 正規表現 `^v\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$` に一致しない場合はエラーで終了
3. **変数の準備**:
   - NEW_VERSION: `v1.2.0` 形式（CHANGELOG.md用）
   - VERSION_NUMBER: `1.2.0` 形式（プロジェクトファイル用、vプレフィックスを除去）

### ステップ1: 変更情報の収集

以下のコマンドを実行して情報を収集する:

```bash
# 最新のタグを取得（セマンティックバージョニング対応）
LATEST_TAG=$(git tag -l "v*" --sort=-version:refname | head -n 1)

# タグの有無を確認して適切なコマンドを実行
if [ -z "$LATEST_TAG" ]; then
  echo "タグが見つかりません。全コミット履歴を取得します。"
  git log --oneline HEAD
  git diff --name-status $(git rev-list --max-parents=0 HEAD)..HEAD
else
  echo "最新タグ: $LATEST_TAG"
  git log --oneline ${LATEST_TAG}..HEAD
  git diff --name-status ${LATEST_TAG} HEAD
fi

# ステージングエリアの変更も取得
git diff --cached --name-status
```

### ステップ2: CHANGELOGエントリーの生成

収集した情報を基に、以下の形式でCHANGELOGエントリーを生成する:

```markdown
## [NEW_VERSION] - YYYY-MM-DD

### 追加
- 新機能について記載

### 変更
- 既存機能への変更について記載

### 非推奨
- 間もなく削除される機能について記載

### 削除
- 削除された機能について記載

### 修正
- 修正されたバグについて記載

### セキュリティ
- 脆弱性に関する変更について記載
```

**生成ルール**:
- バージョン番号はステップ0で保存した NEW_VERSION 変数を使用する
- 該当する変更がないセクションは出力しない
- 各項目は日本語で記述
- 人間が読みやすく、ユーザーにとって価値のある情報を具体的に記載
- 技術的な詳細よりも、ユーザーへの影響を重視

### ステップ3: プロジェクトファイルのバージョン更新

VERSION_NUMBER（vプレフィックスなし）を使用して、以下のファイルが存在すれば更新する:

- **package.json**: `"version": "VERSION_NUMBER"` に更新
- **pyproject.toml**: `[project]` セクション内の `version = "VERSION_NUMBER"` に更新

両方存在する場合は両方を更新する。どちらも存在しない場合はスキップ。

### ステップ4: CHANGELOG.mdの更新

- CHANGELOG.mdが存在しない場合: `# Changelog` ヘッダー付きで新規作成
- CHANGELOG.mdが存在する場合: `# Changelog` 見出しの後、最初のバージョンエントリーの前に新しいエントリーを挿入

### ステップ5: 確認

以下の変更内容をユーザーに表示する:

1. 生成されたCHANGELOGエントリー
2. 更新されたプロジェクトファイル（該当する場合）

ユーザーに「上記の変更内容でファイルを更新してよろしいですか？」と確認を求め、承認を得てからファイルを更新する。キャンセルされた場合は処理を中止する。

## 参考

- Keep a Changelog: https://keepachangelog.com/ja/1.1.0/
- セクション: 追加(Added) / 変更(Changed) / 非推奨(Deprecated) / 削除(Removed) / 修正(Fixed) / セキュリティ(Security)
- 日付形式: ISO 8601 (YYYY-MM-DD)
