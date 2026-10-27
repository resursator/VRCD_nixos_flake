#!/usr/bin/env python3
"""Update VR CyberDeck version and AppImage hashes."""

import base64
import hashlib
import re
import sys
from pathlib import Path
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
FLAKE = ROOT / "flake.nix"

VERSION_PATTERN = re.compile(
    r'^([ \t]*version = ")[^"]+";[ \t]*$',
    re.MULTILINE,
)
ARM_HASH_PATTERN = re.compile(
    r'(^[ \t]*hash = if isArm then\n[ \t]*)"[^"]+"',
    re.MULTILINE,
)
X86_HASH_PATTERN = re.compile(
    r'(^[ \t]*else\n[ \t]*)"[^"]+"(;[ \t]*$)',
    re.MULTILINE,
)

VERSION_RE = re.compile(
    r"\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?"
)

UPSTREAM = (
    "https://github.com/DeliciousMeatPop/VRCD/releases/download"
)


def download_hash(url: str) -> str:
    """Download a file and return its SHA-256 SRI hash."""
    request = Request(
        url,
        headers={"User-Agent": "VRCD-Nix-Flake-Updater"},
    )
    digest = hashlib.sha256()

    with urlopen(request, timeout=180) as response:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)

    return "sha256-" + base64.b64encode(
        digest.digest()
    ).decode("ascii")


def replace_one(
    content: str,
    pattern: re.Pattern,
    replacement: str,
    description: str,
) -> str:
    updated, count = pattern.subn(
        replacement,
        content,
        count=1,
    )
    if count != 1:
        raise RuntimeError(
            f"Expected exactly one {description}, found {count}"
        )
    return updated


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(
            f"Usage: {sys.argv[0]} VERSION"
        )

    version = sys.argv[1].removeprefix("v")
    if not VERSION_RE.fullmatch(version):
        raise SystemExit(f"Invalid version: {version}")

    base_url = f"{UPSTREAM}/v{version}"

    arm_url = (
        f"{base_url}/vr-cyberdeck-{version}-arm64.AppImage"
    )
    x86_url = (
        f"{base_url}/vr-cyberdeck-{version}-x86_64.AppImage"
    )

    print(f"Downloading ARM64 hash: {arm_url}", flush=True)
    arm_hash = download_hash(arm_url)

    print(f"Downloading x86_64 hash: {x86_url}", flush=True)
    x86_hash = download_hash(x86_url)

    content = FLAKE.read_text()

    content = replace_one(
        content,
        VERSION_PATTERN,
        rf'\g<1>{version}";',
        "version field",
    )
    content = replace_one(
        content,
        ARM_HASH_PATTERN,
        rf'\g<1>"{arm_hash}"',
        "ARM64 hash",
    )
    content = replace_one(
        content,
        X86_HASH_PATTERN,
        rf'\g<1>"{x86_hash}"\2',
        "x86_64 hash",
    )

    FLAKE.write_text(content)
    print(f"Updated VR CyberDeck to {version}")


if __name__ == "__main__":
    main()
