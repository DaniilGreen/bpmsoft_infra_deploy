#!/bin/bash

# Скрипт только для развертывания PostgreSQL
set -e

# Параметры по умолчанию
ENVIRONMENT="prod"
BACKUP_VERSION="v1.8.0"
INVENTORY="inventory/hosts.yml"
LIMIT_HOSTS=""
ASK_BECOME_PASS=false

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -b|--backup)
            BACKUP_VERSION="$2"
            shift 2
            ;;
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT_HOSTS="$2"
            shift 2
            ;;
        --ask-become-pass)
            ASK_BECOME_PASS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  -e, --env ENV           Environment (dev, preprod, prod) [default: prod]"
            echo "  -b, --backup VERSION    Backup version (v1.7.1, v1.8.0) [default: v1.8.0]"
            echo "  -i, --inventory FILE    Inventory file [default: inventory/hosts.yml]"
    echo "  -l, --limit HOSTS       Limit to specific hosts"
    echo "  --ask-become-pass       Ask for sudo password"
    echo "  -h, --help              Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🐘 Deploying PostgreSQL..."
echo "Environment: $ENVIRONMENT"
echo "Backup version: $BACKUP_VERSION"

# Build ansible command
ANSIBLE_CMD="ansible-playbook -i \"$INVENTORY\" playbook.yml"
ANSIBLE_CMD="$ANSIBLE_CMD -e \"env=$ENVIRONMENT\""
ANSIBLE_CMD="$ANSIBLE_CMD -e \"backup_version=$BACKUP_VERSION\""
ANSIBLE_CMD="$ANSIBLE_CMD -e \"ansible_ssh_private_key_file=~/.ssh/id_rsa\""

if [[ -n "$LIMIT_HOSTS" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$LIMIT_HOSTS\""
fi

if [[ "$ASK_BECOME_PASS" == true ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --ask-become-pass"
fi

if eval $ANSIBLE_CMD; then
    echo "✅ PostgreSQL deployment completed successfully!"
    echo "Database: bpmsoft_$ENVIRONMENT"
    echo "Backup version: $BACKUP_VERSION"
else
    echo "❌ PostgreSQL deployment failed!"
    exit 1
fi
