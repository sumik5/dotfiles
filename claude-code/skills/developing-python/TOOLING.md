# 開発ツール（uv + ruff + mypy）

## 🚀 uv - 超高速パッケージマネージャー

### uvとは
- **Rust製の超高速パッケージマネージャー**
- pip/pip-tools/virtualenvの代替
- 10-100倍高速な依存関係解決
- プロジェクト管理とビルドを統合

### インストール

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Homebrewの場合
brew install uv
```

### 基本コマンド

```bash
# プロジェクト初期化
uv init

# 依存関係インストール（uv.lockから）
uv sync --frozen

# 開発依存関係を含む
uv sync --frozen --all-extras

# パッケージ追加
uv add fastapi pydantic
uv add --dev pytest pytest-cov

# パッケージ削除
uv remove package-name

# Pythonコマンド実行
uv run python script.py
uv run pytest
uv run mypy src/

# Python仮想環境をアクティベート（手動実行したい場合）
source .venv/bin/activate  # macOS/Linux
.venv\Scripts\activate     # Windows
```

## 📝 pyproject.toml - プロジェクト設定

### 完全な設定例（実際のプロジェクトから抽出）

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-project"
version = "1.0.0"
description = "Project Description"
readme = "README.md"
requires-python = ">=3.13"
license = {text = "Proprietary"}
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]

dependencies = [
    # MCP SDK
    "mcp[cli]>=1.17.0",
    "fastmcp>=2.12.0",

    # Web framework
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.37.0",

    # Data validation
    "pydantic>=2.9.0",
    "pydantic-settings>=2.6.0",

    # Database
    "sqlalchemy>=2.0.0",

    # Utilities
    "python-dotenv>=1.0.0",
    "structlog>=24.4.0",
]

[project.optional-dependencies]
dev = [
    # Build tools
    "hatchling>=1.18.0",

    # Testing
    "pytest>=8.3.0",
    "pytest-asyncio>=0.24.0",
    "pytest-mock>=3.14.0",
    "pytest-cov>=5.0.0",
    "httpx>=0.27.0",

    # Code quality
    "ruff>=0.7.0",
    "mypy>=1.13.0",

    # Type stubs
    "types-requests>=2.31.0",
]

# ==============================================================================
# Pytest設定
# ==============================================================================
[tool.pytest.ini_options]
minversion = "8.0"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "-v",
    "--strict-markers",
    "--tb=short",
    "--cov=src",
    "--cov-report=html",
    "--cov-report=term-missing",
    "--cov-fail-under=80",
    "-p", "no:warnings",
]
markers = [
    "unit: Unit tests",
    "integration: Integration tests",
    "slow: Slow running tests",
    "skip_ci: Skip in CI environment",
]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"

# ==============================================================================
# Coverage設定
# ==============================================================================
[tool.coverage.run]
source = ["src"]
omit = [
    "*/tests/*",
    "*/__pycache__/*",
    "*/venv/*",
    "*/.venv/*",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
    "@abstractmethod",
    "@abc.abstractmethod",
]
precision = 2
show_missing = true

# ==============================================================================
# Ruff設定（Linter + Formatter）
# ==============================================================================
[tool.ruff]
line-length = 100
target-version = "py313"

# 除外ディレクトリ
extend-exclude = [
    ".eggs",
    ".git",
    ".mypy_cache",
    ".pytest_cache",
    ".tox",
    ".venv",
    "venv",
    "_build",
    "buck-out",
    "build",
    "dist",
]

[tool.ruff.lint]
# 有効化するルール
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort（インポート順序）
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "SIM",  # flake8-simplify
]

# 無視するルール
ignore = [
    "E203",  # whitespace before ':'
    "E501",  # line too long（formatterが処理）
]

# 自動修正を許可
fixable = ["ALL"]
unfixable = []

# ファイルごとの除外設定
[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]  # 未使用インポートを許可
"src/config.py" = ["N805"]  # Pydantic validator命名
"tests/conftest.py" = ["N806", "E402"]  # テスト設定
"tests/**/*.py" = ["N806"]  # Mock変数の命名

[tool.ruff.format]
quote-style = "double"  # ダブルクォート使用
indent-style = "space"  # スペースインデント
skip-magic-trailing-comma = false  # マジックカンマを尊重
line-ending = "auto"  # 改行コードの自動検出

# ==============================================================================
# MyPy設定（型チェッカー）
# ==============================================================================
[tool.mypy]
python_version = "3.13"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = false  # 徐々にtrueに移行
disallow_incomplete_defs = false
check_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = false
warn_no_return = true
strict_equality = true
ignore_missing_imports = true  # サードパーティの型不足を許容
explicit_package_bases = true
exclude = ["^build/", "^dist/", "^\\.venv/"]

# サードパーティパッケージの型エラーを無視
[[tool.mypy.overrides]]
module = [
    "google.cloud.*",
    "google.auth.*",
]
ignore_missing_imports = true

# ==============================================================================
# Hatchling（ビルド設定）
# ==============================================================================
[tool.hatch.build.targets.wheel]
packages = ["src"]

[tool.hatch.build.targets.sdist]
include = [
    "/src",
    "/tests",
]
```

## 🎨 ruff - 最速Linter + Formatter

### ruffとは
- **Rust製の超高速linter + formatter**
- flake8、isort、black等を統合
- 自動修正機能が強力

### 基本コマンド

```bash
# Lint実行
uv run ruff check .

# Lint + 自動修正
uv run ruff check --fix .

# Format実行
uv run ruff format .

# Lint + Format（推奨）
uv run ruff check --fix . && uv run ruff format .
```

### VS Code統合

```json
// .vscode/settings.json
{
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  },
  "ruff.lint.args": ["--config=pyproject.toml"],
  "ruff.format.args": ["--config=pyproject.toml"]
}
```

### 重要なルール

- **E**: pycodestyleエラー（PEP 8違反）
- **F**: pyflakes（未使用変数、インポート等）
- **I**: isort（インポート順序）
- **N**: pep8-naming（命名規則）
- **UP**: pyupgrade（新しいPython文法への自動アップグレード）
- **B**: flake8-bugbear（潜在的バグ）
- **SIM**: flake8-simplify（簡潔なコード）

## 🔍 mypy - 型チェッカー

### mypyとは
- **静的型チェックツール**
- 型エラーを実行前に検出
- 型安全性を確保（`enforcing-type-safety`スキル参照）

### 基本コマンド

```bash
# 型チェック実行
uv run mypy src/

# 特定ファイルのみ
uv run mypy src/main.py

# 厳格モード（段階的に導入）
uv run mypy --strict src/
```

### 段階的導入戦略

**Level 1: 基本的な型チェック（現在の設定）**
```toml
[tool.mypy]
disallow_untyped_defs = false
check_untyped_defs = true
ignore_missing_imports = true
```

**Level 2: 中程度の厳格さ（次のステップ）**
```toml
[tool.mypy]
disallow_untyped_defs = true  # 関数に型アノテーション必須
disallow_incomplete_defs = true
no_implicit_optional = true
```

**Level 3: 厳格モード（目標）**
```toml
[tool.mypy]
strict = true  # すべての厳格チェックを有効化
```

### 型アノテーションの例

```python
from typing import Any

# ❌ 悪い例（any型使用）
def process_data(data: Any) -> Any:
    return data

# ✅ 良い例（具体的な型）
def process_data(data: dict[str, int]) -> list[int]:
    return list(data.values())

# ✅ Genericsを使用
from typing import TypeVar

T = TypeVar("T")

def first_element(items: list[T]) -> T | None:
    return items[0] if items else None
```

## 🛠️ mise.toml - ツールバージョン管理（オプション）

### mise（旧rtx）とは
- **複数言語のバージョン管理ツール**
- asdf互換（より高速）
- Python、Node.js等のバージョンをプロジェクトごとに管理

### インストール

```bash
# macOS
brew install mise

# その他
curl https://mise.run | sh
```

### mise.toml設定例

```toml
# .mise.toml
[tools]
python = "3.13"  # Pythonバージョン固定

[env]
# 環境変数設定（オプション）
_.path = ["./bin", "$PATH"]
```

### 基本コマンド

```bash
# ツールのインストール
mise install

# Pythonバージョン確認
mise current python

# 別バージョンに切り替え
mise use python@3.12
```

**注意**: miseはオプションです。uvだけでも十分に動作します。

## 🔄 pre-commit設定（推奨）

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.7.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.13.0
    hooks:
      - id: mypy
        additional_dependencies:
          - pydantic>=2.9.0
          - types-requests

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

### セットアップ

```bash
# pre-commitインストール
uv add --dev pre-commit

# フックインストール
uv run pre-commit install

# 手動実行
uv run pre-commit run --all-files
```

## 📊 開発ワークフロー

### 日常的な開発サイクル

```bash
# 1. コード編集
# ...

# 2. 自動修正（Lint + Format）
uv run ruff check --fix . && uv run ruff format .

# 3. 型チェック
uv run mypy src/

# 4. テスト実行
uv run pytest

# 5. コミット（pre-commitが自動実行）
git commit -m "feat: add new feature"
```

### CI/CD用コマンド

```bash
# すべてのチェックを一度に実行
uv run ruff check . && \
uv run ruff format --check . && \
uv run mypy src/ && \
uv run pytest --cov-fail-under=80
```

## 🔗 関連ドキュメント

- **[PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md)**: pyproject.tomlの配置場所
- **[TESTING.md](./TESTING.md)**: pytest設定の詳細
- **[DOCKER.md](./DOCKER.md)**: uvを使用したDockerビルド
