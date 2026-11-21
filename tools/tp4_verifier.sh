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

afficher_texte() {
    local titre=$1 fichier=$2 ligne nombre=0
    printf '        %s\n' "$titre"
    if [[ ! -s $fichier ]]; then
        printf '          (rien)\n'
        return
    fi
    while IFS= read -r ligne; do
        printf '          |%s|\n' "$ligne"
        nombre=$((nombre + 1))
    done < <(head -c 800 "$fichier" | head -n 10)
    if [[ -n $ligne ]]; then
        printf '          |%s| (sans retour à la ligne dans cet aperçu)\n' "$ligne"
    fi
    if (( nombre == 10 || $(wc -c < "$fichier") > 800 )); then
        printf '          (aperçu limité à 10 lignes et 800 octets)\n'
    fi
}

bilan() {
    local titre=$1 raison=$2
    ((total += 1))
    if [[ -z $raison ]]; then
        ((reussis += 1))
    else
        printf 'ÉCHEC — %s\n        %s\n' "$titre" "$raison"
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
        raison='Le programme a dépassé les 8 secondes autorisées.'
    elif (( code != code_attendu )); then
        raison="Le programme doit se terminer avec le code $code_attendu. Code obtenu : $code."
    elif ! cmp -s attendu sortie; then
        raison='Compare le texte attendu et le texte affiché, ligne par ligne.'
    elif [[ $stderr_attendue == diagnostic && ! -s erreur ]]; then
        raison='Envoie un message qui explique l’erreur sur la sortie d’erreur (stderr).'
    elif [[ $stderr_attendue != diagnostic ]] &&
        ! printf '%s' "$stderr_attendue" | cmp -s - erreur; then
        raison='Vérifie le message envoyé sur la sortie d’erreur (stderr).'
    fi

    bilan "$titre" "$raison"
    if [[ -n $raison ]]; then
        case "$nom:${1-}" in
            lignes_utiles:'nom avec espaces.conf'|echecs:'un echec.log'|ecrire:*|tictac:*)
                printf '        Arguments utilisés dans le dossier de test :'
                if (( $# == 0 )); then printf ' (aucun)'; else printf ' %q' "$@"; fi
                printf '\n'
                if [[ $nom == tictac && $# -gt 0 ]]; then
                    afficher_texte 'Saisie fournie (rien = fin de saisie immédiate)' entree
                fi
                ;;
            *)
                printf '        À essayer depuis le dossier de l’atelier :\n          bash %q' "$nom.sh"
                if (( $# )); then printf ' %q' "$@"; fi
                printf '\n'
                ;;
        esac
        if ! cmp -s attendu sortie; then
            afficher_texte 'Texte attendu' attendu
            afficher_texte 'Texte affiché par ton programme' sortie
        fi
        if [[ $stderr_attendue != diagnostic ]]; then
            printf '%s' "$stderr_attendue" > erreur-attendue
            if ! cmp -s erreur-attendue erreur; then
                afficher_texte 'Message attendu sur la sortie d’erreur' erreur-attendue
                afficher_texte 'Message obtenu sur la sortie d’erreur' erreur
            elif [[ -s erreur ]]; then
                afficher_texte 'Message obtenu sur la sortie d’erreur' erreur
            fi
        elif [[ -s erreur ]]; then
            afficher_texte 'Message obtenu sur la sortie d’erreur' erreur
        fi
    fi
}

fichier() {
    local titre=$1 chemin=$2 contenu=$3 raison=''
    printf '%s' "$contenu" > contenu-attendu
    if [[ ! -f $chemin ]]; then
        raison="Le fichier $chemin devrait exister à cette étape."
    elif ! cmp -s contenu-attendu "$chemin"; then
        raison="Le contenu du fichier $chemin est différent."
    fi
    bilan "$titre" "$raison"
    if [[ -n $raison && -f $chemin ]]; then
        afficher_texte 'Contenu attendu' contenu-attendu
        afficher_texte 'Contenu du fichier' "$chemin"
    fi
}

tester() {
    local nom=$1 source usage question droits
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
            essai 'sans chemin de fichier, afficher le message d’usage et renvoyer 1' 1 '' "$usage" ''
            essai 'avec deux arguments, afficher le message d’usage et renvoyer 1' 1 '' "$usage" '' donnees/sshd_config autre
            essai 'signaler que absent.txt n’existe pas et renvoyer 2' 2 '' diagnostic '' absent.txt
            essai 'refuser donnees car c’est un dossier et renvoyer 2' 2 '' diagnostic '' donnees
            ;;
    esac

    case "$nom" in
        lignes_utiles)
            essai 'directives SSH' 0 $'5\n' '' '' donnees/sshd_config
            essai 'un fichier composé de commentaires et de lignes blanches contient 0 directive' 0 $'0\n' '' '' donnees/commentaires.conf
            printf 'Option oui\n\t# commentaire\nAutre non\n' > 'nom avec espaces.conf'
            essai 'compter 2 directives dans « nom avec espaces.conf », un fichier créé par le vérificateur' 0 $'2\n' '' '' 'nom avec espaces.conf'
            ;;
        echecs)
            essai 'compter 13 échecs au total, puis afficher les trois adresses les plus fréquentes' 0 \
                $'13\n      6 203.0.113.7\n      4 198.51.100.23\n      2 203.0.113.99\n' \
                '' '' donnees/auth.log
            essai 'afficher 0 sans ajouter de classement si le journal ne contient aucun échec' 0 $'0\n' '' '' donnees/sans-echec.log
            head -n 1 donnees/auth.log > 'un echec.log'
            essai 'avec une seule adresse dans le journal de test, afficher une seule ligne de classement' 0 $'1\n      1 203.0.113.7\n' '' '' 'un echec.log'
            ;;
        ecrire)
            usage=$'usage : ecrire FICHIER MOT...\n'
            essai 'un nom de fichier sans mot à écrire doit déclencher le message d’usage' 1 '' "$usage" '' message.txt
            essai 'écrire « Bonjour tout le monde » avec un espace entre les mots' 0 '' '' '' message.txt Bonjour tout le monde
            fichier 'vérifier le contenu de message.txt après la première écriture' message.txt $'Bonjour tout le monde\n'
            droits=$(stat -c %a -- message.txt 2>/dev/null)
            if [[ $droits == 644 ]]; then
                bilan 'permissions de message.txt à la création' ''
            else
                bilan 'permissions de message.txt à la création' \
                    "Permissions attendues : 0644 (lecture et écriture pour le propriétaire, lecture pour les autres). Obtenu : ${droits:-fichier absent}."
            fi
            essai 'remplacer « Bonjour tout le monde » par « un seul mot » sans garder la fin de l’ancien texte' 0 '' '' '' message.txt 'un seul' mot
            fichier 'vérifier que l’ancien texte a été entièrement remplacé dans message.txt' message.txt $'un seul mot\n'
            essai 'signaler que le fichier ne peut pas être créé dans un dossier absent et renvoyer 2' 2 '' diagnostic '' absent/message.txt mot
            ;;
        tictac)
            question=$'Combien de secondes ?\n'
            essai 'argument manquant' 1 '' $'usage : tictac FICHIER\n' ''
            essai 'pour la saisie 2, écrire « tic 1 » puis « tic 2 » et annoncer deux lignes' 0 "${question}"$'2 lignes écrites dans tic.txt\n' '' $'2\n' tic.txt
            fichier 'vérifier les deux lignes écrites dans tic.txt pour la saisie 2' tic.txt $'tic 1\ntic 2\n'
            essai 'refuser la saisie abc et renvoyer 1' 1 "$question" $'tictac : nombre invalide\n' $'abc\n' tic.txt
            essai 'sans saisie (comme avec < /dev/null), signaler une erreur et renvoyer 1' 1 "$question" $'tictac : nombre invalide\n' '' tic.txt
            essai 'refuser la saisie 0 : le nombre de secondes doit être positif' 1 "$question" $'tictac : nombre invalide\n' $'0\n' tic.txt
            fichier 'après abc, une fin de saisie immédiate et 0, tic.txt doit encore contenir ses deux lignes d’origine' tic.txt $'tic 1\ntic 2\n'
            essai 'signaler que le fichier ne peut pas être créé dans un dossier absent et renvoyer 2' 2 "$question" diagnostic $'1\n' absent/tic.txt
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
