"""Regression checks for archiving and charting sanitized hyperfine data."""

import importlib.util
import json
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path
from unittest import mock


SCRIPT = Path(__file__).resolve().parents[1] / "bench" / "profile-data.py"
SPEC = importlib.util.spec_from_file_location("profile_data", SCRIPT)
profile_data = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(profile_data)


class ProfileArchiveTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.artifacts = Path(self.tmp.name) / "artifacts"
        self.repository = Path(self.tmp.name) / "repository"
        self.sha = "a" * 40
        self.environment = {
            "GITHUB_REF": "refs/heads/trunk",
            "GITHUB_RUN_ID": "100",
            "GITHUB_RUN_ATTEMPT": "1",
        }
        for slug, os_name, arch, runner in (
            ("linux-x64", "Linux", "X64", "ubuntu-26.04"),
            ("macos-arm64", "macOS", "ARM64", "macos-26"),
        ):
            directory = self.artifacts / f"shell-profile-{slug}"
            profile_data.save(directory / "metadata.json", {
                "run_id": "100",
                "run_attempt": "1",
                "git_sha": self.sha,
                "runner_os": os_name,
                "runner_arch": arch,
                "runner_label": runner,
                "scenario": "isolated-system-path-no-mise-tools",
                "runs": 1,
            })
            profile_data.save(directory / "results.json", {
                "results": [
                    {
                        "name": name,
                        "command": command,
                        "measurements": [{"exit_code": 0}],
                    }
                    for name, command in profile_data.COMMANDS.items()
                ],
            })
        self.git = self.enterContext(mock.patch.object(
            profile_data, "git", side_effect=[self.sha, ""],
        ))
        self.run = self.enterContext(mock.patch.object(profile_data.subprocess, "run"))
        self.enterContext(mock.patch.dict(profile_data.os.environ, self.environment))

    def test_archive_accepts_both_current_runner_identities(self):
        profile_data.archive(self.artifacts, self.repository)
        for slug in ("linux-x64", "macos-arm64"):
            with self.subTest(slug=slug):
                source = self.artifacts / f"shell-profile-{slug}"
                archived = self.repository / "results" / slug
                self.assertEqual(
                    (archived / "100-1.json").read_bytes(),
                    (source / "results.json").read_bytes(),
                )
                self.assertEqual(
                    (archived / "100-1.meta.json").read_bytes(),
                    (source / "metadata.json").read_bytes(),
                )

    def test_archive_rejects_identity_mismatches_for_both_runners(self):
        for slug in ("linux-x64", "macos-arm64"):
            path = self.artifacts / f"shell-profile-{slug}" / "metadata.json"
            original = profile_data.load(path)
            for key, value in (
                ("run_id", "101"),
                ("run_attempt", "2"),
                ("git_sha", "b" * 40),
                ("runner_os", "unexpected"),
                ("runner_arch", "unexpected"),
                ("runner_label", "ubuntu-24.04" if slug == "linux-x64" else "macos-15"),
            ):
                with self.subTest(slug=slug, key=key):
                    profile_data.save(path, {**original, key: value})
                    self.git.reset_mock(side_effect=True)
                    self.git.return_value = self.sha
                    identity = "artifact" if key in ("run_id", "run_attempt", "git_sha") else "runner"
                    with self.assertRaisesRegex(ValueError, f"{identity} identity mismatch: {slug}"):
                        profile_data.archive(self.artifacts, self.repository)
                    self.git.assert_called_once_with(self.repository, "rev-parse", "HEAD")
                    self.run.assert_not_called()
                    self.assertFalse(self.repository.exists())
                profile_data.save(path, original)


class ProfileChartTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.history = Path(self.tmp.name) / "history"
        self.output = Path(self.tmp.name) / "charts"
        for slug, os_name, arch, runner in (
            ("linux-x64", "Linux", "X64", "ubuntu-24.04"),
            ("macos-arm64", "macOS", "ARM64", "macos-15"),
        ):
            for run_id, image_version, seconds in (
                ("100", "image-1", 0.10),
                ("101", "image-1", 0.12),
                ("102", "image-2", 0.90),
            ):
                directory = self.history / "results" / slug
                directory.mkdir(parents=True, exist_ok=True)
                meta = {
                    "scenario": "isolated-system-path-no-mise-tools",
                    "timestamp_utc": f"2026-11-01T00:00:{int(run_id) - 100:02d}+00:00",
                    "run_id": run_id,
                    "run_attempt": "1",
                    "git_sha": run_id.zfill(40),
                    "runner_os": os_name,
                    "runner_arch": arch,
                    "runner_label": runner,
                    "runner_image": "image",
                    "runner_image_version": image_version,
                    "shell_versions": {"zsh": "zsh 5.9", "sh": "dash 0.5"},
                    "mise_version": "mise 2026",
                    "hyperfine_version": "hyperfine 2.0.0",
                    "warmup": 3,
                    "runs": 2,
                    "submodules_initialized": True,
                    "workload": list(profile_data.COMMANDS),
                    "path_scenario": "/usr/bin:/bin",
                }
                results = {
                    "results": [
                        {
                            "name": name,
                            "command": command,
                            "measurements": [
                                {"exit_code": 0, "time_wall_clock": {"value": seconds + offset}}
                                for offset in (0, 0.01)
                            ],
                        }
                        for name, command in profile_data.COMMANDS.items()
                    ]
                }
                (directory / f"{run_id}-1.meta.json").write_text(json.dumps(meta), encoding="utf-8")
                (directory / f"{run_id}-1.json").write_text(json.dumps(results), encoding="utf-8")

    def test_charts_include_only_matching_runner_image_release(self):
        profile_data.chart_history(self.history, self.output, "101", "1")
        self.assertEqual(len(list(self.output.glob("*.svg"))), 4)
        summary = (self.output / "summary.md").read_text(encoding="utf-8")
        self.assertEqual(summary.count("| 2 |"), 4)
        self.assertNotIn("900.00", summary)
        for chart in self.output.glob("*.svg"):
            root = ET.parse(chart).getroot()
            circles = root.findall("{http://www.w3.org/2000/svg}circle")
            self.assertEqual(len(circles), 2)
            self.assertNotIn("One run; no trend yet", chart.read_text(encoding="utf-8"))

    def test_one_run_is_a_point_not_a_trend(self):
        profile_data.chart_history(self.history, self.output, "102", "1")
        for chart in self.output.glob("*.svg"):
            text = chart.read_text(encoding="utf-8")
            ET.fromstring(text)
            self.assertIn("One run; no trend yet", text)
            self.assertNotIn("<polyline", text)

    def test_failed_samples_cannot_be_plotted(self):
        path = self.history / "results" / "linux-x64" / "101-1.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["results"][0]["measurements"][0]["exit_code"] = 1
        path.write_text(json.dumps(data), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "invalid samples"):
            profile_data.chart_history(self.history, self.output, "101", "1")


if __name__ == "__main__":
    unittest.main()
