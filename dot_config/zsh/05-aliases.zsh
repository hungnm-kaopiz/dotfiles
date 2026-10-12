# Shell aliases
alias grep='grep --color=auto'
alias cls='clear'
alias mv='mv -iv'
alias cp='cp -riv'
alias mkdir='mkdir -vp'
alias ld='lazydocker'
alias cc='claude --permission-mode bypassPermissions'
alias cx='codex --dangerously-bypass-approvals-and-sandbox'
alias hd="herdr"

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
  alias tree='eza -T'
fi

if command -v trash-put >/dev/null 2>&1; then
  alias rm='trash-put'
  alias tp='trash-put'
  alias tl='trash-list'
  alias tr='trash-restore'
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

alias reload='exec zsh'
alias path='print -rl -- $path'
