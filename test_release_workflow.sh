#!/bin/bash

# Test script to verify the GitHub Action release workflow
# This script will simulate the expected behavior of the automated release process

set -e  # Exit on any error

echo "🔍 Testing GitHub Action Release Workflow..."

# Check if CHANGELOG.md exists
if [[ ! -f "CHANGELOG.md" ]]; then
    echo "❌ ERROR: CHANGELOG.md not found!"
    exit 1
fi

echo "✅ CHANGELOG.md exists"

# Extract version from CHANGELOG.md (top entry)
VERSION=$(grep -m 1 "^\## \[.*\].*" CHANGELOG.md | head -1 | sed -E 's/^\## \[(.*)\].*/\1/')

if [[ -z "$VERSION" ]]; then
    echo "❌ ERROR: Could not find version in CHANGELOG.md"
    exit 1
fi

echo "✅ Found version in CHANGELOG.md: $VERSION"

# Validate version format (X.Y.Z)
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    echo "❌ ERROR: Invalid version format found in CHANGELOG.md: $VERSION"
    exit 1
fi

echo "✅ Version format is valid: $VERSION"

# Check if git tag exists
TAG_EXISTS=$(git tag --list | grep "^v$VERSION$" || true)

if [[ -n "$TAG_EXISTS" ]]; then
    echo "⚠️  Warning: Tag v$VERSION already exists"
else
    echo "✅ Tag v$VERSION does not exist yet (expected for new releases)"
fi

# Simulate the GitHub Action process
echo ""
echo "🚀 Simulating GitHub Action Release Process:"
echo "   1. Extract version from CHANGELOG.md: $VERSION"
echo "   2. Verify version exists in CHANGELOG.md: ✅"
echo "   3. Create git tag v$VERSION: (would happen in GitHub Actions)"
echo "   4. Generate GitHub release: (would happen in GitHub Actions)"

# Show the top entry from CHANGELOG.md
echo ""
echo "📋 Top entry from CHANGELOG.md:"
echo "$(grep -A 10 "^\## \[$VERSION\]" CHANGELOG.md | head -15)"

echo ""
echo "✅ Test completed successfully!"
echo "📝 To test the full workflow:"
echo "   1. Update CHANGELOG.md with a new version entry"
echo "   2. Create a PR from your feature branch to develop"
echo "   3. When ready, create a release branch from develop"
echo "   4. Create a PR from release branch to main/master"
echo "   5. Upon merging to main/master, GitHub Actions will:"
echo "      - Extract version from CHANGELOG.md"
echo "      - Create git tag v<version>"
echo "      - Generate GitHub release"