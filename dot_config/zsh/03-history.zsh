# History configuration
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt inc_append_history
setopt share_history
