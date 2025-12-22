# Goテスト戦略

## 基本

### ファイル配置
```
mypackage/
├── handler.go
├── handler_test.go      # 同じパッケージ
├── service.go
└── service_test.go
```

### 基本的なテスト
```go
// handler_test.go
package mypackage

import "testing"

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("Add(2, 3) = %d; want 5", result)
    }
}
```

### テスト実行
```bash
# 全テスト実行
go test ./...

# 特定パッケージ
go test ./internal/handler

# 詳細出力
go test -v ./...

# 特定のテスト
go test -run TestAdd ./...

# カバレッジ
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## テーブル駆動テスト

### 基本パターン
```go
func TestCalculate(t *testing.T) {
    tests := []struct {
        name     string
        input    int
        expected int
    }{
        {"zero", 0, 0},
        {"positive", 5, 25},
        {"negative", -3, 9},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Calculate(tt.input)
            if result != tt.expected {
                t.Errorf("Calculate(%d) = %d; want %d", tt.input, result, tt.expected)
            }
        })
    }
}
```

### エラーケースを含む
```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int
        wantErr bool
    }{
        {"valid", "42", 42, false},
        {"invalid", "abc", 0, true},
        {"empty", "", 0, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Parse(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("Parse(%q) = %d; want %d", tt.input, got, tt.want)
            }
        })
    }
}
```

### 構造体の比較
```go
import "reflect"

func TestCreateUser(t *testing.T) {
    tests := []struct {
        name  string
        input CreateUserInput
        want  *User
    }{
        {
            name:  "basic",
            input: CreateUserInput{Name: "John", Email: "john@example.com"},
            want:  &User{Name: "John", Email: "john@example.com"},
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := CreateUser(tt.input)
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("CreateUser() = %+v; want %+v", got, tt.want)
            }
        })
    }
}
```

## t.Error vs t.Fatal

### t.Error: テスト継続
```go
func TestMultipleAssertions(t *testing.T) {
    result := Process()

    if result.Status != "ok" {
        t.Errorf("Status = %q; want %q", result.Status, "ok")
    }
    if result.Count != 10 {
        t.Errorf("Count = %d; want %d", result.Count, 10)
    }
    // 両方のエラーが報告される
}
```

### t.Fatal: テスト即終了
```go
func TestWithSetup(t *testing.T) {
    db, err := setupDatabase()
    if err != nil {
        t.Fatalf("setup failed: %v", err)  // 続行不可能
    }

    // dbを使ったテスト
    result := db.Query()
    if result == nil {
        t.Error("result should not be nil")
    }
}
```

## テストヘルパー

### t.Helper()
```go
func assertEqual(t *testing.T, got, want int) {
    t.Helper()  // エラー行が呼び出し元を指す
    if got != want {
        t.Errorf("got %d; want %d", got, want)
    }
}

func TestWithHelper(t *testing.T) {
    assertEqual(t, Add(2, 3), 5)  // この行が報告される
}
```

### セットアップ/クリーンアップ
```go
func setupTestDB(t *testing.T) *Database {
    t.Helper()
    db, err := NewDatabase(":memory:")
    if err != nil {
        t.Fatalf("setup: %v", err)
    }

    t.Cleanup(func() {
        db.Close()
    })

    return db
}

func TestDatabase(t *testing.T) {
    db := setupTestDB(t)  // 自動クリーンアップ

    // テスト
}
```

## サブテスト

### 並列テスト
```go
func TestParallel(t *testing.T) {
    tests := []struct {
        name  string
        input int
    }{
        {"case1", 1},
        {"case2", 2},
        {"case3", 3},
    }

    for _, tt := range tests {
        tt := tt  // Go 1.22未満では必要
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()  // 並列実行
            result := SlowProcess(tt.input)
            if result < 0 {
                t.Errorf("unexpected negative result")
            }
        })
    }
}
```

### グループ化
```go
func TestUser(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        t.Run("valid input", func(t *testing.T) {
            // ...
        })
        t.Run("invalid input", func(t *testing.T) {
            // ...
        })
    })

    t.Run("Delete", func(t *testing.T) {
        // ...
    })
}
```

## モック

### インターフェースベース
```go
// プロダクションコード
type UserRepository interface {
    FindByID(id string) (*User, error)
}

type UserService struct {
    repo UserRepository
}

func (s *UserService) GetUser(id string) (*User, error) {
    return s.repo.FindByID(id)
}

// テストコード
type mockUserRepo struct {
    users map[string]*User
    err   error
}

func (m *mockUserRepo) FindByID(id string) (*User, error) {
    if m.err != nil {
        return nil, m.err
    }
    return m.users[id], nil
}

func TestUserService_GetUser(t *testing.T) {
    mock := &mockUserRepo{
        users: map[string]*User{
            "1": {ID: "1", Name: "John"},
        },
    }
    service := &UserService{repo: mock}

    user, err := service.GetUser("1")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "John" {
        t.Errorf("Name = %q; want %q", user.Name, "John")
    }
}
```

## HTTPテスト

### httptest.Server
```go
import (
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestHTTPClient(t *testing.T) {
    // モックサーバー作成
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(`{"status":"ok"}`))
    }))
    defer server.Close()

    // クライアントテスト
    client := NewClient(server.URL)
    resp, err := client.GetStatus()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if resp.Status != "ok" {
        t.Errorf("Status = %q; want %q", resp.Status, "ok")
    }
}
```

### httptest.ResponseRecorder
```go
func TestHandler(t *testing.T) {
    req := httptest.NewRequest("GET", "/users/1", nil)
    rec := httptest.NewRecorder()

    handler := NewUserHandler()
    handler.ServeHTTP(rec, req)

    if rec.Code != http.StatusOK {
        t.Errorf("Status = %d; want %d", rec.Code, http.StatusOK)
    }
}
```

## ベンチマーク

```go
func BenchmarkProcess(b *testing.B) {
    data := prepareData()

    b.ResetTimer()  // 準備時間を除外
    for i := 0; i < b.N; i++ {
        Process(data)
    }
}

func BenchmarkProcessParallel(b *testing.B) {
    data := prepareData()

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            Process(data)
        }
    })
}
```

```bash
go test -bench=. ./...
go test -bench=BenchmarkProcess -benchmem ./...
```

## TestMain

```go
func TestMain(m *testing.M) {
    // セットアップ
    setup()

    // テスト実行
    code := m.Run()

    // クリーンアップ
    cleanup()

    os.Exit(code)
}
```

## ベストプラクティス

| プラクティス | 説明 |
|------------|------|
| テーブル駆動 | 複数ケースを構造化して記述 |
| t.Helper() | ヘルパー関数で使用 |
| t.Parallel() | 独立したテストは並列化 |
| インターフェース | 依存性注入でモック可能に |
| t.Cleanup() | リソースの自動クリーンアップ |
| サブテスト | t.Run()で構造化 |

## アンチパターン

| パターン | 問題 | 修正 |
|---------|------|------|
| グローバル状態に依存 | テストが不安定 | 依存性注入 |
| 外部サービスに直接依存 | CI/CDで失敗 | モック/スタブ |
| 実行順序に依存 | 並列実行で失敗 | 独立したテスト |
| magic number | 意図が不明確 | 名前付き定数 |
| 巨大なテスト関数 | メンテナンス困難 | サブテストに分割 |
