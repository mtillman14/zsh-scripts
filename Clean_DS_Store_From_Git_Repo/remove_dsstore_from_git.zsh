#!/usr/bin/env zsh

# Ensure the script is run inside a git repository
if [[ ! -d .git ]]; then
  echo "Error: This script must be run from the root of a Git repository."
  exit 1
fi

# Step 1: Add .DS_Store to .gitignore if it's not already present
if ! grep -q "^.DS_Store$" .gitignore; then
  echo ".DS_Store" >> .gitignore
  echo ".DS_Store added to .gitignore"
else
  echo ".DS_Store already exists in .gitignore"
fi

# Step 2: Remove .DS_Store files from the Git cache (but keep them locally)
git rm --cached '*.DS_Store'
echo "Removed .DS_Store files from Git cache"

# Step 3: Commit the changes
git commit -m "Remove .DS_Store files and add to .gitignore"
echo "Committed changes"

# Step 4: Push the changes
current_branch=$(git rev-parse --abbrev-ref HEAD)
git push origin "$current_branch" --force
echo "Pushed changes to remote branch: $current_branch"
