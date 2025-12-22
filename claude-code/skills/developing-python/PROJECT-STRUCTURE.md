# Pythonプロジェクト構造

## 🎯 推奨ディレクトリ構成

### src/パッケージレイアウト（推奨）

```
my-project/
├── pyproject.toml          # プロジェクト設定とメタデータ
├── uv.lock                 # 依存関係のロックファイル
├── README.md               # プロジェクト概要
├── .env.example            # 環境変数のテンプレート
├── .env                    # 環境変数（.gitignore対象）
├── Dockerfile              # コンテナイメージ定義
├── .dockerignore           # Docker除外設定
├── .mise.toml              # ツールバージョン管理（オプション）
├── .gitignore              # Git除外設定
│
├── src/                    # ソースコード
│   ├── __init__.py
│   ├── main.py             # エントリーポイント（FastAPI app等）
│   ├── config.py           # 設定管理（pydantic-settings）
│   │
│   ├── server/             # MCPサーバー関連
│   │   ├── __init__.py
│   │   ├── app.py          # FastMCPアプリケーション
│   │   └── tools/          # MCPツール定義
│   │       ├── __init__.py
│   │       └── example_tool.py
│   │
│   ├── models/             # データモデル（Pydantic）
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── request.py
│   │
│   ├── repositories/       # データアクセス層
│   │   ├── __init__.py
│   │   └── user_repository.py
│   │
│   ├── services/           # ビジネスロジック層
│   │   ├── __init__.py
│   │   └── user_service.py
│   │
│   ├── utils/              # 共通ユーティリティ
│   │   ├── __init__.py
│   │   ├── logger.py       # structlogラッパー
│   │   └── exceptions.py   # カスタム例外
│   │
│   └── auth/               # 認証/認可
│       ├── __init__.py
│       ├── oauth.py
│       └── middleware.py
│
├── tests/                  # テストコード
│   ├── __init__.py
│   ├── conftest.py         # pytest設定とfixture
│   │
│   ├── unit/               # 単体テスト
│   │   ├── __init__.py
│   │   ├── test_models.py
│   │   ├── test_repositories.py
│   │   └── test_services.py
│   │
│   ├── integration/        # 統合テスト
│   │   ├── __init__.py
│   │   └── test_api.py
│   │
│   └── utils/              # テスト用ユーティリティ
│       ├── __init__.py
│       └── fixtures.py
│
└── docs/                   # ドキュメント
    ├── architecture.md     # アーキテクチャ設計
    ├── api.md              # API仕様
    └── deployment.md       # デプロイ手順
```

## 📁 ディレクトリの役割

### src/ ディレクトリ
**すべてのソースコードをsrc/配下に配置する理由：**
- インポートパスが明確になる（`from src.models import User`）
- テストコードとの分離が容易
- ビルド時のパッケージング が簡潔
- ルートディレクトリが整理される

### models/ - データモデル
**Pydanticモデルを定義：**
```python
# src/models/user.py
from pydantic import BaseModel, EmailStr, Field

class User(BaseModel):
    """ユーザーモデル"""
    id: int = Field(..., description="ユーザーID")
    email: EmailStr = Field(..., description="メールアドレス")
    name: str = Field(..., min_length=1, max_length=100)

    class Config:
        # Pydantic v2の設定
        from_attributes = True  # ORMモデルからの変換を許可
```

**設計原則：**
- バリデーションルールを明確に定義
- ドメインモデルとリクエスト/レスポンスモデルを分離
- `Any`型を使用しない（`enforcing-type-safety`スキル参照）

### repositories/ - データアクセス層
**データベースアクセスを抽象化：**
```python
# src/repositories/user_repository.py
from typing import Protocol

class UserRepository(Protocol):
    """ユーザーリポジトリのインターフェース"""
    async def find_by_id(self, user_id: int) -> User | None: ...
    async def create(self, user: User) -> User: ...
```

**設計原則：**
- インターフェース（Protocol）を定義
- ビジネスロジックからデータアクセスを分離
- SQLAlchemy 2.0のasync APIを活用

### services/ - ビジネスロジック層
**ドメインロジックを実装：**
```python
# src/services/user_service.py
from src.repositories.user_repository import UserRepository
from src.models.user import User

class UserService:
    """ユーザーサービス"""

    def __init__(self, repository: UserRepository) -> None:
        self._repository = repository

    async def register_user(self, email: str, name: str) -> User:
        """新規ユーザー登録"""
        # ビジネスロジックを実装
        ...
```

**設計原則：**
- 依存性注入（DI）を活用
- 単一責任の原則（SRP）を遵守
- テストしやすい設計

### server/ - MCPサーバー
**FastMCPアプリケーション：**
```python
# src/server/app.py
from fastmcp import FastMCP

mcp = FastMCP("My MCP Server")

@mcp.tool()
async def example_tool(query: str) -> str:
    """ツールの説明"""
    return f"Result for: {query}"
```

### utils/ - 共通ユーティリティ
**横断的関心事を実装：**
- `logger.py`: 構造化ロギング（structlog）
- `exceptions.py`: カスタム例外
- `validation.py`: 共通バリデーション

### tests/ ディレクトリ
**テストコードを分類：**
- `unit/`: 単体テスト（高速、外部依存なし）
- `integration/`: 統合テスト（データベース等を含む）
- `conftest.py`: 共通fixture、pytest設定

詳細は `TESTING.md` を参照してください。

## 📄 重要な設定ファイル

### pyproject.toml
プロジェクトのメタデータと依存関係を定義します。
詳細は `TOOLING.md` を参照してください。

### .env と .env.example
**環境変数管理：**
```bash
# .env.example（リポジトリにコミット）
ENVIRONMENT=development
LOG_LEVEL=DEBUG
DATABASE_URL=postgresql://user:pass@localhost/dbname
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com

# .env（.gitignore対象）
ENVIRONMENT=production
LOG_LEVEL=INFO
DATABASE_URL=postgresql://prod-user:secret@prod-host/prod-db
GOOGLE_CLIENT_ID=real-client-id.apps.googleusercontent.com
```

**重要な原則：**
- `.env`は絶対にコミットしない
- `.env.example`でテンプレートを提供
- `pydantic-settings`で型安全に読み込み

### Dockerfile
マルチステージビルドでイメージを最適化します。
詳細は `DOCKER.md` を参照してください。

## 🔒 .gitignore の重要項目

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
.Python

# 仮想環境
.venv/
venv/
env/

# 環境変数（重要）
.env
.env.local

# IDE
.vscode/
.idea/
*.swp

# テスト/カバレッジ
.pytest_cache/
.coverage
htmlcov/

# ビルド成果物
dist/
build/
*.egg-info/

# ログ
*.log

# OS
.DS_Store
Thumbs.db
```

## 📝 ベストプラクティス

### 1. インポート順序（ruffが自動整形）
```python
# 標準ライブラリ
import os
from typing import Any

# サードパーティ
from fastapi import FastAPI
from pydantic import BaseModel

# プロジェクト内
from src.config import get_config
from src.models.user import User
```

### 2. モジュール分割の基準
- **1ファイル = 1つの責任**
- ファイルサイズは300行以下を目安
- 関連する機能はサブパッケージにまとめる

### 3. 命名規則
- **ファイル名**: `snake_case.py`
- **クラス名**: `PascalCase`
- **関数/変数**: `snake_case`
- **定数**: `UPPER_SNAKE_CASE`

### 4. __init__.py の活用
```python
# src/models/__init__.py
from src.models.user import User
from src.models.request import CreateUserRequest

__all__ = ["User", "CreateUserRequest"]
```

**メリット：**
- インポートが簡潔になる: `from src.models import User`
- パッケージの公開APIを明示

## 🔗 関連ドキュメント

- **[FASTAPI-GUIDE.md](./FASTAPI-GUIDE.md)**: FastAPI実装パターン
- **[TESTING.md](./TESTING.md)**: テスト構造の詳細
- **[TOOLING.md](./TOOLING.md)**: pyproject.toml設定
- **[DOCKER.md](./DOCKER.md)**: Dockerfile構成
