#!/usr/bin/env bash
# Vérifie les données et mécanismes de découverte ; aucun corrigé élève n'est créé.
set -eu

project_root=$(cd "$(dirname "$0")/.." && pwd)
qa_dir="${project_root}/.cache/tp3-qa"
mkdir -p "$qa_dir"
unzip -oq "${project_root}/docs/assets/tp3-atelier-decisions.zip" -d "$qa_dir"
cd "${qa_dir}/atelier-decisions"

fail() { printf 'ECHEC : %s\n' "$*" >&2; exit 1; }
equal() { [ "$1" = "$2" ] || fail "$3 : obtenu <$1>, attendu <$2>"; }

block_count=0
for block in "${qa_dir}"/bash-blocs/*.sh; do
    bash -n "$block" || fail "Syntaxe : $block"
    block_count=$((block_count + 1))
done

cat > essais/repere.sh <<'SCRIPT'
#!/usr/bin/env bash
echo "Dossier de travail :"
pwd
SCRIPT
chmod u+x essais/repere.sh
atelier_dir=$PWD
initial_path=$PATH
equal "$(PATH="essais:$PATH" repere.sh)" "$(./essais/repere.sh)" 'PATH relatif depuis atelier'
cd donnees
if PATH="essais:$PATH" repere.sh > ../rapports/path-sortie.txt 2> ../rapports/path-erreur.txt; then
    fail 'PATH relatif devrait désigner un dossier absent depuis donnees'
else
    equal "$?" 127 'Commande introuvable depuis donnees'
fi
equal "$(PATH="${atelier_dir}/essais:$PATH" repere.sh)" "$(../essais/repere.sh)" 'PATH absolu depuis donnees'
equal "$PATH" "$initial_path" 'Affectation temporaire de PATH'
cd "$atelier_dir"
document='donnees/nom avec espaces.txt'
if cat ${document} >/dev/null 2>&1; then fail 'Le nom non protégé devrait être découpé'; fi
equal "$(cat "$document")" 'Un nom avec espaces reste un seul argument.' 'Nom de fichier protégé'

unset message_aurore || true
message_aurore='relais disponible'
equal "$(bash -c 'printf "%s" "${message_aurore}"')" '' 'Variable non exportée'
export message_aurore
equal "$(bash -c 'printf "%s" "${message_aurore}"')" 'relais disponible' 'Variable exportée'
bash -c 'message_aurore=autre'
equal "$message_aurore" 'relais disponible' 'Parent préservé'
export -n message_aurore
equal "$(bash -c 'printf "%s" "${message_aurore}"')" '' 'Export retiré'
equal "$message_aurore" 'relais disponible' 'Valeur conservée'
unset message_aurore

if ((0)); then fail '((0)) doit être faux'; fi
if ((7)); then :; else fail '((7)) doit être vrai'; fi
if bash -c 'false'; then fail 'Statut implicite de false'; else equal "$?" 1 'Statut implicite'; fi
if bash -c 'exit 7'; then fail 'exit 7'; else equal "$?" 7 'Statut explicite'; fi
equal "$((10#007))" 7 'Conversion décimale'
equal "$((10#0))" 0 'Conversion de zéro'
n=10
m=7
equal "$((n + m))" 17 'Addition du TD'
expression='2 + 3 * 4'
equal "$((expression))" 14 'Priorité arithmétique'

equal "$(bash -c 'for arg in "$@"; do printf "<%s>\n" "$arg"; done' demo alpha 'beta gamma' '' delta)" \
    $'<alpha>\n<beta gamma>\n<>\n<delta>' 'Parcours des arguments'
equal "$(bash -c 'while [ "$#" -gt 0 ]; do printf "<%s>\n" "$1"; shift; done' demo alpha 'beta gamma' '' delta)" \
    $'<alpha>\n<beta gamma>\n<>\n<delta>' 'Parcours par shift'
equal "$(bash -c 'printf "<%s>\n" "$*"' demo alpha 'beta gamma')" '<alpha beta gamma>' 'Regroupement par étoile'

IFS= read -r ligne < donnees/espaces.txt
equal "$ligne" '  chemin C:\relais\nord  ' 'Espaces et antislashs préservés'
equal "$(while IFS= read -r ligne || [ -n "$ligne" ]; do printf '<%s>\n' "$ligne"; done < donnees/sans-retour.txt)" \
    $'<premiere ligne>\n<derniere ligne sans retour>' 'Dernière ligne incomplète'

log_count=0
for log in donnees/logs/*.log; do
    [ -f "$log" ] || fail 'Nom de journal découpé'
    log_count=$((log_count + 1))
done
equal "$log_count" 2 'Deux journaux dont un nom avec espaces'
chmod u+x donnees/entrees/lancer.sh
chmod u-x donnees/entrees/note.txt
[ -x donnees/entrees/lancer.sh ] || fail 'Exécutable du laboratoire'
[ ! -x donnees/entrees/note.txt ] || fail 'Fichier non exécutable du laboratoire'
executable_count=0
for entry in "${PWD}"/donnees/entrees/*; do
    if [ -f "$entry" ] && [ -x "$entry" ]; then executable_count=$((executable_count + 1)); fi
done
equal "$executable_count" 1 'Dossier traversable exclu des fichiers exécutables'

equal "$(seq 5 -2 -1)" $'5\n3\n1\n-1' 'Suite décroissante'
equal "$(seq 5 1 2)" '' 'Suite vide'
if seq 1 0 3 >/dev/null 2>&1; then fail 'Pas nul accepté'; fi

printf '     1\talpha$\n     2\t$\n     3\t  $\n     4\tbeta\\suite$\n     5\t$\n     6\tgamma$\n     7\t$\n' > rapports/cat-attendu-qa.txt
cat -nsE donnees/lignes.txt donnees/suite.txt > rapports/cat-reference-qa.txt
diff -u rapports/cat-attendu-qa.txt rapports/cat-reference-qa.txt
printf '     1\tdebut suite$\n' > rapports/morceaux-attendu-qa.txt
cat -nE donnees/morceau-a.txt donnees/morceau-b.txt > rapports/morceaux-reference-qa.txt
diff -u rapports/morceaux-attendu-qa.txt rapports/morceaux-reference-qa.txt

cas='7=49'
equal "${cas%%=*}" 7 'Argument du cas de test'
equal "${cas#*=}" 49 'Résultat attendu'
equal "$((100 * 2 / 3))" 66 'Pourcentage entier'

printf 'TP3 : données, statuts, variables, arguments et lectures vérifiés ; %s blocs Bash syntaxiquement valides.\n' "$block_count"
