# Go並行処理

## 設計哲学

> "Do not communicate by sharing memory; instead, share memory by communicating."
> （メモリを共有して通信するのではなく、通信によってメモリを共有せよ）

## goroutine

### 基本
```go
// goroutineの起動
go func() {
    // 並行処理
}()

// 関数をgoroutineで実行
go process(data)
```

### goroutineの終了管理
```go
// Bad: goroutineがリークする可能性
func serve() {
    go func() {
        for {
            handleRequest()  // 終了条件がない
        }
    }()
}

// Good: contextでキャンセル可能
func serve(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return  // 終了
            default:
                handleRequest()
            }
        }
    }()
}
```

## チャネル

### 基本操作
```go
// 作成
ch := make(chan int)        // バッファなし
ch := make(chan int, 10)    // バッファあり

// 送信
ch <- 42

// 受信
value := <-ch

// クローズ
close(ch)
```

### チャネルの方向
```go
// 送信専用
func producer(out chan<- int) {
    out <- 42
}

// 受信専用
func consumer(in <-chan int) {
    value := <-in
}

// 双方向（関数内で方向を制限）
func worker(jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        results <- process(job)
    }
}
```

### パターン: ワーカープール
```go
func workerPool(ctx context.Context, jobs <-chan Job, numWorkers int) <-chan Result {
    results := make(chan Result)

    var wg sync.WaitGroup
    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for {
                select {
                case <-ctx.Done():
                    return
                case job, ok := <-jobs:
                    if !ok {
                        return
                    }
                    results <- process(job)
                }
            }
        }()
    }

    go func() {
        wg.Wait()
        close(results)
    }()

    return results
}
```

### パターン: Fan-out/Fan-in
```go
// Fan-out: 1つのチャネルから複数のワーカーが読み取り
func fanOut(in <-chan int, n int) []<-chan int {
    outs := make([]<-chan int, n)
    for i := 0; i < n; i++ {
        outs[i] = worker(in)
    }
    return outs
}

// Fan-in: 複数のチャネルを1つにまとめる
func fanIn(channels ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup

    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan int) {
            defer wg.Done()
            for v := range c {
                out <- v
            }
        }(ch)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

## select文

### 基本
```go
select {
case msg := <-ch1:
    fmt.Println("received from ch1:", msg)
case msg := <-ch2:
    fmt.Println("received from ch2:", msg)
case ch3 <- value:
    fmt.Println("sent to ch3")
default:
    fmt.Println("no channel ready")
}
```

### タイムアウト
```go
select {
case result := <-resultCh:
    return result, nil
case <-time.After(5 * time.Second):
    return nil, errors.New("timeout")
}
```

### contextとの組み合わせ
```go
func doWork(ctx context.Context) error {
    resultCh := make(chan Result)

    go func() {
        resultCh <- heavyComputation()
    }()

    select {
    case result := <-resultCh:
        return processResult(result)
    case <-ctx.Done():
        return ctx.Err()
    }
}
```

## 同期プリミティブ

### sync.Mutex
```go
type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

func (c *Counter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}
```

### sync.RWMutex
```go
type Cache struct {
    mu   sync.RWMutex
    data map[string]string
}

func (c *Cache) Get(key string) (string, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    v, ok := c.data[key]
    return v, ok
}

func (c *Cache) Set(key, value string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = value
}
```

### sync.WaitGroup
```go
func processAll(items []Item) {
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            process(item)
        }(item)
    }

    wg.Wait()  // 全てのgoroutineが完了するまで待機
}
```

### sync.Once
```go
var (
    instance *Singleton
    once     sync.Once
)

func GetInstance() *Singleton {
    once.Do(func() {
        instance = &Singleton{}
        instance.init()
    })
    return instance
}
```

### sync.Pool
```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return make([]byte, 1024)
    },
}

func process() {
    buf := bufferPool.Get().([]byte)
    defer bufferPool.Put(buf)

    // bufを使用
}
```

## context

### 基本的な使い方
```go
// Background: ルートcontext
ctx := context.Background()

// TODO: 未確定のcontext（後で置き換え）
ctx := context.TODO()

// キャンセル可能
ctx, cancel := context.WithCancel(context.Background())
defer cancel()

// タイムアウト付き
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

// デッドライン付き
ctx, cancel := context.WithDeadline(context.Background(), time.Now().Add(time.Hour))
defer cancel()
```

### 値の伝播
```go
type contextKey string

const userIDKey contextKey = "userID"

// 値の設定
ctx := context.WithValue(ctx, userIDKey, "user-123")

// 値の取得
if userID, ok := ctx.Value(userIDKey).(string); ok {
    fmt.Println("User ID:", userID)
}
```

### HTTPハンドラでの使用
```go
func handler(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()

    result, err := doWork(ctx)
    if err != nil {
        if errors.Is(err, context.Canceled) {
            // クライアントがキャンセル
            return
        }
        if errors.Is(err, context.DeadlineExceeded) {
            http.Error(w, "Timeout", http.StatusGatewayTimeout)
            return
        }
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(result)
}
```

## ベストプラクティス

### goroutineリークを防ぐ
```go
// Good: contextでキャンセル可能
func stream(ctx context.Context) <-chan Data {
    ch := make(chan Data)
    go func() {
        defer close(ch)
        for {
            select {
            case <-ctx.Done():
                return
            case ch <- fetchData():
            }
        }
    }()
    return ch
}
```

### チャネルの所有者がクローズ
```go
// 送信者がチャネルをクローズ
func producer() <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)  // 送信者がクローズ
        for i := 0; i < 10; i++ {
            ch <- i
        }
    }()
    return ch
}
```

### バッファサイズの考慮
```go
// バッファなし: 同期的通信
ch := make(chan int)

// バッファあり: 非同期的（送信者がブロックしない）
ch := make(chan int, 100)

// バッファサイズは予想される最大値か、制限のために設定
```

## アンチパターン

| パターン | 問題 | 修正 |
|---------|------|------|
| ループ変数をgoroutineで直接参照 | レースコンディション | 引数で渡す |
| contextなしのgoroutine | リーク | context.WithCancelを使用 |
| nilチャネルへの送受信 | 永久ブロック | 必ず初期化 |
| closeしたチャネルへの送信 | panic | 送信者のみがclose |
| 共有変数の非同期アクセス | データレース | Mutex/チャネル使用 |

### ループ変数の落とし穴
```go
// Bad: 全てのgoroutineが同じiを参照
for i := 0; i < 10; i++ {
    go func() {
        fmt.Println(i)  // 予期しない値
    }()
}

// Good: 引数で渡す
for i := 0; i < 10; i++ {
    go func(n int) {
        fmt.Println(n)  // 正しい値
    }(i)
}

// Go 1.22+: ループ変数のセマンティクス変更により修正済み
```
