#!/usr/bin/env bash

# AI-powered git status display
# Uses Claude to format git status output with summaries and colors

{
  echo "$(cat ~/dotfiles/claude/commands/gst.md)"
  echo ""
  echo "Do not use markdown formatting in your response. Use plain text only."
  echo ""
  echo "Use minimal colors for terminal use:"
  echo "- Branch name in green"
  echo "- Section headers in blue" 
  echo "- Counts in yellow"
  echo ""
  echo "Current git status:"
  git status
  echo ""
  echo "Current git diff:"
  git diff
} | claude -p
