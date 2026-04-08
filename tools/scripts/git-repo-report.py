#!/usr/bin/env python3
"""
Git Repository Report — understand a codebase before reading the code.

Based on: https://piechowski.io/post/git-commands-before-reading-code/

Runs git archaeology commands against a repository and produces a
formatted terminal report covering churn hotspots, contributors,
bug-prone files, commit velocity, and emergency deployments.
"""

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass

# ── ANSI helpers ──────────────────────────────────────────────────────

BOLD = "\033[1m"
DIM = "\033[2m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
CYAN = "\033[36m"
RESET = "\033[0m"


def supports_color() -> bool:
    """Check if the terminal supports ANSI color."""
    if os.environ.get("NO_COLOR"):
        return False
    return hasattr(sys.stdout, "isatty") and sys.stdout.isatty()


USE_COLOR = supports_color()


def c(code: str, text: str) -> str:
    return f"{code}{text}{RESET}" if USE_COLOR else text


# ── Git command runner ────────────────────────────────────────────────


def git(args: str, *, cwd: str) -> str:
    """Run a git command and return stdout, or empty string on failure."""
    result = subprocess.run(
        f"git {args}",
        shell=True,
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    return result.stdout.strip()


def run_pipeline(cmd: str, *, cwd: str) -> str:
    """Run a full shell pipeline (for commands with pipes)."""
    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    return result.stdout.strip()


# ── Report sections ──────────────────────────────────────────────────


@dataclass
class Section:
    title: str
    description: str
    content: str


def section_churn(cwd: str, since: str, top_n: int) -> Section:
    """Most-changed files — churn hotspots."""
    cmd = (
        f'git log --format=format: --name-only --since="{since}" '
        f"| grep -v '^$' | sort | uniq -c | sort -nr | head -{top_n}"
    )
    raw = run_pipeline(cmd, cwd=cwd)

    lines = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) == 2:
            count, path = parts
            bar = bar_chart(int(count), max_count_from(raw))
            lines.append(f"  {c(YELLOW, count.rjust(6))}  {bar}  {path}")

    return Section(
        title="Churn Hotspots",
        description=(
            f"Files with the most commits in the last {since}. "
            "High churn often signals risky, unstable code."
        ),
        content="\n".join(lines) if lines else "  (no data)",
    )


def section_contributors(cwd: str) -> Section:
    """Top contributors by commit count."""
    raw = git("shortlog -sn --no-merges HEAD", cwd=cwd)

    lines = []
    total = 0
    entries: list[tuple[int, str]] = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split("\t", 1)
        if len(parts) == 2:
            count = int(parts[0].strip())
            name = parts[1].strip()
            total += count
            entries.append((count, name))

    for count, name in entries[:15]:
        pct = (count / total * 100) if total else 0
        color = RED if pct > 50 else YELLOW if pct > 25 else GREEN
        lines.append(
            f"  {c(color, f'{count:>6}')}  {c(DIM, f'({pct:5.1f}%)')}  {name}"
        )

    bus_factor_warning = ""
    if entries and total:
        top_pct = entries[0][0] / total * 100
        if top_pct > 50:
            bus_factor_warning = (
                f"\n  {c(RED, '  Bus factor risk:')} top contributor has "
                f"{top_pct:.0f}% of all commits."
            )

    return Section(
        title="Contributors",
        description="Ranked by commit count (excluding merges).",
        content=(
            ("\n".join(lines) if lines else "  (no data)") + bus_factor_warning
        ),
    )


def section_bug_hotspots(cwd: str, top_n: int) -> Section:
    """Files most frequently touched in bug-fix commits."""
    cmd = (
        'git log -i -E --grep="fix|bug|broken" --name-only --format=\'\' '
        f"| grep -v '^$' | sort | uniq -c | sort -nr | head -{top_n}"
    )
    raw = run_pipeline(cmd, cwd=cwd)

    lines = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) == 2:
            count, path = parts
            bar = bar_chart(int(count), max_count_from(raw))
            lines.append(f"  {c(RED, count.rjust(6))}  {bar}  {path}")

    return Section(
        title="Bug Hotspots",
        description=(
            "Files appearing most in commits mentioning "
            "'fix', 'bug', or 'broken'. High overlap with churn = highest risk."
        ),
        content="\n".join(lines) if lines else "  (no data)",
    )


def section_commit_velocity(cwd: str) -> Section:
    """Monthly commit counts across the project's history."""
    cmd = "git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c"
    raw = run_pipeline(cmd, cwd=cwd)

    entries: list[tuple[str, int]] = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) == 2:
            count, month = parts
            entries.append((month, int(count)))

    if not entries:
        return Section(
            title="Commit Velocity",
            description="Monthly commit counts over time.",
            content="  (no data)",
        )

    max_val = max(c for _, c in entries)
    # Show last 24 months at most to keep the report readable
    display = entries[-24:]

    lines = []
    for month, count in display:
        bar = bar_chart(count, max_val, width=30)
        lines.append(f"  {c(CYAN, month)}  {count:>5}  {bar}")

    if len(entries) > 24:
        lines.insert(0, f"  {c(DIM, f'(showing last 24 of {len(entries)} months)')}")

    # Trend indicator
    if len(entries) >= 6:
        recent_avg = sum(c for _, c in entries[-3:]) / 3
        older_avg = sum(c for _, c in entries[-6:-3]) / 3
        if older_avg > 0:
            change = ((recent_avg - older_avg) / older_avg) * 100
            if change < -20:
                trend = c(RED, f"  Declining ({change:+.0f}% over last 6 months)")
            elif change > 20:
                trend = c(GREEN, f"  Accelerating ({change:+.0f}% over last 6 months)")
            else:
                trend = c(DIM, f"  Stable ({change:+.0f}% over last 6 months)")
            lines.append(f"\n  Trend: {trend}")

    return Section(
        title="Commit Velocity",
        description="Monthly commit counts — look for momentum shifts.",
        content="\n".join(lines),
    )


def section_emergencies(cwd: str, since: str) -> Section:
    """Reverts, hotfixes, and emergency deployments."""
    cmd = (
        f'git log --oneline --since="{since}" '
        "| grep -iE 'revert|hotfix|emergency|rollback'"
    )
    raw = run_pipeline(cmd, cwd=cwd)

    lines = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        # Color-code by severity
        lower = line.lower()
        if "revert" in lower:
            lines.append(f"  {c(RED, 'REVERT')}    {line}")
        elif "hotfix" in lower:
            lines.append(f"  {c(YELLOW, 'HOTFIX')}    {line}")
        elif "emergency" in lower:
            lines.append(f"  {c(RED, 'EMERGENCY')} {line}")
        elif "rollback" in lower:
            lines.append(f"  {c(RED, 'ROLLBACK')}  {line}")

    count = len(lines)
    summary = ""
    if count == 0:
        summary = f"  {c(GREEN, 'None found')} — either a clean record, or commit messages don't flag emergencies."
    elif count > 5:
        summary = f"\n  {c(RED, f'  {count} emergency commits')} in the last {since} — signals process issues."

    return Section(
        title="Emergency Deployments",
        description=(
            f"Reverts, hotfixes, and rollbacks in the last {since}."
        ),
        content=("\n".join(lines) + ("\n" + summary if summary else ""))
        if lines
        else summary,
    )


# ── Helpers ───────────────────────────────────────────────────────────


def max_count_from(raw: str) -> int:
    """Extract the maximum count from the first line of sorted output."""
    for line in raw.splitlines():
        parts = line.strip().split(None, 1)
        if parts:
            try:
                return int(parts[0])
            except ValueError:
                continue
    return 1


def bar_chart(value: int, max_val: int, width: int = 20) -> str:
    """Render a simple inline bar chart."""
    if max_val == 0:
        return ""
    filled = int((value / max_val) * width)
    return c(DIM, "\u2588" * filled + "\u2591" * (width - filled))


# ── Report rendering ─────────────────────────────────────────────────


def render_report(repo_path: str, sections: list[Section]) -> None:
    """Print the full formatted report."""
    repo_name = git("rev-parse --show-toplevel", cwd=repo_path)
    repo_name = os.path.basename(repo_name) if repo_name else repo_path
    branch = git("rev-parse --abbrev-ref HEAD", cwd=repo_path)
    commit_count = git("rev-list --count HEAD", cwd=repo_path)
    first_commit = run_pipeline("git log --reverse --format='%ad' --date=short | head -1", cwd=repo_path)
    last_commit = git("log -1 --format='%ad' --date=short", cwd=repo_path)

    width = 72
    border = "═" * width

    print()
    print(c(BOLD, f"  ╔{border}╗"))
    print(c(BOLD, f"  ║{'GIT REPOSITORY REPORT':^{width}}║"))
    print(c(BOLD, f"  ╚{border}╝"))
    print()
    print(f"  Repository:  {c(BOLD, repo_name)}")
    print(f"  Branch:      {c(CYAN, branch)}")
    print(f"  Commits:     {commit_count}")
    print(f"  History:     {first_commit} → {last_commit}")
    print(f"  {'─' * width}")

    for section in sections:
        print()
        print(f"  {c(BOLD, f'┌── {section.title} ') + c(DIM, '─' * (width - len(section.title) - 5))}")
        print(f"  {c(DIM, section.description)}")
        print()
        print(section.content)
        print()

    print(c(DIM, f"  {'─' * width}"))
    print(c(DIM, "  Source: https://piechowski.io/post/git-commands-before-reading-code/"))
    print()


# ── Main ──────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate a git archaeology report for a repository.",
    )
    parser.add_argument(
        "repo",
        nargs="?",
        default=".",
        help="Path to the git repository (default: current directory).",
    )
    parser.add_argument(
        "--since",
        default="1 year ago",
        help="Time window for churn and emergency analysis (default: '1 year ago').",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=15,
        help="Number of entries to show in hotspot lists (default: 15).",
    )
    args = parser.parse_args()

    repo = os.path.abspath(args.repo)

    # Verify it's a git repo
    check = subprocess.run(
        "git rev-parse --git-dir",
        shell=True,
        capture_output=True,
        cwd=repo,
    )
    if check.returncode != 0:
        print(f"Error: '{repo}' is not a git repository.", file=sys.stderr)
        sys.exit(1)

    sections = [
        section_churn(repo, args.since, args.top),
        section_contributors(repo),
        section_bug_hotspots(repo, args.top),
        section_commit_velocity(repo),
        section_emergencies(repo, args.since),
    ]

    render_report(repo, sections)


if __name__ == "__main__":
    main()
