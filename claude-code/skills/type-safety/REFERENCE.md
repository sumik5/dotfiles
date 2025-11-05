# リファレンス：チェックリスト、ツール設定、型チェッカー

このファイルでは、型安全性を確保するための実践的なリファレンス情報を提供します。

## 📋 目次

- [型安全性チェックリスト](#型安全性チェックリスト)
- [TypeScript設定](#typescript設定)
- [Python設定](#python設定)
- [型チェッカー実行コマンド](#型チェッカー実行コマンド)
- [トラブルシューティング](#トラブルシューティング)
- [CI/CD統合](#cicd統合)

## ✅ 型安全性チェックリスト

### 実装前チェックリスト

コードを書く前に確認する項目：

- [ ] **any/Any型の使用を避ける計画か？**
  - TypeScript: `any` → `unknown` + 型ガード、または明示的な型定義
  - Python: `Any` → `Union`、`Optional`、`Protocol`、または明示的な型ヒント

- [ ] **型定義ファイルの確認**
  - 既存の型を再利用できないか確認
  - 新しい型定義が必要な場合、適切な場所に配置する計画

- [ ] **外部ライブラリの型定義**
  - TypeScript: `@types/*` パッケージの確認
  - Python: 型スタブ（`types-*`）の確認

- [ ] **型の共有範囲**
  - ローカル型で十分か、共有型として定義すべきか
  - 型定義ファイルの配置場所（`types/`、`models/`等）

### 実装中チェックリスト

コードを書いている最中に確認する項目：

#### TypeScript/JavaScript

- [ ] **strict mode有効化**
  - `tsconfig.json` で `"strict": true` が設定されているか
  - `noImplicitAny: true` が有効か

- [ ] **明示的な型注釈**
  - すべての関数の引数と戻り値に型注釈があるか
  - クラスのプロパティに型注釈があるか

- [ ] **any型の不使用**
  - `any` 型を使用していないか
  - `Function` 型を使用していないか

- [ ] **型ガードの実装**
  - `unknown` 型を使用する際は型ガードがあるか
  - カスタム型ガード関数 (`is` 型述語) を実装したか

- [ ] **オプショナルチェイニングの活用**
  - `?.` でnull/undefinedを安全に扱っているか
  - `??` (Nullish Coalescing) でデフォルト値を提供しているか

- [ ] **non-null assertion（!）の濫用回避**
  - `!` を使用している箇所は本当に必要か
  - 型ガードやオプショナルチェイニングで代替できないか

- [ ] **厳密等価演算子の使用**
  - `===` / `!==` を使用しているか（`==` / `!=` は禁止）

#### Python

- [ ] **型ヒントの徹底**
  - すべての関数の引数と戻り値に型ヒントがあるか
  - クラスの属性に型ヒントがあるか

- [ ] **Any型の不使用**
  - `Any` 型を使用していないか
  - `Union`、`Optional`、`Protocol` で代替できているか

- [ ] **TypedDictの活用**
  - 辞書型のデータには `TypedDict` を使用しているか

- [ ] **dataclassの活用**
  - データクラスには `@dataclass` を使用しているか
  - 可変デフォルト引数を避けているか（`field(default_factory=list)`）

- [ ] **Protocolの活用**
  - ダックタイピングが必要な場合は `Protocol` を使用しているか

- [ ] **型ガードの実装**
  - `TypeGuard` を使用した型ガード関数を実装したか

- [ ] **例外処理の具体化**
  - bare `except` を使用していないか
  - 具体的な例外クラスを指定しているか

### 実装後チェックリスト

コードを書き終えた後に確認する項目：

- [ ] **型チェッカーの実行**
  - TypeScript: `tsc --noEmit` でエラーがないか
  - Python: `mypy` / `pyright` でエラーがないか

- [ ] **コードレビュー観点**
  - [ ] any/Any型が使用されていないか
  - [ ] すべての関数に型注釈があるか
  - [ ] 型ガードが適切に実装されているか
  - [ ] エラーハンドリングが適切か
  - [ ] ユニットテストが型安全か

- [ ] **ドキュメントの更新**
  - 型定義のドキュメントコメントが適切か
  - 使用例が型安全か

## ⚙️ TypeScript設定

### tsconfig.json（推奨設定）

```json
{
  "compilerOptions": {
    // === 型チェック関連（必須） ===
    "strict": true,                          // すべてのstrict系フラグを有効化
    "noImplicitAny": true,                   // 暗黙的なanyを禁止
    "strictNullChecks": true,                // null/undefinedの厳密チェック
    "strictFunctionTypes": true,             // 関数型の厳密チェック
    "strictBindCallApply": true,             // bind/call/applyの型チェック
    "strictPropertyInitialization": true,    // プロパティ初期化チェック
    "noImplicitThis": true,                  // 暗黙的なthisを禁止
    "alwaysStrict": true,                    // 'use strict'を自動挿入

    // === 追加の型チェック（推奨） ===
    "noUnusedLocals": true,                  // 未使用のローカル変数を検出
    "noUnusedParameters": true,              // 未使用のパラメータを検出
    "noImplicitReturns": true,               // すべてのコードパスでreturnを強制
    "noFallthroughCasesInSwitch": true,      // switch文のfallthrough検出
    "noUncheckedIndexedAccess": true,        // インデックスアクセスをundefined許容型に
    "noImplicitOverride": true,              // オーバーライド時にoverrideキーワード必須
    "allowUnusedLabels": false,              // 未使用のラベルを禁止
    "allowUnreachableCode": false,           // 到達不能コードを禁止

    // === モジュール解決 ===
    "moduleResolution": "node",              // Node.jsスタイルのモジュール解決
    "esModuleInterop": true,                 // CommonJSとES Moduleの相互運用
    "allowSyntheticDefaultImports": true,    // デフォルトエクスポートの柔軟な扱い
    "resolveJsonModule": true,               // JSONファイルのインポート許可
    "isolatedModules": true,                 // 各ファイルを独立したモジュールとして扱う

    // === 出力設定 ===
    "target": "ES2020",                      // ECMAScriptターゲットバージョン
    "module": "ESNext",                      // モジュールコード生成方式
    "lib": ["ES2020", "DOM"],                // 使用するライブラリ
    "outDir": "./dist",                      // 出力ディレクトリ
    "rootDir": "./src",                      // ソースルートディレクトリ
    "sourceMap": true,                       // ソースマップ生成
    "declaration": true,                     // .d.ts ファイル生成
    "declarationMap": true,                  // .d.ts のソースマップ

    // === その他 ===
    "skipLibCheck": true,                    // ライブラリの型チェックをスキップ
    "forceConsistentCasingInFileNames": true // ファイル名の大文字小文字を統一
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### ESLint設定（TypeScript用）

```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "rules": {
    // any型の禁止
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "@typescript-eslint/no-unsafe-member-access": "error",
    "@typescript-eslint/no-unsafe-call": "error",
    "@typescript-eslint/no-unsafe-return": "error",

    // 型安全性の強化
    "@typescript-eslint/strict-boolean-expressions": "error",
    "@typescript-eslint/no-unnecessary-condition": "error",
    "@typescript-eslint/prefer-nullish-coalescing": "error",
    "@typescript-eslint/prefer-optional-chain": "error",

    // 命名規則
    "@typescript-eslint/naming-convention": [
      "error",
      {
        "selector": "interface",
        "format": ["PascalCase"]
      },
      {
        "selector": "typeAlias",
        "format": ["PascalCase"]
      }
    ],

    // その他
    "@typescript-eslint/explicit-function-return-type": "error",
    "@typescript-eslint/no-non-null-assertion": "warn",
    "@typescript-eslint/consistent-type-imports": "error"
  }
}
```

## 🐍 Python設定

### mypy.ini（推奨設定）

```ini
[mypy]
# === 基本設定 ===
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True

# === Any型の厳格な禁止 ===
disallow_any_unimported = True       # インポートされた型でのAny使用を禁止
disallow_any_expr = False             # 完全に厳格にする場合はTrue
disallow_any_decorated = True         # デコレータでのAny使用を禁止
disallow_any_explicit = True          # 明示的なAny使用を禁止
disallow_any_generics = True          # ジェネリクスでのAny使用を禁止
disallow_subclassing_any = True       # Anyのサブクラス化を禁止

# === 型チェックの厳格化 ===
check_untyped_defs = True            # 型ヒントなし関数もチェック
strict_optional = True                # Optionalの厳密チェック
strict_equality = True                # 等価性チェックの厳格化
strict_concatenate = True             # 文字列結合の厳格化

# === エラー・警告設定 ===
warn_redundant_casts = True          # 冗長なキャストを警告
warn_unused_ignores = True           # 未使用の# type: ignoreを警告
warn_no_return = True                # 戻り値がない関数を警告
warn_unreachable = True              # 到達不能コードを警告
warn_incomplete_stub = True          # 不完全な型スタブを警告

# === インポート設定 ===
ignore_missing_imports = False       # インポートの型定義がない場合エラー
follow_imports = normal              # インポートを追跡
namespace_packages = True            # 名前空間パッケージをサポート

# === その他 ===
pretty = True                        # エラーメッセージを見やすく
show_error_codes = True              # エラーコードを表示
show_column_numbers = True           # カラム番号を表示
show_error_context = True            # エラーコンテキストを表示

# === プラグイン ===
plugins = pydantic.mypy              # Pydantic使用時

# === サードパーティライブラリ ===
# 型定義がないライブラリは個別に設定
[mypy-pytest.*]
ignore_missing_imports = True

[mypy-requests.*]
ignore_missing_imports = True

[mypy-celery.*]
ignore_missing_imports = True

# === Pydanticプラグイン設定 ===
[pydantic-mypy]
init_forbid_extra = True
init_typed = True
warn_required_dynamic_aliases = True
```

### pyrightconfig.json（推奨設定）

```json
{
  "include": ["src"],
  "exclude": [
    "**/node_modules",
    "**/__pycache__",
    "**/.*",
    "tests"
  ],

  "typeCheckingMode": "strict",

  "reportMissingImports": true,
  "reportMissingTypeStubs": false,
  "reportImportCycles": true,
  "reportUnusedImport": true,
  "reportUnusedClass": true,
  "reportUnusedFunction": true,
  "reportUnusedVariable": true,
  "reportDuplicateImport": true,
  "reportOptionalSubscript": true,
  "reportOptionalMemberAccess": true,
  "reportOptionalCall": true,
  "reportOptionalIterable": true,
  "reportOptionalContextManager": true,
  "reportOptionalOperand": true,
  "reportTypedDictNotRequiredAccess": true,
  "reportUntypedFunctionDecorator": true,
  "reportUntypedClassDecorator": true,
  "reportUntypedBaseClass": true,
  "reportUntypedNamedTuple": true,
  "reportPrivateUsage": true,
  "reportConstantRedefinition": true,
  "reportIncompatibleMethodOverride": true,
  "reportIncompatibleVariableOverride": true,
  "reportUnnecessaryIsInstance": true,
  "reportUnnecessaryCast": true,
  "reportAssertAlwaysTrue": true,
  "reportSelfClsParameterName": true,
  "reportUnusedCoroutine": true,

  "pythonVersion": "3.11",
  "pythonPlatform": "Linux",

  "executionEnvironments": [
    {
      "root": "src",
      "pythonVersion": "3.11",
      "pythonPlatform": "Linux",
      "extraPaths": ["lib"]
    }
  ],

  "venvPath": ".",
  "venv": ".venv"
}
```

### Ruff設定（.ruff.toml）

```toml
# Pythonバージョン
target-version = "py311"

# チェック対象
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "N",      # pep8-naming
    "UP",     # pyupgrade
    "ANN",    # flake8-annotations
    "ASYNC",  # flake8-async
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "DTZ",    # flake8-datetimez
    "T10",    # flake8-debugger
    "EXE",    # flake8-executable
    "ISC",    # flake8-implicit-str-concat
    "G",      # flake8-logging-format
    "PIE",    # flake8-pie
    "T20",    # flake8-print
    "PT",     # flake8-pytest-style
    "Q",      # flake8-quotes
    "RSE",    # flake8-raise
    "RET",    # flake8-return
    "SIM",    # flake8-simplify
    "TCH",    # flake8-type-checking
    "ARG",    # flake8-unused-arguments
    "PTH",    # flake8-use-pathlib
    "ERA",    # eradicate (コメントアウトされたコード)
    "PL",     # pylint
    "TRY",    # tryceratops
    "RUF",    # Ruff-specific rules
]

# 除外するルール
ignore = [
    "ANN101",  # Missing type annotation for self
    "ANN102",  # Missing type annotation for cls
]

# 1行あたりの最大文字数
line-length = 100

# 除外するディレクトリ
exclude = [
    ".git",
    "__pycache__",
    ".venv",
    "venv",
    "build",
    "dist",
]

[per-file-ignores]
"tests/**/*.py" = [
    "S101",    # Use of assert
    "ANN201",  # Missing return type annotation
]
```

## 🚀 型チェッカー実行コマンド

### TypeScript

```bash
# 基本的な型チェック
tsc --noEmit

# watchモード（ファイル変更を監視）
tsc --noEmit --watch

# 特定のファイルのみチェック
tsc --noEmit src/main.ts

# 詳細な出力
tsc --noEmit --pretty --listFiles

# ESLintと組み合わせ
eslint --ext .ts,.tsx src/

# すべてまとめて実行
npm run type-check  # package.jsonで定義
```

**package.json scripts例**:
```json
{
  "scripts": {
    "type-check": "tsc --noEmit",
    "type-check:watch": "tsc --noEmit --watch",
    "lint": "eslint --ext .ts,.tsx src/",
    "lint:fix": "eslint --ext .ts,.tsx src/ --fix",
    "check": "npm run type-check && npm run lint"
  }
}
```

### Python

```bash
# === mypy ===
# 基本的な型チェック
mypy src/

# 厳格モード
mypy --strict src/

# 特定のファイルのみチェック
mypy src/main.py

# HTMLレポート生成
mypy --html-report ./mypy-report src/

# キャッシュをクリア
mypy --no-incremental src/

# === pyright ===
# 基本的な型チェック
pyright

# 特定のファイルのみチェック
pyright src/main.py

# 設定ファイル指定
pyright --project pyrightconfig.json

# === Ruff ===
# コードチェック
ruff check src/

# 自動修正
ruff check --fix src/

# フォーマット
ruff format src/

# === すべてまとめて実行 ===
# Makefileで管理する例
make type-check
```

**Makefile例**:
```makefile
.PHONY: type-check lint format check

type-check:
	mypy src/
	pyright

lint:
	ruff check src/

format:
	ruff format src/

check: type-check lint
	@echo "All checks passed!"
```

## 🔧 トラブルシューティング

### TypeScript

#### Q1. `Cannot find module` エラー

**問題**:
```
Cannot find module '@/types/user' or its corresponding type declarations.
```

**解決策**:
```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

#### Q2. `Object is possibly 'null'` エラー

**問題**:
```typescript
const element = document.getElementById('app')
element.textContent = 'Hello'  // エラー: Object is possibly 'null'.
```

**解決策**:
```typescript
// 方法1: 型ガード
const element = document.getElementById('app')
if (element !== null) {
  element.textContent = 'Hello'
}

// 方法2: オプショナルチェイニング
const element = document.getElementById('app')
if (element) {
  element.textContent = 'Hello'
}

// 方法3: non-null assertion（確実な場合のみ）
const element = document.getElementById('app')!
element.textContent = 'Hello'
```

#### Q3. 型の循環参照エラー

**問題**:
```
'User' implicitly has type 'any' because it does not have a type annotation and is referenced directly or indirectly in its own initializer.
```

**解決策**:
```typescript
// 悪い例
type User = {
  id: string
  friends: User[]  // 循環参照
}

// 良い例: interfaceを使用
interface User {
  id: string
  friends: User[]  // OK
}

// またはtypeで前方参照
type User = {
  id: string
  friends: Array<User>  // OK
}
```

### Python

#### Q1. `Cannot find implementation or library stub` エラー

**問題**:
```
error: Cannot find implementation or library stub for module named "requests"
```

**解決策**:
```bash
# 型スタブをインストール
pip install types-requests

# または mypy.ini で無視
[mypy-requests.*]
ignore_missing_imports = True
```

#### Q2. `Incompatible types in assignment` エラー

**問題**:
```python
def get_user() -> User:
    return None  # エラー: Incompatible return value type
```

**解決策**:
```python
from typing import Optional

def get_user() -> Optional[User]:
    return None  # OK
```

#### Q3. `Name "X" is not defined` エラー（前方参照）

**問題**:
```python
class User:
    def get_friend(self) -> User:  # エラー: Name "User" is not defined
        pass
```

**解決策**:
```python
from __future__ import annotations  # Python 3.7+

class User:
    def get_friend(self) -> User:  # OK
        pass

# またはクォートで囲む
class User:
    def get_friend(self) -> 'User':  # OK
        pass
```

## 🔄 CI/CD統合

### GitHub Actions（TypeScript）

```yaml
name: Type Check (TypeScript)

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  type-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: TypeScript type check
        run: npm run type-check

      - name: ESLint
        run: npm run lint
```

### GitHub Actions（Python）

```yaml
name: Type Check (Python)

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  type-check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install mypy pyright ruff
          pip install types-requests  # 型スタブ

      - name: mypy type check
        run: mypy src/

      - name: pyright type check
        run: pyright

      - name: Ruff lint
        run: ruff check src/
```

### pre-commit設定

#### .pre-commit-config.yaml（TypeScript）

```yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.52.0
    hooks:
      - id: eslint
        files: \.[jt]sx?$
        types: [file]
        args: ['--fix']
        additional_dependencies:
          - '@typescript-eslint/parser'
          - '@typescript-eslint/eslint-plugin'

  - repo: local
    hooks:
      - id: tsc
        name: TypeScript type check
        entry: npx tsc --noEmit
        language: system
        pass_filenames: false
        types: [typescript]
```

#### .pre-commit-config.yaml（Python）

```yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.7.0
    hooks:
      - id: mypy
        args: [--strict]
        additional_dependencies:
          - types-requests

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TYPESCRIPT.md](./TYPESCRIPT.md)** - TypeScript型安全性
- **[PYTHON.md](./PYTHON.md)** - Python型安全性
- **[ANTI-PATTERNS.md](./ANTI-PATTERNS.md)** - 避けるべきパターン
