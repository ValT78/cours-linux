#!/usr/bin/env bash
# Tableau de bord fourni pour le TP bonus Aurore.

affichage_couleur() {
    [[ -t 1 && ${TERM:-dumb} != dumb ]]
}

afficher_vol() {
    local position="$1" distance_affichee="$2" avant apres
    if [ "$position" -gt 20 ]; then
        position=20
    fi
    printf -v avant '%*s' "$position" ''
    printf -v apres '%*s' "$((20 - position))" ''

    if affichage_couleur; then
        printf '\033[H\033[J\n  \033[1;36mAURORE  /  VOL DE SECOURS VERS DELTA\033[0m\n'
    else
        printf '\n  AURORE  /  VOL DE SECOURS VERS DELTA\n'
    fi
    printf '\n  DÉPART %s🚀%s DELTA\n' "${avant// /━}" "${apres// /━}"
    printf '                 %s / 200 km\n\n' "$distance_affichee"
}

afficher_article() {
    local touche_article="$1" nom="$2" prix="$3" installe="$4" solde="$5"
    local etat="$prix crédits" couleur=90
    if [ "$installe" -eq 1 ]; then
        etat='INSTALLÉ'
        couleur=32
    elif [ "$solde" -ge "$prix" ]; then
        couleur=33
    fi
    if affichage_couleur; then
        printf '  \033[%sm[%s]  %-24s  %s\033[0m\n' "$couleur" "$touche_article" "$nom" "$etat"
    else
        printf '  [%s]  %-24s  %s\n' "$touche_article" "$nom" "$etat"
    fi
}

afficher_boutique() {
    local solde="$1" auto="$2" vitesse="${3-}" pousse="${4-5}"
    local booster="${5-0}" ionique="${6-0}"
    printf '  Crédits   %s' "$solde"
    if [ -n "$vitesse" ]; then
        printf '              Propulsion auto   +%s km/s' "$vitesse"
    fi
    printf '\n\n  [ESPACE]  Impulsion manuelle  +%s km\n' "$pousse"
    afficher_article 1 'Propulseur automatique' 10 "$auto" "$solde"
    if [ "$#" -ge 5 ]; then
        afficher_article 2 'Booster' 30 "$booster" "$solde"
    fi
    if [ "$#" -ge 6 ]; then
        afficher_article 3 'Moteur ionique' 50 "$ionique" "$solde"
    fi
}

afficher_commandes() {
    local texte="${1-}"
    if [ -n "$texte" ]; then
        printf '\n  > %s\n' "$texte"
    fi
    printf '\n  [Q] Quitter\n'
}
