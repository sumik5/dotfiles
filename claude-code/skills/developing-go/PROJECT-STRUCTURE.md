# Goプロジェクト構造

## 標準レイアウト

### シンプルなプロジェクト
```
myproject/
├── go.mod
├── go.sum
├── main.go           # エントリーポイント
├── handler.go        # HTTPハンドラ
├── service.go        # ビジネスロジック
├── repository.go     # データアクセス
└── handler_test.go   # テスト
```

### 中規模プロジェクト
```
myproject/
├── go.mod
├── go.sum
├── main.go
├── cmd/
│   └── myapp/
│       └── main.go       # エントリーポイント
├── internal/             # プロジェクト内部パッケージ
│   ├── handler/
│   │   ├── handler.go
│   │   └── handler_test.go
│   ├── service/
│   │   ├── service.go
│   │   └── service_test.go
│   └── repository/
│       ├── repository.go
│       └── repository_test.go
├── pkg/                  # 外部公開パッケージ（必要な場合）
│   └── client/
│       └── client.go
└── Makefile
```

### 大規模プロジェクト
```
myproject/
├── go.mod
├── go.sum
├── cmd/
│   ├── api/
│   │   └── main.go       # APIサーバー
│   ├── worker/
│   │   └── main.go       # バックグラウンドワーカー
│   └── cli/
│       └── main.go       # CLIツール
├── internal/
│   ├── app/              # アプリケーション層
│   │   ├── api/
│   │   └── worker/
│   ├── domain/           # ドメイン層
│   │   ├── user/
│   │   │   ├── entity.go
│   │   │   ├── repository.go  # インターフェース
│   │   │   └── service.go
│   │   └── order/
│   ├── infra/            # インフラ層
│   │   ├── database/
│   │   ├── cache/
│   │   └── external/
│   └── config/
│       └── config.go
├── pkg/                  # 公開ライブラリ
├── api/                  # API定義
│   ├── openapi.yaml
│   └── proto/
├── migrations/           # DBマイグレーション
├── scripts/              # ビルド/デプロイスクリプト
├── deployments/          # デプロイ設定
│   ├── docker/
│   └── k8s/
├── docs/
├── Makefile
├── Dockerfile
└── docker-compose.yml
```

## ディレクトリの役割

### cmd/
実行可能ファイルのエントリーポイント：

```go
// cmd/api/main.go
package main

import (
    "context"
    "log"
    "os/signal"
    "syscall"

    "github.com/username/myproject/internal/app/api"
    "github.com/username/myproject/internal/config"
)

func main() {
    ctx, stop := signal.NotifyContext(context.Background(),
        syscall.SIGINT, syscall.SIGTERM)
    defer stop()

    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("load config: %v", err)
    }

    if err := api.Run(ctx, cfg); err != nil {
        log.Fatalf("run api: %v", err)
    }
}
```

### internal/
プロジェクト内部のコード。外部からインポート不可：

```go
// internal/handler/user.go
package handler

type UserHandler struct {
    service UserService
}

func NewUserHandler(service UserService) *UserHandler {
    return &UserHandler{service: service}
}
```

### pkg/
外部に公開するパッケージ（慎重に使用）：

```go
// pkg/client/client.go
package client

// Client は外部から使用可能
type Client struct {
    baseURL string
}

func New(baseURL string) *Client {
    return &Client{baseURL: baseURL}
}
```

## go.mod

### 初期化
```bash
go mod init github.com/username/myproject
```

### 基本構造
```go
module github.com/username/myproject

go 1.22

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/lib/pq v1.10.9
)

require (
    // 間接依存
    golang.org/x/net v0.17.0 // indirect
)
```

### コマンド
```bash
# 依存関係の追加
go get github.com/gin-gonic/gin

# 不要な依存の削除
go mod tidy

# 依存関係の検証
go mod verify

# ベンダリング
go mod vendor
```

## パッケージ設計

### 単一責任
```go
// Good: 明確な責任
package user

type User struct { ... }
type Repository interface { ... }
type Service struct { ... }

// Bad: 複数の責任
package models  // 様々なエンティティが混在
```

### 依存関係の方向
```
cmd/
 └── depends on → internal/app/
                   └── depends on → internal/domain/
                                    └── depends on → internal/infra/ (via interface)
```

### インターフェースの配置
```go
// internal/domain/user/repository.go
// インターフェースは使用する側で定義
package user

type Repository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// internal/infra/database/user_repository.go
// 実装はインフラ層
package database

type UserRepository struct {
    db *sql.DB
}

func (r *UserRepository) FindByID(ctx context.Context, id string) (*user.User, error) {
    // 実装
}
```

## 設定管理

### 環境変数ベース
```go
// internal/config/config.go
package config

import (
    "os"
    "strconv"
    "time"
)

type Config struct {
    Server   ServerConfig
    Database DatabaseConfig
}

type ServerConfig struct {
    Port         int
    ReadTimeout  time.Duration
    WriteTimeout time.Duration
}

type DatabaseConfig struct {
    Host     string
    Port     int
    User     string
    Password string
    Name     string
}

func Load() (*Config, error) {
    return &Config{
        Server: ServerConfig{
            Port:         getEnvInt("SERVER_PORT", 8080),
            ReadTimeout:  getEnvDuration("SERVER_READ_TIMEOUT", 30*time.Second),
            WriteTimeout: getEnvDuration("SERVER_WRITE_TIMEOUT", 30*time.Second),
        },
        Database: DatabaseConfig{
            Host:     getEnv("DB_HOST", "localhost"),
            Port:     getEnvInt("DB_PORT", 5432),
            User:     getEnv("DB_USER", "postgres"),
            Password: os.Getenv("DB_PASSWORD"),  // 必須
            Name:     getEnv("DB_NAME", "mydb"),
        },
    }, nil
}

func getEnv(key, defaultValue string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
    if v := os.Getenv(key); v != "" {
        if i, err := strconv.Atoi(v); err == nil {
            return i
        }
    }
    return defaultValue
}

func getEnvDuration(key string, defaultValue time.Duration) time.Duration {
    if v := os.Getenv(key); v != "" {
        if d, err := time.ParseDuration(v); err == nil {
            return d
        }
    }
    return defaultValue
}
```

## Makefile

```makefile
.PHONY: build test lint run clean

# 変数
BINARY_NAME=myapp
BUILD_DIR=bin

# ビルド
build:
	go build -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/api

# テスト
test:
	go test -v -race -cover ./...

# Lint
lint:
	golangci-lint run

# 開発サーバー起動
run:
	go run ./cmd/api

# クリーン
clean:
	rm -rf $(BUILD_DIR)

# 依存関係
deps:
	go mod tidy
	go mod verify

# 全チェック
check: lint test
```

## ベストプラクティス

| プラクティス | 説明 |
|------------|------|
| internal/使用 | 内部コードを外部から保護 |
| 小さなパッケージ | 単一責任、テスト容易性 |
| インターフェース分離 | 使用側で定義 |
| 依存性注入 | テスト容易性、疎結合 |
| 設定は環境変数 | 12-Factor App準拠 |

## アンチパターン

| パターン | 問題 | 修正 |
|---------|------|------|
| 巨大なmain.go | テスト困難 | cmd/とinternal/に分離 |
| 循環インポート | ビルドエラー | インターフェースで分離 |
| グローバル変数 | テスト困難 | 依存性注入 |
| utils/パッケージ | 意味不明な集合 | 目的別パッケージ |
| pkg/の乱用 | API汚染 | internal/を優先 |
