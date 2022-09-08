HB_ARM_PREFIX='/opt/homebrew/bin/brew'  # Default path for ARM
if command -v brew > /dev/null; then
  eval "$(brew shellenv)"
elif [ -x "${HB_ARM_PREFIX}" ]; then
  eval "$(${HB_ARM_PREFIX} shellenv)"
fi
