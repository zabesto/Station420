#!/usr/bin/env python3

from pathlib import Path
import sys

OLD_VIEWPORT = '<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">'
NEW_VIEWPORT = '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, viewport-fit=cover, user-scalable=no">'

OLD_STYLE = """html, body, #canvas {
\tmargin: 0;
\tpadding: 0;
\tborder: 0;
}

body {
\tcolor: white;
\tbackground-color: black;
\toverflow: hidden;
\ttouch-action: none;
}

#canvas {
\tdisplay: block;
}
"""

NEW_STYLE = """html, body, #canvas {
\tmargin: 0;
\tpadding: 0;
\tborder: 0;
\twidth: 100%;
\theight: 100%;
}

html {
\tbackground-color: black;
}

body {
\tcolor: white;
\tbackground-color: black;
\toverflow: hidden;
\ttouch-action: none;
\tposition: fixed;
\tinset: 0;
\tmin-height: 100vh;
\tmin-height: 100dvh;
\tpadding-top: env(safe-area-inset-top);
\tpadding-right: env(safe-area-inset-right);
\tpadding-bottom: env(safe-area-inset-bottom);
\tpadding-left: env(safe-area-inset-left);
}

#canvas {
\tdisplay: block;
\twidth: 100% !important;
\theight: 100% !important;
}
"""


OLD_BLOCK = """\t} else {\n\t\tsetStatusMode('progress');\n\t\tengine.startGame({\n\t\t\t'onProgress': function (current, total) {\n\t\t\t\tif (current > 0 && total > 0) {\n\t\t\t\t\tstatusProgress.value = current;\n\t\t\t\t\tstatusProgress.max = total;\n\t\t\t\t} else {\n\t\t\t\t\tstatusProgress.removeAttribute('value');\n\t\t\t\t\tstatusProgress.removeAttribute('max');\n\t\t\t\t}\n\t\t\t},\n\t\t}).then(() => {\n\t\t\tsetStatusMode('hidden');\n\t\t}, displayFailureNotice);\n\t}\n}());"""

NEW_BLOCK = """\t} else {\n\t\tconst waitForInteraction = function () {\n\t\t\treturn new Promise((resolve) => {\n\t\t\t\tconst start = function () {\n\t\t\t\t\twindow.removeEventListener('pointerdown', start);\n\t\t\t\t\twindow.removeEventListener('keydown', start);\n\t\t\t\t\twindow.removeEventListener('touchstart', start);\n\t\t\t\t\tresolve();\n\t\t\t\t};\n\t\t\t\twindow.addEventListener('pointerdown', start, { once: true });\n\t\t\t\twindow.addEventListener('keydown', start, { once: true });\n\t\t\t\twindow.addEventListener('touchstart', start, { once: true });\n\t\t\t});\n\t\t};\n\n\t\tsetStatusNotice('Click, tap, or press any key to start.');\n\t\tsetStatusMode('notice');\n\t\twaitForInteraction().then(function () {\n\t\t\tsetStatusMode('progress');\n\t\t\treturn engine.startGame({\n\t\t\t\t'onProgress': function (current, total) {\n\t\t\t\t\tif (current > 0 && total > 0) {\n\t\t\t\t\t\tstatusProgress.value = current;\n\t\t\t\t\t\tstatusProgress.max = total;\n\t\t\t\t\t} else {\n\t\t\t\t\t\tstatusProgress.removeAttribute('value');\n\t\t\t\t\t\tstatusProgress.removeAttribute('max');\n\t\t\t\t\t}\n\t\t\t\t},\n\t\t\t});\n\t\t}).then(() => {\n\t\t\tsetStatusMode('hidden');\n\t\t}, displayFailureNotice);\n\t}\n}());"""


def patch_html(path: Path) -> None:
    text = path.read_text()
    text = text.replace(OLD_VIEWPORT, NEW_VIEWPORT)
    text = text.replace(OLD_STYLE, NEW_STYLE)
    if NEW_BLOCK in text:
        path.write_text(text)
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
