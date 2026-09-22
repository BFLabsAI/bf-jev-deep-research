#!/usr/bin/env python3
"""Verifica se todo link markdown local (`[texto](./caminho.md)`) do repositório
resolve para um arquivo que realmente existe no disco.

Uso:
    python3 scripts/check-links.py [pasta]

Sem argumento, varre o repositório inteiro a partir da pasta onde o script
está (um nível acima de scripts/). Ignora links http(s):// (externos) e a
pasta .git/. Sai com código 1 se encontrar algum link quebrado (útil para
rodar depois de editar qualquer coisa em skill/ ou study/, ou como um passo
de CI), e código 0 se tudo estiver limpo.
"""

import os
import re
import sys
import urllib.parse

LINK_RE = re.compile(r"\]\(([^)]+\.md)(#[^)]*)?\)")


def check(root: str) -> tuple[int, list[tuple[str, str]]]:
    total = 0
    broken: list[tuple[str, str]] = []

    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d != ".git"]
        for fn in filenames:
            if not fn.endswith(".md"):
                continue
            path = os.path.join(dirpath, fn)
            with open(path, encoding="utf-8") as f:
                text = f.read()
            for m in LINK_RE.finditer(text):
                target = urllib.parse.unquote(m.group(1))
                if target.startswith("http://") or target.startswith("https://"):
                    continue
                total += 1
                resolved = os.path.normpath(os.path.join(dirpath, target))
                if not os.path.isfile(resolved):
                    broken.append((os.path.relpath(path, root), target))

    return total, broken


def main() -> int:
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.normpath(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
    )

    total, broken = check(root)

    print(f"Links markdown locais verificados: {total}")
    if broken:
        print(f"\n{len(broken)} link(s) quebrado(s):\n")
        for src, tgt in broken:
            print(f"  {src}  ->  {tgt}")
        return 1

    print("Tudo certo — nenhum link quebrado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
