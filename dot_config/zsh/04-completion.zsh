# Completion config (BEFORE compinit)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Completions - ONCE, with cache
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${zcompdump:h}"
autoload -Uz compinit
compinit -C -d "$zcompdump"

# fzf-tab - AFTER compinit
zinit light Aloxaf/fzf-tab

# fzf-tab configuration
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no

if command -v eza >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
else
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
fi

zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 ${(Q)realpath}'
zstyle ':fzf-tab:*' switch-group '<' '>'
