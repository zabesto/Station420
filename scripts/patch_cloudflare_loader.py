#!/usr/bin/env python3

from pathlib import Path
import json
import re
import sys


def patch_loader(path: Path) -> None:
    text = path.read_text()

    old_instantiate = """\t\t\t\tif (typeof (WebAssembly.instantiateStreaming) !== 'undefined') {\n\t\t\t\t\tWebAssembly.instantiateStreaming(Promise.resolve(r), imports).then(done);\n\t\t\t\t} else {\n\t\t\t\t\tr.arrayBuffer().then(function (buffer) {\n\t\t\t\t\t\tWebAssembly.instantiate(buffer, imports).then(done);\n\t\t\t\t\t});\n\t\t\t\t}"""
    new_instantiate = """\t\t\t\tconst response = r;\n\t\t\t\tconst isGzipWasm = response.url.endsWith('.wasm.gz');\n\t\t\t\tconst getSource = function () {\n\t\t\t\t\tif (!isGzipWasm) {\n\t\t\t\t\t\treturn Promise.resolve(response);\n\t\t\t\t\t}\n\t\t\t\t\tif (typeof DecompressionStream === 'undefined') {\n\t\t\t\t\t\tthrow new Error('This browser cannot decompress the WebAssembly payload.');\n\t\t\t\t\t}\n\t\t\t\t\treturn Promise.resolve(new Response(\n\t\t\t\t\t\tresponse.body.pipeThrough(new DecompressionStream('gzip')),\n\t\t\t\t\t\t{ headers: [['content-type', 'application/wasm']] }\n\t\t\t\t\t));\n\t\t\t\t};\n\t\t\t\tgetSource().then(function (source) {\n\t\t\t\t\tif (typeof (WebAssembly.instantiateStreaming) !== 'undefined') {\n\t\t\t\t\t\tWebAssembly.instantiateStreaming(Promise.resolve(source), imports).then(done);\n\t\t\t\t\t} else {\n\t\t\t\t\t\tsource.arrayBuffer().then(function (buffer) {\n\t\t\t\t\t\t\tWebAssembly.instantiate(buffer, imports).then(done);\n\t\t\t\t\t\t});\n\t\t\t\t\t}\n\t\t\t\t});"""

    text = text.replace(old_instantiate, new_instantiate)
    text = text.replace("loadPromise = preloader.loadPromise(`${loadPath}.wasm`, size, true);", "loadPromise = preloader.loadPromise(`${loadPath}.wasm.gz`, size, true);")
    text = text.replace("Engine.load(basePath, this.config.fileSizes[`${basePath}.wasm`]);", "Engine.load(basePath, this.config.fileSizes[`${basePath}.wasm.gz`] || this.config.fileSizes[`${basePath}.wasm`]);")

    path.write_text(text)


def patch_html(path: Path, wasm_gz_size: int) -> None:
    text = path.read_text()
    match = re.search(r"const GODOT_CONFIG = (\{.*?\});", text)
    if match is None:
        raise ValueError(f"Could not locate GODOT_CONFIG in {path}")

    config = json.loads(match.group(1))
    file_sizes = config.setdefault("fileSizes", {})
    file_sizes["index.wasm.gz"] = wasm_gz_size

    replacement = f"const GODOT_CONFIG = {json.dumps(config, separators=(',', ':'))};"
    text = text[:match.start()] + replacement + text[match.end():]
    path.write_text(text)


def patch_bundle(path: Path) -> None:
    if path.is_dir():
        bundle_dir = path
        js_path = bundle_dir / "index.js"
    else:
        js_path = path
        bundle_dir = js_path.parent

    patch_loader(js_path)

    html_path = bundle_dir / "index.html"
    wasm_gz_path = bundle_dir / "index.wasm.gz"
    if html_path.exists() and wasm_gz_path.exists():
        patch_html(html_path, wasm_gz_path.stat().st_size)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: patch_cloudflare_loader.py <bundle-dir-or-index.js>", file=sys.stderr)
        return 1
    patch_bundle(Path(sys.argv[1]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
