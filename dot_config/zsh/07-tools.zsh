# Tool initialization
# `fzf --zsh` needs fzf >= 0.48; older distro packages ship key-bindings.zsh instead
if command -v fzf >/dev/null 2>&1 && [[ -t 1 ]]; then
  if _fzf_init="$(fzf --zsh 2>/dev/null)"; then
    eval "$_fzf_init"
  elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
  unset _fzf_init
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Atuin - load last (overrides Ctrl+R)
[[ -r "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v omp >/dev/null 2>&1; then
  eval "$(omp completions zsh)"
fi
