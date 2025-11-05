---
name: mcp-aws
description: AWS専門ツール - AWSインフラ構築時に最優先使用。公式ドキュメント参照とTerraformベストプラクティスを提供。
---

# AWS専門ツール

## 🎯 使用タイミング
- **AWSインフラ構築時（最優先）**
- **AWSベストプラクティス確認時**
- **Terraform（AWS特化）実装時**
- **Well-Architected Review実施時**

## 📋 2つのMCP

### 1. awslabs.aws-documentation MCP（AWSドキュメント専門）
**用途**: AWSサービスの公式ドキュメントとベストプラクティス

```typescript
// AWSサービス検索
// 利用可能なツールをリスト
ListMcpResourcesTool({ server: "awslabs.aws-documentation-mcp-server" })

// ドキュメント読み込み
ReadMcpResourceTool({
  server: "awslabs.aws-documentation-mcp-server",
  uri: "aws://service/ec2"  // 例
})
```

**主な参照先**:
- AWSサービスの仕様と制約
- セキュリティベストプラクティス
- コスト最適化ガイドライン
- Well-Architected Framework
- コンプライアンス要件

### 2. awslabs.terraform MCP（AWS Terraform専門）
**用途**: AWS特化のTerraformベストプラクティス

```typescript
// Terraformドキュメント検索
ListMcpResourcesTool({ server: "awslabs.terraform-mcp-server" })

// リソースドキュメント取得
ReadMcpResourceTool({
  server: "awslabs.terraform-mcp-server",
  uri: "terraform://aws/resource/vpc"  // 例
})
```

**主な参照先**:
- AWSプロバイダー（aws、awscc）最新仕様
- セキュリティ重視のTerraformワークフロー
- State管理ベストプラクティス
- AWSリソース最適化パターン
- モジュール設計パターン

## 🏗️ 推奨ワークフロー（AWSインフラ構築）

### 段階1: 要件・設計フェーズ
```
1. AWSドキュメント調査
   - awslabs.aws-documentation MCP でサービス仕様確認
   - Well-Architected Frameworkレビュー

2. アーキテクチャ設計
   - ベストプラクティス適用
   - セキュリティ要件定義
   - コスト見積もり
```

### 段階2: IaC実装フェーズ
```
3. Terraformコード作成
   - awslabs.terraform MCP でベストプラクティス確認
   - セキュリティ重視の実装
   - State管理設定

4. レビューと最適化
   - CodeGuardでセキュリティチェック
   - コスト最適化確認
```

### 段階3: デプロイ・検証
```
5. デプロイテスト
   - terraform plan で変更確認
   - terraform apply で適用
   - バリデーション実施
```

## 🔒 セキュリティ重視の原則
1. **最小権限**: IAMポリシーは必要最小限
2. **暗号化**: データ保存時・転送時の暗号化必須
3. **ロギング**: CloudTrail、VPCフローログ有効化
4. **ネットワーク分離**: VPC、サブネット適切に設計
5. **秘密情報管理**: Secrets Manager、Parameter Store活用

## 🆚 マルチクラウドとの使い分け
- **AWS専用プロジェクト**: awslabs MCP優先
- **マルチクラウド**: 汎用terraform MCPを併用
- **Azure/GCP**: 汎用terraform MCPを使用

## 📚 主要リソース
**AWSドキュメントMCP**:
- AWSサービス仕様
- Well-Architected Framework
- セキュリティベストプラクティス
- コスト最適化ガイド

**Terraform MCP**:
- AWSプロバイダードキュメント
- セキュアなIaCパターン
- State管理ベストプラクティス
- モジュール設計パターン

## ⚠️ 注意点
- **最新情報確認**: AWSサービスは頻繁に更新
- **リージョン制約**: 一部サービスは特定リージョンのみ
- **コスト管理**: 常にコスト影響を考慮
- **セキュリティ優先**: ベストプラクティスを厳守
