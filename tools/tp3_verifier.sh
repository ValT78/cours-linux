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
for outil in timeout cmp wc mktemp cp chmod seq cat env head mkdir whoami ls rm sort; do
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

# Une commande à recopier, sauf quand l’essai dépend de fichiers temporaires.
afficher_appel() {
    case "$cible" in
        executables|tester_script)
            printf '        Arguments utilisés dans le dossier de test :'
            if (( $# == 0 )); then printf ' (aucun)'; else printf ' %q' "$@"; fi
            printf '\n'
            return
            ;;
    esac

    printf '        À essayer depuis le dossier de l’atelier :\n          '
    if [[ -s $entree ]]; then
        # read -d '' conserve même les retours à la ligne à la fin de la saisie.
        local saisie
        IFS= read -r -d '' saisie < "$entree" || :
        printf "printf '%%s' %q | " "$saisie"
    fi
    if [[ $cible == enfant ]]; then
        printf 'env -u secteur_aurore'
        if (( ${#env_cas[@]} )); then printf ' %q' "${env_cas[@]}"; fi
        printf ' '
    fi
    if [[ $cible == repere && $terrain == "$travail/repere/ailleurs" ]]; then
        printf '(script="$PWD"/preparation/repere.sh; cd donnees && bash "$script")\n'
        printf '        Dans cet exemple, ton script doit afficher le chemin du dossier donnees.\n'
        return
    fi
    case "$cible" in
        parametres|parametres2|arguments3) printf 'bash "$PWD"/%q' "${candidat#"$atelier"/}" ;;
        *) printf 'bash %q' "${candidat#"$atelier"/}" ;;
    esac
    if (( $# )); then printf ' %q' "$@"; fi
    if [[ $cible == mon_cat && ! -s $entree ]]; then printf ' < /dev/null'; fi
    printf '\n'
    if [[ $cible == repere ]]; then
        printf '        Ton script doit afficher le dossier courant. Le vérificateur utilise un dossier temporaire.\n'
    fi
}

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
        (( code != 0 )) || raison='Le script doit signaler une erreur avec un code différent de 0. Code obtenu : 0.'
    elif [[ $code != "$code_attendu" ]]; then
        raison="Le script doit se terminer avec le code $code_attendu. Code obtenu : $code."
    fi
    if [[ -z $raison && $sortie_correcte == 0 ]]; then
        raison='Compare le texte attendu et le texte affiché, ligne par ligne.'
    fi
    if [[ -z $raison && $erreur_attendue == vide && -s $erreur ]]; then
        raison='Ce cas ne doit rien écrire sur la sortie d’erreur (stderr).'
    elif [[ -z $raison && $erreur_attendue == presente && ! -s $erreur ]]; then
        raison='Envoie un message qui explique l’erreur sur la sortie d’erreur (stderr), par exemple avec >&2.'
    fi
    if [[ -z $raison ]]; then
        reussis=$((reussis + 1))
    else
        echo "ÉCHEC — $titre"
        afficher_appel "$@"
        echo "        $raison"
        if (( sortie_correcte == 0 )); then
            afficher_texte 'Texte attendu' "$attendu"
            if [[ -n $autre_attendu ]]; then afficher_texte 'Autre texte accepté' "$autre_attendu"; fi
            afficher_texte 'Texte affiché par ton script' "$sortie"
        fi
        if [[ -s $erreur ]]; then
            afficher_texte 'Message obtenu sur la sortie d’erreur' "$erreur"
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
            cas_texte 'afficher le dossier courant et le nom de l’utilisateur au lancement' 0 vide "$texte"
            terrain="${terrain}/ailleurs"; mkdir -p "$terrain"
            printf -v texte 'Atelier Aurore\n%s\n%s\n' "$terrain" "$(whoami)"
            cas_texte 'relancé ailleurs, le script doit afficher le nouveau dossier courant' 0 vide "$texte"
            ;;
        parametres)
            for n in 0 1 2 3 4 5; do
                args=(); for ((i=1; i<=n; i++)); do args+=("argument$i"); done
                printf -v texte '%s\n%s\n%s\n%s\n%s\n' "$n" "$candidat" "${args[0]-}" "${args[1]-}" "${args[2]-}"
                cas_texte "$n argument(s) reçu(s) : afficher le nombre, le chemin du script et les trois premières valeurs (ligne vide si absente)" 0 vide "$texte" "${args[@]}"
            done
            printf -v texte '1\n%s\nHello World !\n\n\n' "$candidat"
            cas_texte '« Hello World ! » compte pour un seul argument malgré les espaces' 0 vide "$texte" 'Hello World !'
            printf -v texte '3\n%s\nalpha\n\nbeta gamma\n' "$candidat"
            cas_texte 'entre alpha et « beta gamma », l’argument vide doit produire une ligne vide' 0 vide "$texte" alpha '' 'beta gamma'
            ;;
        enfant)
            cas_texte 'sans la variable secteur_aurore, afficher <>' 0 vide $'<>\n'
            env_cas=('secteur_aurore=Aurore Nord')
            cas_texte 'afficher <Aurore Nord> en conservant l’espace' 0 vide $'<Aurore Nord>\n'
            ;;
        statut)
            cas_texte 'un argument normal' 0 vide $'bonjour\n' bonjour
            cas_texte 'afficher « bonjour aurore » sur une seule ligne' 0 vide $'bonjour aurore\n' 'bonjour aurore'
            cas_texte 'un argument vide compte comme un argument et doit produire une ligne vide' 0 vide $'\n' ''
            cas_texte 'afficher -n suivi d’un retour à la ligne (echo -n ne l’affiche pas)' 0 vide $'-n\n' -n
            cas_texte 'sans argument, signaler une erreur : un argument est obligatoire' 1 presente ''
            cas_texte 'avec deux arguments, signaler une erreur : un seul argument est autorisé' 1 presente '' un deux
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
            cas_texte 'afficher de 5 à 1, puis « Partez ! » une seule fois' 0 vide $'5\n4\n3\n2\n1\nPartez !\n'
            ;;
        somme)
            for n in 1 4 7; do
                { seq "$n"; printf '%s\n' "$((n * (n + 1) / 2))"; } > "$attendu"
                texte_entree ''; essai "afficher les entiers de 1 à $n, puis leur somme sur la dernière ligne" 0 vide "$n"
            done
            ;;
        concatenation)
            cas_texte 'zéro ajout conserve la chaîne initiale' 0 vide $'salut !\n' 'salut !' 0
            cas_texte 'deux ajouts donnent trois exemplaires' 0 vide $'salut ! salut ! salut !\n' 'salut !' 2
            cas_texte 'répéter « Aurore Nord » en conservant l’espace entre les deux mots' 0 vide $'Aurore Nord Aurore Nord\n' 'Aurore Nord' 1
            cas_texte 'avec -n et zéro ajout, afficher -n suivi d’un retour à la ligne (echo -n ne l’affiche pas)' 0 vide $'-n\n' -n 0
            ;;
        triangle)
            cas_texte 'hauteur 1' 0 vide $'X\n' 1
            cas_texte 'hauteur 4' 0 vide $'X\nXX\nXXX\nXXXX\n' 4
            ;;
        parametres2|arguments3)
            printf -v texte '%s\n' "$candidat"
            cas_texte 'aucun argument' 0 vide "$texte"
            printf -v texte '%s\nalpha\nbeta gamma\n\ndelta\n-n\n' "$candidat"
            cas_texte 'afficher chaque argument sur sa propre ligne, y compris l’argument vide et -n' 0 vide "$texte" alpha 'beta gamma' '' delta -n
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
            cas_texte 'lister les fichiers exécutables, y compris beta gamma.sh, en ignorant le sous-dossier et le fichier non exécutable' 0 vide "$texte" "$terrain/labo executables"
            cas_texte 'un dossier vide est valide et ne produit aucune ligne' 0 vide '' "$terrain/labo vide"
            cas_texte 'dossier absent' 1 presente '' "$terrain/absent"
            cas_texte 'argument manquant' 1 presente ''
            ;;
        factorielle|factorielle_recursif)
            for cas in 0:1 1:1 3:6 6:720 007:5040 12:479001600; do
                n=${cas%%:*}
                printf -v texte '%s\n' "${cas#*:}"
                case "$n" in
                    0) cas_texte 'factorielle de 0 : afficher 1' 0 vide "$texte" "$n" ;;
                    007) cas_texte 'calculer 7! même si l’argument est écrit 007' 0 vide "$texte" "$n" ;;
                    *) cas_texte "factorielle de $n" 0 vide "$texte" "$n" ;;
                esac
            done
            cas_texte 'argument manquant' 1 presente ''
            cas_texte 'trop d’arguments' 1 presente '' 2 3
            cas_texte 'négatif refusé' 1 presente '' -1
            cas_texte 'texte refusé' 1 presente '' bonjour
            cas_texte 'décimal non entier refusé' 1 presente '' 2.5
            ;;
        afficher_nom)
            cas_texte 'valeurs par défaut' 0 vide $'main.c\n'
            cas_texte 'avec -e suivi d’un argument vide, afficher le nom sans point final' 0 vide $'/tmp/foo\n' -e '' -r /tmp -n foo
            cas_texte 'traiter -r et -e même si -n est absent' 0 vide $'/var/main.log\n' -r /var -e log
            cas_texte 'si -n apparaît deux fois, garder « dernier » et conserver les espaces du chemin' 0 vide $'dossier de test/dernier.c\n' -n premier -n dernier -r 'dossier de test/'
            cas_texte 'avec -r /, garder une seule barre oblique au début du chemin' 0 vide $'/main.c\n' -r /
            cas_texte 'avec -r suivi d’un argument vide, afficher main.c sans barre oblique' 0 vide $'main.c\n' -r ''
            cas_texte 'option inconnue' 1 presente '' -d /var
            cas_texte 'refuser -n quand aucun argument ne donne le nom' 1 presente '' -n
            cas_texte 'refuser « intrus », qui ne suit aucune option' 1 presente '' intrus
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
            texte_entree ''; essai 'traiter chaque chemin dans l’ordre : afficher le fichier, signaler l’absence ou lister le dossier' 0 vide "${args[@]}"
            ;;
        mon_seq)
            for cas in \
                '4|avec une seule borne, commencer à 1 et avancer de 1 en 1' \
                '3 6|avec deux bornes, avancer de 1 en 1' \
                '1 3 9|avec un pas de 3, afficher 1, 4 et 7 sans dépasser 9' \
                '5 -2 -1|avec un pas de -2, descendre de 5 à -1' \
                '5 1 2|avec un pas positif et un départ au-dessus de la fin, ne rien afficher' \
                '-3 0|accepter une borne négative et terminer à 0' \
                '+3 +2 +7|accepter le signe + devant les nombres' \
                '01 02 07|accepter les zéros initiaux et afficher 1, 3, 5 et 7'; do
                read -r -a args <<< "${cas%%|*}"
                seq "${args[@]}" > "$attendu"
                texte_entree ''; essai "${cas#*|}" 0 vide "${args[@]}"
            done
            cas_texte 'refuser le pas 0 : la suite ne pourrait pas avancer' 1 presente '' 1 0 3
            cas_texte 'argument manquant' 1 presente ''
            cas_texte 'trop d’arguments' 1 presente '' 1 2 3 4
            cas_texte 'valeur non entière' 1 presente '' 1.5
            ;;
        calculatrice)
            texte_attendu $'> 3\n> 7\n> 9\n> 3\n> '
            texte_entree $'1 + 2\n1 + 2 * 3\n(1 + 2) * 3\n7 / 2\nexit\n'
            essai 'respecter la priorité de la multiplication et les parenthèses, puis afficher 3 pour 7 / 2' 0 vide
            texte_attendu $'> 3\n> '; texte_entree $'5 - 2\n'
            printf '> 3\n' > "${travail}/sans-invite-finale.txt"; autre_attendu="${travail}/sans-invite-finale.txt"
            essai 'calculer 5 - 2 puis s’arrêter à la fin de la saisie, même sans la commande exit' 0 vide
            texte_entree '5 - 2'; autre_attendu="${travail}/sans-invite-finale.txt"
            essai 'calculer 5 - 2 même si la saisie se termine sans retour à la ligne' 0 vide
            texte_attendu '> > '; texte_entree $'\nexit\n'; essai 'ignorer la ligne vide puis quitter à la lecture de exit' 0 vide
            cas_texte 'refuser « intrus » car la calculatrice lit ses expressions sur l’entrée standard' 1 presente '' intrus
            ;;
        mon_cat)
            texte_entree ''
            cas_reference_cat 'lecture simple' donnees/lignes.txt
            cas_reference_cat 'recopier les fichiers tels quels, y compris les espaces, les antislashs et la dernière ligne sans retour' donnees/vide.txt donnees/espaces.txt donnees/sans-retour.txt
            cas_reference_cat 'le premier fichier n’a pas de retour final : le second continue la même ligne' donnees/morceau-a.txt donnees/morceau-b.txt
            texte_entree $'une ligne\n\nfin sans retour'; cas_reference_cat 'entrée standard sans fichier'
            texte_entree $'texte du clavier\n'; cas_reference_cat 'lire le premier fichier, puis lire la saisie à l’emplacement de l’argument -' donnees/message.txt -
            texte_entree ''; cas_reference_cat 'signaler le fichier absent, puis lire quand même donnees/suite.txt' donnees/message.txt donnees/absent.txt donnees/suite.txt
            if [[ $etape != lecture ]]; then
                cas_reference_cat 'numérotation continue entre fichiers' -n donnees/lignes.txt donnees/suite.txt
                cas_reference_cat 'avec -n, les deux morceaux de la même ligne ne reçoivent qu’un seul numéro' -n donnees/morceau-a.txt donnees/morceau-b.txt
            fi
            if [[ $etape == complet ]]; then
                for cas in '' -n -s -E -ns -nE -sE -nsE; do
                    options=(); [[ -z $cas ]] || options+=("$cas")
                    cas_reference_cat "combinaison ${cas:-sans option}" "${options[@]}" donnees/lignes.txt donnees/suite.txt
                done
                cas_reference_cat 'options séparées' -n -s -E donnees/lignes.txt
                cas_reference_cat 'avec -E, une ligne sans retour final ne reçoit pas de marque de fin' -nE donnees/sans-retour.txt
                cas_reference_cat 'avec -E, ne pas ajouter de retour ni de marque de fin entre les deux morceaux' -nsE donnees/morceau-a.txt donnees/morceau-b.txt
                texte_entree $'entree\n\n\nfin'; cas_reference_cat 'appliquer la numérotation, la réduction des lignes vides et les marques de fin à la saisie' -nsE
                texte_entree ''; cas_reference_cat 'reconnaître -- comme fin des options, puis lire le fichier qui suit' -n -- donnees/message.txt
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
            cas_texte 'lancer l’outil malgré les espaces dans son chemin et compter les trois réussites' 0 vide $'OK 2 => 4\nOK 3 => 6\nOK 5 => 10\n3 tests, 100% OK\n' "$outil" 2=4 3=6 5=10
            cas_texte 'deux réussites sur trois donnent 66 %, avec un code de sortie de 1' 1 vide $'OK 2 => 4\nOK 3 => 6\nNOK 5 => 11, obtenu : 10\n3 tests, 66% OK\n' "$outil" 2=4 3=6 5=11
            cas_texte 'signaler 3:6, continuer avec 5=11 et renvoyer 2 même si ce dernier essai échoue' 2 presente $'OK 2 => 4\nNOK 5 => 11, obtenu : 10\n2 tests, 50% OK\n' "$outil" 2=4 3:6 5=11
            cas_texte 'si toutes les paires sont invalides, afficher « 0 tests, 0% OK »' 2 presente $'0 tests, 0% OK\n' "$outil" '=1' '1=' '1=2=3' 'a b=c'
            cas_texte 'l’outil affiche bien 4 mais renvoie 1 : compter cet essai comme un échec' 1 vide $'NOK 2 => 4, obtenu : 4\n1 tests, 0% OK\n' './outils de test/echec.sh' 2=4
            cas_texte 'syntaxe d’appel : aucun argument' 3 presente ''
            cas_texte 'sans paire ENTREE=ATTENDU après le chemin de l’outil, renvoyer 3' 3 presente '' "$outil"
            cas_texte 'chemin absent' 2 presente '' ./absent.sh 1=2
            cas_texte 'fichier non exécutable' 2 presente '' ./non-executable 1=2
            ;;
    esac
    if [[ $nom == tout ]]; then
        echo "Bilan $cible : $((reussis - avant_reussis))/$((total - avant_total)) essais réussis."
    fi
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
