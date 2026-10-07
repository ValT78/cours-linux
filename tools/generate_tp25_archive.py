"""Génère le terrain de jeu du TP 2.5, sans scripts corrigés."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


ROOT = Path(__file__).resolve().parents[1]
FILES = {
    "00-LIRE-MOI.txt": """ATELIER AURORE — PREMIERS SCRIPTS

Le relais fonctionne à nouveau. Il lui manque dix petits outils.
Le sujet est sur le site du cours : TP 2.5.

scripts : tes dix scripts, à créer toi-même
essais : commandes de découverte et petits fichiers de test
projet : terrain du script projet.sh
recents : fichiers pour étudier les dates de modification
csv : grille simple et coordonnées de la case recherchée
production : sources fictives à compter, pas à compiler
nettoyage : copies jetables pour apprendre à supprimer avec confirmation
connexions : relevé fictif pour tester même si who ne renvoie rien

Lance les scripts depuis le dossier indiqué dans le sujet.
Les dates de recents et nettoyage seront préparées avec touch dans le TP.
Tous les fichiers texte utilisent des fins de ligne Linux.
""",
    "essais/couleurs.txt": "bleu\nambre\nbleu\nvert\n",
    "essais/capteurs.txt": "sonde-b:EST:12\nsonde-a:NORD:3\nsonde-c:SUD:20\n",
    "essais/comptes-exemple.txt": (
        "zoe:x:1002:1002:Zoe:/home/zoe:/bin/bash\n"
        "robot:x:998:998:Service:/var/lib/robot:/usr/sbin/nologin\n"
        "alice:x:1000:1000:Alice:/home/alice:/bin/bash\n"
        "sam:x:1001:1001:Sam:/home/sam:/bin/zsh\n"
    ),
    "essais/scores.txt": "balise-b 9\nbalise-a 12\nbalise-c 100\n",
    "essais/note avec espaces.txt": "Un seul nom, même avec des espaces.\n",
    "essais/extraits.txt": "alpha\nbeta\ngamma\ndelta\nepsilon\n",
    "recents/zeta.txt": "Premier fichier à dater.\n",
    "recents/alpha.txt": "Deuxième fichier à dater.\n",
    "recents/milieu.txt": "Troisième fichier à dater.\n",
    "recents/beta.txt": "Quatrième fichier à dater.\n",
    "recents/ancien.txt": "Dernier fichier à dater.\n",
    "csv/fichier.csv": "balise;zone;etat\nB17;NORD;OK\nB23;SUD;ALERTE\nB41;EST;OK\n",
    "csv/ligne.txt": "3\n",
    "csv/colonne.txt": "2\n",
    "production/main.c": "// Source fictive\nint main(void)\n{\n    return 0;\n}\n",
    "production/radio.c": "// Source fictive\nvoid envoyer(void)\n{\n    // simulation\n}\n\n// fin\n",
    "production/radio.h": "// Interface fictive\nvoid envoyer(void);\n",
    "production/notes.txt": "Ce fichier ne fait pas partie des sources.\n",
    "nettoyage/a-retirer.txt": "Fichier jetable : suppression à accepter pendant le test.\n",
    "nettoyage/a-garder.txt": "Fichier jetable : suppression à refuser pendant le test.\n",
    "nettoyage/recent.txt": "Ce fichier doit rester.\n",
    "nettoyage/sous-dossier/ancien-profond.txt": "Ce fichier doit rester : pas de récursion.\n",
    "nettoyage/essais/accepte.txt": "Copie jetable pour tester find -ok.\n",
    "nettoyage/essais/refuse.txt": "Copie jetable pour tester un refus.\n",
    "nettoyage/essais/recent.txt": "Copie récente.\n",
    "connexions/connexions-exemple.txt": (
        "zoe pts/2 2026-09-22 14:10 (192.0.2.12)\n"
        "alice pts/0 2026-09-22 08:05 (192.0.2.10)\n"
        "sam pts/3 2026-09-21 23:50 (192.0.2.13)\n"
        "alice pts/1 2026-09-22 11:20 (192.0.2.10)\n"
    ),
}


def main():
    destination = ROOT / "docs/assets/tp2-5-atelier-aurore.zip"
    with ZipFile(destination, "w", compression=ZIP_DEFLATED) as archive:
        for directory in ("scripts", "projet"):
            entry = ZipInfo(f"atelier-aurore/{directory}/", (2026, 1, 1, 0, 0, 0))
            entry.external_attr = (0o40755 << 16) | 0x10
            archive.writestr(entry, b"")
        for name, contents in FILES.items():
            entry = ZipInfo(f"atelier-aurore/{name}", (2026, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, contents.encode("utf-8"))
    print(f"Archive créée : {destination} ({len(FILES)} fichiers, aucun corrigé)")


if __name__ == "__main__":
    main()
