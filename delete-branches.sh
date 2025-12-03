#!/bin/bash

# Script to delete all local and remote branches except main
# Usage: ./delete-branches.sh

set -e  # Exit on error

echo "🗑️  Deleting all branches except 'main'..."
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Warn if not on main
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Warning: You are currently on branch '$CURRENT_BRANCH', not 'main'"
    echo "   This script will delete all branches except 'main'"
    read -p "   Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted"
        exit 1
    fi
fi

echo "📋 Local branches to delete:"
LOCAL_BRANCHES=$(git branch | grep -v "^\*" | grep -v "main" | sed 's/^[[:space:]]*//')
if [ -z "$LOCAL_BRANCHES" ]; then
    echo "   (none)"
else
    echo "$LOCAL_BRANCHES" | sed 's/^/   - /'
fi

echo ""
echo "📋 Remote branches to delete:"
REMOTE_BRANCHES=$(git branch -r | grep -v "origin/main" | grep -v "origin/HEAD" | sed 's/origin\///' | sed 's/^[[:space:]]*//')
if [ -z "$REMOTE_BRANCHES" ]; then
    echo "   (none)"
else
    echo "$REMOTE_BRANCHES" | sed 's/^/   - /'
fi

echo ""
read -p "⚠️  Are you sure you want to delete these branches? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted"
    exit 1
fi

echo ""
echo "🗑️  Deleting local branches..."
if [ -n "$LOCAL_BRANCHES" ]; then
    echo "$LOCAL_BRANCHES" | xargs -r git branch -D
    echo "✅ Local branches deleted"
else
    echo "   (no local branches to delete)"
fi

echo ""
echo "🗑️  Deleting remote branches..."
if [ -n "$REMOTE_BRANCHES" ]; then
    echo "$REMOTE_BRANCHES" | xargs -r -I {} git push origin --delete {}
    echo "✅ Remote branches deleted"
else
    echo "   (no remote branches to delete)"
fi

echo ""
echo "✨ Done! Only 'main' branch remains."
echo ""
echo "Current branches:"
git branch
echo ""
git branch -r

