for P in "${HOME}/bin" "${HOME}/.local/bin"; do
  [ -d "${P}" ] && PATH="${P}${PATH+:$PATH}"
done
