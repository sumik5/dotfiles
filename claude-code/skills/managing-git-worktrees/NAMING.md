# Worktree命名規則

## 🎯 基本フォーマット

### 標準的な命名パターン

```bash
git worktree add -b <ブランチ名> <worktreeディレクトリ名> <元ブランチ>
```

**推奨フォーマット**:
```
wt-<カテゴリ>-<機能名>
```

### パラメータの詳細説明

| パラメータ | 説明 | 例 |
|----------|------|-----|
| `ブランチ名` | Gitブランチの名前（スラッシュ区切り） | `feature/user-auth`, `hotfix/bug-123` |
| `worktreeディレクトリ名` | ファイルシステム上のディレクトリ名（wt-プレフィックス必須） | `wt-feat-user-auth`, `wt-fix-bug-123` |
| `元ブランチ` | ベースとするブランチ（通常は`main`または`develop`） | `main`, `develop`, `release/v2.0` |

### 命名規則の重要性

#### wt-プレフィックスの利点

1. **視覚的識別**: ディレクトリ一覧で即座にworktreeと識別可能
2. **Git除外**: `.gitignore`で`wt-*/`として一括除外可能
3. **ツール連携**: gwq等のツールとの統合がスムーズ
4. **誤削除防止**: 通常のディレクトリと明確に区別

```bash
# ディレクトリ一覧での視認性
ls -la
# drwxr-xr-x  src/
# drwxr-xr-x  tests/
# drwxr-xr-x  wt-feat-auth/      # worktreeと明確
# drwxr-xr-x  wt-feat-payment/   # worktreeと明確
```

## 📋 カテゴリ別の命名例

### 1. 機能開発（feature）

**ブランチ名**: `feature/<機能名>`
**Worktree名**: `wt-feat-<機能名>`

```bash
# ユーザー認証機能
git worktree add -b feature/user-auth wt-feat-user-auth main

# 決済統合機能
git worktree add -b feature/payment-integration wt-feat-payment main

# プロフィール画面
git worktree add -b feature/profile-page wt-feat-profile main

# ダークモード対応
git worktree add -b feature/dark-mode wt-feat-dark-mode main

# 通知システム
git worktree add -b feature/notification-system wt-feat-notifications main
```

### 2. バグ修正（bugfix/hotfix）

**ブランチ名**: `hotfix/<バグ説明>` または `hotfix/issue-<番号>`
**Worktree名**: `wt-fix-<バグ説明>`

```bash
# メモリリーク修正
git worktree add -b hotfix/memory-leak wt-fix-memory-leak main

# イシュー番号で管理
git worktree add -b hotfix/issue-456 wt-fix-issue-456 main

# ログイン失敗バグ
git worktree add -b hotfix/login-failure wt-fix-login main

# データベース接続エラー
git worktree add -b hotfix/db-connection wt-fix-db-connection main
```

### 3. 緊急修正（critical hotfix）

**ブランチ名**: `hotfix/critical-<問題>`
**Worktree名**: `wt-hotfix-<問題>`

```bash
# セキュリティ脆弱性の緊急修正
git worktree add -b hotfix/critical-security wt-hotfix-security main

# 本番環境での重大なバグ
git worktree add -b hotfix/critical-production wt-hotfix-production main

# データ損失リスクの修正
git worktree add -b hotfix/critical-data-loss wt-hotfix-data-loss main
```

### 4. 実験的開発（experimental）

**ブランチ名**: `experimental/<実験内容>`
**Worktree名**: `wt-exp-<実験内容>`

```bash
# 新しいアーキテクチャの検証
git worktree add -b experimental/new-arch wt-exp-new-arch main

# パフォーマンス最適化の実験
git worktree add -b experimental/perf-optimization wt-exp-perf main

# 新しいUIフレームワークの試行
git worktree add -b experimental/ui-framework wt-exp-ui-framework main
```

### 5. リリース準備（release）

**ブランチ名**: `release/v<バージョン>`
**Worktree名**: `wt-release-v<バージョン>`

```bash
# バージョン2.0.0のリリース準備
git worktree add -b release/v2.0.0 wt-release-v2.0.0 develop

# パッチリリース
git worktree add -b release/v1.5.3 wt-release-v1.5.3 main

# メジャーバージョンアップ
git worktree add -b release/v3.0.0 wt-release-v3.0.0 develop
```

### 6. リファクタリング（refactor）

**ブランチ名**: `refactor/<対象>`
**Worktree名**: `wt-refactor-<対象>`

```bash
# 認証システムのリファクタリング
git worktree add -b refactor/auth-system wt-refactor-auth main

# データベース層の改善
git worktree add -b refactor/database-layer wt-refactor-db main

# コンポーネント構造の再編
git worktree add -b refactor/component-structure wt-refactor-components main
```

### 7. ドキュメント更新（docs）

**ブランチ名**: `docs/<ドキュメント名>`
**Worktree名**: `wt-docs-<ドキュメント名>`

```bash
# APIドキュメントの更新
git worktree add -b docs/api-documentation wt-docs-api main

# README改善
git worktree add -b docs/readme-update wt-docs-readme main

# チュートリアル追加
git worktree add -b docs/tutorial wt-docs-tutorial main
```

### 8. テスト追加（test）

**ブランチ名**: `test/<テスト対象>`
**Worktree名**: `wt-test-<テスト対象>`

```bash
# E2Eテスト追加
git worktree add -b test/e2e-suite wt-test-e2e main

# ユニットテスト拡充
git worktree add -b test/unit-coverage wt-test-unit main

# パフォーマンステスト
git worktree add -b test/performance wt-test-perf main
```

## 🎨 命名のベストプラクティス

### DO（推奨）

#### 1. 簡潔で説明的な名前を使用

```bash
# ✅ 良い例: 簡潔で意図が明確
git worktree add -b feature/user-auth wt-feat-user-auth main
git worktree add -b hotfix/login-bug wt-fix-login main

# ❌ 悪い例: 冗長または不明瞭
git worktree add -b feature/implement-user-authentication-system wt-feature-implement-user-authentication-system main
git worktree add -b fix/bug wt-fix main
```

#### 2. ケバブケース（kebab-case）を使用

```bash
# ✅ 良い例: ケバブケース
wt-feat-user-profile
wt-fix-memory-leak
wt-exp-new-framework

# ❌ 悪い例: スネークケースやキャメルケース
wt_feat_user_profile
wtFeatUserProfile
```

#### 3. プレフィックスで種類を明確化

```bash
# ✅ 良い例: プレフィックスで種類が明確
wt-feat-payment      # 機能開発
wt-fix-bug-123       # バグ修正
wt-hotfix-security   # 緊急修正
wt-exp-new-arch      # 実験的開発
wt-refactor-auth     # リファクタリング

# ❌ 悪い例: 種類が不明
wt-payment
wt-work1
wt-temp
```

#### 4. イシュー番号を含める（該当する場合）

```bash
# ✅ 良い例: イシュー番号で追跡可能
git worktree add -b hotfix/issue-456 wt-fix-issue-456 main
git worktree add -b feature/ticket-789 wt-feat-ticket-789 main

# GitHub/GitLabのイシュー番号との紐付け
git worktree add -b hotfix/gh-123 wt-fix-gh-123 main
```

### DON'T（避けるべき）

#### 1. 一般的すぎる名前

```bash
# ❌ 悪い例: 何を作業しているか不明
wt-work
wt-temp
wt-test
wt-new

# ✅ 良い例: 具体的で明確
wt-feat-payment-integration
wt-fix-login-validation
wt-test-e2e-checkout
```

#### 2. スペースや特殊文字

```bash
# ❌ 悪い例: スペースや特殊文字
wt-feat user auth
wt-fix@bug
wt-test#123

# ✅ 良い例: 英数字とハイフンのみ
wt-feat-user-auth
wt-fix-bug
wt-test-123
```

#### 3. wt-プレフィックスの省略

```bash
# ❌ 悪い例: プレフィックスなし
git worktree add -b feature/auth feat-auth main
git worktree add -b hotfix/bug fix-bug main

# ✅ 良い例: wt-プレフィックス
git worktree add -b feature/auth wt-feat-auth main
git worktree add -b hotfix/bug wt-fix-bug main
```

#### 4. 過度に長い名前

```bash
# ❌ 悪い例: 過度に長い
wt-feature-implement-comprehensive-user-authentication-and-authorization-system

# ✅ 良い例: 適度な長さ
wt-feat-user-auth
```

## 📊 命名パターンのまとめ

| カテゴリ | ブランチ形式 | Worktree形式 | 例 |
|---------|------------|-------------|-----|
| 機能開発 | `feature/<名前>` | `wt-feat-<名前>` | `wt-feat-user-auth` |
| バグ修正 | `hotfix/<名前>` | `wt-fix-<名前>` | `wt-fix-login-bug` |
| 緊急修正 | `hotfix/critical-<名前>` | `wt-hotfix-<名前>` | `wt-hotfix-security` |
| 実験的 | `experimental/<名前>` | `wt-exp-<名前>` | `wt-exp-new-arch` |
| リリース | `release/v<version>` | `wt-release-v<version>` | `wt-release-v2.0.0` |
| リファクタリング | `refactor/<名前>` | `wt-refactor-<名前>` | `wt-refactor-auth` |
| ドキュメント | `docs/<名前>` | `wt-docs-<名前>` | `wt-docs-api` |
| テスト | `test/<名前>` | `wt-test-<名前>` | `wt-test-e2e` |

## 🔍 命名規則のチェックリスト

新しいworktreeを作成する前に確認：

- [ ] `wt-`プレフィックスを使用している
- [ ] カテゴリプレフィックス（feat/fix/hotfix/exp等）を含めている
- [ ] ケバブケース（kebab-case）を使用している
- [ ] 簡潔で説明的な名前になっている
- [ ] 特殊文字やスペースを含んでいない
- [ ] 該当する場合、イシュー番号を含めている
- [ ] 20文字以下の適度な長さである
- [ ] ブランチ名とworktree名が対応している

## 🔗 次のステップ

- [ワークフロー](./WORKFLOWS.md): worktreeの作成と操作手順
- [トラブルシューティング](./TROUBLESHOOTING.md): 問題解決とベストプラクティス

---

[← ワークフロー](./WORKFLOWS.md) | [SKILL.md](./SKILL.md) | [トラブルシューティング →](./TROUBLESHOOTING.md)
