# Clean TERM variable for fzf
# https://github.com/junegunn/fzf/wiki/Windows
if (Test-Path "Env:\TERM") {
  Remove-Item "Env:\TERM"
}

$env:FZF_DEFAULT_OPTS = "`
    --color fg:11,bg+:7,hl:8,hl+:8 `
    --exit-0 `
    --select-1 `
    --reverse `
    "

# $env:FZF_DEFAULT_OPTS = "`
#     --color fg+:6,bg+:-1,hl:3,hl+:3 `
#     --exit-0 `
#     --select-1 `
#     --reverse `
#     "