#!/bin/bash

# BPMSoft PostgreSQL Deployment Script
# This script handles SSH key setup and PostgreSQL deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="prod"
BACKUP_VERSION="v1.8.0"
INVENTORY="inventory/hosts.yml"
SSH_KEY="~/.ssh/id_rsa"
LIMIT_HOSTS=""
SKIP_UNAVAILABLE=false

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --env ENV           Environment (dev, preprod, prod) [default: prod]"
    echo "  -b, --backup VERSION    Backup version (v1.7.1, v1.8.0) [default: v1.8.0]"
    echo "  -i, --inventory FILE    Inventory file [default: inventory/hosts.yml]"
    echo "  -k, --ssh-key PATH      SSH private key path [default: ~/.ssh/id_rsa]"
    echo "  -l, --limit HOSTS       Limit to specific hosts (comma-separated)"
    echo "  --skip-unavailable      Skip unavailable hosts instead of failing"
    echo "  --ssh-only              Only setup SSH keys, don't deploy PostgreSQL"
    echo "  --no-ssh                Skip SSH setup, use password authentication"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Deploy prod with v1.8.0"
    echo "  $0 -e dev -b v1.7.1                  # Deploy dev with v1.7.1"
    echo "  $0 -l postgresql-company-a-01        # Deploy only specific host"
    echo "  $0 --skip-unavailable                 # Skip unavailable hosts"
    echo "  $0 --ssh-only                         # Only setup SSH keys"
    echo "  $0 --no-ssh -e prod                  # Deploy with password auth"
}

# Parse command line arguments
SSH_ONLY=false
NO_SSH=false

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
        -k|--ssh-key)
            SSH_KEY="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT_HOSTS="$2"
            shift 2
            ;;
        --skip-unavailable)
            SKIP_UNAVAILABLE=true
            shift
            ;;
        --ssh-only)
            SSH_ONLY=true
            shift
            ;;
        --no-ssh)
            NO_SSH=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|preprod|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, preprod, or prod"
    exit 1
fi

# Validate backup version
if [[ ! "$BACKUP_VERSION" =~ ^(v1\.7\.1|v1\.8\.0)$ ]]; then
    print_error "Invalid backup version: $BACKUP_VERSION. Must be v1.7.1 or v1.8.0"
    exit 1
fi

# Check if inventory file exists
if [[ ! -f "$INVENTORY" ]]; then
    print_error "Inventory file not found: $INVENTORY"
    exit 1
fi

# Check if SSH key exists (if not using --no-ssh)
if [[ "$NO_SSH" == false ]] && [[ ! -f "${SSH_KEY/#\~/$HOME}" ]]; then
    print_error "SSH private key not found: $SSH_KEY"
    print_warning "Generate SSH key with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa"
    exit 1
fi

print_status "Starting BPMSoft PostgreSQL deployment..."
print_status "Environment: $ENVIRONMENT"
print_status "Backup version: $BACKUP_VERSION"
print_status "Inventory: $INVENTORY"
if [[ -n "$LIMIT_HOSTS" ]]; then
    print_status "Limited to hosts: $LIMIT_HOSTS"
fi
if [[ "$SKIP_UNAVAILABLE" == true ]]; then
    print_status "Will skip unavailable hosts"
fi

# Step 1: Setup SSH keys (if not skipped)
if [[ "$NO_SSH" == false ]]; then
    print_status "Step 1: Setting up SSH keys..."
    
    # Build ansible command with optional parameters
    ANSIBLE_CMD="ansible-playbook -i \"$INVENTORY\" setup-ssh.yml --ask-pass"
    
    if [[ -n "$LIMIT_HOSTS" ]]; then
        ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$LIMIT_HOSTS\""
    fi
    
    if [[ "$SKIP_UNAVAILABLE" == true ]]; then
        ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags unavailable"
    fi
    
    if eval $ANSIBLE_CMD --ask-become-pass; then
        print_status "SSH keys successfully configured!"
    else
        print_error "Failed to setup SSH keys"
        exit 1
    fi
else
    print_warning "Skipping SSH setup, using password authentication"
fi

# Exit if only SSH setup was requested
if [[ "$SSH_ONLY" == true ]]; then
    print_status "SSH setup completed. Exiting."
    exit 0
fi

# Step 2: Deploy PostgreSQL
print_status "Step 2: Deploying PostgreSQL..."

# Build ansible command for main deployment
ANSIBLE_CMD="ansible-playbook -i \"$INVENTORY\" playbook.yml"
ANSIBLE_CMD="$ANSIBLE_CMD -e \"env=$ENVIRONMENT\""
ANSIBLE_CMD="$ANSIBLE_CMD -e \"backup_version=$BACKUP_VERSION\""
ANSIBLE_CMD="$ANSIBLE_CMD -e \"ssh_private_key=$SSH_KEY\""

if [[ -n "$LIMIT_HOSTS" ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --limit \"$LIMIT_HOSTS\""
fi

if [[ "$SKIP_UNAVAILABLE" == true ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --skip-tags unavailable"
fi

if [[ "$NO_SSH" == true ]]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --ask-pass"
fi

if eval $ANSIBLE_CMD --ask-become-pass; then
    print_status "PostgreSQL deployment completed successfully!"
    print_status "Database: bpmsoft_$ENVIRONMENT"
    print_status "Backup version: $BACKUP_VERSION"
    print_status "You can now connect to PostgreSQL on your servers"
else
    print_error "PostgreSQL deployment failed!"
    exit 1
fi

if [[ $? -eq 0 ]]; then
    print_status "PostgreSQL deployment completed successfully!"
    print_status "Database: bpmsoft_$ENVIRONMENT"
    print_status "Backup version: $BACKUP_VERSION"
    print_status "You can now connect to PostgreSQL on your servers"
else
    print_error "PostgreSQL deployment failed!"
    exit 1
fi
