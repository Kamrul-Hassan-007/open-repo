#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/bin:$PATH"



# Enable advanced tab completion
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# Arrow-key friendly completion
bind '"\e[Z": menu-complete-backward'
bind 'set completion-ignore-case on'

# History search with up/down arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
