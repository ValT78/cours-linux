"""Génère l’atelier élève du TP bonus Aurore."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


ROOT = Path(__file__).resolve().parents[1]
DESTINATION = ROOT / "docs/assets/tp-bonus-aurore.zip"


def main():
    fichiers = {
        "00-LIRE-MOI.txt": (
            "AURORE — DÉCOLLAGE VERS DELTA\n\n"
            "Ouvre le sujet du TP bonus sur le site du cours.\n"
            "Crée ton fichier fusee.sh dans ce dossier, à côté d’affichage.sh.\n"
            "Lance ton jeu avec bash fusee.sh.\n"
            "Après ton premier essai, lance bash verifier.sh niveau-1.\n"
        ),
        "affichage.sh": (ROOT / "tools/tp_bonus_affichage.sh").read_text(encoding="utf-8"),
        "verifier.sh": '#!/usr/bin/env bash\nexec python3 "$(dirname "$0")/verifier.py" "$@"\n',
        "verifier.py": (ROOT / "tools/tp_bonus_verifier.py").read_text(encoding="utf-8"),
    }
    with ZipFile(DESTINATION, "w") as archive:
        for nom, contenu in fichiers.items():
            entree = ZipInfo(f"atelier-aurore-delta/{nom}", (2026, 1, 1, 0, 0, 0))
            entree.external_attr = 0o100644 << 16
            archive.writestr(entree, contenu.encode("utf-8"), compress_type=ZIP_DEFLATED)


if __name__ == "__main__":
    main()
