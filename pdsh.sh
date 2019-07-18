# setup pdsh for cluster users
export PDSH_RCMD_TYPE='ssh'
export WCOLL='/etc/pdsh/nodes'
export PDSH_SSH_ARGS_APPEND="-q -o StrictHostKeyChecking=no -o ConnectTimeout=1"
