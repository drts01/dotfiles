
# Check for default Mac ARM Homebrew path
HB_PREFIX='/opt/homebrew'
if [ -d "${HB_PREFIX}/bin" ]; then
  PATH="${HB_PATH}/bin:"${HB_PATH}/sbin:${PATH}"
end
