HB_ARM_PREFIX='/opt/homebrew/bin/brew'
if command -v brew > /dev/null; then
  eval "$(brew shellenv)"
elif [ -x "${HB_ARM_PREFIX}" ]; then
  eval "$(${HOMEBREW_ARM_PREFIX} shellenv)"
fi
