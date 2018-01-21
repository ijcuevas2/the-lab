setopt PROMPT_SUBST
PROMPT='%B%F{red}%n@%m%f%F{yellow}[%D{%L:%M:%S}]%f:%F{blue}${${(%):-%~}}%f
$ %b'
TMOUT=1

TRAPALRM() {
    zle reset-prompt
}

alias python='/anaconda3/bin/python'
alias python3='/anaconda3/bin/python'
alias pythonw='/anaconda3/bin/pythonw'
alias pip='/anaconda3/bin/pip'
alias p='pwd | pbcopy'
alias tmux='tmux -2'
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=${PATH}:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
# alias vim='nvim'
alias s='pmset sleepnow'
alias l='ls'
alias ll='ls -lt'
alias la='ls -a'
set -o vi
alias history='history 0'
bindkey '^R' history-incremental-search-backward
