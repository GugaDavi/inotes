#!/bin/sh

git config core.hooksPath .githooks
chmod +x .githooks/pre-push

echo "✓ Git hooks configured. 'git push' will now run flutter analyze and flutter test."
