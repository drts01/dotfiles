"""Exercise save-time whitespace handling with isolated, plugin-free editors."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


CONFIG = Path(__file__).resolve().parents[2]


class EditorWhitespaceTest(unittest.TestCase):
    def check_saved_whitespace(self, filetype, expected):
        for editor, config in (("vim", "vim/vimrc"), ("nvim", "nvim/init.lua")):
            with self.subTest(editor=editor):
                executable = shutil.which(editor)
                if executable is None:
                    self.skipTest(f"{editor} executable unavailable")
                with tempfile.TemporaryDirectory() as temporary:
                    home = Path(temporary)
                    environment = {"HOME": str(home), "PATH": os.defpath}
                    for name in ("CONFIG", "DATA", "STATE", "CACHE"):
                        directory = home / f".{name.lower()}"
                        directory.mkdir()
                        environment[f"XDG_{name}_HOME"] = str(directory)
                    for kind in ("backup", "swap", "undo"):
                        (home / ".config" / "nvim" / kind).mkdir(parents=True)
                    target = home / "sample.txt"
                    target.write_bytes(b"hard break  \ntrailing\t \nclean\n\n")
                    script = home / "save.vim"
                    script.write_text(
                        f"setlocal filetype={filetype}\n"
                        "write\n"
                        "if !empty(v:errmsg) | cquit | endif\n"
                        "qa!\n",
                        encoding="utf-8",
                    )
                    flags = ["-N", "-es"] if editor == "vim" else ["--headless"]
                    result = subprocess.run(
                        [executable, *flags, "-V1", "-n", "-i", "NONE",
                         "--cmd", "set encoding=utf-8",
                         "-u", str(CONFIG / config), str(target), "-S", str(script)],
                        cwd=home,
                        env=environment,
                        capture_output=True,
                        text=True,
                        timeout=15,
                    )
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertEqual(target.read_bytes(), expected)

    def test_markdown_preserves_trailing_whitespace(self):
        self.check_saved_whitespace("markdown", b"hard break  \ntrailing\t \nclean\n\n")

    def test_text_still_trims_trailing_whitespace(self):
        self.check_saved_whitespace("text", b"hard break\ntrailing\nclean\n\n")


if __name__ == "__main__":
    unittest.main()
