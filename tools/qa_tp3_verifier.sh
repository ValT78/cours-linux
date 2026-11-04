#!/usr/bin/env bash
# Contrôles de fonctionnement du vérificateur fourni, sans corrigés des outils finaux.
set -eu
projet=$(cd "$(dirname "$0")/.." && pwd -P)
parent_tmp=$(cd "${TMPDIR:-/tmp}" && pwd -P)
dossier=$(mktemp -d "${parent_tmp}/tp3-verifier-qa.XXXXXXXX")
nettoyer() {
    case "$dossier" in "$parent_tmp"/tp3-verifier-qa.*) rm -rf -- "$dossier";; esac
}
trap nettoyer EXIT
mkdir -p "$dossier/chemin avec espaces"
unzip -q "$projet/docs/assets/tp3-atelier-decisions.zip" -d "$dossier/chemin avec espaces"
atelier="$dossier/chemin avec espaces/atelier-decisions"
journal="$dossier/journal.txt"

verifier_statut() {
    local attendu=$1 obtenu
    shift
    if bash "$atelier/verifier.sh" "$@" > "$journal" 2>&1; then obtenu=0; else obtenu=$?; fi
    if [[ $obtenu != "$attendu" ]]; then cat "$journal"; echo "Statut $obtenu au lieu de $attendu" >&2; exit 1; fi
}

verifier_statut 0
grep -q 'Programmes disponibles' "$journal"
verifier_statut 2 introuvable
verifier_statut 2 factorielle lecture
verifier_statut 2 mon_cat inconnue
verifier_statut 1 tout
test "$(grep -c 'A CREER' "$journal")" -eq 20

printf '#!/usr/bin/env bash\nif\n' > "$atelier/preparation/repere.sh"
verifier_statut 1 repere
grep -q 'syntaxe' "$journal"

printf '#!/usr/bin/env bash\necho faux\n' > "$atelier/preparation/repere.sh"
verifier_statut 1 repere
grep -q 'attendu' "$journal"
grep -q 'obtenu' "$journal"

# Témoin minimal : messages et emplacement doivent suivre le dossier de lancement.
printf '#!/usr/bin/env bash\necho "Atelier Aurore"\npwd\nwhoami\n' > "$atelier/preparation/repere.sh"
verifier_statut 0 repere.sh
grep -q '2/2 essais' "$journal"

# Un programme constant ne doit pas être accepté comme une factorielle.
printf '#!/usr/bin/env bash\necho 720\n' > "$atelier/scripts/factorielle.sh"
verifier_statut 1 factorielle
grep -q 'OK.*factorielle de 6' "$journal"
grep -q 'ECHEC.*factorielle de 0' "$journal"

printf '#!/usr/bin/env bash\nwhile true; do :; done\n' > "$atelier/preparation/depart.sh"
verifier_statut 1 depart
grep -q 'limite' "$journal"

echo 'Vérificateur TP3 : aide, appels incorrects, fichiers manquants, syntaxe, sorties fausses, témoin valide, chemin avec espaces et boucle infinie vérifiés.'
