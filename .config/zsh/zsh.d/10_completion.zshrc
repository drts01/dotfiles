ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/.zcompdump"
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p "${ZSH_COMPDUMP:h}"

autoload -Uz compinit
_zcomp_stale=("$ZSH_COMPDUMP"(N.mh+24))
if [[ -s $ZSH_COMPDUMP ]] && (( ! ${#_zcomp_stale} )); then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -i -d "$ZSH_COMPDUMP"
  zcompile "$ZSH_COMPDUMP"
fi
unset _zcomp_stale
