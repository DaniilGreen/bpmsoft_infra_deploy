#!/bin/bash

# BPMSoft deployment script
# Usage: ./deploy-bpmsoft.sh [--ask-pass] [--limit host]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ASK_PASS_FLAG=""
LIMIT_FLAG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --ask-pass)
      ASK_PASS_FLAG="--ask-pass"
      shift
      ;;
    --limit)
      LIMIT_FLAG="--limit $2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${GREEN}🚀 Starting BPMSoft environment deployment${NC}"

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

# Add limit flag if provided
if [ -n "$LIMIT_FLAG" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $LIMIT_FLAG"
fi

echo -e "${YELLOW}Running command: ${ANSIBLE_CMD}${NC}"
echo ""

# Execute the playbook
eval $ANSIBLE_CMD

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ BPMSoft environment deployment completed successfully!${NC}"
    echo -e "${GREEN}🔗 BPMSoft is ready for application deployment${NC}"
    echo -e "${YELLOW}💡 Next step: Copy BPMSoft application files to {{ bpmsoft_home_dir }}${NC}"
else
    echo -e "${RED}❌ BPMSoft environment deployment failed!${NC}"
    exit 1
fi
