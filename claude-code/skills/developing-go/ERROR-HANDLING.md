# Goエラーハンドリング

## 基本原則

### エラーは値
Goではエラーは例外ではなく値として扱う：

```go
// 常にエラーをチェック
result, err := doSomething()
if err != nil {
    return err
}

// エラーを無視しない（明示的に無視する場合のみ _ を使用）
_ = file.Close()  // 意図的な無視は明示
```

### エラーの伝播
エラーにコンテキストを追加して伝播：

```go
// Good: コンテキストを追加
func ProcessUser(id string) error {
    user, err := fetchUser(id)
    if err != nil {
        return fmt.Errorf("fetch user %s: %w", id, err)
    }

    if err := user.Validate(); err != nil {
        return fmt.Errorf("validate user %s: %w", id, err)
    }

    return nil
}

// Bad: コンテキストなし
func ProcessUser(id string) error {
    user, err := fetchUser(id)
    if err != nil {
        return err  // どこで失敗したか不明
    }
    return nil
}
```

## エラーラッピング

### %w vs %v
```go
// %w: エラーをラップ（errors.Is/Asで検査可能）
return fmt.Errorf("open config: %w", err)

// %v: エラーを文字列化（元のエラー情報は失われる）
return fmt.Errorf("open config: %v", err)
```

### 使い分け
```go
// %w を使う場合: 呼び出し側がエラー種別を判断する必要がある
func ReadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("read config file: %w", err)
        // 呼び出し側で errors.Is(err, os.ErrNotExist) が使える
    }
    return parseConfig(data)
}

// %v を使う場合: 実装詳細を隠蔽したい
func (s *Service) Process(ctx context.Context) error {
    if err := s.internalStep(); err != nil {
        return fmt.Errorf("process failed: %v", err)
        // 内部実装の詳細を外部に漏らさない
    }
    return nil
}
```

## センチネルエラー

### 定義
```go
package mypackage

import "errors"

// パッケージレベルで定義
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrInvalidInput = errors.New("invalid input")
)
```

### 使用
```go
// エラーの判定
if errors.Is(err, ErrNotFound) {
    // 404を返す
}

// switch文での判定
switch {
case errors.Is(err, ErrNotFound):
    return http.StatusNotFound
case errors.Is(err, ErrUnauthorized):
    return http.StatusUnauthorized
default:
    return http.StatusInternalServerError
}
```

## カスタムエラー型

### 構造体エラー
```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}

// 使用
func Validate(input Input) error {
    if input.Name == "" {
        return &ValidationError{
            Field:   "name",
            Message: "cannot be empty",
        }
    }
    return nil
}

// errors.Asで型アサーション
var validErr *ValidationError
if errors.As(err, &validErr) {
    fmt.Printf("Field: %s, Message: %s\n", validErr.Field, validErr.Message)
}
```

### エラーのネスト
```go
type QueryError struct {
    Query string
    Err   error
}

func (e *QueryError) Error() string {
    return fmt.Sprintf("query %s: %v", e.Query, e.Err)
}

// Unwrapを実装してエラーチェーン対応
func (e *QueryError) Unwrap() error {
    return e.Err
}
```

## panic と recover

### panicの使用
panicは**本当に回復不能な状況**でのみ使用：

```go
// Good: プログラムの前提条件違反
func MustCompileRegex(pattern string) *regexp.Regexp {
    re, err := regexp.Compile(pattern)
    if err != nil {
        panic(fmt.Sprintf("invalid regex pattern: %s", pattern))
    }
    return re
}

// 初期化時のみ使用
var emailRegex = MustCompileRegex(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

// Bad: 通常のエラー処理にpanicを使用
func GetUser(id string) *User {
    user, err := db.FindUser(id)
    if err != nil {
        panic(err)  // これはダメ
    }
    return user
}
```

### recoverの使用
```go
// HTTPハンドラでのリカバリ
func RecoveryMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err != nil {
                log.Printf("panic recovered: %v\n%s", err, debug.Stack())
                http.Error(w, "Internal Server Error", http.StatusInternalServerError)
            }
        }()
        next.ServeHTTP(w, r)
    })
}
```

## エラーハンドリングパターン

### 早期リターン
```go
// Good: ガード節
func ProcessOrder(order *Order) error {
    if order == nil {
        return errors.New("order is nil")
    }
    if order.Items == nil || len(order.Items) == 0 {
        return errors.New("order has no items")
    }
    if order.CustomerID == "" {
        return errors.New("order has no customer")
    }

    // メインロジック
    return processValidOrder(order)
}
```

### エラーのグループ化
```go
// 複数のエラーをまとめる
func ValidateUser(u *User) error {
    var errs []error

    if u.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if u.Email == "" {
        errs = append(errs, errors.New("email is required"))
    }
    if u.Age < 0 {
        errs = append(errs, errors.New("age must be non-negative"))
    }

    if len(errs) > 0 {
        return errors.Join(errs...)  // Go 1.20+
    }
    return nil
}
```

### deferでのエラーハンドリング
```go
func WriteToFile(path string, data []byte) (err error) {
    f, err := os.Create(path)
    if err != nil {
        return fmt.Errorf("create file: %w", err)
    }

    // 名前付き戻り値でdeferからエラーを設定
    defer func() {
        if cerr := f.Close(); cerr != nil && err == nil {
            err = fmt.Errorf("close file: %w", cerr)
        }
    }()

    if _, err := f.Write(data); err != nil {
        return fmt.Errorf("write data: %w", err)
    }

    return nil
}
```

## アンチパターン

| パターン | 問題 | 修正 |
|---------|------|------|
| `if err != nil { return err }` | コンテキストなし | `fmt.Errorf("context: %w", err)` |
| `panic(err)` | 通常エラーでpanic | `return err` |
| `err.Error() == "not found"` | 文字列比較 | `errors.Is(err, ErrNotFound)` |
| エラーの無視 | バグの温床 | 必ずチェックまたは明示的に`_`で無視 |
| ログ後に再度return err | 二重ログ | どちらか一方のみ |
