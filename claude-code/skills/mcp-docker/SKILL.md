---
name: mcp-docker
description: Docker開発環境管理 - コンテナ化プロジェクトでのDocker操作、Compose管理、環境構築を支援。
---

# Docker開発環境管理

## 🎯 使用タイミング
- **開発環境のコンテナ化時**
- **マイクロサービス構成時**
- **Docker Composeプロジェクト管理時**
- **コンテナのデバッグ・ログ確認時**

## 📋 基本操作

### 1. コンテナ管理
```typescript
// コンテナ一覧
mcp__docker__list_containers()

// コンテナ起動
mcp__docker__start_container({
  container_name: "app-container"
})

// コンテナ停止
mcp__docker__stop_container({
  container_name: "app-container"
})

// ログ取得
mcp__docker__get_container_logs({
  container_name: "app-container"
})
```

### 2. イメージ管理
```typescript
// イメージビルド
mcp__docker__build_image({
  dockerfile_path: "./Dockerfile",
  image_name: "my-app:latest"
})

// イメージ一覧
// Bash: docker images
```

### 3. Docker Compose管理
```typescript
// Composeプロジェクト起動
mcp__docker__compose_up({
  compose_file: "docker-compose.yml",
  project_name: "my-project"
})

// Composeプロジェクト停止
mcp__docker__compose_down({
  project_name: "my-project"
})
```

## 🏗️ 推奨ワークフロー

### 新規コンテナ化プロジェクト
```
段階1: 設計
- dev1: Dockerfile作成
- dev2: docker-compose.yml設計

段階2: ビルド・テスト
- dev3: イメージビルド・テスト
- dev4: ネットワーク・ボリューム設定

段階3: 統合テスト
- dev1: コンテナ統合テスト
```

### 既存プロジェクトのデバッグ
```
1. コンテナ状態確認
   mcp__docker__list_containers()

2. ログ確認
   mcp__docker__get_container_logs({ container_name: "..." })

3. 問題解決
   - 必要に応じてコンテナ再起動
   - 設定ファイル修正
```

## 🎨 よくあるパターン

### Web + DB構成
```yaml
# docker-compose.yml
services:
  web:
    build: ./web
    ports:
      - "3000:3000"
    depends_on:
      - db

  db:
    image: postgres:15
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}

volumes:
  db_data:
```

### マイクロサービス構成
```yaml
services:
  api:
    build: ./api
    ports:
      - "8000:8000"

  worker:
    build: ./worker
    depends_on:
      - redis

  redis:
    image: redis:alpine
```

## ⚠️ ベストプラクティス

**Dockerfile作成時は必ず `dockerfile-best-practices` スキルを参照してください。**

主要ポイント:
1. **マルチステージビルド**: イメージサイズ最小化
2. **環境変数管理**: .envファイルで管理、.gitignore追加
3. **ヘルスチェック**: コンテナの正常性監視
4. **ボリューム活用**: データ永続化
5. **ネットワーク分離**: セキュリティ向上
6. **ログ管理**: ログドライバー設定

## 🔧 トラブルシューティング

### コンテナが起動しない
```bash
# ログ確認
mcp__docker__get_container_logs({ container_name: "..." })

# コンテナ詳細確認
# Bash: docker inspect container_name
```

### イメージビルド失敗
```bash
# キャッシュなしで再ビルド
# Bash: docker build --no-cache -t image_name .
```

### ネットワーク問題
```bash
# ネットワーク確認
# Bash: docker network ls
# Bash: docker network inspect network_name
```

## 📚 主要コマンド
- `list_containers` - コンテナ一覧
- `start_container` - コンテナ起動
- `stop_container` - コンテナ停止
- `build_image` - イメージビルド
- `compose_up` - Compose起動
- `get_container_logs` - ログ取得

## 🔗 関連ツール
- **filesystem MCP**: Dockerfile、docker-compose.yml編集
- **serena MCP**: アプリケーションコード編集
- **bash**: docker CLI直接実行
