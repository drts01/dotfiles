# shellcheck shell=sh

Describe 'SSH agent forwarding defaults'
Skip if 'SSH is not installed' skip_shell ssh
Before 'setup_home'
After 'cleanup_home'

forwarding_setting() {
  run_isolated ssh -G -F "$ROOT/.ssh/config" "$@" audit.example.invalid 2> /dev/null |
    grep '^forwardagent '
}

It 'does not forward the agent to arbitrary hosts'
When run forwarding_setting
The status should be success
The output should equal 'forwardagent no'
End

It 'allows an explicit per-connection opt-in'
When run forwarding_setting -A
The status should be success
The output should equal 'forwardagent yes'
End
End
