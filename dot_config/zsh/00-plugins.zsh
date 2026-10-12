# Zinit installation
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME/.git" ] && git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# OMZ libs (cherry-picked)
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::theme-and-appearance.zsh

# eza (only if installed)
if command -v eza >/dev/null 2>&1; then
  zstyle ':omz:plugins:eza' 'dirs-first' yes
  zstyle ':omz:plugins:eza' 'git-status' yes
  zstyle ':omz:plugins:eza' 'header' yes
  zstyle ':omz:plugins:eza' 'icons' yes
  zinit snippet OMZP::eza
fi

# Zsh plugins (before compinit is OK for these)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
