"""Génère l'atelier du TP3 et son vérificateur, sans les solutions des élèves."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


ROOT = Path(__file__).resolve().parents[1]
ARCHIVE_ROOT = "atelier-decisions"
FILES = {
    "00-LIRE-MOI.txt": """AURORE — LES OUTILS QUI DECIDENT

Le sujet est sur le site du cours : TP 3 — Donner des décisions aux outils d'Aurore.

essais       : petites expériences et fichiers que tu peux modifier
preparation  : premiers programmes à écrire toi-même
scripts      : les huit outils à écrire toi-même
donnees      : données de départ à conserver
rapports     : résultats et diagnostics de tes essais
verifier.sh  : outil de vérification présenté après le premier script

Sauf indication contraire, lance les commandes depuis atelier-decisions.
Un script travaille dans le dossier de lancement, pas automatiquement dans scripts.
Le TP prépare les droits du petit laboratoire donnees/entrees au niveau 4.
Ne décompresse pas une seconde fois sur ton travail lors d'une reprise.
Tous les textes utilisent des fins de ligne Linux. Certains fichiers de lecture
sont volontairement vides ou privés de retour à la ligne final.
Aucun des programmes demandés n'est fourni dans l'archive.
Le carnet est facultatif : le travail consiste à écrire et corriger les scripts.
Après avoir créé et lancé repere.sh : bash verifier.sh repere
Pour le bilan : bash verifier.sh tout
Pour construire mon_cat par étapes : bash verifier.sh mon_cat lecture
                                    bash verifier.sh mon_cat numeros
                                    bash verifier.sh mon_cat
""",
    "donnees/message.txt": "Relais Aurore : OK\nDeuxieme ligne du message.\n",
    "donnees/nom avec espaces.txt": "Un nom avec espaces reste un seul argument.\n",
    "donnees/espaces.txt": "  chemin C:\\relais\\nord  \n",
    "donnees/lignes.txt": "alpha\n\n\n  \nbeta\\suite\n\n\n",
    "donnees/suite.txt": "\n\ngamma\n\n",
    "donnees/vide.txt": "",
    "donnees/sans-retour.txt": "premiere ligne\nderniere ligne sans retour",
    "donnees/morceau-a.txt": "debut",
    "donnees/morceau-b.txt": " suite\n",
    "donnees/logs/radio nord.log": "08:00 OK nord\n08:01 OK nord\n",
    "donnees/logs/radio-sud.log": "08:00 OK sud\n08:01 ALERTE sud\n08:02 OK sud\n",
    "donnees/entrees/lancer.sh": (
        "#!/usr/bin/env bash\necho 'Temoin executable du laboratoire.'\n"
    ),
    "donnees/entrees/note.txt": "Un fichier ordinaire sans droit d'execution.\n",
    "donnees/entrees/sous-dossier/temoin.txt": "Pas de parcours recursif demande.\n",
}
DIRECTORIES = (
    "essais", "preparation", "scripts", "rapports", "donnees/entrees/vide"
)


def main():
    destination = ROOT / "docs/assets/tp3-atelier-decisions.zip"
    files = {**FILES, "verifier.sh": (ROOT / "tools/tp3_verifier.sh").read_text(encoding="utf-8")}
    with ZipFile(destination, "w", compression=ZIP_DEFLATED) as archive:
        for directory in DIRECTORIES:
            entry = ZipInfo(f"{ARCHIVE_ROOT}/{directory}/", (2026, 1, 1, 0, 0, 0))
            entry.external_attr = (0o40755 << 16) | 0x10
            archive.writestr(entry, b"")
        for name, contents in files.items():
            entry = ZipInfo(f"{ARCHIVE_ROOT}/{name}", (2026, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, contents.encode("utf-8"))
    print(f"Archive TP3 créée : {len(files)} fichiers, dont le vérificateur ; aucun outil corrigé.")


if __name__ == "__main__":
    main()
