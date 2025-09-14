#!/bin/bash

# Общий скрипт для настройки SSH ключей на всех серверах
set -e

# Параметры по умолчанию
INVENTORY=""
LIMIT_HOSTS=""

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT_HOSTS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  -i, --inventory FILE    Inventory file (required)"
            echo "  -l, --limit HOSTS       Limit to specific hosts"
            echo "  -h, --help              Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 -i postgresql/inventory/hosts.yml"
            echo "  $0 -i postgresql/inventory/hosts.yml -l postgresql-test-nau"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Проверка обязательных параметров
if [[ -z "$INVENTORY" ]]; then
    echo "❌ Error: Inventory file is required"
    echo "Use -i or --inventory to specify inventory file"
    exit 1
fi

if [[ ! -f "$INVENTORY" ]]; then
    echo "❌ Error: Inventory file not found: $INVENTORY"
    exit 1
fi

echo "🔑 Setting up SSH keys for all servers..."
echo "Inventory: $INVENTORY"

# Build ansible command
ANSIBLE_CMD="ansible-playbook -i \"$INVENTORY\" setup-ssh.yml --ask-pass --ask-become-pass"

if [[ -n "$LIMIT_HOSTS" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$LIMIT_HOSTS\""
    echo "Limited to hosts: $LIMIT_HOSTS"
fi

if eval $ANSIBLE_CMD; then
    echo "✅ SSH keys successfully configured!"
    echo "You can now run component deployments without passwords"
else
    echo "❌ Failed to setup SSH keys"
    exit 1
fi
