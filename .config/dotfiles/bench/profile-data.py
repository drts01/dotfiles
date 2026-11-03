"""Sanitize shell benchmark exports, archive run artifacts, and read comparable history."""

import datetime
import json
import os
import platform
import statistics
import subprocess
import sys
from pathlib import Path

COMMANDS = {
    "zsh login": "zsh -d -lic exit",
    "POSIX sh interactive": "sh -ic exit",
}


def git(root, *args):
    return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()


def version(*args):
    try:
        return subprocess.check_output(
            args, text=True, stderr=subprocess.DEVNULL
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "unavailable"


def load(path):
    with open(path, encoding="utf-8") as source:
        return json.load(source)


def save(path, data):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as target:
        json.dump(data, target, indent=2)
        target.write("\n")


def finalize(raw, output, metadata, root, runs, warmup, home):
    data = load(raw)
    results = data["results"]
    if len(results) != len(COMMANDS) or {r["name"] for r in results} != set(COMMANDS):
        raise ValueError("unexpected hyperfine commands")
    for result in results:
        measurements = result["measurements"]
        if (
            len(measurements) != runs
            or not result["command"]
            or any(sample["exit_code"] != 0 for sample in measurements)
        ):
            raise ValueError(
                f"incomplete or failed hyperfine samples: {result['name']}"
            )
        result["command"] = COMMANDS[result["name"]]
    if home in json.dumps(data):
        raise ValueError("temporary HOME leaked into sanitized export")
    statuses = subprocess.check_output(
        ["git", "-C", str(root), "submodule", "status", "--", ".local/share/zsh"],
        text=True,
    ).splitlines()
    sh_version = version("sh", "-c", 'printf "%s" "${BASH_VERSION:-unknown}"')
    if sh_version == "unknown":
        sh_version = "dash " + version("dpkg-query", "-W", "-f=${Version}", "dash")
    info = {
        "scenario": "isolated-system-path-no-mise-tools",
        "timestamp_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "git_sha": git(root, "rev-parse", "HEAD"),
        "run_id": os.environ.get("GITHUB_RUN_ID", "local"),
        "run_attempt": os.environ.get("GITHUB_RUN_ATTEMPT", "local"),
        "runner_os": os.environ.get("RUNNER_OS", platform.system()),
        "runner_arch": os.environ.get("RUNNER_ARCH", platform.machine()),
        "runner_label": os.environ.get("PROFILE_RUNNER_LABEL", "local"),
        "runner_image": os.environ.get("ImageOS", "local"),
        "runner_image_version": os.environ.get("ImageVersion", "local"),
        "shell_versions": {
            "zsh": version("zsh", "--version"),
            "sh": sh_version,
        },
        "mise_version": version("mise", "--version"),
        "hyperfine_version": version("hyperfine", "--version"),
        "warmup": warmup,
        "runs": runs,
        "submodules_initialized": bool(statuses)
        and all(s.startswith(" ") for s in statuses),
        "workload": list(COMMANDS),
        "path_scenario": "/usr/bin:/bin",
    }
    save(output, data)
    save(metadata, info)


def archive(artifacts, repository):
    if os.environ.get("GITHUB_REF") != "refs/heads/trunk":
        raise ValueError("refusing to archive a non-trunk workflow")
    run_id = os.environ["GITHUB_RUN_ID"]
    attempt = os.environ["GITHUB_RUN_ATTEMPT"]
    sha = git(repository, "rev-parse", "HEAD")
    files = {}
    for slug in ("linux-x64", "macos-arm64"):
        directory = Path(artifacts) / f"shell-profile-{slug}"
        data_path = directory / "results.json"
        meta_path = directory / "metadata.json"
        data, meta = load(data_path), load(meta_path)
        if (meta["run_id"], meta["run_attempt"], meta["git_sha"]) != (
            run_id,
            attempt,
            sha,
        ):
            raise ValueError(f"artifact identity mismatch: {slug}")
        expected = {
            "linux-x64": ("Linux", "X64", "ubuntu-24.04"),
            "macos-arm64": ("macOS", "ARM64", "macos-15-arm64"),
        }[slug]
        if (meta["runner_os"], meta["runner_arch"], meta["runner_label"]) != expected:
            raise ValueError(f"runner identity mismatch: {slug}")
        if meta["scenario"] != "isolated-system-path-no-mise-tools" or {
            result["name"] for result in data["results"]
        } != set(COMMANDS):
            raise ValueError(f"invalid benchmark scenario: {slug}")
        for result in data["results"]:
            if (
                result["command"] != COMMANDS[result["name"]]
                or len(result["measurements"]) != meta["runs"]
                or any(sample["exit_code"] != 0 for sample in result["measurements"])
            ):
                raise ValueError(f"invalid benchmark samples: {slug}/{result['name']}")
        files[f"results/{slug}/{run_id}-{attempt}.json"] = data_path.read_bytes()
        files[f"results/{slug}/{run_id}-{attempt}.meta.json"] = meta_path.read_bytes()
    remote = git(repository, "ls-remote", "--heads", "origin", "benchmarks")
    if remote:
        subprocess.run(
            ["git", "-C", str(repository), "fetch", "origin", "refs/heads/benchmarks"],
            check=True,
        )
        subprocess.run(
            [
                "git",
                "-C",
                str(repository),
                "switch",
                "--create",
                "benchmarks",
                "FETCH_HEAD",
            ],
            check=True,
        )
    else:
        subprocess.run(
            ["git", "-C", str(repository), "switch", "--orphan", "benchmarks"],
            check=True,
        )

    for name, content in files.items():
        destination = Path(repository) / name
        if destination.exists():
            raise ValueError(f"refusing to overwrite archived result: {name}")
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
    subprocess.run(["git", "-C", str(repository), "add", "--", "results"], check=True)
    subprocess.run(
        [
            "git",
            "-C",
            str(repository),
            "-c",
            "user.name=github-actions[bot]",
            "-c",
            "user.email=41898282+github-actions[bot]@users.noreply.github.com",
            "commit",
            "-m",
            f"Archive shell profile {run_id} attempt {attempt}",
        ],
        check=True,
    )
    subprocess.run(
        ["git", "-C", str(repository), "push", "origin", "HEAD:refs/heads/benchmarks"],
        check=True,
    )


def compare(directory):
    directory = Path(directory)
    common = (
        "scenario", "run_id", "run_attempt", "runner_os", "runner_arch",
        "runner_label", "runner_image", "runner_image_version", "shell_versions",
        "mise_version", "hyperfine_version", "warmup", "runs",
        "submodules_initialized", "workload", "path_scenario",
    )
    revisions = {}
    for revision in ("trunk", "candidate"):
        batches = []
        for batch in (1, 2):
            prefix = f"{revision}-{batch}"
            data = load(directory / f"{prefix}.json")
            info = load(directory / f"{prefix}.meta.json")
            if {result["name"] for result in data["results"]} != set(COMMANDS):
                raise ValueError(f"unexpected benchmark commands: {prefix}")
            if not info["submodules_initialized"]:
                raise ValueError(f"Zsh submodules not initialized: {prefix}")
            if batches:
                previous = batches[0][1]
                if info["git_sha"] != previous["git_sha"]:
                    raise ValueError(f"revision changed between batches: {revision}")
            batches.append((data, info))
        revisions[revision] = batches
    baseline = revisions["trunk"][0][1]
    candidate = revisions["candidate"][0][1]
    if baseline["git_sha"] == candidate["git_sha"]:
        raise ValueError("candidate must differ from trunk")
    for batches in revisions.values():
        for _, info in batches:
            if any(info[key] != baseline[key] for key in common):
                raise ValueError("benchmark environments or workloads differ")
    print(f"## Shell startup: trunk `{baseline['git_sha'][:12]}` vs candidate `{candidate['git_sha'][:12]}`")
    print(f"{baseline['runner_label']} | {baseline['runner_image']} {baseline['runner_image_version']} | {baseline['scenario']}")
    print("\n| Command | Trunk median (s) | Candidate median (s) | Change | Trunk / candidate sample stdev (s) |")
    print("| --- | ---: | ---: | ---: | ---: |")
    for name, expected_command in COMMANDS.items():
        values = {}
        for revision, batches in revisions.items():
            times = []
            for data, info in batches:
                result = next(r for r in data["results"] if r["name"] == name)
                if (result["command"] != expected_command or
                        len(result["measurements"]) != info["runs"] or
                        any(sample["exit_code"] != 0 for sample in result["measurements"])):
                    raise ValueError(f"invalid samples: {revision}/{name}")
                times.extend(sample["time_wall_clock"]["value"] for sample in result["measurements"])
            values[revision] = (statistics.median(times), statistics.stdev(times))
        old, new = values["trunk"], values["candidate"]
        print(f"| {name} | {old[0]:.6f} | {new[0]:.6f} | {(new[0] / old[0] - 1) * 100:+.1f}% | {old[1]:.6f} / {new[1]:.6f} |")
    print("\nInformational only: shared-runner noise can exceed the observed change. Timings exclude mise-installed tools.")


def read_history(directory):
    groups = {}
    for metadata in Path(directory).glob("results/*/*.meta.json"):
        info = load(metadata)
        data = load(
            metadata.with_name(metadata.name.removesuffix(".meta.json") + ".json")
        )
        key = (
            info["runner_os"],
            info["runner_arch"],
            info["runner_image"],
            info["runner_image_version"],
            info["scenario"],
            info["runner_label"],
            info["hyperfine_version"],
            info["runs"],
            info["warmup"],
            info["submodules_initialized"],
        )
        for result in data["results"]:
            times = [
                sample["time_wall_clock"]["value"] for sample in result["measurements"]
            ]
            groups.setdefault((*key, result["name"]), []).append(
                (
                    info["timestamp_utc"],
                    statistics.median(times),
                    statistics.stdev(times) if len(times) > 1 else 0.0,
                )
            )
    for group, samples in sorted(groups.items()):
        print(" | ".join(map(str, group)))
        for timestamp, median, deviation in sorted(samples):
            print(f"  {timestamp}  median={median:.6f}s  sample_stdev={deviation:.6f}s")


if __name__ == "__main__":
    try:
        args = sys.argv[1:]
        if len(args) == 8 and args[0] == "finalize":
            _, raw, output, metadata, root, runs, warmup, home = args
            finalize(raw, output, metadata, root, int(runs), int(warmup), home)
        elif len(args) == 3 and args[0] == "archive":
            archive(args[1], args[2])
        elif len(args) == 2 and args[0] == "read":
            read_history(args[1])
        elif len(args) == 2 and args[0] == "compare":
            compare(args[1])
        else:
            raise ValueError(
                "usage: profile-data.py finalize RAW JSON META ROOT RUNS WARMUP HOME | archive ARTIFACTS REPO | read BRANCH_DIR | compare PAIR_DIR"
            )
    except (KeyError, ValueError, OSError, subprocess.CalledProcessError) as exc:
        sys.exit(f"shell profile data: {exc}")
