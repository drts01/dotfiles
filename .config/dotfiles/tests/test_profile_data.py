"""Regression checks for history charts generated from sanitized hyperfine data."""

import importlib.util
import json
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "bench" / "profile-data.py"
SPEC = importlib.util.spec_from_file_location("profile_data", SCRIPT)
profile_data = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(profile_data)


class ProfileChartTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.history = Path(self.tmp.name) / "history"
        self.output = Path(self.tmp.name) / "charts"
        for slug, os_name, arch, runner in (
            ("linux-x64", "Linux", "X64", "ubuntu-24.04"),
            ("macos-arm64", "macOS", "ARM64", "macos-15-arm64"),
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
