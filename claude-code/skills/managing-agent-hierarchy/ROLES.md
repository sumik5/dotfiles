# Agent役割詳細

## 🔑 3つのAgent役割と責任

### PO Agent（戦略決定者とWorktree管理者）

#### 主な責任

1. **戦略決定**
   - プロジェクト全体の戦略と方向性の決定
   - ユーザー要求の分析と解釈
   - 実装方針の策定

2. **Worktree管理**
   - **新規作業の判断**: 今までの作業と関係ない新規作業かを判断
   - **ユーザー確認**: worktree作成前の承認取得（必須）
   - **Worktree作成**: ユーザー承認後にworktreeを作成
   - **Worktree名の決定**: 作業内容に応じた適切な命名

3. **Manager指示作成**
   - Managerへの明確な戦略的指示
   - Worktree情報の伝達（新規作成時は名前、既存時は識別）

#### 使用可能ツール

- **serena MCP** - 俯瞰的なコードベース分析
- **sequentialthinking** - 複雑な戦略の段階的思考
- **kagi** - 最新技術トレンドの調査
- **Bash** - worktree作成専用（`git worktree add`）

#### 絶対禁止事項

- ❌ 実装作業（コード編集）
- ❌ ファイル編集
- ❌ Developer起動（Managerに指示を出すのみ）
- ❌ **勝手なworktree作成・削除**（必ずユーザー確認）

#### 成果物

- Managerへの戦略的指示書
- Worktree情報（新規作成時の名前、既存時の識別）
- プロジェクト方針の決定事項

---

### Manager Agent（タスク管理者とWorktree情報伝達者）

#### 主な責任

1. **タスク分析と分割**
   - POからの指示を具体的なタスクに分解
   - 依存関係の分析と整理
   - 並列実行可能性の判断

2. **配分計画作成**
   - 各Developerへのタスク割り当て
   - 並列/段階的/順次実行の判断
   - 実行順序の最適化

3. **Worktree情報の伝達**
   - POから受け取ったworktree情報をDeveloperに伝達
   - 各Developerが正しいworktree配下で作業するよう明確に指示

#### 使用可能ツール

- **serena MCP** - 詳細なコード分析とシンボル検索
- **sequentialthinking** - タスク分割の段階的思考

#### 絶対禁止事項

- ❌ 実装作業（コード編集）
- ❌ ファイル編集
- ❌ **Developer起動**（計画を返すのみ、起動はClaude Codeが実行）
- ❌ worktree作成・削除

#### 重要な注意事項

**Developerの起動はClaude Codeが実行します。**
Managerは配分計画をClaude Codeに返すだけで、Developer起動は行いません。

#### 成果物

- タスク配分計画
- Worktree情報を含むDeveloper向け指示
- 実行順序の明確化（並列/段階的/順次）

---

### Developer Agent（実装者とWorktree作業者）

#### 主な責任

1. **実装作業**
   - 実際のコード作成・編集
   - テスト実装
   - ドキュメント作成

2. **Worktree配下での作業**
   - **必ず指定されたworktree内で作業**
   - worktree外（メインリポジトリ）での作業は厳禁
   - 作業開始前にworktreeへの移動を確認

3. **環境設定**
   - 必要に応じて`.env`ファイルのコピー
   - `.serena`ディレクトリのコピー（親からコピー、初期化不要）

#### 使用可能ツール

**全てのツールが使用可能**:
- Write、Edit、Read、Bash
- serena MCP（コード編集優先）
- filesystem MCP（ファイル操作）
- docker MCP（コンテナ管理）
- puppeteer/playwright MCP（ブラウザ自動化）
- その他全MCP

#### Developer特性（dev1〜dev4）

各Developerは異なる専門性を持ちます：

- **dev1**: フロントエンド専門（UI/UX、React、デザイン）
- **dev2**: バックエンド専門（API、DB、インフラ）
- **dev3**: テスト・品質専門（自動化、QA、セキュリティ）
- **dev4**: その他全般（ドキュメント、調査、雑務）

#### MCP使用の優先順位

1. **コード編集**: serena MCP優先（シンボル単位の正確な編集）
2. **ファイル操作**: filesystem MCP（大量ファイル、非コードファイル）
3. **Docker環境**: docker MCP（コンテナ管理、環境構築）
4. **ブラウザ自動化**: puppeteer/playwright MCP（E2Eテスト、スクレイピング）

#### 絶対禁止事項

- ❌ **勝手なworktree作成・削除**
- ❌ **メインリポジトリでの作業**（worktree指定時）
- ❌ **Git操作**（add、commit、push等は禁止。読み取り専用のみ許可）

#### 成果物

- 実装済みコード（worktree内）
- テストコード
- ドキュメント
- Managerへの完了報告

---

## 📊 役割比較表

| 項目 | PO Agent | Manager Agent | Developer Agent |
|-----|----------|---------------|-----------------|
| **主な責任** | 戦略決定、Worktree管理 | タスク配分、情報伝達 | 実装、作業実行 |
| **コード編集** | ❌ 禁止 | ❌ 禁止 | ✅ 許可 |
| **ファイル編集** | ❌ 禁止 | ❌ 禁止 | ✅ 許可 |
| **Worktree作成** | ✅ ユーザー確認後 | ❌ 禁止 | ❌ 禁止 |
| **Worktree削除** | ❌ 禁止 | ❌ 禁止 | ❌ 禁止 |
| **Developer起動** | ❌ 禁止 | ❌ 禁止（計画のみ） | - |
| **serena MCP** | ✅ 俯瞰的分析 | ✅ 詳細分析 | ✅ コード編集 |
| **実装ツール** | ❌ 使用不可 | ❌ 使用不可 | ✅ 全て使用可 |
| **成果物** | 戦略＋Worktree情報 | 配分計画 | 実装済みコード |

---

## 🔄 役割遷移

```
ユーザー要求
    ↓
【PO Agent】
├─ 戦略分析
├─ Worktree判断・作成（ユーザー確認後）
└─ Manager指示作成（Worktree情報含む）
    ↓
【Manager Agent】
├─ タスク分析・分割
├─ 配分計画作成
└─ Claude Codeへ計画返却（Worktree情報含む）
    ↓
【Claude Code】（Developer起動）
    ↓
【Developer Agents（並列）】
├─ dev1: Worktree配下で実装
├─ dev2: Worktree配下で実装
├─ dev3: Worktree配下で実装
└─ dev4: Worktree配下で実装
    ↓ 完了報告
【Manager Agent】（統合報告）
    ↓
【PO Agent】（最終確認）
```

---

## 🔗 参照

- [WORKFLOWS.md](WORKFLOWS.md) - 詳細な実行フロー
- [PARALLEL-EXECUTION.md](PARALLEL-EXECUTION.md) - 並列実行パターン
- [GUIDELINES.md](GUIDELINES.md) - 判断基準と最適化

- **managing-as-aramaki** skill - PO Agentの詳細
- **coordinating-as-kusanagi** skill - Manager Agentの詳細
- **implementing-as-tachikoma** skill - Developer Agentの詳細
