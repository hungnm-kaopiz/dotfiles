# Completion config (BEFORE compinit)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Completions - ONCE, with cache
zcompdump="$_zsh_cache_dir/zcompdump-${ZSH_VERSION}"
mkdir -p "${zcompdump:h}"

# Generated completions go in fpath; compinit autoloads them on first Tab.
# compinit -C reuses the dump without rescanning fpath, so drop it when one changes.
_zsh_comp_dir="$_zsh_cache_dir/functions"
fpath=("$_zsh_comp_dir" $fpath)
_zsh_gen_completion() {
  _zsh_cmd_cache "$_zsh_comp_dir/_$1" "$@" && [[ $REPLY == new ]] && rm -f "$zcompdump"
}
_zsh_gen_completion omp completions zsh
unfunction _zsh_gen_completion

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
