#!/bin/bash

# Redis deployment script for BPMSoft
# Usage: ./deploy-redis.sh [--ask-pass]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ASK_PASS_FLAG=${1:-""}

echo -e "${GREEN}🚀 Starting Redis deployment for BPMSoft${NC}"

# Check if inventory file exists
if [ ! -f "inventory/hosts.yml" ]; then
    echo -e "${RED}❌ Inventory file not found: inventory/hosts.yml${NC}"
    exit 1
fi

# Check if playbook exists
if [ ! -f "playbook.yml" ]; then
    echo -e "${RED}❌ Playbook not found: playbook.yml${NC}"
    exit 1
fi

# Build ansible-playbook command
ANSIBLE_CMD="ansible-playbook -i inventory/hosts.yml playbook.yml -e ansible_ssh_private_key_file=~/.ssh/id_rsa"

# Add ask-pass flag if provided
if [ "$ASK_PASS_FLAG" = "--ask-pass" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --ask-pass"
fi

echo -e "${YELLOW}Running command: ${ANSIBLE_CMD}${NC}"
echo ""

# Execute the playbook
eval $ANSIBLE_CMD

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Redis deployment completed successfully!${NC}"
    echo -e "${GREEN}🔗 Redis is available on port 6379${NC}"
    echo -e "${YELLOW}💡 To test Redis connection: redis-cli -h <host> -p 6379${NC}"
else
    echo -e "${RED}❌ Redis deployment failed!${NC}"
    exit 1
fi
