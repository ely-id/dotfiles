"""Transfer a completed screenshot PNG to/from the clipboard and the screenshot preview.

Actions: `read [path]` prints the PNG as base64, `copy` takes base64 on stdin, `copy-file <path>` copies a PNG file, and
`save <path>` takes base64 on stdin and writes the PNG to <path>, creating the folder and never overwriting an existing file.
"""

import base64
from pathlib import Path
import subprocess
import sys


def save_png(target, png):
    """Writes `png` to `target` without ever replacing a file that is already there (exclusive create)."""
    target.parent.mkdir(parents=True, exist_ok=True)
    try:
        with open(target, "xb") as out:
            try:
                out.write(png)
            except BaseException:
                # A half-written file would pass for a screenshot; remove the one this call created.
                target.unlink(missing_ok=True)
                raise
    except FileExistsError:
        raise ValueError(f"File already exists: {target}") from None


def main():
    action = sys.argv[1]
    if action == "read":
        path = sys.argv[2] if len(sys.argv) > 2 else ""
        png = Path(path).read_bytes() if path else subprocess.run(
            ["wl-paste", "--no-newline", "--type", "image/png"],
            check=True, capture_output=True, timeout=5,
        ).stdout
    elif action == "copy":
        png = base64.b64decode(sys.stdin.buffer.read(), validate=True)
    elif action == "save":
        path = sys.argv[2] if len(sys.argv) > 2 else ""
        if not path:
            raise ValueError("Missing destination path")
        png = base64.b64decode(sys.stdin.buffer.read(), validate=True)
        if not png.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError("Screenshot is not a PNG")
        save_png(Path(path), png)
        return
    elif action == "copy-file":
        path = sys.argv[2] if len(sys.argv) > 2 else ""
        if not path:
            raise ValueError("Missing screenshot path")
        png = Path(path).read_bytes()
    else:
        raise ValueError("Unknown clipboard action")

    if not png.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("Screenshot is not a PNG")
    if action == "read":
        print(base64.b64encode(png).decode("ascii"))
    else:
        subprocess.run(["wl-copy", "--type", "image/png"], input=png,
                       check=True, timeout=5)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"Screenshot preview: {error}", file=sys.stderr)
        sys.exit(1)
