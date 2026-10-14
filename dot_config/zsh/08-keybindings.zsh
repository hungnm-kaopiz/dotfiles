# Key bindings (Delete/Home/End send escape sequences zsh doesn't bind by default, e.g. on Fedora)
bindkey '^[[3~' delete-char
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
