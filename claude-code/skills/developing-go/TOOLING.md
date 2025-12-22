# Go開発ツール

## 標準ツール

### gofmt
公式フォーマッター。全Goコードに必須：

```bash
# フォーマット確認
gofmt -d .

# フォーマット適用
gofmt -w .

# シンプル化も適用
gofmt -s -w .
```

### goimports
gofmt + インポート整理：

```bash
# インストール
go install golang.org/x/tools/cmd/goimports@latest

# 実行
goimports -w .
```

### go vet
静的解析で潜在的な問題を検出：

```bash
go vet ./...
```

検出例：
- Printf系関数の引数ミスマッチ
- 到達不能コード
- コピーされるべきでない値のコピー

### go mod
依存関係管理：

```bash
# 初期化
go mod init github.com/username/project

# 依存追加
go get github.com/gin-gonic/gin@v1.9.1

# 不要な依存削除
go mod tidy

# 依存のダウンロード
go mod download

# ベンダリング
go mod vendor

# 依存グラフ表示
go mod graph
```

## golangci-lint

### インストール
```bash
# macOS
brew install golangci-lint

# Go
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# バイナリ
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
```

### 実行
```bash
# 全チェック
golangci-lint run

# 特定パッケージ
golangci-lint run ./internal/...

# 自動修正
golangci-lint run --fix
```

### 設定ファイル (.golangci.yml)
```yaml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - errcheck      # エラーチェック漏れ
    - govet         # go vet
    - ineffassign   # 無駄な代入
    - staticcheck   # 静的解析
    - unused        # 未使用コード
    - gosimple      # 簡略化可能なコード
    - gocritic      # コードレビュー的チェック
    - gofmt         # フォーマット
    - goimports     # インポート整理
    - misspell      # スペルミス
    - revive        # golint後継

linters-settings:
  errcheck:
    check-type-assertions: true
    check-blank: true

  govet:
    enable-all: true

  revive:
    rules:
      - name: exported
        severity: warning
      - name: blank-imports
        severity: warning
      - name: context-as-argument
        severity: warning
      - name: error-return
        severity: warning

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - errcheck
        - gocritic
```

## delve（デバッガ）

### インストール
```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

### 使用方法
```bash
# デバッグ実行
dlv debug ./cmd/api

# テストのデバッグ
dlv test ./internal/handler

# 実行中プロセスにアタッチ
dlv attach <pid>

# コアダンプのデバッグ
dlv core ./myapp core.dump
```

### 基本コマンド
```
(dlv) break main.main     # ブレークポイント設定
(dlv) break handler.go:42 # 行指定
(dlv) continue            # 実行継続
(dlv) next                # ステップオーバー
(dlv) step                # ステップイン
(dlv) print variable      # 変数表示
(dlv) locals              # ローカル変数一覧
(dlv) goroutines          # goroutine一覧
(dlv) stack               # スタックトレース
```

## go generate

### 使用例
```go
//go:generate mockgen -source=repository.go -destination=mock_repository.go -package=user

type Repository interface {
    FindByID(ctx context.Context, id string) (*User, error)
}
```

```bash
# 実行
go generate ./...
```

### よく使うジェネレータ
- **mockgen**: モック生成
- **stringer**: String()メソッド生成
- **sqlc**: SQLからGoコード生成
- **ent**: ORMコード生成

## Makefile

```makefile
.PHONY: all build test lint clean

# 変数
BINARY_NAME := myapp
BUILD_DIR := bin
GO_FILES := $(shell find . -name '*.go' -not -path './vendor/*')

# デフォルトターゲット
all: lint test build

# ビルド
build:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/api

# 開発ビルド（デバッグ情報付き）
build-dev:
	go build -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/api

# テスト
test:
	go test -v -race -cover ./...

# カバレッジレポート
coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# Lint
lint:
	golangci-lint run

# フォーマット
fmt:
	gofmt -s -w .
	goimports -w .

# 依存関係
deps:
	go mod tidy
	go mod verify

# コード生成
generate:
	go generate ./...

# クリーン
clean:
	rm -rf $(BUILD_DIR)
	rm -f coverage.out coverage.html

# 開発サーバー（ホットリロード）
dev:
	air -c .air.toml

# Docker
docker-build:
	docker build -t $(BINARY_NAME) .

docker-run:
	docker run -p 8080:8080 $(BINARY_NAME)
```

## Air（ホットリロード）

### インストール
```bash
go install github.com/air-verse/air@latest
```

### 設定 (.air.toml)
```toml
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main ./cmd/api"
  bin = "./tmp/main"
  include_ext = ["go", "tpl", "tmpl", "html"]
  exclude_dir = ["assets", "tmp", "vendor", "testdata"]
  delay = 1000

[log]
  time = false

[color]
  main = "magenta"
  watcher = "cyan"
  build = "yellow"
  runner = "green"

[misc]
  clean_on_exit = true
```

## pre-commit

### インストール
```bash
pip install pre-commit
```

### 設定 (.pre-commit-config.yaml)
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml

  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: go-fmt
      - id: go-imports
      - id: go-vet
      - id: golangci-lint

  - repo: local
    hooks:
      - id: go-mod-tidy
        name: go mod tidy
        entry: go mod tidy
        language: system
        pass_filenames: false
```

```bash
# 有効化
pre-commit install

# 手動実行
pre-commit run --all-files
```

## CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v4
        with:
          version: latest

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Test
        run: go test -v -race -coverprofile=coverage.out ./...
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: coverage.out

  build:
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Build
        run: go build -o bin/myapp ./cmd/api
```

## ツール一覧

| ツール | 目的 | コマンド |
|-------|------|---------|
| gofmt | フォーマット | `gofmt -w .` |
| goimports | インポート整理 | `goimports -w .` |
| go vet | 静的解析 | `go vet ./...` |
| golangci-lint | 統合lint | `golangci-lint run` |
| delve | デバッグ | `dlv debug` |
| air | ホットリロード | `air` |
| mockgen | モック生成 | `go generate` |
