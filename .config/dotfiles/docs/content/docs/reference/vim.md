+++
title = "Vim settings"
description = "Fallback Vim files, package gates, mappings, and optional CLI tools."
weight = 75

[extra]
type = "reference"
+++

Vim is the fallback editor; Helix remains primary.
The base configuration supports Vim 8 or newer and starts without packages.
Configuration: {{<source path=".config/vim/" />}}.

## Files

| Path | Contents |
| ---- | -------- |
| `.config/vim/vimrc` | Managed configuration; no `~/.vimrc` |
| `.config/vim/pack/plugins/start/` | Pinned shallow package submodules loaded at startup |
| `.config/vim/pack/plugins/opt/` | Pinned shallow packages loaded conditionally or explicitly |
| `$XDG_STATE_HOME/vim/` | Private `backup/`, `swap/`, and `undo/` recovery directories |

The state root defaults to `~/.local/state/vim` when `XDG_STATE_HOME` is unset or empty.
New recovery directories are created with mode `0700`.
Existing vim-plug content in `~/.vim` is untouched but unused by the managed configuration.

The shell defines `vim()` only when the Vim executable and
`${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc` exist.
The wrapper sets a process-local `VIMINIT` expression to source the file through `fnameescape()`
only when the caller has not set `VIMINIT`; an existing value, including an empty one, is preserved.
No global `VIMINIT` is exported: Neovim also consumes it, so a global value could load Vim configuration in `nvim`.
The wrapper leaves `nvim` unaffected.

`command vim` bypasses the wrapper and uses native configuration discovery.
Scripts launching older Vim outside the configured shell require an explicit `-u` path;
see [Load the configuration](@/docs/how-to/vim.md#load-the-configuration).

## Packages

The `vim` plugin group covers both `start/` and `opt/` under `.config/vim/pack/plugins`.
The installer selects it with `auto` or `all` when `vim` is installed, or explicitly with `DOTFILES_SUBMODULES=vim`.
Bootstrap regenerates help tags; failures are warnings, not deployment failures.

| Package | Directory | Loading and purpose |
| ------- | --------- | ------------------- |
| `vim-fugitive` | `start/` | Git commands such as `:Git` |
| `vim-gitgutter` | `start/` | Diff signs and hunk actions |
| `vim-repeat` | `start/` | Repeatable GitGutter actions; pinned shallow submodule |
| `fzf` | `start/` | Vim runtime integration, separate from the `fzf` binary |
| `fzf.vim` | `start/` | Pickers including `:Files`, `:Buffers`, `:Rg`, `:Commits`, and `:BCommits` |
| `lightline.vim` | `start/` | Status line with the `wombat` theme and default components |
| `ale` | `start/` | CLI linting, explicit fixes, and diagnostics from the separate LSP client; the built-in ALE LSP client disabled with `ale_disable_lsp=1` |
| `vim-fern` | `opt/` | Loaded automatically on Vim 8.2.5136 or newer; tree opens only on demand |
| `editorconfig-vim` | `opt/` | Automatic fallback only when no bundled EditorConfig implementation is available |
| `lsp` | `opt/` | Vim 9+ client; enabled explicitly per session with `:VimLspEnable` |

Packages are optional; no plugin manager or `fzf` installer runs at Vim startup.

## Defaults

| Setting | Value |
| ------- | ----- |
| Leader | `,` |
| Line numbers | Absolute current line and relative surrounding lines |
| Splits | Below and right |
| Indentation | Literal tabs, 4 columns; EditorConfig may override |
| Search | Incremental, highlighted, case-insensitive unless uppercase is present |
| Base colors | `desert`, dark background |
| Status line | Built-in fallback; `lightline.vim` with `wombat` when initialized |
| Save formatting | No ALE fixers or LSP formatting on save; ALE fixers run explicitly with `,a` |
| Save whitespace cleanup | Trailing whitespace removed from modifiable normal buffers except Markdown |

## Mappings

Mappings use normal mode. Package mappings require initialized packages and their tools.

| Keys | Action | Requirement |
| ---- | ------ | ----------- |
| `,w` | Write | Base Vim |
| `,q` | Quit | Base Vim |
| `,Space` | Clear search highlighting | Base Vim |
| `Ctrl-h`, `Ctrl-j`, `Ctrl-k`, `Ctrl-l` | Move between splits | Base Vim |
| `F5` | List buffers and prompt for a buffer | Base Vim |
| `Q` | Format text with `gq` | Base Vim |
| `,n` | Toggle Fern drawer, or `:Explore` with `netrw` | Fern on supported Vim; `netrw` otherwise |
| `Ctrl-p` | `:Files` | `fzf` runtime, `fzf.vim`, and `fzf` binary |
| `,b` | `:Buffers` | `fzf` runtime, `fzf.vim`, and `fzf` binary |
| `,f` | `:Rg` | `fzf` runtime, `fzf.vim`, `fzf` binary, and `rg` |
| `,a` | `:ALEFix` | ALE and a configured fixer executable |
| `[e`, `]e` | Previous or next diagnostic | ALE |
| `[c`, `]c` | Previous or next hunk | GitGutter |
| `,hp` | Preview hunk | GitGutter |
| `,hs` | Stage hunk | GitGutter |
| `,hu` | Undo hunk; discards that hunk's working-tree changes | GitGutter; destructive |

Fugitive supplies `:Git` and related Git commands.
fzf.vim supplies repository history with `:Commits` and current-file history with `:BCommits`.

## External tools

Executables are reused from `PATH`, including mise-managed tools.
No language server or other binary is downloaded by the Vim configuration.

| Executable | Use |
| ---------- | --- |
| `git` | Fugitive, GitGutter, and Git history pickers |
| `fzf` | Pickers; upstream minimum 0.54.0, with newer features potentially requiring a newer binary; installed through mise |
| `rg` | `:Rg` text search |
| `ruff` | Python CLI linting and `ruff` / `ruff_format` ALE fixers |
| `shellcheck` | Shell CLI linting for the `sh` file type |
| `shfmt` | Explicit shell fixes through ALE |

The `fzf` binary, `fzf` runtime submodule, and `fzf.vim` submodule are separate dependencies.
The base editor remains usable without them or mise.

## Language servers

LSP is off by default and requires Vim 9+, the `lsp` package, and `:VimLspEnable` in each session.
Only executable servers are registered.

| Executable | File types |
| ---------- | --------- |
| `bash-language-server` | `sh`, `bash` |
| `yaml-language-server` | `yaml` |
| `marksman` | `markdown` |
| `ty` | `python` |

For Python, `ty` supplies language-server features; Ruff supplies CLI linting and explicit fixes through ALE.
The LSP client sets `aleSupport` to `true` when ALE is installed, routing its diagnostics through ALE.
The `ale_disable_lsp=1` setting disables language-server management in ALE, not this diagnostic integration.
The separate LSP client owns server processes; ALE does not start duplicate servers, and Ruff CLI linting remains enabled.

## Related

- [Use Vim as a fallback](@/docs/how-to/vim.md)
- [Plugin groups](@/docs/reference/environment.md#plugin-groups)
