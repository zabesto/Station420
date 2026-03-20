#!/usr/bin/env python3

from pathlib import Path
import sys


OLD_BLOCK = """\t} else {\n\t\tsetStatusMode('progress');\n\t\tengine.startGame({\n\t\t\t'onProgress': function (current, total) {\n\t\t\t\tif (current > 0 && total > 0) {\n\t\t\t\t\tstatusProgress.value = current;\n\t\t\t\t\tstatusProgress.max = total;\n\t\t\t\t} else {\n\t\t\t\t\tstatusProgress.removeAttribute('value');\n\t\t\t\t\tstatusProgress.removeAttribute('max');\n\t\t\t\t}\n\t\t\t},\n\t\t}).then(() => {\n\t\t\tsetStatusMode('hidden');\n\t\t}, displayFailureNotice);\n\t}\n}());"""

NEW_BLOCK = """\t} else {\n\t\tconst waitForInteraction = function () {\n\t\t\treturn new Promise((resolve) => {\n\t\t\t\tconst start = function () {\n\t\t\t\t\twindow.removeEventListener('pointerdown', start);\n\t\t\t\t\twindow.removeEventListener('keydown', start);\n\t\t\t\t\twindow.removeEventListener('touchstart', start);\n\t\t\t\t\tresolve();\n\t\t\t\t};\n\t\t\t\twindow.addEventListener('pointerdown', start, { once: true });\n\t\t\t\twindow.addEventListener('keydown', start, { once: true });\n\t\t\t\twindow.addEventListener('touchstart', start, { once: true });\n\t\t\t});\n\t\t};\n\n\t\tsetStatusNotice('Click, tap, or press any key to start.');\n\t\tsetStatusMode('notice');\n\t\twaitForInteraction().then(function () {\n\t\t\tsetStatusMode('progress');\n\t\t\treturn engine.startGame({\n\t\t\t\t'onProgress': function (current, total) {\n\t\t\t\t\tif (current > 0 && total > 0) {\n\t\t\t\t\t\tstatusProgress.value = current;\n\t\t\t\t\t\tstatusProgress.max = total;\n\t\t\t\t\t} else {\n\t\t\t\t\t\tstatusProgress.removeAttribute('value');\n\t\t\t\t\t\tstatusProgress.removeAttribute('max');\n\t\t\t\t\t}\n\t\t\t\t},\n\t\t\t});\n\t\t}).then(() => {\n\t\t\tsetStatusMode('hidden');\n\t\t}, displayFailureNotice);\n\t}\n}());"""


def patch_html(path: Path) -> None:
    text = path.read_text()
    if NEW_BLOCK in text:
        return
    if OLD_BLOCK not in text:
        raise ValueError(f"Could not locate startup block in {path}")
    path.write_text(text.replace(OLD_BLOCK, NEW_BLOCK))


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: patch_web_shell.py <index.html> [<index.html> ...]", file=sys.stderr)
        return 1
    for arg in sys.argv[1:]:
        patch_html(Path(arg))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
