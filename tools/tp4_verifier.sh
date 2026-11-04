#!/usr/bin/env bash
# Vérificateur de l’atelier TP4. Compile et essaie les programmes dans un dossier temporaire.
set -u

aide() {
    echo 'Usage : bash verifier.sh ecrire|tictac|echecs|lignes_utiles|tout'
}

if (( $# == 0 )) || [[ $1 == --help ]]; then aide; exit 0; fi
if (( $# != 1 )); then aide >&2; exit 2; fi
case "$1" in
    ecrire|tictac|echecs|lignes_utiles|tout) choix=$1 ;;
    *) aide >&2; exit 2 ;;
esac

atelier=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || exit 2
parent_tmp=$(CDPATH= cd -- "${TMPDIR:-/tmp}" && pwd -P) || exit 2
travail=$(mktemp -d "$parent_tmp/tp4-verifier.XXXXXXXX") || exit 2
nettoyer() {
    case "$travail" in
        "$parent_tmp"/tp4-verifier.*) rm -rf -- "$travail" ;;
    esac
}
trap nettoyer EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

cd -- "$travail" || exit 2
cp -R -- "$atelier/donnees" . || exit 2
umask 022
export LC_ALL=C
total=0
reussis=0

bilan() {
    local titre=$1 raison=$2
    ((total += 1))
    if [[ -z $raison ]]; then
        ((reussis += 1))
        echo "OK    — $titre"
    else
        echo "ÉCHEC — $titre ($raison)"
    fi
}

essai() {
    local titre=$1 code_attendu=$2 stdout_attendue=$3 stderr_attendue=$4 saisie=$5
    local code raison=''
    shift 5
    printf '%s' "$saisie" > entree
    printf '%s' "$stdout_attendue" > attendu
    (
        ulimit -f 2048
        timeout --kill-after=1s 8s "${commande[@]}" "$@"
    ) < entree > sortie 2> erreur
    code=$?

    if (( code == 124 || code == 137 )); then
        raison='délai dépassé'
    elif (( code != code_attendu )); then
        raison="statut attendu $code_attendu, obtenu $code"
    elif ! cmp -s attendu sortie; then
        raison='sortie standard différente'
    elif [[ $stderr_attendue == diagnostic && ! -s erreur ]]; then
        raison='diagnostic manquant sur la sortie d’erreur'
    elif [[ $stderr_attendue != diagnostic ]] &&
        ! printf '%s' "$stderr_attendue" | cmp -s - erreur; then
        raison='sortie d’erreur différente'
    fi

    bilan "$titre" "$raison"
    if [[ -n $raison ]]; then
        diff -u --label 'sortie attendue' --label 'sortie obtenue' attendu sortie
        if [[ -s erreur ]]; then
            echo '        Sortie d’erreur obtenue (début) :'
            head -c 400 erreur
            echo
        fi
    fi
}

fichier() {
    local chemin=$1 contenu=$2 raison=''
    if ! printf '%s' "$contenu" | cmp -s - "$chemin"; then
        raison='fichier absent ou contenu différent'
    fi
    bilan "$chemin — contenu" "$raison"
}

tester() {
    local nom=$1 source usage question
    local -a commande
    echo "== $nom =="

    case "$nom" in
        ecrire|tictac)
            source="$atelier/$nom.c"
            if [[ ! -f $source ]]; then bilan "$nom.c" 'fichier manquant'; return; fi
            if ! command -v gcc >/dev/null; then bilan 'gcc' 'compilateur introuvable'; return; fi
            if ! gcc -Wall -Wextra -Werror -pedantic -o "./$nom" "$source"; then
                bilan "$nom.c" 'compilation échouée'
                return
            fi
            commande=("./$nom")
            ;;
        *)
            source="$atelier/$nom.sh"
            if [[ ! -f $source ]]; then bilan "$nom.sh" 'fichier manquant'; return; fi
            commande=(bash "$source")
            ;;
    esac

    case "$nom" in
        lignes_utiles|echecs)
            usage="usage : $nom.sh FICHIER"$'\n'
            essai 'appel sans argument' 1 '' "$usage" ''
            essai 'argument en trop' 1 '' "$usage" '' donnees/sshd_config autre
            essai 'fichier absent' 2 '' diagnostic '' absent.txt
            essai 'répertoire à la place d’un fichier' 2 '' diagnostic '' donnees
            ;;
    esac

    case "$nom" in
        lignes_utiles)
            essai 'directives SSH' 0 $'5\n' '' '' donnees/sshd_config
            essai 'seulement des commentaires et des blancs' 0 $'0\n' '' '' donnees/commentaires.conf
            printf 'Option oui\n\t# commentaire\nAutre non\n' > 'nom avec espaces.conf'
            essai 'nom avec espaces' 0 $'2\n' '' '' 'nom avec espaces.conf'
            ;;
        echecs)
            essai 'classement des trois adresses' 0 \
                $'13\n      6 203.0.113.7\n      4 198.51.100.23\n      2 203.0.113.99\n' \
                '' '' donnees/auth.log
            essai 'aucun échec' 0 $'0\n' '' '' donnees/sans-echec.log
            head -n 1 donnees/auth.log > 'un echec.log'
            essai 'une seule adresse' 0 $'1\n      1 203.0.113.7\n' '' '' 'un echec.log'
            ;;
        ecrire)
            usage=$'usage : ecrire FICHIER MOT...\n'
            essai 'mot manquant' 1 '' "$usage" '' message.txt
            essai 'écrire plusieurs arguments' 0 '' '' '' message.txt Bonjour tout le monde
            fichier message.txt $'Bonjour tout le monde\n'
            if [[ $(stat -c %a -- message.txt 2>/dev/null) == 644 ]]; then
                bilan 'droits à la création' ''
            else
                bilan 'droits à la création' '0644 attendu'
            fi
            essai 'remplacer un texte plus long' 0 '' '' '' message.txt 'un seul' mot
            fichier message.txt $'un seul mot\n'
            essai 'ouverture impossible' 2 '' diagnostic '' absent/message.txt mot
            ;;
        tictac)
            question=$'Combien de secondes ?\n'
            essai 'argument manquant' 1 '' $'usage : tictac FICHIER\n' ''
            essai 'écrire deux lignes' 0 "${question}"$'2 lignes écrites dans tic.txt\n' '' $'2\n' tic.txt
            fichier tic.txt $'tic 1\ntic 2\n'
            essai 'saisie non numérique' 1 "$question" $'tictac : nombre invalide\n' $'abc\n' tic.txt
            essai 'entrée vide' 1 "$question" $'tictac : nombre invalide\n' '' tic.txt
            essai 'zéro' 1 "$question" $'tictac : nombre invalide\n' $'0\n' tic.txt
            fichier tic.txt $'tic 1\ntic 2\n'
            essai 'ouverture impossible' 2 "$question" diagnostic $'1\n' absent/tic.txt
            ;;
    esac
}

if [[ $choix == tout ]]; then
    for nom in lignes_utiles echecs ecrire tictac; do tester "$nom"; done
else
    tester "$choix"
fi
echo "$reussis/$total vérifications réussies."
(( reussis == total ))
