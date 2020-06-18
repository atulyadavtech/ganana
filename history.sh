######History Mgmt ##############
export HISTSIZE=10000
export HISTCONTROL=erasedups
export HISTTIMEFORMAT='%F %T    '
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
