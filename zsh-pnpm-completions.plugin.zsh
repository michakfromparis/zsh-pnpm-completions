0=${(%):-%N}
source ${0:A:h}/zsh-pnpm-completions.zsh

if [[ -z "$ZSH_PNPM_NO_ALIASES" ]]; then
  source ${0:A:h}/zsh-pnpm-aliases.zsh
  # Real `p` executable, so wrappers like nohup, env or xargs can run it
  path=(${path:#${0:A:h}/bin} ${0:A:h}/bin)
fi
