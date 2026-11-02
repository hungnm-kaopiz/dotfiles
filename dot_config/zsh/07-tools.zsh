# Tool initialization (init scripts cached by 01-cache.zsh)
# `fzf --zsh` needs fzf >= 0.48; older distro packages ship key-bindings.zsh instead
if command -v fzf >/dev/null 2>&1 && [[ -t 1 ]]; then
  if _zsh_cached_init fzf --zsh; then
    source "$_zsh_init"
  elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
fi

_zsh_cached_init zoxide init zsh && source "$_zsh_init"
_zsh_cached_init starship init zsh && source "$_zsh_init"

# Atuin - load last (overrides Ctrl+R)
[[ -r "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
_zsh_cached_init -d "${XDG_CONFIG_HOME:-$HOME/.config}/atuin/config.toml" atuin init zsh && source "$_zsh_init"

# Not cached: its output bakes in the current $PATH
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# omp completions: generated into fpath by 04-completion.zsh
unset _zsh_init
