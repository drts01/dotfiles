"""Exercise Vim startup and recovery in disposable, offline homes."""

import os
import shutil
import stat
import subprocess
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

    def run_vim(self, commands, *, explicit=True, environment=None):
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

    def test_editorconfig_controls_indentation_and_preserves_make_tabs(self):
        self.install_packages()
        (self.home / '.editorconfig').write_text(
            'root = true\n[*.sh]\nindent_style = space\nindent_size = 2\n'
        )
        (self.home / 'sample.sh').write_text('echo hello\n')
        (self.home / 'Makefile').write_text('all:\n\techo hello\n')
        self.run_vim(
            "edit sample.sh\n"
            "call assert_equal(2, &shiftwidth)\n"
            "call assert_equal(1, &expandtab)\n"
            "edit Makefile\n"
            "call assert_equal(0, &expandtab)"
        )

    def test_viminit_discovery(self):
        environment = self.environment.copy()
        environment["VIMINIT"] = (
            "execute 'source ' . fnameescape($XDG_CONFIG_HOME . '/vim/vimrc')"
        )
        self.run_vim("call assert_equal(',', g:mapleader)", explicit=False, environment=environment)


if __name__ == "__main__":
    unittest.main()
