---
description: CHANGELOG.mdから該当バージョンのエントリーを抽出し、annotated tagを自動作成
argument-hint: <タグ名> (例: v1.2.0)
---

# Git Tag Command

CHANGELOG.mdから該当バージョンのエントリーを抽出し、annotated tagを自動作成する。

## 引数

- `$1`: **必須**。作成するタグ名（例: `v1.2.0`）

## バージョン番号のフォーマット規則

- **形式**: `v` + セマンティックバージョニング（`MAJOR.MINOR.PATCH`）
- **オプション**: プレリリース版やビルドメタデータ（例: `v1.0.0-beta.1`）

## エラー条件

- 引数が指定されていない場合: `エラー: タグ名が指定されていません。使用方法: /prompts:git-tag <タグ名>`
- タグ名の形式が不正な場合: `エラー: タグ名の形式が不正です。正しい形式: v1.0.0`
- CHANGELOG.mdが存在しない場合: `エラー: CHANGELOG.mdが見つかりません`
- 該当するバージョンエントリーが存在しない場合: `エラー: CHANGELOG.mdに <タグ名> のエントリーが見つかりません`

## 手順

### ステップ0: 引数の検証

1. `$1` が空の場合はエラーで終了
2. 正規表現 `^v\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$` で形式検証
3. 検証成功したら TAG_NAME 変数に保存

### ステップ1: CHANGELOG.mdの確認

```bash
test -f CHANGELOG.md && echo "CHANGELOG.md found" || echo "CHANGELOG.md not found"
```

存在しない場合はエラーで終了。

### ステップ2: タグの存在確認

```bash
git tag -l "$TAG_NAME"
```

タグが既に存在する場合:
- ユーザーに「タグ '$TAG_NAME' は既に存在します。上書きしますか？」と確認を求める
- 上書きする場合: `git tag -d $TAG_NAME` で既存タグを削除してから続行
- キャンセルの場合: 処理を中止

### ステップ3: CHANGELOGエントリーの抽出

```bash
VERSION_NUMBER=$(echo "$TAG_NAME" | sed 's/^v//')

# 該当バージョンの見出しから次の見出しの直前まで抽出
CHANGELOG_ENTRY=$(sed -n "/^## \[v\?${VERSION_NUMBER}\]/,/^## \[v/p" CHANGELOG.md | sed '$d')

# 最後のセクションの場合（次の見出しがない場合）
if [ -z "$CHANGELOG_ENTRY" ]; then
  CHANGELOG_ENTRY=$(sed -n "/^## \[v\?${VERSION_NUMBER}\]/,\$p" CHANGELOG.md)
fi

# 末尾の空行を削除
CHANGELOG_ENTRY=$(echo "$CHANGELOG_ENTRY" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

if [ -z "$CHANGELOG_ENTRY" ]; then
  echo "エラー: CHANGELOG.mdに $TAG_NAME のエントリーが見つかりません"
  exit 1
fi
```

### ステップ4: タグメッセージの確認

抽出した内容をユーザーに表示し、「このままタグを作成してよろしいですか？」と確認を求める。承認されたら次のステップへ。キャンセルされた場合は処理を中止。

### ステップ5: Annotated Tagの作成

```bash
git tag -a "$TAG_NAME" -m "$CHANGELOG_ENTRY"
```

### ステップ6: 完了メッセージ

```
タグ '$TAG_NAME' が正常に作成されました

リモートにプッシュするには:
  git push origin $TAG_NAME

すべてのタグをプッシュするには:
  git push --tags
```

## 参考

- Keep a Changelog: https://keepachangelog.com/ja/1.1.0/
- Annotated tagは完全なGitオブジェクト（タグ名、メッセージ、作成者、日時を含む）
