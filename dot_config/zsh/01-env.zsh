# Environment variables and PATH
export PAGER="${PAGER:-less}"
export EDITOR="${EDITOR:-vi}"
export VISUAL="${VISUAL:-$EDITOR}"

typeset -U path PATH

[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)

# opencode
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)

# bun global packages
[[ -d "$HOME/.cache/.bun/bin" ]] && path=("$HOME/.cache/.bun/bin" $path)
