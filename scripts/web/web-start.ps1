#!/usr/bin/env pwsh

Param([string]$name)

if ( !$name ) {
  Write-Host "Missing sandbox name"
} else {
  Set-Location (Join-Path  "${env:HOME}" "sandbox" )

  if ($null -eq (Get-Command "pollinate" -ErrorAction SilentlyContinue)) {
    Write-Host "I require 'pollinate' but it's not installed. Aborting."
    exit 1
  }

  pollinate (Join-Path "${env:HOME}" "code" "web-start") --name $name

  Set-Location $name

  git init
  git add .
  git commit -m "Initial commit"

  code .
  code --reuse-window index.html style.css script.js

  browser-sync start --server --files . --no-notify --open .
}