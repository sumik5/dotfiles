# Python型安全性詳細

このファイルでは、Pythonにおける型安全性の詳細なガイドラインを説明します。

## 📋 目次

- [Any型の絶対禁止](#any型の絶対禁止)
- [正しい型ヒント方法](#正しい型ヒント方法)
- [Pythonベストプラクティス](#pythonベストプラクティス)
- [TypedDictの活用](#typeddictの活用)
- [Protocolの活用](#protocolの活用)
- [dataclassの活用](#dataclassの活用)
- [型チェッカーの使用](#型チェッカーの使用)

## 🚫 Any型の絶対禁止

### ❌ 絶対に使用してはいけないパターン

#### パターン1: Any型の直接使用

```python
# ❌ 悪い例
from typing import Any

def process_data(data: Any) -> Any:
    return data.get('value')  # 型安全性が失われる

result: Any = fetch_data()  # 型チェックが無効化される
```

**問題点**:
- Pythonの型チェックが完全に無効化される
- ランタイムエラーの原因になる
- IDEの補完が効かない
- リファクタリングが困難になる

#### パターン2: bare exceptの使用

```python
# ❌ 悪い例
try:
    result = risky_operation()
except:  # すべての例外をキャッチ（Any型と同等）
    pass
```

**問題点**:
- 想定外の例外もキャッチしてしまう
- デバッグが困難
- KeyboardInterrupt等のシステム例外もキャッチ

**正しい方法**:
```python
# ✅ 良い例
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
except KeyError as e:
    logger.error(f"Missing key: {e}")
```

#### パターン3: eval/exec の使用

```python
# ❌ 絶対禁止
user_input = request.get('code')
eval(user_input)  # セキュリティリスク、型安全性ゼロ
exec(user_input)  # 同様に危険
```

**問題点**:
- 重大なセキュリティリスク
- 型チェック不可能
- デバッグ不可能

## ✅ 正しい型ヒント方法

### 1. 明示的な型ヒント（必須）

```python
# ✅ すべての関数に型ヒント
from typing import Optional, List, Dict

def get_user_by_id(user_id: str) -> Optional[User]:
    """ユーザーをIDで取得"""
    # 実装
    pass

def get_all_users() -> List[User]:
    """全ユーザーを取得"""
    # 実装
    return []

def get_user_settings(user_id: str) -> Dict[str, str]:
    """ユーザー設定を取得"""
    # 実装
    return {}
```

### 2. Union型の使用

```python
from typing import Union

# ✅ 複数の型を許可する場合
def process_value(value: Union[int, str]) -> str:
    if isinstance(value, int):
        return str(value)
    return value

# Python 3.10以降は | 演算子も使用可能
def process_value_modern(value: int | str) -> str:
    if isinstance(value, int):
        return str(value)
    return value
```

### 3. Optional型の明示

```python
from typing import Optional

# ✅ Noneの可能性がある場合
def find_user(user_id: str) -> Optional[User]:
    user = db.query(User).filter_by(id=user_id).first()
    return user  # User | None

# 使用時は必ずNoneチェック
user = find_user('123')
if user is not None:
    print(user.name)  # 型安全
```

### 4. Generic型の使用

```python
from typing import TypeVar, Generic, List

T = TypeVar('T')

class Repository(Generic[T]):
    def __init__(self, model: type[T]) -> None:
        self.model = model

    def find_by_id(self, id: str) -> Optional[T]:
        # 実装
        pass

    def find_all(self) -> List[T]:
        # 実装
        return []

# 使用例
user_repo = Repository[User](User)
user = user_repo.find_by_id('123')  # Optional[User]
users = user_repo.find_all()  # List[User]
```

## 📚 Pythonベストプラクティス

### 1. 型ヒントの徹底

```python
# ✅ すべての関数シグネチャに型ヒント
def calculate_total(
    items: List[Dict[str, float]],
    tax_rate: float = 0.1
) -> float:
    """合計金額を計算（税込み）"""
    subtotal = sum(item['price'] for item in items)
    return subtotal * (1 + tax_rate)

# ✅ クラスの属性にも型ヒント
class User:
    id: str
    name: str
    email: str
    age: int
    is_active: bool

    def __init__(
        self,
        id: str,
        name: str,
        email: str,
        age: int,
        is_active: bool = True
    ) -> None:
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.is_active = is_active
```

### 2. 型ガードの使用

```python
from typing import TypeGuard

def is_user_dict(data: object) -> TypeGuard[Dict[str, str]]:
    """辞書がUser型かチェック"""
    return (
        isinstance(data, dict) and
        'id' in data and isinstance(data['id'], str) and
        'name' in data and isinstance(data['name'], str) and
        'email' in data and isinstance(data['email'], str)
    )

# 使用例
def process_user_data(data: object) -> None:
    if is_user_dict(data):
        print(f"User: {data['name']}")  # 型安全
    else:
        raise ValueError("Invalid user data")
```

### 3. 型エイリアスの活用

```python
from typing import Dict, List, Tuple

# ✅ 複雑な型には型エイリアスを定義
UserId = str
UserData = Dict[str, str | int | bool]
UserList = List[UserData]
Coordinate = Tuple[float, float]

def get_user_location(user_id: UserId) -> Coordinate:
    # 実装
    return (35.6895, 139.6917)

def get_users() -> UserList:
    # 実装
    return []
```

### 4. 型変数の制約

```python
from typing import TypeVar

# ✅ 特定の型に制約
T = TypeVar('T', str, int, float)

def first_element(items: List[T]) -> T:
    return items[0]

# ✅ 上限境界の指定
class Animal:
    pass

class Dog(Animal):
    pass

T_Animal = TypeVar('T_Animal', bound=Animal)

def feed_animal(animal: T_Animal) -> T_Animal:
    # Animalまたはそのサブクラスのみ受け付ける
    return animal
```

## 📦 TypedDictの活用

### 基本的な使用方法

```python
from typing import TypedDict

# ✅ 辞書型のデータ構造にはTypedDictを使用
class UserDict(TypedDict):
    id: str
    name: str
    email: str
    age: int

class UserDictOptional(TypedDict, total=False):
    # total=False で全プロパティをオプショナルに
    phone: str
    address: str

# 使用例
def create_user(user_data: UserDict) -> User:
    return User(
        id=user_data['id'],
        name=user_data['name'],
        email=user_data['email'],
        age=user_data['age']
    )

user_data: UserDict = {
    'id': '123',
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30
}

user = create_user(user_data)
```

### 部分的なオプショナル

```python
from typing import TypedDict, NotRequired

# Python 3.11以降
class UserProfile(TypedDict):
    id: str
    name: str
    email: str
    bio: NotRequired[str]  # このプロパティのみオプショナル
    avatar_url: NotRequired[str]

# Python 3.10以前の場合
class UserProfileBase(TypedDict):
    id: str
    name: str
    email: str

class UserProfileOptional(TypedDict, total=False):
    bio: str
    avatar_url: str

# 継承で合成
class UserProfile310(UserProfileBase, UserProfileOptional):
    pass
```

### ネストしたTypedDict

```python
class AddressDict(TypedDict):
    street: str
    city: str
    postal_code: str

class UserWithAddress(TypedDict):
    id: str
    name: str
    address: AddressDict  # ネストした構造

# 使用例
user: UserWithAddress = {
    'id': '123',
    'name': 'John',
    'address': {
        'street': '123 Main St',
        'city': 'Tokyo',
        'postal_code': '100-0001'
    }
}
```

## 🔌 Protocolの活用（構造的部分型）

### 基本的なProtocol

```python
from typing import Protocol

# ✅ ダックタイピングが必要な場合はProtocolを使用
class Drawable(Protocol):
    """描画可能なオブジェクト"""
    def draw(self) -> None:
        ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")

class Square:
    def draw(self) -> None:
        print("Drawing square")

# どちらもDrawableとして扱える（明示的な継承不要）
def render(shape: Drawable) -> None:
    shape.draw()

render(Circle())  # OK
render(Square())  # OK
```

### ランタイムチェック可能なProtocol

```python
from typing import Protocol, runtime_checkable

@runtime_checkable
class Closable(Protocol):
    def close(self) -> None:
        ...

class FileWrapper:
    def close(self) -> None:
        print("Closing file")

# ランタイムでの型チェック
obj = FileWrapper()
if isinstance(obj, Closable):
    obj.close()  # OK
```

### 複雑なProtocol

```python
from typing import Protocol, Iterator

class SupportsIter(Protocol):
    """イテレート可能なオブジェクト"""
    def __iter__(self) -> Iterator[int]:
        ...

    def __len__(self) -> int:
        ...

class CustomRange:
    def __init__(self, max_value: int) -> None:
        self.max = max_value

    def __iter__(self) -> Iterator[int]:
        return iter(range(self.max))

    def __len__(self) -> int:
        return self.max

def process_iterable(items: SupportsIter) -> int:
    return sum(items)

custom_range = CustomRange(10)
result = process_iterable(custom_range)  # OK
```

## 🎁 dataclassの活用

### 基本的なdataclass

```python
from dataclasses import dataclass, field
from typing import List

# ✅ データクラスには@dataclassを使用
@dataclass
class User:
    id: str
    name: str
    email: str
    age: int
    is_active: bool = True  # デフォルト値

# 自動的に__init__, __repr__, __eq__等が生成される
user = User(
    id='123',
    name='John Doe',
    email='john@example.com',
    age=30
)

print(user)  # User(id='123', name='John Doe', ...)
```

### 不変dataclass

```python
@dataclass(frozen=True)
class Point:
    x: float
    y: float

point = Point(1.0, 2.0)
# point.x = 3.0  # エラー: frozen=Trueなので変更不可
```

### デフォルト値とfactory

```python
from typing import List
from dataclasses import dataclass, field

@dataclass
class Team:
    name: str
    members: List[str] = field(default_factory=list)  # ✅ 可変デフォルト値
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())

# ❌ 悪い例（絶対禁止）
# members: List[str] = []  # 可変デフォルト引数は危険
```

### 継承とpost_init

```python
@dataclass
class Person:
    name: str
    age: int

@dataclass
class Employee(Person):
    employee_id: str
    department: str

    def __post_init__(self) -> None:
        """初期化後の処理"""
        if self.age < 18:
            raise ValueError("Employee must be at least 18 years old")

employee = Employee(
    name='John',
    age=25,
    employee_id='E001',
    department='Engineering'
)
```

## 🔧 型チェッカーの使用

### mypy

#### 基本的な使用方法

```bash
# すべてのPythonファイルをチェック
mypy src/

# 特定のファイルのみチェック
mypy src/main.py

# 厳格モードでチェック
mypy --strict src/

# HTMLレポート生成
mypy --html-report ./mypy-report src/
```

#### mypy.ini 設定例

```ini
[mypy]
# 基本設定
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True

# 厳格な型チェック
disallow_any_unimported = True
disallow_any_expr = False  # 完全に厳格にする場合はTrue
disallow_any_decorated = True
disallow_any_explicit = True
disallow_any_generics = True
disallow_subclassing_any = True

# エラー設定
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True

# インポート設定
ignore_missing_imports = False
follow_imports = normal

# その他
strict_equality = True
strict_optional = True

# サードパーティライブラリ
[mypy-pytest.*]
ignore_missing_imports = True

[mypy-requests.*]
ignore_missing_imports = True
```

### pyright

#### 基本的な使用方法

```bash
# すべてのPythonファイルをチェック
pyright

# 特定のファイルのみチェック
pyright src/main.py

# 設定ファイル指定
pyright --project pyrightconfig.json
```

#### pyrightconfig.json 設定例

```json
{
  "include": ["src"],
  "exclude": [
    "**/node_modules",
    "**/__pycache__",
    "**/.*"
  ],
  "ignore": ["tests"],

  "typeCheckingMode": "strict",

  "reportMissingImports": true,
  "reportMissingTypeStubs": false,

  "pythonVersion": "3.11",
  "pythonPlatform": "Linux",

  "executionEnvironments": [
    {
      "root": "src",
      "pythonVersion": "3.11",
      "extraPaths": ["lib"]
    }
  ]
}
```

### pyright vs mypy 使い分け

| 特徴 | mypy | pyright |
|------|------|---------|
| 速度 | 遅い | 高速 |
| 精度 | 高い | 非常に高い |
| VS Code統合 | Pylance経由 | ネイティブ対応 |
| カスタマイズ | 豊富 | シンプル |
| 推奨用途 | CI/CD | エディタ統合 |

**推奨構成**:
- **開発時**: pyright（VS Code + Pylance）
- **CI/CD**: mypy（より厳格なチェック）

### 型チェックのCI/CD統合

```yaml
# .github/workflows/type-check.yml
name: Type Check

on: [push, pull_request]

jobs:
  type-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install mypy
          pip install types-requests  # 型スタブ

      - name: Run mypy
        run: mypy src/

      - name: Run pyright
        run: |
          npm install -g pyright
          pyright
```

## 🔗 関連ファイル

- **[SKILL.md](./SKILL.md)** - 概要に戻る
- **[TYPESCRIPT.md](./TYPESCRIPT.md)** - TypeScript型安全性
- **[ANTI-PATTERNS.md](./ANTI-PATTERNS.md)** - 避けるべきパターン
- **[REFERENCE.md](./REFERENCE.md)** - チェックリストとツール設定
