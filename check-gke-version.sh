#!/bin/bash

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# YAMLファイルのパス
YAML_FILE="gke-version.yaml"
LOCATION="asia-northeast1"

# YAMLファイルからバージョンを取得
CONTROLPLANE_VERSION=$(grep -A 1 "controlplane:" "$YAML_FILE" | grep "version:" | awk '{print $2}')
NODES_VERSION=$(grep -A 1 "nodes:" "$YAML_FILE" | grep "version:" | awk '{print $2}')

echo "Checking GKE versions..."
echo "Controlplane version: $CONTROLPLANE_VERSION"
echo "Nodes version: $NODES_VERSION"
echo ""

# gcloud から利用可能なバージョンを取得
echo "Fetching available versions from GKE..."
VALID_VERSIONS=$(gcloud container get-server-config \
    --location "$LOCATION" \
    --format=json | jq -r '.channels[] | select(.channel == "REGULAR") | .validVersions[]')

echo ""
echo "Valid versions in REGULAR channel:"
echo "$VALID_VERSIONS"
echo ""

# コントロールプレーンバージョンをチェック
if echo "$VALID_VERSIONS" | grep -q "^${CONTROLPLANE_VERSION}$"; then
    echo -e "${GREEN}✓ Controlplane version ${CONTROLPLANE_VERSION} is valid${NC}"
else
    echo -e "${RED}✗ Controlplane version ${CONTROLPLANE_VERSION} is NOT available${NC}"
    exit 1
fi

# ノードバージョンをチェック
if echo "$VALID_VERSIONS" | grep -q "^${NODES_VERSION}$"; then
    echo -e "${GREEN}✓ Nodes version ${NODES_VERSION} is valid${NC}"
else
    echo -e "${RED}✗ Nodes version ${NODES_VERSION} is NOT available${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}All versions are valid!${NC}"
