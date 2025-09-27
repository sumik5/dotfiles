#!/bin/bash

# 色付き出力用の関数
print_status() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

# 現在の認証状態を確認
print_status "現在の認証状態を確認中..."
CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null)

if [ -z "$CURRENT_ACCOUNT" ]; then
    print_status "認証されていません。新規認証を開始します..."
else
    print_status "現在のアカウント: $CURRENT_ACCOUNT"
    read -p "再認証しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# 認証実行
print_status "GCloud認証を実行中..."
if gcloud auth login; then
    print_success "GCloud CLI認証成功"
else
    echo "GCloud CLI認証に失敗しました"
    exit 1
fi

print_status "Application Default認証を実行中..."
if gcloud auth application-default login; then
    print_success "Application Default認証成功"
else
    echo "Application Default認証に失敗しました"
    exit 1
fi

# 認証情報の確認
print_success "認証完了！"
echo "----------------------------------------"
echo "アクティブアカウント: $(gcloud config get-value account)"
echo "プロジェクト: $(gcloud config get-value project)"
echo "----------------------------------------"
