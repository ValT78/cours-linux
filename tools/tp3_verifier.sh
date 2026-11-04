#!/usr/bin/env bash
# Vérificateur fourni aux élèves. Ne contient pas les programmes à réaliser.
set -u

atelier=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
programmes=(repere parametres enfant statut parite depart somme concatenation triangle parametres2 arguments3 executables factorielle factorielle_recursif afficher_nom afficher_contenu mon_seq calculatrice mon_cat tester_script)
preparation=' repere parametres enfant statut parite depart somme concatenation triangle parametres2 arguments3 executables '

aide() {
    echo 'Usage : bash verifier.sh NOM [ETAPE]'
    echo 'Exemples : bash verifier.sh factorielle'
    echo '           bash verifier.sh mon_cat lecture'
    echo '           bash verifier.sh mon_cat numeros'
    echo '           bash verifier.sh tout'
    echo 'Programmes disponibles :'
    printf '  %s\n' "${programmes[@]}"
}

if (( $# == 0 )); then aide; exit 0; fi
if (( $# > 2 )); then aide >&2; exit 2; fi
nom=${1%.sh}
etape=${2:-complet}
if [[ $nom == --help || $nom == aide || $nom == liste ]]; then aide; exit 0; fi
if [[ $etape != complet && $etape != lecture && $etape != numeros ]]; then
    echo 'Etape inconnue : choisir lecture, numeros ou complet pour mon_cat.' >&2; exit 2
fi
if [[ $etape != complet && $nom != mon_cat ]]; then
    echo 'Les étapes lecture et numeros concernent uniquement mon_cat.' >&2; exit 2
fi
if [[ " ${programmes[*]} tout " != *" $nom "* ]]; then
    echo "Programme inconnu : $nom" >&2; aide >&2; exit 2
fi
for outil in timeout diff cmp mktemp cp chmod seq cat env head mkdir whoami ls rm sort; do
    if ! command -v "$outil" >/dev/null 2>&1; then
        echo "Outil Linux nécessaire introuvable : $outil" >&2; exit 2
    fi
done

# Un dossier temporaire par lancement ; sa cible est vérifiée avant nettoyage.
parent_tmp=$(CDPATH= cd -- "${TMPDIR:-/tmp}" && pwd -P) || exit 2
travail=$(mktemp -d "${parent_tmp}/tp3-verifier.XXXXXXXX") || exit 2
nettoyer() {
    case "$travail" in
        "$parent_tmp"/tp3-verifier.*) rm -rf -- "$travail" ;;
    esac
}
trap nettoyer EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
export LC_ALL=C
total=0
reussis=0
env_cas=()
comparaison=exacte
autre_attendu=''
attendu="${travail}/attendu.txt"
entree="${travail}/entree.txt"
sortie="${travail}/sortie.txt"
erreur="${travail}/erreur.txt"

texte_attendu() { printf '%s' "$1" > "$attendu"; }
texte_entree() { printf '%s' "$1" > "$entree"; }

essai() {
    local titre=$1 code_attendu=$2 erreur_attendue=$3 code raison='' sortie_correcte=0
    shift 3
    total=$((total + 1))
    (
        cd "$terrain" || exit 125
        # Limite aussi les sorties d'un programme qui afficherait sans fin.
        ulimit -f 2048 2>/dev/null || true
        env -u secteur_aurore "${env_cas[@]}" timeout --kill-after=1s 5s bash "$candidat" "$@"
    ) < "$entree" > "$sortie" 2> "$erreur"
    code=$?
    if [[ $comparaison == lignes ]]; then
        sort "$attendu" > "${travail}/attendu-trie.txt"
        sort "$sortie" > "${travail}/obtenu-trie.txt"
        cmp -s "${travail}/attendu-trie.txt" "${travail}/obtenu-trie.txt" && sortie_correcte=1
    elif cmp -s "$attendu" "$sortie"; then
        sortie_correcte=1
    elif [[ -n $autre_attendu ]] && cmp -s "$autre_attendu" "$sortie"; then
        sortie_correcte=1
    fi
    if (( code == 124 || code == 137 )); then
        raison='durée limite dépassée : vérifie la condition et la mise à jour de ta boucle'
    elif [[ $code_attendu == nonzero ]]; then
        (( code != 0 )) || raison='un statut d’erreur était attendu, obtenu : 0'
    elif [[ $code != "$code_attendu" ]]; then
        raison="statut attendu : $code_attendu ; obtenu : $code"
    fi
    if [[ -z $raison && $sortie_correcte == 0 ]]; then
        raison='la sortie normale ne correspond pas'
    fi
    if [[ -z $raison && $erreur_attendue == vide && -s $erreur ]]; then
        raison='un message inattendu est écrit sur la sortie d’erreur'
    elif [[ -z $raison && $erreur_attendue == presente && ! -s $erreur ]]; then
        raison='un diagnostic était attendu sur la sortie d’erreur'
    fi
    if [[ -z $raison ]]; then
        reussis=$((reussis + 1))
        echo "OK    — $titre"
    else
        echo "ECHEC — $titre"
        echo "        $raison"
        if (( sortie_correcte == 0 )); then
            echo '        Différence : - attendu ; + obtenu'
            diff -u --label attendu --label obtenu "$attendu" "$sortie" | head -n 28 | head -c 2400
        fi
        if [[ -s $erreur ]]; then
            echo '        Message du programme :'
            head -c 800 "$erreur"
            echo
        fi
    fi
    comparaison=exacte
    autre_attendu=''
}

cas_texte() {
    local titre=$1 code=$2 diagnostic=$3 texte=$4
    shift 4
    texte_attendu "$texte"
    texte_entree ''
    essai "$titre" "$code" "$diagnostic" "$@"
}

cas_reference_cat() {
    local titre=$1
    shift
    (cd "$terrain" && cat "$@") < "$entree" > "$attendu" 2>/dev/null
    local code=$? diagnostic=vide
    (( code == 0 )) || diagnostic=presente
    essai "$titre" "$code" "$diagnostic" "$@"
}

tester() {
    local cible=$1 avant_total=$total avant_reussis=$reussis i n resultat texte cas
    local -a args options
    echo
    echo "=== $cible ==="
    if [[ $preparation == *" $cible "* ]]; then
        candidat="${atelier}/preparation/${cible}.sh"
    else
        candidat="${atelier}/scripts/${cible}.sh"
    fi
    if [[ ! -f $candidat ]]; then
        total=$((total + 1)); echo "A CREER — ${candidat#"$atelier"/}"; return
    fi
    if ! bash -n "$candidat" 2> "$erreur"; then
        total=$((total + 1)); echo 'ECHEC — syntaxe du script'; cat "$erreur"; return
    fi
    terrain="${travail}/${cible}"
    mkdir -p "$terrain/donnees" "$terrain/rapports" "$terrain/essais"
    cp -R "${atelier}/donnees/." "$terrain/donnees/" || exit 2
    env_cas=()
    texte_entree ''

    case "$cible" in
        repere)
            printf -v texte 'Atelier Aurore\n%s\n%s\n' "$terrain" "$(whoami)"
            cas_texte 'dossier et utilisateur calculés au lancement' 0 vide "$texte"
            terrain="${terrain}/ailleurs"; mkdir -p "$terrain"
            printf -v texte 'Atelier Aurore\n%s\n%s\n' "$terrain" "$(whoami)"
            cas_texte 'lancement depuis un autre dossier' 0 vide "$texte"
            ;;
        parametres)
            for n in 0 1 2 3 4 5; do
                args=(); for ((i=1; i<=n; i++)); do args+=("argument$i"); done
                printf -v texte '%s\n%s\n%s\n%s\n%s\n' "$n" "$candidat" "${args[0]-}" "${args[1]-}" "${args[2]-}"
                cas_texte "$n argument(s), paramètres manquants ou supplémentaires" 0 vide "$texte" "${args[@]}"
            done
            printf -v texte '1\n%s\nHello World !\n\n\n' "$candidat"
            cas_texte 'une phrase reste un seul argument' 0 vide "$texte" 'Hello World !'
            printf -v texte '3\n%s\n-n\n\nbeta gamma\n' "$candidat"
            cas_texte 'arguments particuliers conservés' 0 vide "$texte" -n '' 'beta gamma'
            ;;
        enfant)
            cas_texte 'variable non transmise' 0 vide $'<>\n'
            env_cas=('secteur_aurore=Aurore Nord')
            cas_texte 'variable exportée avec espaces' 0 vide $'<Aurore Nord>\n'
            ;;
        statut)
            cas_texte 'un argument normal' 0 vide $'bonjour\n' bonjour
            cas_texte 'phrase conservée' 0 vide $'bonjour aurore\n' 'bonjour aurore'
            cas_texte 'argument vide présent' 0 vide $'\n' ''
            cas_texte 'une valeur ne doit pas devenir une option d’affichage' 0 vide $'-n\n' -n
            cas_texte 'argument manquant' 1 presente ''
            cas_texte 'trop d’arguments' 1 presente '' un deux
            ;;
        parite)
            for n in 0 10 7 -3; do
                if ((n % 2 == 0)); then resultat=pair; else resultat=impair; fi
                printf -v texte '%s est %s\n' "$n" "$resultat"
                cas_texte "parité de $n" 0 vide "$texte" "$n"
            done
            cas_texte 'argument manquant' 1 presente ''
            cas_texte 'trop d’arguments' 1 presente '' 2 3
            ;;
        depart)
            cas_texte 'décompte sans zéro et un seul départ' 0 vide $'5\n4\n3\n2\n1\nPartez !\n'
            ;;
        somme)
            for n in 1 4 7; do
                { seq "$n"; printf '%s\n' "$((n * (n + 1) / 2))"; } > "$attendu"
                texte_entree ''; essai "entiers et somme pour $n" 0 vide "$n"
            done
            ;;
        concatenation)
            cas_texte 'zéro ajout conserve la chaîne initiale' 0 vide $'salut !\n' 'salut !' 0
            cas_texte 'deux ajouts donnent trois exemplaires' 0 vide $'salut ! salut ! salut !\n' 'salut !' 2
            cas_texte 'les espaces restent dans le texte' 0 vide $'Aurore Nord Aurore Nord\n' 'Aurore Nord' 1
            cas_texte 'texte qui ressemble à une option' 0 vide $'-n\n' -n 0
            ;;
        triangle)
            cas_texte 'hauteur 1' 0 vide $'X\n' 1
            cas_texte 'hauteur 4' 0 vide $'X\nXX\nXXX\nXXXX\n' 4
            ;;
        parametres2|arguments3)
            printf -v texte '%s\n' "$candidat"
            cas_texte 'aucun argument' 0 vide "$texte"
            printf -v texte '%s\nalpha\nbeta gamma\n\ndelta\n-n\n' "$candidat"
            cas_texte 'chaque argument reste une ligne, même vide' 0 vide "$texte" alpha 'beta gamma' '' delta -n
            ;;
        executables)
            mkdir -p "$terrain/labo vide" "$terrain/labo executables/sous-dossier"
            printf '#!/usr/bin/env bash\necho temoin\n' > "$terrain/labo executables/alpha.sh"
            printf '#!/usr/bin/env bash\necho temoin\n' > "$terrain/labo executables/beta gamma.sh"
            printf 'note\n' > "$terrain/labo executables/note.txt"
            chmod u+x "$terrain/labo executables/alpha.sh" "$terrain/labo executables/beta gamma.sh"
            chmod a-x "$terrain/labo executables/note.txt"
            printf -v texte '%s\n%s\n' "$terrain/labo executables/alpha.sh" "$terrain/labo executables/beta gamma.sh"
            comparaison=lignes
            cas_texte 'fichiers exécutables seulement, noms avec espaces' 0 vide "$texte" "$terrain/labo executables"
            cas_texte 'dossier vide' 0 vide '' "$terrain/labo vide"
            cas_texte 'dossier absent' 1 presente '' "$terrain/absent"
            cas_texte 'argument manquant' 1 presente ''
            ;;
        factorielle|factorielle_recursif)
            for cas in 0:1 1:1 3:6 6:720 007:5040 12:479001600; do
                printf -v texte '%s\n' "${cas#*:}"
                cas_texte "factorielle de ${cas%%:*}" 0 vide "$texte" "${cas%%:*}"
            done
            cas_texte 'argument manquant' 1 presente ''
            cas_texte 'trop d’arguments' 1 presente '' 2 3
            cas_texte 'négatif refusé' 1 presente '' -1
            cas_texte 'texte refusé' 1 presente '' bonjour
            cas_texte 'décimal non entier refusé' 1 presente '' 2.5
            ;;
        afficher_nom)
            cas_texte 'valeurs par défaut' 0 vide $'main.c\n'
            cas_texte 'extension vide' 0 vide $'/tmp/foo\n' -e '' -r /tmp -n foo
            cas_texte 'autre ordre d’options' 0 vide $'/var/main.log\n' -r /var -e log
            cas_texte 'dernière valeur répétée et répertoire avec espaces' 0 vide $'dossier de test/dernier.c\n' -n premier -n dernier -r 'dossier de test/'
            cas_texte 'répertoire racine' 0 vide $'/main.c\n' -r /
            cas_texte 'répertoire explicitement vide' 0 vide $'main.c\n' -r ''
            cas_texte 'option inconnue' 1 presente '' -d /var
            cas_texte 'valeur manquante' 1 presente '' -n
            cas_texte 'argument isolé' 1 presente '' intrus
            ;;
        afficher_contenu)
            cas_texte 'sans argument' 0 vide ''
            args=(donnees/message.txt 'donnees/nom avec espaces.txt' donnees/absent.txt donnees/logs)
            {
                for cas in "${args[@]}"; do
                    printf '%s :\n' "$cas"
                    if [[ -d "$terrain/$cas" ]]; then ls "$terrain/$cas";
                    elif [[ -f "$terrain/$cas" ]]; then cat "$terrain/$cas";
                    else printf 'pas une entree\n'; fi
                done
            } > "$attendu"
            texte_entree ''; essai 'fichier, espaces, absence et dossier dans l’ordre' 0 vide "${args[@]}"
            ;;
        mon_seq)
            for cas in '4' '3 6' '1 3 9' '5 -2 -1' '5 1 2' '-3 0' '+3 +2 +7' '01 02 07'; do
                read -r -a args <<< "$cas"
                seq "${args[@]}" > "$attendu"
                texte_entree ''; essai "suite : $cas" 0 vide "${args[@]}"
            done
            cas_texte 'pas nul' 1 presente '' 1 0 3
            cas_texte 'argument manquant' 1 presente ''
            cas_texte 'trop d’arguments' 1 presente '' 1 2 3 4
            cas_texte 'valeur non entière' 1 presente '' 1.5
            ;;
        calculatrice)
            texte_attendu $'> 3\n> 7\n> 9\n> 3\n> '
            texte_entree $'1 + 2\n1 + 2 * 3\n(1 + 2) * 3\n7 / 2\nexit\n'
            essai 'conversation, priorités et division entière' 0 vide
            texte_attendu $'> 3\n> '; texte_entree $'5 - 2\n'
            printf '> 3\n' > "${travail}/sans-invite-finale.txt"; autre_attendu="${travail}/sans-invite-finale.txt"
            essai 'fin d’entrée sans exit' 0 vide
            texte_entree '5 - 2'; autre_attendu="${travail}/sans-invite-finale.txt"
            essai 'dernière expression sans retour final' 0 vide
            texte_attendu '> > '; texte_entree $'\nexit\n'; essai 'ligne vide puis exit' 0 vide
            cas_texte 'argument d’appel inattendu' 1 presente '' intrus
            ;;
        mon_cat)
            texte_entree ''
            cas_reference_cat 'lecture simple' donnees/lignes.txt
            cas_reference_cat 'fichier vide, espaces, antislashs et dernière ligne incomplète' donnees/vide.txt donnees/espaces.txt donnees/sans-retour.txt
            cas_reference_cat 'deux fichiers terminant la même ligne' donnees/morceau-a.txt donnees/morceau-b.txt
            texte_entree $'une ligne\n\nfin sans retour'; cas_reference_cat 'entrée standard sans fichier'
            texte_entree $'texte du clavier\n'; cas_reference_cat 'entrée standard désignée par -' donnees/message.txt -
            texte_entree ''; cas_reference_cat 'fichier absent, poursuite des autres lectures' donnees/message.txt donnees/absent.txt donnees/suite.txt
            if [[ $etape != lecture ]]; then
                cas_reference_cat 'numérotation continue entre fichiers' -n donnees/lignes.txt donnees/suite.txt
                cas_reference_cat 'une seule ligne numérotée entre deux morceaux' -n donnees/morceau-a.txt donnees/morceau-b.txt
            fi
            if [[ $etape == complet ]]; then
                for cas in '' -n -s -E -ns -nE -sE -nsE; do
                    options=(); [[ -z $cas ]] || options+=("$cas")
                    cas_reference_cat "combinaison ${cas:-sans option}" "${options[@]}" donnees/lignes.txt donnees/suite.txt
                done
                cas_reference_cat 'options séparées' -n -s -E donnees/lignes.txt
                cas_reference_cat 'marques de fin et ligne sans retour final' -nE donnees/sans-retour.txt
                cas_reference_cat 'marques de fin sans ligne inventée entre morceaux' -nsE donnees/morceau-a.txt donnees/morceau-b.txt
                texte_entree $'entree\n\n\nfin'; cas_reference_cat 'options sur entrée standard' -nsE
                texte_entree ''; cas_reference_cat 'fin des options' -n -- donnees/message.txt
                cas_texte 'option inconnue' 1 presente '' -Z
            fi
            ;;
        tester_script)
            mkdir -p "$terrain/outils de test"
            printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$(( $1 * 2 ))"\n' > "$terrain/outils de test/double.sh"
            printf '#!/usr/bin/env bash\nprintf "4\\n"\nexit 1\n' > "$terrain/outils de test/echec.sh"
            printf 'temoin\n' > "$terrain/non-executable"
            chmod u+x "$terrain/outils de test/"*.sh
            chmod a-x "$terrain/non-executable"
            local outil='./outils de test/double.sh'
            cas_texte 'plusieurs réussites, chemin contenant des espaces' 0 vide $'OK 2 => 4\nOK 3 => 6\nOK 5 => 10\n3 tests, 100% OK\n' "$outil" 2=4 3=6 5=10
            cas_texte 'échec détecté, pourcentage entier' 1 vide $'OK 2 => 4\nOK 3 => 6\nNOK 5 => 11, obtenu : 10\n3 tests, 66% OK\n' "$outil" 2=4 3=6 5=11
            cas_texte 'test mal formé, poursuite, priorité au statut 2' 2 presente $'OK 2 => 4\nNOK 5 => 11, obtenu : 10\n2 tests, 50% OK\n' "$outil" 2=4 3:6 5=11
            cas_texte 'aucun test valide, pas de division par zéro' 2 presente $'0 tests, 0% OK\n' "$outil" '=1' '1=' '1=2=3' 'a b=c'
            cas_texte 'une sortie correcte ne masque pas un échec' 1 vide $'NOK 2 => 4, obtenu : 4\n1 tests, 0% OK\n' './outils de test/echec.sh' 2=4
            cas_texte 'syntaxe d’appel : aucun argument' 3 presente ''
            cas_texte 'syntaxe d’appel : tests manquants' 3 presente '' "$outil"
            cas_texte 'chemin absent' 2 presente '' ./absent.sh 1=2
            cas_texte 'fichier non exécutable' 2 presente '' ./non-executable 1=2
            ;;
    esac
    echo "Bilan $cible : $((reussis - avant_reussis))/$((total - avant_total)) essais réussis."
}

if [[ ! -d $atelier/donnees ]]; then
    echo 'Place verifier.sh à la racine de l’atelier, à côté de donnees, preparation et scripts.' >&2
    exit 2
fi
if [[ $nom == tout ]]; then
    for programme in "${programmes[@]}"; do tester "$programme"; done
else
    tester "$nom"
fi
echo
echo "Bilan : $reussis/$total essais réussis."
if (( reussis == total )); then exit 0; fi
exit 1
