#!/usr/bin/env bash

STORAGE_BOX_LOGIN="USERNAME"
STORAGE_BOX_PASSWORD="password"
STORAGE_BOX_ID="IDIDID"
STORAGE_BOX_API="https://robot-ws.your-server.de/storagebox/$STORAGE_BOX_ID"

get_storagebox_info() {
    response=$(curl -u "$STORAGE_BOX_LOGIN:$STORAGE_BOX_PASSWORD" -s "$STORAGE_BOX_API")

    if [[ $? -ne 0 ]]; then
        echo "Error while connecting to Hetzner API"
        exit 1
    fi

    disk_quota=$(echo "$response" | jq -r '.storagebox.disk_quota')
    disk_usage=$(echo "$response" | jq -r '.storagebox.disk_usage')
    storage_name=$(echo "$response" | jq -r '.storagebox.name')
    product=$(echo "$response" | jq -r '.storagebox.product')
    location=$(echo "$response" | jq -r '.storagebox.location')
    paid_until=$(echo "$response" | jq -r '.storagebox.paid_until')

    if [[ -z "$disk_quota" || -z "$disk_usage" ]]; then
        echo "Error: Cannot retrieve disk data."
        exit 1
    fi

    free_space=$((disk_quota - disk_usage))
    usage_percent=$((100 * disk_usage / disk_quota))

    echo "╭╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╮"
    echo "   📦📦📦 Storage Box 📦📦📦"
    echo "╰╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╯"
    echo "╭╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╮"
    echo "    🍰 Name: ${storage_name:-<not provided>}"
    echo "    🚀 Product: $product"
    echo "    🍡 Location: $location"
    echo "    ⏳ Paid until: $paid_until"
    echo "╰╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╯"
    echo "╭╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╮"
    echo "  😱 Disk quota: $disk_quota MB"
    echo "    ⠧ Used: $disk_usage MB "
    echo "    ⠼ free: $free_space MB"
    echo "╰╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╯"
}

if ! command -v jq &>/dev/null; then
    echo "❌ jq not found. Install it from package manager"
    exit 1
fi

get_storagebox_info