телю#!/bin/bash

# Test script for SSH key setup
echo "🔑 Testing SSH key setup..."

# Check if SSH key exists
if [[ -f ~/.ssh/id_rsa ]]; then
    echo "✅ SSH private key found: ~/.ssh/id_rsa"
else
    echo "❌ SSH private key not found!"
    exit 1
fi

if [[ -f ~/.ssh/id_rsa.pub ]]; then
    echo "✅ SSH public key found: ~/.ssh/id_rsa.pub"
else
    echo "❌ SSH public key not found!"
    exit 1
fi

# Display public key
echo ""
echo "📋 Your public key (copy this to servers):"
echo "----------------------------------------"
cat ~/.ssh/id_rsa.pub
echo "----------------------------------------"

# Test SSH key format
echo ""
echo "🔍 Testing SSH key format..."
if ssh-keygen -l -f ~/.ssh/id_rsa.pub > /dev/null 2>&1; then
    echo "✅ SSH key format is valid"
else
    echo "❌ SSH key format is invalid!"
    exit 1
fi

echo ""
echo "🎉 SSH key setup is ready!"
echo "You can now use this key for all your deployments."
