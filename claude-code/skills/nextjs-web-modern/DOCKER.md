# Docker デプロイガイド

## 概要

このガイドでは、Next.js 16アプリケーションのマルチステージビルドとGCP Cloud Runへのデプロイ方法を説明します。

## Dockerfile（マルチステージビルド）

### 完全なDockerfile

```dockerfile
FROM node:22.0-bookworm-slim AS base

ENV HOSTNAME=0.0.0.0

RUN corepack disable && corepack enable

RUN apt-get update \
  && apt-get -qq install -y --no-install-recommends \
  tini build-essential  \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /app && chown node:node /app

#######################################################################
FROM base AS builder

USER node

WORKDIR /app

COPY --chown=node:node package.json pnpm-lock.yaml ./

RUN NODE_ENV=production pnpm install --ignore-scripts

COPY --chown=node:node next-env.d.ts next.config.js postcss.config.cjs tailwind.config.js ./
COPY --chown=node:node tsconfig.json ./
COPY --chown=node:node public ./public
COPY --chown=node:node src ./src
COPY --chown=node:node prisma ./prisma

RUN npx next telemetry disable && \
    npx prisma generate && \
    pnpm next build

#######################################################################
FROM base AS prod

USER node

WORKDIR /app

EXPOSE 3000

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./standalone/
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/prisma ./prisma/

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
```

### ステージ説明

#### 1. base（基本イメージ）

```dockerfile
FROM node:22.0-bookworm-slim AS base

ENV HOSTNAME=0.0.0.0

RUN corepack disable && corepack enable

RUN apt-get update \
  && apt-get -qq install -y --no-install-recommends \
  tini build-essential  \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /app && chown node:node /app
```

**ポイント:**
- `node:22.0-bookworm-slim`: 軽量なDebianベースイメージ
- `HOSTNAME=0.0.0.0`: すべてのネットワークインターフェースでリッスン
- `corepack enable`: pnpmを有効化
- `tini`: プロセスマネージャー（シグナル処理）
- `build-essential`: Prismaネイティブバイナリビルド用

#### 2. builder（ビルドステージ）

```dockerfile
FROM base AS builder

USER node

WORKDIR /app

COPY --chown=node:node package.json pnpm-lock.yaml ./

RUN NODE_ENV=production pnpm install --ignore-scripts

COPY --chown=node:node next-env.d.ts next.config.js postcss.config.cjs tailwind.config.js ./
COPY --chown=node:node tsconfig.json ./
COPY --chown=node:node public ./public
COPY --chown=node:node src ./src
COPY --chown=node:node prisma ./prisma

RUN npx next telemetry disable && \
    npx prisma generate && \
    pnpm next build
```

**ポイント:**
- `USER node`: rootユーザーを使用しない（セキュリティ）
- `pnpm install --ignore-scripts`: 依存関係インストール
- `npx prisma generate`: Prismaクライアント生成
- `pnpm next build`: Next.jsビルド（standalone出力）

#### 3. prod（本番イメージ）

```dockerfile
FROM base AS prod

USER node

WORKDIR /app

EXPOSE 3000

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./standalone/
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/prisma ./prisma/

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
```

**ポイント:**
- `COPY --from=builder`: ビルド成果物のみコピー（軽量化）
- `.next/standalone`: Next.jsが生成したスタンドアロンサーバー
- `node_modules/@prisma`: Prismaクライアントのみコピー
- `tini`: プロセスマネージャーとして起動

## Next.js設定（standalone出力）

### next.config.js

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: "standalone", // Docker本番環境用（重要）

  logging: {
    fetches: {
      fullUrl: false,
    },
  },
};

export default nextConfig;
```

**`output: "standalone"`の効果:**
- `.next/standalone`ディレクトリに最小限のファイルを出力
- `node_modules`全体ではなく、必要な依存関係のみ含む
- イメージサイズを大幅削減

## docker-compose.yml（開発環境）

```yaml
version: "3.9"

services:
  db:
    image: postgres:16-alpine
    container_name: next-app-db
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: dbname
    ports:
      - "5432:5432"
    volumes:
      - db-data:/var/lib/postgresql/data

  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: prod
    container_name: next-app
    depends_on:
      - db
    environment:
      DATABASE_URL: postgresql://user:password@db:5432/dbname
      NEXTAUTH_SECRET: your-secret-here
      NEXTAUTH_URL: http://localhost:3000
    ports:
      - "3000:3000"

volumes:
  db-data:
```

## ビルドとデプロイ

### ローカルビルド

```bash
# イメージビルド
docker build -t next-app .

# コンテナ起動
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://user:password@localhost:5432/dbname \
  -e NEXTAUTH_SECRET=your-secret-here \
  next-app

# docker-compose起動
docker-compose up -d

# ログ確認
docker-compose logs -f
```

### GCP Cloud Runへのデプロイ

#### 1. Artifact Registryにプッシュ

```bash
# 認証設定
gcloud auth configure-docker asia-northeast1-docker.pkg.dev

# イメージビルド
docker build -t asia-northeast1-docker.pkg.dev/PROJECT_ID/next-app/app:latest .

# プッシュ
docker push asia-northeast1-docker.pkg.dev/PROJECT_ID/next-app/app:latest
```

#### 2. Cloud Runデプロイ

```bash
gcloud run deploy next-app \
  --image asia-northeast1-docker.pkg.dev/PROJECT_ID/next-app/app:latest \
  --platform managed \
  --region asia-northeast1 \
  --allow-unauthenticated \
  --set-env-vars "DATABASE_URL=postgresql://user:password@host:5432/dbname" \
  --set-env-vars "NEXTAUTH_SECRET=your-secret-here" \
  --set-env-vars "NODE_ENV=production"
```

#### 3. Cloud Buildでの自動デプロイ

**cloudbuild.yaml:**
```yaml
steps:
  # ビルド
  - name: "gcr.io/cloud-builders/docker"
    args:
      - "build"
      - "-t"
      - "asia-northeast1-docker.pkg.dev/$PROJECT_ID/next-app/app:$SHORT_SHA"
      - "."

  # プッシュ
  - name: "gcr.io/cloud-builders/docker"
    args:
      - "push"
      - "asia-northeast1-docker.pkg.dev/$PROJECT_ID/next-app/app:$SHORT_SHA"

  # Cloud Runデプロイ
  - name: "gcr.io/google.com/cloudsdktool/cloud-sdk"
    entrypoint: gcloud
    args:
      - "run"
      - "deploy"
      - "next-app"
      - "--image"
      - "asia-northeast1-docker.pkg.dev/$PROJECT_ID/next-app/app:$SHORT_SHA"
      - "--region"
      - "asia-northeast1"
      - "--platform"
      - "managed"

images:
  - "asia-northeast1-docker.pkg.dev/$PROJECT_ID/next-app/app:$SHORT_SHA"
```

## Prismaマイグレーション

### Dockerコンテナ内でのマイグレーション

**instrumentation.ts（Next.js 16起動時に実行）:**
```typescript
// src/instrumentation.ts
export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    const { prisma } = await import("@/lib/prisma");

    // マイグレーション実行（本番環境）
    if (process.env.NODE_ENV === "production") {
      const { execSync } = await import("child_process");
      execSync("npx prisma migrate deploy", { stdio: "inherit" });
    }

    // Prismaクライアント接続確認
    await prisma.$connect();
    console.log("Prisma connected");
  }
}
```

**手動実行:**
```bash
# コンテナ内で実行
docker exec -it next-app npx prisma migrate deploy
```

## トラブルシューティング

### イメージサイズが大きい

**解決策:**
- `output: "standalone"`が有効か確認
- `.dockerignore`を設定

**.dockerignore:**
```
node_modules
.next
.git
.vscode
coverage
wt-*
```

### Prismaクライアントエラー

**解決策:**
```bash
# Prismaクライアント再生成
docker exec -it next-app npx prisma generate
```

### メモリ不足

**Cloud Run設定:**
```bash
gcloud run deploy next-app \
  --memory 1Gi \
  --cpu 1
```

## ベストプラクティス

### 1. マルチステージビルド

**イメージサイズを最小化:**
- 開発依存関係を本番イメージに含めない
- ビルド成果物のみコピー

### 2. セキュリティ

**rootユーザーを使用しない:**
```dockerfile
USER node
```

### 3. ヘルスチェック

**Dockerfile:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"
```

## 参考資料

- **Next.js Dockerガイド**: https://nextjs.org/docs/deployment#docker-image
- **GCP Cloud Run**: https://cloud.google.com/run/docs
- **Docker公式**: https://docs.docker.com

---

**関連ドキュメント:**
- [TOOLING.md](./TOOLING.md) - 開発ツール設定
- [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md) - プロジェクト構造
