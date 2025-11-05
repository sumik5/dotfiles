---
name: mcp-serena
description: Serenaエキスパート - コード編集・解析作業時に最優先で使用。プロジェクト初期化、シンボル検索、効率的なコード変更を支援。
---

# Serena MCP エキスパートガイド

## 🎯 使用タイミング
- **プロジェクト開始時（必須）**: `.serena`ディレクトリが存在しない場合
- **コード編集・解析時（最優先）**: ファイル全体読込の代わりにシンボル単位で操作
- **リファクタリング時**: 依存関係を分析してから変更

## 📋 必須手順

### 1. プロジェクト初期化（初回のみ）
```
# .serenaディレクトリ確認
ls -la .serena

# 存在しない場合
mcp__serena__activate_project(project=".")
mcp__serena__check_onboarding_performed()
mcp__serena__onboarding()  # 未実施の場合
```

### 2. コード分析ワークフロー
```
# ファイル概要取得
mcp__serena__get_symbols_overview(relative_path="src/file.ts")

# シンボル検索
mcp__serena__find_symbol(name_path="ClassName/methodName")

# 依存関係分析
mcp__serena__find_referencing_symbols(name_path="functionName", relative_path="src/file.ts")

# パターン検索
mcp__serena__search_for_pattern(substring_pattern="TODO|FIXME")
```

### 3. 効率的編集
```
# シンボル置換
mcp__serena__replace_symbol_body(name_path="methodName", relative_path="src/file.ts", body="new code")

# シンボル前に挿入（import文追加等）
mcp__serena__insert_before_symbol(name_path="firstSymbol", relative_path="src/file.ts", body="import ...")

# シンボル後に挿入（新規メソッド追加等）
mcp__serena__insert_after_symbol(name_path="lastMethod", relative_path="src/file.ts", body="newMethod() {}")
```

### 4. プロジェクト知識管理
```
# メモリ一覧
mcp__serena__list_memories()

# メモリ読込
mcp__serena__read_memory(memory_file_name="architecture.md")

# メモリ保存
mcp__serena__write_memory(memory_name="decisions", content="設計決定内容")
```

## ⚠️ 重要な原則
1. **ファイル全体読込は最終手段**: まずSerenaでシンボル検索
2. **トークン効率**: シンボル単位の操作で大幅削減
3. **Worktree使用時**: `.serena`を親からコピー（`cp -r ../.serena .serena`）

## 📚 参照ツール
- `mcp__serena__activate_project`
- `mcp__serena__get_symbols_overview`
- `mcp__serena__find_symbol`
- `mcp__serena__replace_symbol_body`
- `mcp__serena__insert_before_symbol`
- `mcp__serena__insert_after_symbol`
- `mcp__serena__write_memory`
- `mcp__serena__read_memory`
