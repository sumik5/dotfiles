# FastAPI + FastMCPガイド

## 🎯 FastAPIベストプラクティス

### アプリケーション初期化

```python
# src/main.py
from fastapi import FastAPI
from fastmcp import FastMCP
import structlog

from src.config import get_config
from src.utils.logger import setup_logging

# ロギング設定
setup_logging()
logger = structlog.get_logger()

# FastAPIアプリケーション
app = FastAPI(
    title="My API",
    description="API Description",
    version="1.0.0",
)

# FastMCPサーバー
mcp = FastMCP("My MCP Server")

@app.get("/health")
async def health_check() -> dict[str, str]:
    """ヘルスチェックエンドポイント"""
    return {"status": "healthy"}

@mcp.tool()
async def example_tool(query: str) -> str:
    """MCP Example Tool"""
    logger.info("tool_called", tool="example_tool", query=query)
    return f"Result for: {query}"

if __name__ == "__main__":
    import uvicorn
    config = get_config()
    uvicorn.run(
        app,
        host=config.host,
        port=config.port,
        log_config=None,  # structlogを使用
    )
```

## 🔧 設定管理（Pydantic Settings）

### 型安全な設定クラス

```python
# src/config.py
from functools import lru_cache
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

class Config(BaseSettings):
    """アプリケーション設定

    環境変数から自動的に読み込まれる。
    型安全性を確保し、バリデーションを実施。
    """

    # サーバー設定
    environment: str = Field(
        default="development",
        description="実行環境（development, staging, production）"
    )
    host: str = Field(default="0.0.0.0", description="サーバーホスト")
    port: int = Field(default=8080, description="サーバーポート")
    log_level: str = Field(default="INFO", description="ログレベル")

    # Google OAuth設定
    google_client_id: str = Field(..., description="Google Client ID")
    google_client_secret: str = Field(..., description="Google Client Secret")
    google_redirect_uri: str = Field(..., description="OAuth Redirect URI")
    allowed_email_domain: str = Field(..., description="許可するメールドメイン")

    # GCP設定
    gcp_project_id: str = Field(..., description="GCP Project ID")
    bigquery_dataset: str = Field(..., description="BigQuery Dataset")

    # セッション設定
    session_secret_key: str = Field(
        ...,
        min_length=32,
        description="セッション暗号化キー（32文字以上）"
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,  # 環境変数名の大文字小文字を区別しない
    )

@lru_cache
def get_config() -> Config:
    """設定をキャッシュして返す

    アプリケーション起動時に1回だけ読み込まれる。
    テスト時はキャッシュをクリアする必要がある。
    """
    return Config()
```

**設計原則：**
- **型安全性**: すべてのフィールドに型アノテーション
- **バリデーション**: Fieldでバリデーションルール定義
- **キャッシング**: `@lru_cache`で設定を1回だけ読み込み
- **説明**: `description`で各設定の意味を明記

## 🛡️ 依存性注入（DI）パターン

### FastAPIの依存性注入

```python
# src/repositories/user_repository.py
from typing import AsyncIterator
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from src.config import get_config

# データベースエンジン
config = get_config()
async_engine = create_async_engine(
    config.database_url,
    echo=config.environment == "development",
)

AsyncSessionLocal = sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db() -> AsyncIterator[AsyncSession]:
    """データベースセッションを提供する依存性"""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

```python
# src/api/users.py
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.repositories.user_repository import get_db
from src.models.user import User, CreateUserRequest

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=User)
async def create_user(
    request: CreateUserRequest,
    db: AsyncSession = Depends(get_db),
) -> User:
    """新規ユーザー作成"""
    # ビジネスロジック
    ...
```

**メリット：**
- テストが容易（モックに差し替え可能）
- 責任の分離
- コードの再利用性

## 📊 Pydanticモデル活用

### リクエスト/レスポンスモデル

```python
# src/models/user.py
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field

class UserBase(BaseModel):
    """ユーザー基本情報"""
    email: EmailStr = Field(..., description="メールアドレス")
    name: str = Field(..., min_length=1, max_length=100, description="ユーザー名")

class CreateUserRequest(UserBase):
    """ユーザー作成リクエスト"""
    password: str = Field(..., min_length=8, description="パスワード")

class User(UserBase):
    """ユーザーレスポンス（パスワードなし）"""
    id: int = Field(..., description="ユーザーID")
    created_at: datetime = Field(..., description="作成日時")

    class Config:
        from_attributes = True  # ORMモデルからの変換を許可
```

**設計原則：**
- **継承**: 共通フィールドは基底クラスに
- **分離**: リクエストとレスポンスで異なるモデル
- **セキュリティ**: レスポンスにパスワードを含めない

## 🚨 エラーハンドリング

### カスタム例外とエラーハンドラ

```python
# src/utils/exceptions.py
class AppException(Exception):
    """アプリケーション基底例外"""
    def __init__(self, message: str, status_code: int = 500) -> None:
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class UserNotFoundError(AppException):
    """ユーザーが見つからない"""
    def __init__(self, user_id: int) -> None:
        super().__init__(
            message=f"User not found: {user_id}",
            status_code=404,
        )

class AuthenticationError(AppException):
    """認証エラー"""
    def __init__(self, message: str = "Authentication failed") -> None:
        super().__init__(message=message, status_code=401)
```

```python
# src/main.py
from fastapi import Request
from fastapi.responses import JSONResponse

from src.utils.exceptions import AppException

@app.exception_handler(AppException)
async def app_exception_handler(
    request: Request,
    exc: AppException,
) -> JSONResponse:
    """アプリケーション例外のハンドリング"""
    logger.error(
        "app_exception",
        exception=exc.__class__.__name__,
        message=exc.message,
        status_code=exc.status_code,
        path=request.url.path,
    )
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.__class__.__name__,
            "message": exc.message,
        },
    )
```

## 🔐 認証/認可パターン

### Google OAuth実装例

```python
# src/auth/oauth.py
from typing import Any
from google.auth.transport import requests
from google.oauth2 import id_token

from src.config import get_config
from src.utils.exceptions import AuthenticationError

async def verify_google_token(token: str) -> dict[str, Any]:
    """GoogleトークンをIDトークンとして検証"""
    config = get_config()

    try:
        # トークン検証
        idinfo = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            config.google_client_id,
        )

        # メールドメイン検証
        email = idinfo.get("email", "")
        if not email.endswith(f"@{config.allowed_email_domain}"):
            raise AuthenticationError(
                f"Email domain not allowed: {email}"
            )

        return idinfo

    except ValueError as e:
        raise AuthenticationError(f"Invalid token: {e}") from e
```

```python
# src/auth/middleware.py
from fastapi import Depends, Header

from src.auth.oauth import verify_google_token

async def get_current_user(
    authorization: str = Header(...),
) -> dict[str, Any]:
    """認証済みユーザーを取得する依存性"""
    if not authorization.startswith("Bearer "):
        raise AuthenticationError("Invalid authorization header")

    token = authorization.removeprefix("Bearer ")
    return await verify_google_token(token)
```

## 🏗️ FastMCP実装パターン

### MCP Toolの定義

```python
# src/server/app.py
from fastmcp import FastMCP
from pydantic import BaseModel, Field

mcp = FastMCP("Database Query MCP")

class QueryResult(BaseModel):
    """クエリ結果"""
    rows: list[dict[str, Any]] = Field(..., description="結果行")
    count: int = Field(..., description="件数")

@mcp.tool()
async def execute_query(
    query: str = Field(..., description="実行するSQLクエリ"),
) -> QueryResult:
    """データベースクエリを実行

    Args:
        query: SQLクエリ文字列

    Returns:
        クエリ結果

    Raises:
        ValueError: クエリが不正な場合
    """
    # クエリ実行ロジック
    ...
```

**設計原則：**
- **型アノテーション**: すべてのパラメータに型とdescription
- **Pydanticモデル**: 複雑な戻り値はモデル化
- **docstring**: 明確な説明とExamples

### MCP Resourceの定義

```python
@mcp.resource("config://settings")
async def get_settings() -> str:
    """現在の設定を返す"""
    config = get_config()
    return f"Environment: {config.environment}\nLog Level: {config.log_level}"
```

## 📝 構造化ロギング

### structlogのセットアップ

```python
# src/utils/logger.py
import structlog
from src.config import get_config

def setup_logging() -> None:
    """構造化ロギングを設定"""
    config = get_config()

    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.stdlib.BoundLogger,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )
```

### ロギングの使用例

```python
import structlog

logger = structlog.get_logger()

# コンテキスト付きログ
logger.info(
    "user_created",
    user_id=user.id,
    email=user.email,
    environment=config.environment,
)

# エラーログ
logger.error(
    "database_error",
    error=str(e),
    query=query,
    exc_info=True,
)
```

## 🔗 関連ドキュメント

- **[PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md)**: ディレクトリ構成
- **[TESTING.md](./TESTING.md)**: FastAPI/FastMCPのテスト方法
- **[TOOLING.md](./TOOLING.md)**: pyproject.toml設定
- **[EXAMPLES.md](./EXAMPLES.md)**: より詳細なコード例
