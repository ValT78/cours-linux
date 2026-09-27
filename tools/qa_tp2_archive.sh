#!/usr/bin/env bash
set -euo pipefail

archive_path=${1:?"Usage: qa_tp2_archive.sh /chemin/vers/tp2-relais-aurore.zip"}
qa_dir=$(mktemp -d /tmp/tp2-aurore-qa.XXXXXX)

case "$qa_dir" in
  /tmp/tp2-aurore-qa.*) ;;
  *) echo "Dossier temporaire inattendu : $qa_dir" >&2; exit 90 ;;
esac

cleanup() {
  rm -rf -- "$qa_dir"
}
trap cleanup EXIT

unzip -q "$archive_path" -d "$qa_dir"
cd "$qa_dir/relais-aurore"

test "$(wc -l < bruts/communications-2026-09-21.log)" -eq 900
test "$(wc -l < bruts/communications-2026-09-22.log)" -eq 1050
test "$(wc -l < bruts/communications-2026-09-23.log)" -eq 1200
test "$(grep -h 'CRITIQUE' bruts/*.log | wc -l)" -eq 2
test "$(grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f3 | sort -u)" = 'balise-7'
test "$(grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f4 | sort -u)" = 'DELTA'
test "$(grep 'urgent' bruts/inventaire.csv | cut -d';' -f1 | wc -l)" -eq 2

chmod 640 scripts/diagnostic.sh
if ./scripts/diagnostic.sh >/dev/null 2>&1; then
  echo 'Le script ne devrait pas être exécutable en mode 640.' >&2
  exit 91
fi
chmod 750 scripts/diagnostic.sh
./scripts/diagnostic.sh

chmod u=,g=r,o= laboratoire/categorie-groupe.txt
if cat laboratoire/categorie-groupe.txt >/dev/null 2>&1; then
  echo 'Le propriétaire ne devrait pas pouvoir lire avec u=.' >&2
  exit 92
fi
chmod u=rw,g=r,o= laboratoire/categorie-groupe.txt

chmod u-w laboratoire/depot
if touch laboratoire/depot/nouveau.txt >/dev/null 2>&1; then
  echo 'La création ne devrait pas fonctionner sans w sur le dossier.' >&2
  exit 93
fi
test "$(cat laboratoire/depot/temoin.txt | wc -l)" -eq 1
chmod u+w laboratoire/depot

channel=$(head -n 1 bruts/communications-2026-09-21.log | cut -d= -f2)
signal=$(grep 'SIGNAL-URGENCE' bruts/*.log | cut -d= -f2)
zone=$(grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f4 | sort -u)
number=$(tail -n 1 bruts/communications-2026-09-23.log | cut -d= -f2)
test "$channel-$signal-$zone-$number" = 'VEGA-POLARIS-DELTA-42'

printf 'Code final : %s-%s-%s-%s\n' "$channel" "$signal" "$zone" "$number"
echo 'Archive TP2 validée.'
