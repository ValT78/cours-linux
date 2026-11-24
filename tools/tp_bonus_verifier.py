"""Vérifie le vol d'Aurore avec des entrées déterministes."""

import re
import subprocess
import sys
from pathlib import Path


ATELIER = Path(__file__).resolve().parent


def lancer(bash_args, touches=""):
    resultat = subprocess.run(
        ["bash", *bash_args], cwd=ATELIER, input=touches,
        capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3,
    )
    if resultat.returncode or resultat.stderr:
        raise AssertionError(resultat.stderr.strip() or f"Bash a renvoyé {resultat.returncode}.")
    return resultat.stdout


def partie(touches):
    return lancer(["./fusee.sh"], touches)


def egal(obtenu, attendu, essai):
    if obtenu != attendu:
        raise AssertionError(f"{essai} — attendu : {attendu!r} ; observé : {obtenu!r}")
    print(f"OK — {essai}")


def distances(ecran):
    valeurs = re.findall(r"^ *([0-9]+)(?: / 200)? km *$", ecran, re.MULTILINE)
    if not valeurs:
        raise AssertionError("Distance introuvable. Garde un compteur « 0 km » ou l’écran fourni.")
    return [int(valeur) for valeur in valeurs]


def derniere_image(ecran):
    return ecran.rsplit("AURORE  /", 1)[-1]


def solde(image):
    valeur = re.search(r"^ *Crédits +([0-9]+)", image, re.MULTILINE)
    return int(valeur[1]) if valeur else None


def installe(image, equipement):
    return bool(re.search(rf"^ *\[{equipement}\][^\n]*INSTALLÉ *$", image, re.MULTILINE))


def niveau_1():
    mesures = distances(partie(" "))
    egal((mesures[0], mesures[-1]), (0, 5), "Un appui sur Espace")
    egal(set(distances(partie("x"))), {0}, "Une autre touche laisse la distance à 0 km")


def niveau_2():
    egal(distances(partie("   q "))[-1], 15, "Trois impulsions donnent 15 km et q termine la partie")
    egal(distances(partie(" x  Q "))[-1], 15, "X est ignoré et Q termine la partie")


def niveau_3():
    image = derniere_image(partie("1q"))
    egal((solde(image), installe(image, 1)), (0, False), "Crédits insuffisants")
    ecran = partie("  1q")
    image = derniere_image(ecran)
    egal((distances(ecran)[-1], solde(image), installe(image, 1)), (10, 0, True),
         "Achat à 10 crédits et conservation de la distance")
    image = derniere_image(partie("    11q"))
    egal((solde(image), installe(image, 1)), (10, True), "Deuxième achat ignoré malgré un solde suffisant")


def avancer(vitesse):
    return lancer(["-c", """
        source ./fusee.sh --fonctions
        type avancer_auto >/dev/null || exit 1
        distance=10
        credits=7
        vitesse_auto="$1"
        avancer_auto 5
        printf '%s km, %s crédits' "$distance" "$credits"
    """, "verifier", str(vitesse)])


def niveau_4():
    egal(avancer(0), "10 km, 7 crédits", "Cinq secondes sans propulseur")
    egal(avancer(1), "15 km, 12 crédits", "Cinq secondes avec le propulseur")


def niveau_5():
    ecran = partie(" " * 6 + "2 q")
    egal((distances(ecran)[-1], installe(derniere_image(ecran), 2)), (38, True),
         "Un appui donne 8 km après l’achat du booster")

    for ordre in ("13", "31"):
        image = derniere_image(partie(" " * 12 + ordre + "q"))
        egal((installe(image, 1), installe(image, 3), solde(image), "+3 km/s" in image),
             (True, True, 0, True), f"Les deux moteurs totalisent 3 km/s (ordre {ordre})")
    egal(avancer(3), "25 km, 22 crédits", "Cinq secondes à 3 km/s")

    ecran = partie(" " * 9 + "2" + " " * 20)
    egal(distances(ecran)[-2:], [197, 205], "Une impulsion fait passer de 197 à 205 km")
    egal("DELTA atteint à 205 km !" in ecran, True, "Le dépassement déclenche l’arrivée")


NIVEAUX = {
    "niveau-1": niveau_1,
    "niveau-2": niveau_2,
    "niveau-3": niveau_3,
    "niveau-4": niveau_4,
    "niveau-5": niveau_5,
}


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in NIVEAUX:
        print("Utilisation : bash verifier.sh niveau-N (de niveau-1 à niveau-5)")
        return 0 if len(sys.argv) == 1 else 2
    try:
        lancer(["-n", "./fusee.sh"])
        NIVEAUX[sys.argv[1]]()
    except subprocess.TimeoutExpired:
        print("À revoir — le script dure plus de 3 secondes. Vérifie la sortie de ta boucle.", file=sys.stderr)
        return 1
    except AssertionError as erreur:
        print(f"À revoir — {erreur}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
