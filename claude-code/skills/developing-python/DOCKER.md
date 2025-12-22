# Docker構成（uvマルチステージビルド）

## 🎯 Dockerイメージ最適化戦略

### マルチステージビルドの利点
- **イメージサイズの削減**: ビルドツールを最終イメージに含めない
- **ビルド時間の短縮**: レイヤーキャッシュを最大限活用
- **セキュリティ向上**: 不要なツールを含まない

### 基本原則
- **Stage 1（builder）**: 依存関係のインストール
- **Stage 2（runtime）**: 実行環境のみを含む

## 📄 Dockerfile完全版（実際のプロジェクトから）

```dockerfile
# ==============================================================================
# Stage 1: Builder - 依存関係のインストール
# ==============================================================================
FROM python:3.13-slim AS builder

# uvのインストール（最新版を使用）
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# 依存関係定義ファイルのコピー
COPY pyproject.toml uv.lock README.md ./

# 依存関係のインストール
# --frozen: uv.lockを使用（再解決しない）
# --no-dev: 開発依存関係を除外
RUN uv sync --frozen --no-dev

# ==============================================================================
# Stage 2: Runtime - 実行環境
# ==============================================================================
FROM python:3.13-slim

# ヘルスチェック用のcurlをインストール
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Stage 1からビルドされた仮想環境をコピー
COPY --from=builder /app/.venv /app/.venv

# ソースコードをコピー
COPY src/ /app/src/

# 仮想環境のPythonを使用するようPATHを設定
ENV PATH="/app/.venv/bin:$PATH"

# ポートを公開
EXPOSE 8080

# ヘルスチェック（オプション: 必要に応じてコメント解除）
#HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#  CMD curl -f http://localhost:8080/health || exit 1

# アプリケーション起動
# PORT環境変数を使用（Cloud Run等が動的に設定）
CMD ["sh", "-c", "uvicorn src.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
```

## 📐 Dockerイメージ構成の詳細解説

### Stage 1: Builder

```dockerfile
FROM python:3.13-slim AS builder
```
- **ベースイメージ**: `python:3.13-slim`（Debian slim版）
- **AS builder**: 後続のステージから参照可能な名前

```dockerfile
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
```
- **uvのインストール**: 公式イメージから実行ファイルをコピー
- **メリット**: uvのインストールスクリプトを実行不要（高速）

```dockerfile
COPY pyproject.toml uv.lock README.md ./
```
- **依存関係定義のみコピー**: レイヤーキャッシュを活用
- **ソースコードは含めない**: 依存関係が変わらなければキャッシュが有効

```dockerfile
RUN uv sync --frozen --no-dev
```
- **--frozen**: uv.lockを厳密に使用（再解決しない）
- **--no-dev**: 開発依存関係を除外（pytest等は不要）

### Stage 2: Runtime

```dockerfile
FROM python:3.13-slim
```
- **新しいベースイメージ**: builderステージのゴミを含まない

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```
- **curl**: ヘルスチェック用（必要に応じて）
- **--no-install-recommends**: 推奨パッケージを除外（サイズ削減）
- **rm -rf /var/lib/apt/lists/\***: aptキャッシュを削除（サイズ削減）

```dockerfile
COPY --from=builder /app/.venv /app/.venv
```
- **仮想環境のコピー**: builderステージで作成した.venvをコピー
- **メリット**: Pythonパッケージのみ（uvは含まない）

```dockerfile
ENV PATH="/app/.venv/bin:$PATH"
```
- **PATH設定**: 仮想環境のPythonを優先
- **効果**: `python`コマンドで.venv内のPythonが実行される

```dockerfile
CMD ["sh", "-c", "uvicorn src.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
```
- **sh -c**: シェル経由で実行（環境変数展開のため）
- **${PORT:-8080}**: PORT環境変数（未設定なら8080）
- **Cloud Run対応**: Cloud RunがPORT環境変数を設定

## 🚀 ビルドと実行

### ローカルでのビルド

```bash
# イメージビルド
docker build -t my-app:latest .

# コンテナ実行
docker run -p 8080:8080 --env-file .env my-app:latest

# バックグラウンド実行
docker run -d -p 8080:8080 --env-file .env --name my-app my-app:latest

# ログ確認
docker logs -f my-app

# コンテナ停止
docker stop my-app
docker rm my-app
```

### イメージサイズ確認

```bash
# イメージサイズ確認
docker images my-app

# レイヤー詳細確認
docker history my-app:latest
```

**期待されるサイズ:**
- **python:3.13-slim**: 約150MB
- **依存関係追加後**: 200-400MB（依存関係による）

## 🔒 .dockerignore

```.dockerignore
# Git
.git
.gitignore
.gitattributes

# Python
__pycache__/
*.py[cod]
*$py.class
.Python

# 仮想環境（ビルド時に作成）
.venv/
venv/
env/

# テスト
.pytest_cache/
.coverage
htmlcov/
tests/

# ビルド成果物
dist/
build/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp

# ドキュメント
docs/
*.md
!README.md  # README.mdは含める（pyproject.tomlで参照）

# 環境変数
.env
.env.*

# ログ
*.log

# OS
.DS_Store
Thumbs.db

# CI/CD
.github/
.gitlab-ci.yml

# Docker自身
Dockerfile*
docker-compose.yml
.dockerignore
```

**重要な除外項目:**
- **tests/**: テストコードは不要
- **.venv/**: ローカルの仮想環境（コンテナ内で再作成）
- **.env**: セキュリティ上絶対に含めない

## 🌐 Cloud Run対応

### Cloud Run特有の要件

```dockerfile
# ポート環境変数に対応
CMD ["sh", "-c", "uvicorn src.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
```

**Cloud Runの動作:**
- `PORT`環境変数を動的に設定（通常8080）
- コンテナはこのポートでリッスン必須

### デプロイコマンド例

```bash
# Google Cloud Buildでビルド
gcloud builds submit --tag gcr.io/PROJECT_ID/my-app

# Cloud Runにデプロイ
gcloud run deploy my-app \
  --image gcr.io/PROJECT_ID/my-app \
  --platform managed \
  --region asia-northeast1 \
  --allow-unauthenticated \
  --set-env-vars ENVIRONMENT=production
```

## 🐳 docker-compose.yml（開発用）

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    env_file:
      - .env
    volumes:
      # ホットリロード用（開発時のみ）
      - ./src:/app/src
    command: uvicorn src.main:app --host 0.0.0.0 --port 8080 --reload

  # データベース（必要に応じて）
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### 使用方法

```bash
# サービス起動
docker-compose up

# バックグラウンド起動
docker-compose up -d

# ログ確認
docker-compose logs -f app

# サービス停止
docker-compose down

# ボリュームも削除
docker-compose down -v
```

## ⚡ ビルド最適化テクニック

### 1. ビルドキャッシュの活用

```dockerfile
# ❌ 悪い例: ソースコードと依存関係を同時にコピー
COPY . .
RUN uv sync

# ✅ 良い例: 依存関係定義のみ先にコピー
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen
COPY src/ ./src/
```

**効果**: ソースコード変更時、依存関係の再インストールが不要

### 2. レイヤー数の最小化

```dockerfile
# ❌ 悪い例: レイヤーが多い
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# ✅ 良い例: 1つのRUNで完結
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

### 3. BuildKitの活用

```bash
# BuildKit有効化（より高速なビルド）
DOCKER_BUILDKIT=1 docker build -t my-app .

# キャッシュマウント（さらに高速化）
# Dockerfile内で:
# RUN --mount=type=cache,target=/root/.cache/uv \
#     uv sync --frozen
```

## 🔍 トラブルシューティング

### 問題: イメージサイズが大きすぎる
**原因**: 不要なファイルが含まれている

**解決**:
```bash
# レイヤー分析ツール（dive）を使用
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest my-app:latest
```

### 問題: ビルドが遅い
**原因**: キャッシュが効いていない

**解決**:
- `.dockerignore`を適切に設定
- 依存関係定義を先にコピー
- BuildKitを有効化

### 問題: コンテナ起動時にエラー
**原因**: 環境変数が設定されていない

**解決**:
```bash
# 環境変数を渡す
docker run -e GOOGLE_CLIENT_ID=xxx -e GOOGLE_CLIENT_SECRET=yyy my-app

# .envファイルを使用
docker run --env-file .env my-app
```

## 🔗 関連ドキュメント

- **[PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md)**: ソースコード配置
- **[TOOLING.md](./TOOLING.md)**: pyproject.tomlとuv設定
- **[EXAMPLES.md](./EXAMPLES.md)**: 実際のプロジェクト例
