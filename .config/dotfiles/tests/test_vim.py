"""Exercise Vim startup and recovery in disposable, offline homes."""

import os
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
VIM = shutil.which("vim")


@unittest.skipUnless(VIM, "vim executable unavailable")
class VimTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="vim test ")
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.config = self.home / "config" / "vim"
        self.config.mkdir(parents=True)
        shutil.copyfile(ROOT / ".config/vim/vimrc", self.config / "vimrc")
        self.bin = self.home / "bin"
        self.bin.mkdir()
        for tool in ("curl", "wget", "git"):
            executable = self.bin / tool
            executable.write_text("#!/bin/sh\necho unexpected-external-command >&2\nexit 99\n")
            executable.chmod(0o700)
        self.environment = {
            "HOME": str(self.home),
            "PATH": str(self.bin),
            "XDG_CONFIG_HOME": str(self.config.parent),
            "XDG_STATE_HOME": str(self.home / "state"),
        }
        self.target = self.home / "sample.txt"
        self.target.write_text("original\n")

    def run_vim(self, commands, *, explicit=True, environment=None, pre_commands=None):
        script = self.home / "check.vim"
        script.write_text(
            commands + "\n"
            "if !empty(v:errmsg) | call add(v:errors, v:errmsg) | endif\n"
            "if !empty(v:errors)\n"
            " call writefile(v:errors, 'errors')\n"
            " cquit\n"
            "endif\nqa!\n"
        )
        arguments = [
            VIM, "-N", "-V1", "-i", "NONE", "-T", "dumb",
                        "--cmd", "set lines=40 columns=120 nomore shortmess+=I",
        ]
        if explicit:
            arguments += ["-es", "-u", str(self.config / "vimrc")]
        if pre_commands:
            arguments += ["--cmd", pre_commands]
        result = subprocess.run(
            [*arguments, str(self.target), "-S", str(script)],
            cwd=self.home,
            env=self.environment if environment is None else environment,
            capture_output=True,
            input="\n",
            text=True,
            timeout=20,
        )
        errors = self.home / "errors"
        self.assertEqual(
            result.returncode, 0,
            result.stdout + result.stderr + (errors.read_text() if errors.exists() else ""),
        )
        self.assertNotIn("unexpected-external-command", result.stderr)
        self.assertFalse((self.home / ".vimrc").exists())
        self.assertFalse((self.home / ".vim").exists())
        return result

    def test_fresh_home_saves_and_creates_private_recovery(self):
        self.run_vim(
            "call assert_true(!empty(swapname('%')))\n"
            "call setline(1, 'changed')\nwrite\n"
            "call assert_equal(1, &backup)\n"
            "call assert_equal(1, &undofile)"
        )
        self.assertEqual(self.target.read_text(), "changed\n")
        for kind in ("backup", "swap", "undo"):
            directory = self.home / "state/vim" / kind
            self.assertEqual(stat.S_IMODE(directory.stat().st_mode), 0o700)
        backups = list((self.home / "state/vim/backup").iterdir())
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "original\n")
        self.assertTrue(list((self.home / "state/vim/undo").iterdir()))
        self.run_vim("undo\ncall assert_equal('original', getline(1))")

    def test_state_home_fallback(self):
        environment = self.environment.copy()
        environment.pop("XDG_STATE_HOME")
        self.run_vim("call setline(1, 'changed')\nwrite", environment=environment)
        self.assertTrue((self.home / ".local/state/vim/undo").is_dir())

    def test_reload_preserves_search_view_and_single_save_handler(self):
        self.run_vim(
            "source " + str(self.config / "vimrc").replace(" ", "\\ ") + "\n"
            "call setline(1, ['one  ', 'two  ', 'three'])\n"
            "call cursor(2, 2)\nlet @/ = 'keep-search'\n"
            "redraw\nlet view = winsaveview()\nwrite\n"
            "call assert_equal(view, winsaveview())\n"
            "call assert_equal('keep-search', @/)\n"
            "call assert_equal(['one', 'two', 'three'], getline(1, '$'))\n"
            "let handlers = execute('autocmd dotfiles_vim BufWritePre')\n"
            "call assert_equal(1, count(handlers, 'StripTrailingWhitespace'))\n"
            "call assert_equal(1, &showmode)\n"
            "call assert_equal(':Explore<CR>', maparg(',n', 'n'))"
        )

    def test_xdg_discovery_on_supported_vim(self):
        version = subprocess.run([VIM, "--version"], capture_output=True, text=True, timeout=5)
        if '"$XDG_CONFIG_HOME/vim/vimrc"' not in version.stdout:
            self.skipTest("Vim does not advertise XDG vimrc discovery")
        self.run_vim("call assert_equal(',', g:mapleader)", explicit=False)

    def install_packages(self):
        packages = ROOT / '.config/vim/pack/plugins'
        if not (packages / 'start/ale/plugin/ale.vim').is_file():
            self.skipTest('Initialize Vim package submodules for integration tests')
        (self.config / 'pack').symlink_to(packages.parent, target_is_directory=True)
        (self.bin / 'git').unlink()
        self.environment['PATH'] += os.pathsep + os.defpath

    def test_packages_load_without_optional_executables(self):
        self.install_packages()
        self.run_vim(
            "doautocmd VimEnter\n"
            "call assert_equal(2, exists(':Git'))\n"
            "call assert_equal(2, exists(':GitGutter'))\n"
            "call assert_equal(2, exists(':ALEInfo'))\n"
            "call assert_equal(2, exists(':Files'))\n"
            "call assert_equal(0, &showmode)\n"
            "call assert_equal(0, exists('g:loaded_lsp'))\n"
            "call assert_equal(1, g:ale_disable_lsp)\n"
            "call assert_equal(['ruff'], g:ale_linters.python)\n"
            "call assert_true(g:ale_sign_priority > g:gitgutter_sign_priority)\n"
            "call assert_equal('', maparg('<C-p>', 'n'))\n"
            "if has('patch-8.2.5136') | call assert_equal(2, exists(':Fern')) | endif\n"
            "call setline(1, 'changed')\nwrite"
        )

    def test_fuzzy_mappings_require_available_executables(self):
        self.install_packages()
        for name in ('fzf', 'rg'):
            executable = self.bin / name
            executable.write_text('#!/bin/sh\nexit 0\n')
            executable.chmod(0o700)
        self.run_vim(
            "doautocmd VimEnter\n"
            "call assert_equal(':Files<CR>', maparg('<C-p>', 'n'))\n"
            "call assert_equal(':Buffers<CR>', maparg(',b', 'n'))\n"
            "call assert_equal(':Rg<CR>', maparg(',f', 'n'))"
        )

    def test_gitgutter_previews_and_stages_buffer_changes(self):
        self.install_packages()
        commands = (
            ['git', 'init', '-q'],
            ['git', 'add', 'sample.txt'],
            ['git', '-c', 'user.name=Vim test', '-c', 'user.email=vim@example.invalid',
             '-c', 'commit.gpgsign=false', 'commit', '-qm', 'fixture'],
        )
        for command in commands:
            subprocess.run(command, cwd=self.home, env=self.environment,
                           check=True, capture_output=True, timeout=15)
        self.run_vim(
            "call setline(1, 'changed')\nGitGutter\n"
            "for attempt in range(100)\n"
            " if GitGutterGetHunkSummary()[1] == 1 | break | endif\n"
            " sleep 20m\n"
            "endfor\n"
            "call assert_equal([0, 1, 0], GitGutterGetHunkSummary())\n"
            "GitGutterPreviewHunk\n"
            "GitGutterStageHunk"
        )
        result = subprocess.run(['git', 'show', ':sample.txt'], cwd=self.home,
                                env=self.environment, check=True,
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.stdout, 'changed\n')
        self.assertEqual(self.target.read_text(), 'original\n')

    def test_editorconfig_controls_indentation_and_preserves_make_tabs(self):
        self.install_packages()
        (self.home / '.editorconfig').write_text(
            'root = true\n[*.sh]\nindent_style = space\nindent_size = 2\n'
            '[*.py]\nindent_style = tab\nindent_size = 8\n'
        )
        (self.home / 'sample.sh').write_text('echo hello\n')
        (self.home / 'sample.py').write_text('print("hello")\n')
        (self.home / 'Makefile').write_text('all:\n\techo hello\n')
        self.run_vim(
            "edit sample.sh\n"
            "call assert_equal(2, &shiftwidth)\n"
            "call assert_equal(1, &expandtab)\n"
            "edit Makefile\n"
            "call assert_equal(0, &expandtab)"
        )
        self.run_vim(
            "edit sample.py\n"
            "call assert_equal(8, &shiftwidth)\n"
            "call assert_equal(0, &expandtab)",
            pre_commands="set packpath= noloadplugins",
        )

    def test_lsp_remains_disabled_without_packages_or_servers(self):
        self.run_vim("VimLspEnable\ncall assert_equal(0, exists('g:loaded_lsp'))")
        self.install_packages()
        self.run_vim("VimLspEnable\ncall assert_equal(0, exists('g:loaded_lsp'))")

    def test_lsp_registers_available_servers_only_once(self):
        version = subprocess.run([VIM, '--version'], capture_output=True, text=True, timeout=5)
        if '+vim9script' not in version.stdout:
            self.skipTest('LSP requires Vim9 script')
        self.install_packages()
        server = self.bin / 'ty'
        server.write_text(f"#!{sys.executable}\n" + '''
import json
import sys
from pathlib import Path

while True:
    headers = {}
    while line := sys.stdin.buffer.readline():
        if line == b"\\r\\n":
            break
        name, value = line.decode().split(":", 1)
        headers[name.lower()] = value.strip()
    if not headers:
        break
    message = json.loads(sys.stdin.buffer.read(int(headers["content-length"])))
    if message.get("method") == "initialized":
        Path("lsp-initialized").write_text("ready")
    if "id" in message:
        result = {"capabilities": {}} if message.get("method") == "initialize" else None
        body = json.dumps({"jsonrpc": "2.0", "id": message["id"], "result": result}).encode()
        sys.stdout.buffer.write(f"Content-Length: {len(body)}\\r\\n\\r\\n".encode() + body)
        sys.stdout.buffer.flush()
''')
        server.chmod(0o700)
        self.run_vim(
            "call assert_equal(0, exists('g:loaded_lsp'))\n"
            "setfiletype python\n"
            "VimLspEnable\n"
            "for attempt in range(100)\n"
            " if filereadable('lsp-initialized') | break | endif\n"
            " sleep 20m\n"
            "endfor\n"
            "call assert_true(filereadable('lsp-initialized'))\n"
            "call assert_equal(1, g:dotfiles_lsp_enabled)\n"
            "call assert_equal(2, exists(':LspGotoDefinition'))\n"
            "call assert_equal(1, LspOptionsGet().aleSupport)\n"
            "VimLspEnable\n"
            "call assert_equal(1, g:dotfiles_lsp_enabled)"
        )

    def test_viminit_discovery(self):
        environment = self.environment.copy()
        environment["VIMINIT"] = (
            "execute 'source ' . fnameescape($XDG_CONFIG_HOME . '/vim/vimrc')"
        )
        self.run_vim("call assert_equal(',', g:mapleader)", explicit=False, environment=environment)


if __name__ == "__main__":
    unittest.main()
