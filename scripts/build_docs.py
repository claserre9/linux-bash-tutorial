#!/usr/bin/env python3
"""Génère docs/ depuis les sources cours/ et annexes/ pour MkDocs."""

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).parent.parent
DOCS = ROOT / "docs"


def réécrire_liens(contenu: str, contexte: str) -> str:
    def remplacer(m: re.Match) -> str:
        lien = m.group(1)

        ch = re.match(r"(?:\.\.\/|cours\/)(\d+_[^/]+)\/README\.md", lien)
        if ch:
            nom = ch.group(1)
            if contexte == "cours":
                return f"({nom}.md)"
            else:
                return f"(cours/{nom}.md)"

        ann = re.match(r"\.\.\/\.\.\/annexes\/(.*\.md)", lien)
        if ann:
            return f"(../annexes/{ann.group(1)})"

        ann2 = re.match(r"annexes\/(.*\.md)", lien)
        if ann2 and contexte == "index":
            return f"(annexes/{ann2.group(1)})"

        return m.group(0)

    return re.sub(r"\(([^)]+\.md)\)", remplacer, contenu)


def copier_et_réécrire(src: Path, dst: Path, contexte: str) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    contenu = src.read_text(encoding="utf-8")
    contenu = réécrire_liens(contenu, contexte)
    dst.write_text(contenu, encoding="utf-8")


if DOCS.exists():
    shutil.rmtree(DOCS)
DOCS.mkdir()

copier_et_réécrire(ROOT / "README.md", DOCS / "index.md", "index")

for readme in sorted((ROOT / "cours").glob("*/README.md")):
    nom = readme.parent.name
    copier_et_réécrire(readme, DOCS / "cours" / f"{nom}.md", "cours")

for md in sorted((ROOT / "annexes").glob("*.md")):
    copier_et_réécrire(md, DOCS / "annexes" / md.name, "annexes")

print(f"docs/ généré : {sum(1 for _ in DOCS.rglob('*.md'))} fichiers")
