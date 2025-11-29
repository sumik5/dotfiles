# GitLab Merge Request 生成コマンド

このコマンドは、現在のブランチと分岐元ブランチとの差分を分析し、GitLab Merge Request用の説明文を自動生成します。

## 使用方法

```bash
/generate-mr [JIRAチケット名]
```

### 引数

- `[JIRAチケット名]`: オプション。JIRAチケット名を指定するとMRタイトルの先頭に追加されます
  - 例: `/generate-mr PROJ-123`, `/generate-mr ABC-456`

### 使用例

```bash
# JIRAチケットなし
/generate-mr

# JIRAチケットあり
/generate-mr PROJ-123
```

## 実行手順

### ステップ0: Gitリポジトリの確認

まず、現在のディレクトリがGitリポジトリであることを確認してください：

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

失敗した場合: "エラー: Gitリポジトリではありません" を表示して終了

### ステップ1: ブランチ情報の取得と分岐元ブランチの特定

```bash
# 現在のブランチ名を取得
CURRENT_BRANCH=$(git branch --show-current)

echo "現在のブランチ: $CURRENT_BRANCH"
```

分岐元ブランチを特定するため、以下の手順で調査してください：

```bash
# 1. リモート追跡ブランチの確認
git branch -vv

# 2. 主要ブランチ（main, master, develop等）との分岐点を確認
# 各ブランチとの共通祖先からのコミット数を比較
for branch in main master develop; do
  if git show-ref --verify --quiet refs/heads/$branch 2>/dev/null || \
     git show-ref --verify --quiet refs/remotes/origin/$branch 2>/dev/null; then
    MERGE_BASE=$(git merge-base HEAD $branch 2>/dev/null || git merge-base HEAD origin/$branch 2>/dev/null)
    if [ -n "$MERGE_BASE" ]; then
      COMMIT_COUNT=$(git rev-list --count $MERGE_BASE..HEAD)
      echo "$branch: 分岐点から $COMMIT_COUNT コミット"
    fi
  fi
done

# 3. reflogから分岐元を推測（ブランチ作成時のログ）
git reflog show $CURRENT_BRANCH --format="%gs" | head -5
```

上記の情報から分岐元ブランチを特定し、`BASE_BRANCH` として使用してください。
特定のルール:
- 共通祖先からのコミット数が最も少ないブランチを分岐元とする
- reflogに "branch: Created from" の情報があればそれを優先
- 特定できない場合は main または master をフォールバックとする

```bash
# 分岐元ブランチを設定（上記調査結果から決定）
BASE_BRANCH="<特定された分岐元ブランチ>"

echo "分岐元ブランチ: $BASE_BRANCH"
```

エラー条件:
- 現在のブランチが分岐元ブランチと同じ場合: "エラー: 分岐元ブランチからはMerge Requestを作成できません"
- 分岐元ブランチとの差分がない場合: "エラー: 分岐元ブランチとの差分がありません"

### ステップ2: 変更情報の収集

ステップ1で特定した `BASE_BRANCH` を使用して、以下のコマンドで情報を収集してください：

```bash
# コミット履歴を取得
echo "=== コミット履歴 ==="
git log --oneline ${BASE_BRANCH}..HEAD

# 詳細なコミットメッセージを取得
echo ""
echo "=== 詳細なコミットメッセージ ==="
git log ${BASE_BRANCH}..HEAD --pretty=format:"%s%n%b" --reverse

# 変更統計
echo ""
echo "=== 変更統計 ==="
git diff --stat ${BASE_BRANCH}..HEAD

# 変更ファイル一覧（A: 追加, M: 変更, D: 削除）
echo ""
echo "=== 変更ファイル一覧 ==="
git diff --name-status ${BASE_BRANCH}..HEAD

# 実際のdiff（コード変更の詳細把握用）
echo ""
echo "=== コード変更の詳細 ==="
git diff ${BASE_BRANCH}..HEAD
```

### ステップ3: Merge Request文章の生成

収集した情報を分析し、以下のフォーマットでMerge Request文章を生成してください。

#### 生成ルール

1. JIRAチケット名が引数として渡された場合（$ARGUMENTS に格納）:
   - タイトル先頭に `[チケット名] ` を付与
   - 例: `[PROJ-123] ユーザー認証機能の実装`

2. タイトルは変更内容を端的に表す日本語で記述

3. 本文は以下の構成で生成:

```
## 概要

このMRで実現することを1-3文で記述。
何が達成されるのかをユーザー視点で説明。

## 背景

なぜこのMRが必要かを説明。
- 課題や要件があれば記述
- 関連するチケットやドキュメントがあれば記載

## 変更内容

このMRで何を実装したかをざっくり説明。

主な変更点:
- 変更点1
- 変更点2
- 変更点3

<details>
<summary>詳細な変更内容</summary>

ファイル単位または機能単位での詳細な変更内容を記述。
技術的な詳細はここに記載。

</details>
```

#### 文章生成の注意点

- Markdownの強調（**太字**、*斜体*）は使用しない
- 項目名はh2（##）から始め、改行して本文を書く
- GitLabのURLはそのまま埋め込む（GitLab viewerが装飾してくれる）
- GitLab以外のURLは `[タイトル](URL)` 形式で埋め込む
- 人間に読みやすく、編集しやすいよう適度に改行と箇条書きを使う
- Human Readableな自然な日本語で記述

### ステップ4: 出力

生成したMerge Request文章をコードブロックで出力してください：

```
=== Merge Request 文章 ===

タイトル:
```
[生成されたタイトル]
```

本文:
```
[生成された本文]
```

===
```

注意事項:
- 前置きの説明やコメントは不要です
- MR文章のみをそのまま出力してください
- 出力後、ユーザーがコピーしてGitLabに貼り付けられる形式にしてください
- タイトルと本文は別々のコードブロックで出力（コピーしやすくするため）

## 出力例

JIRAチケットあり（`/generate-mr PROJ-123`）の場合:

タイトル:
```
[PROJ-123] ユーザー認証機能の実装
```

本文:
```
## 概要

ユーザーがメールアドレスとパスワードでログインできる認証機能を追加しました。
セッション管理とログアウト機能も含まれています。

## 背景

新規ユーザー登録フローの実装に伴い、認証基盤が必要となりました。
セキュリティ要件に基づき、JWTトークンベースの認証を採用しています。

## 変更内容

認証に必要なエンドポイントとミドルウェアを実装しました。

主な変更点:
- ログイン/ログアウトAPIエンドポイントの追加
- JWTトークン生成・検証ロジックの実装
- 認証ミドルウェアの追加

<details>
<summary>詳細な変更内容</summary>

追加ファイル:
- src/auth/login.ts: ログイン処理
- src/auth/logout.ts: ログアウト処理
- src/middleware/auth.ts: 認証ミドルウェア

変更ファイル:
- src/routes/index.ts: 認証ルートの追加

</details>
```
