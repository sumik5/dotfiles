# Changelog Command

このコマンドは、前回のgitタグから現在までの変更履歴を分析し、Keep a Changelog形式でCHANGELOG.mdエントリーを自動生成します。

## 使用方法

```bash
/changelog <新しいバージョン>
```

### 引数

- `<新しいバージョン>`: **必須**。リリースするバージョン番号を指定します

### バージョン番号のフォーマット規則

バージョン番号は以下の規則に従う必要があります：

- **形式**: `v` + セマンティックバージョニング（`MAJOR.MINOR.PATCH`）
- **例**: `v1.0.0`, `v2.1.3`, `v0.5.0`
- **必須要素**:
  - 先頭の `v` プレフィックス
  - 3つの数字（メジャー、マイナー、パッチ）をドットで区切る
- **オプション**: プレリリース版やビルドメタデータ（例: `v1.0.0-beta.1`, `v2.0.0+20250104`）

### エラー条件

以下の場合はエラーを返します：

- 引数が指定されていない場合
  - エラーメッセージ: `エラー: バージョン番号が指定されていません。使用方法: /changelog <新しいバージョン>`
- バージョン番号の形式が不正な場合
  - エラーメッセージ: `エラー: バージョン番号の形式が不正です。正しい形式: v1.0.0`

### 使用例

```bash
# 正しい使用例
/changelog v1.2.0
# → CHANGELOG.md: [v1.2.0]
# → package.json: "version": "1.2.0"
# → pyproject.toml: version = "1.2.0"

/changelog v2.0.0
# → CHANGELOG.md: [v2.0.0]
# → package.json: "version": "2.0.0"
# → pyproject.toml: version = "2.0.0"

/changelog v0.1.0-beta.1
# → CHANGELOG.md: [v0.1.0-beta.1]
# → package.json: "version": "0.1.0-beta.1"
# → pyproject.toml: version = "0.1.0-beta.1"

# 誤った使用例（エラーになる）
/changelog          # 引数なし
/changelog 1.2.0    # v プレフィックスなし
/changelog v1.2     # パッチバージョンなし
```

## 実行内容

1. **引数の検証**: バージョン番号の形式を検証し、変数に保存します
   - NEW_VERSION: `v1.2.0` 形式（CHANGELOG.md用）
   - VERSION_NUMBER: `1.2.0` 形式（プロジェクトファイル用）

2. **変更の収集**: 以下の情報を収集します
   - 最新のgitタグを取得
   - タグから現在(HEAD)までのコミット履歴
   - タグから現在までのファイル差分
   - ステージングエリアの変更（まだコミットされていない変更も含む）

3. **CHANGELOG生成**: 収集した情報を基に、Keep a Changelog形式でエントリーを生成します
   - フォーマット: https://keepachangelog.com/ja/1.1.0/
   - 日付形式: ISO 8601 (YYYY-MM-DD)
   - セクション: 追加/変更/非推奨/削除/修正/セキュリティ

4. **プロジェクトファイルの更新**: バージョン番号を以下のファイルに反映します
   - package.json（存在する場合）: `"version": "1.2.0"`
   - pyproject.toml（存在する場合）: `version = "1.2.0"`

5. **CHANGELOG.mdの更新**: 生成したエントリーをCHANGELOG.mdの先頭に挿入します

## 手順

### ステップ0: 引数の検証

まず、コマンドに渡された引数を検証してください：

1. **引数の存在確認**
   ```
   引数が存在しない場合:
   → エラーメッセージを表示: "エラー: バージョン番号が指定されていません。使用方法: /changelog <新しいバージョン>"
   → 処理を終了
   ```

2. **バージョン番号の形式検証**
   ```
   正規表現パターン: ^v\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$

   形式が不正な場合:
   → エラーメッセージを表示: "エラー: バージョン番号の形式が不正です。正しい形式: v1.0.0"
   → 処理を終了
   ```

3. **バージョン番号を変数に保存**
   ```
   検証が成功した場合:
   → 引数で渡されたバージョン番号を変数 NEW_VERSION に保存（例: v1.2.0）
   → vプレフィックスを除いた番号を VERSION_NUMBER に保存（例: 1.2.0）
   → 次のステップへ進む
   ```

### ステップ1: 変更情報の収集

以下のbashコマンドを実行して情報を収集してください:

```bash
# 最新のタグを取得（セマンティックバージョニング対応）
LATEST_TAG=$(git tag -l "v*" --sort=-version:refname | head -n 1)

# タグの有無を確認して適切なコマンドを実行
if [ -z "$LATEST_TAG" ]; then
  # タグが存在しない場合（初回リリース）
  echo "タグが見つかりません。全コミット履歴を取得します。"
  git log --oneline HEAD
  git diff --name-status $(git rev-list --max-parents=0 HEAD)..HEAD
else
  # タグが存在する場合
  echo "最新タグ: $LATEST_TAG"
  git log --oneline ${LATEST_TAG}..HEAD
  git diff --name-status ${LATEST_TAG} HEAD
fi

# ステージングエリアの変更を取得（タグの有無に関わらず常に実行）
git diff --cached --name-status
```

**注意**:
- `--sort=-version:refname`により、v1.0.0形式のタグをバージョン番号順にソートし、最新バージョンを取得します
- タグが存在しない場合（初回リリース）は、リポジトリの最初のコミットから現在までのすべての変更を取得します
- 変数置換（`${LATEST_TAG}`）を使用してタグが空の場合の構文エラーを防止します
- すべての情報を次のステップで使用するため、出力を保持してください

### ステップ2: CHANGELOGエントリーの生成

収集した情報を基に、以下の形式でCHANGELOGエントリーを生成してください:

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
- セクションヘッダー（### 追加 など）の後には必ず空行を入れる
- 該当する変更がないセクションは出力しない
- 各項目は日本語で記述
- 人間が読みやすく、ユーザーにとって価値のある情報を具体的に記載
- 変更の影響や理由が分かるように記述
- コミット済みの変更とステージング中の変更を統合して記載
- 技術的な詳細よりも、ユーザーへの影響を重視
- 前置きや説明文は一切含めず、CHANGELOGエントリー本文のみを出力

### ステップ3: プロジェクトファイルのバージョン更新

VERSION_NUMBER（vプレフィックスを除いた番号）を使用して、プロジェクトのバージョン管理ファイルを更新してください：

#### package.jsonの更新

1. **ファイルの存在確認**
   ```bash
   test -f package.json && echo "package.json found"
   ```

2. **package.jsonが存在する場合の更新**
   - ファイルを読み込む
   - `"version": "現在のバージョン",` の行を探す
   - `"version": "VERSION_NUMBER",` に置き換える

   **更新例**:
   ```json
   {
     "name": "my-project",
     "version": "1.2.0",
     "description": "..."
   }
   ```

#### pyproject.tomlの更新

1. **ファイルの存在確認**
   ```bash
   test -f pyproject.toml && echo "pyproject.toml found"
   ```

2. **pyproject.tomlが存在する場合の更新**
   - ファイルを読み込む
   - `[project]` セクション内の `version = "現在のバージョン"` の行を探す
   - `version = "VERSION_NUMBER"` に置き換える

   **更新例**:
   ```toml
   [project]
   name = "my-project"
   version = "1.2.0"
   description = "..."
   ```

**注意事項**:
- 両方のファイルが存在する場合は、両方を更新する
- どちらのファイルも存在しない場合は、このステップをスキップ
- バージョン番号は必ず VERSION_NUMBER（vなし）を使用する

### ステップ4: CHANGELOG.mdの更新

生成したエントリーを以下の位置に挿入してください:

1. CHANGELOG.mdが存在しない場合:
   ```markdown
   # Changelog

   ## [NEW_VERSION] - YYYY-MM-DD
   ...
   ```

2. CHANGELOG.mdが存在する場合:
   - ファイルを読み込む
   - "# Changelog" の見出しの後、最初のバージョンエントリーの前に新しいエントリーを挿入
   - 既存のエントリーとの間に空行を1行挿入

**例** (`/changelog v1.2.0` を実行した場合):
```markdown
# Changelog

## [v1.2.0] - 2025-10-04

### 追加
- 新しいCHANGELOGコマンドを追加

## [v1.0.0] - 2025-10-01
...
```

### ステップ5: 確認

以下の変更内容をユーザーに表示して確認を求める：

1. **生成されたCHANGELOGエントリー**
2. **更新されたプロジェクトファイル**（該当する場合）
   - package.json: `"version": "VERSION_NUMBER"`
   - pyproject.toml: `version = "VERSION_NUMBER"`

AskUserQuestionで確認を求める：

```python
AskUserQuestion(
    questions=[{
        "question": "上記の変更内容でファイルを更新してよろしいですか？",
        "header": "CHANGELOG更新",
        "options": [
            {"label": "更新する", "description": "CHANGELOG.mdとバージョンファイルを更新"},
            {"label": "キャンセル", "description": "更新せず終了（内容を再確認）"}
        ],
        "multiSelect": False
    }]
)
```

**処理**:
- 「更新する」が選択された場合: すべてのファイルを更新する
- 「キャンセル」が選択された場合: 処理を中止

## Keep a Changelog形式の詳細

### セクション構造

- **追加 (Added)**: 新機能
- **変更 (Changed)**: 既存機能の変更
- **非推奨 (Deprecated)**: 間もなく削除される機能
- **削除 (Removed)**: 削除された機能
- **修正 (Fixed)**: バグ修正
- **セキュリティ (Security)**: 脆弱性対応

### 日付形式

- ISO 8601形式: YYYY-MM-DD
- 例: 2025-10-04

### バージョン表記

- `[v1.0.0]`: リリースバージョン（引数で指定）
- セマンティックバージョニング形式（v + MAJOR.MINOR.PATCH）を使用

## 参考

- Keep a Changelog: https://keepachangelog.com/ja/1.1.0/
