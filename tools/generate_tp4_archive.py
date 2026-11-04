"""Génère les données et le vérificateur distribués aux élèves pour le TP4."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


ROOT = Path(__file__).resolve().parents[1]
ARCHIVE_ROOT = "atelier-journalisation"
AUTH_LOG = """Nov 3 08:14:03 aurore sshd[1302]: Failed password for root from 203.0.113.7 port 51234 ssh2
Nov 3 08:14:06 aurore sshd[1302]: Failed password for root from 203.0.113.7 port 51234 ssh2
Nov 3 08:20:45 aurore sshd[1355]: Invalid user admin from 198.51.100.23 port 40022
Nov 3 08:20:47 aurore sshd[1355]: Failed password for invalid user admin from 198.51.100.23 port 40022 ssh2
Nov 3 08:20:50 aurore sshd[1355]: Failed password for invalid user admin from 198.51.100.23 port 40022 ssh2
Nov 3 08:21:00 aurore sshd[1357]: Failed password for invalid user guest from 203.0.113.99 port 40102 ssh2
Nov 3 08:21:04 aurore sshd[1357]: Failed password for invalid user guest from 203.0.113.99 port 40102 ssh2
Nov 3 08:22:11 aurore sshd[1360]: Failed password for root from 203.0.113.7 port 51245 ssh2
Nov 3 08:22:15 aurore sshd[1360]: Failed password for root from 203.0.113.7 port 51245 ssh2
Nov 3 08:24:10 aurore sshd[1362]: Failed password for invalid user admin from 198.51.100.23 port 40102 ssh2
Nov 3 08:24:13 aurore sshd[1362]: Failed password for invalid user admin from 198.51.100.23 port 40102 ssh2
Nov 3 08:26:10 aurore sshd[1364]: Failed password for root from 203.0.113.7 port 51280 ssh2
Nov 3 08:26:14 aurore sshd[1364]: Failed password for root from 203.0.113.7 port 51280 ssh2
Nov 3 08:31:30 aurore sshd[1410]: Accepted publickey for alex from 192.0.2.11 port 50544 ssh2
Nov 3 08:35:10 aurore sshd[1422]: Accepted publickey for alex from 192.0.2.11 port 50590 ssh2
Nov 3 08:39:10 aurore sshd[1430]: Accepted publickey for alex from 192.0.2.11 port 50632 ssh2
Nov 3 08:42:10 aurore sshd[1488]: Failed password for zoe from 192.0.2.44 port 52011 ssh2
Nov 3 08:42:15 aurore sshd[1488]: Accepted password for zoe from 192.0.2.44 port 52011 ssh2
"""
FILES = {
    "00-LIRE-MOI.txt": """AURORE — ENQUÊTER ET JOURNALISER

Ouvre le sujet « TP 4 — Enquêter et journaliser sur Aurore » sur le site du cours.
Travaille depuis la racine de l'atelier. Les fichiers dans donnees sont des exemples fictifs.
Crée tes programmes à côté de donnees et de verifier.sh.

Après ton premier essai, lance bash verifier.sh lignes_utiles.
Lance bash verifier.sh pour la liste, ou bash verifier.sh tout pour le bilan.
Pour le C, le vérificateur utilise gcc et compile dans un dossier temporaire.
""",
    "donnees/sonde.txt": (
        "alerte\nAlerte nord\nprealerte\nalerte sud\nalertes\na@erte\n"
        "poste 75001\n75001\n08:14:03\nreleve 08:14:55\n03/11/2026\n"
    ),
    "donnees/comptes.txt": (
        "root:x:0:0:root:/root:/bin/bash\n"
        "alex:x:1001:1001:Alex:/home/alex:/bin/bash\n"
        "zoe:x:1002:1002:Zoe:/home/zoe:/bin/zsh\n"
        "relais:x:1003:1003:Relais:/var/lib/relais:/usr/sbin/nologin\n"
        "nobody:x:65534:65534:Nobody:/nonexistent:/usr/sbin/nologin\n"
    ),
    "donnees/sshd_config": (
        "# Configuration du relais Aurore\nPort 22\n\n"
        "\t# Accès de secours\n\t \t\nPermitRootLogin no\n"
        "   PasswordAuthentication yes\nPubkeyAuthentication yes\n"
        "AllowUsers alex zoe # compte comme une directive\n"
    ),
    "donnees/commentaires.conf": "# En attente\n\n  \t # Aucune directive\n\t \n",
    "donnees/auth.log": AUTH_LOG,
    "donnees/sans-echec.log": "".join(
        line for line in AUTH_LOG.splitlines(keepends=True) if "Accepted" in line
    ),
}


def main():
    destination = ROOT / "docs/assets/tp4-atelier-journalisation.zip"
    verifier = (ROOT / "tools/tp4_verifier.sh").read_text(encoding="utf-8")
    with ZipFile(destination, "w", compression=ZIP_DEFLATED) as archive:
        for name, contents in {**FILES, "verifier.sh": verifier}.items():
            entry = ZipInfo(f"{ARCHIVE_ROOT}/{name}", (2026, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, contents.encode("utf-8"))
    print(f"Archive TP4 créée : {len(FILES)} fichiers de départ et un vérificateur.")


if __name__ == "__main__":
    main()
