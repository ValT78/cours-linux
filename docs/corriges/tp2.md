# Corrigé du TP 2 — Faire parler les traces du relais Aurore

Suis le [sujet](../eleves/tp2-lire-les-traces.md) avec ton carnet. Sauf indication contraire, lance les commandes depuis `~/base-exploration/tp2/relais-aurore`.

## Niveaux 0 et 1 — Te repérer et examiner les fichiers

**N01.** Bash remplace `~` par le chemin de ton dossier personnel. Le résultat commence par `/`, par exemple `/home/alice`. L’écriture `~` est un raccourci que Bash développe.

**N02.** Pour revenir depuis `/tmp`, donne à `cd` le chemin complet obtenu avec `pwd` dans le relais, par exemple `/home/alice/base-exploration/tp2/relais-aurore`. Quand tu es dans `documentation`, `.` désigne `documentation` et `..` désigne `relais-aurore`.

**N03.** `type bruts` cherche une commande qui s’appellerait `bruts`. Pour examiner l’objet sur le disque, utilise `file bruts` ou `ls -ld bruts`. Le premier dit qu’il s’agit d’un dossier. Le second montre un `d` au début de la ligne. `file scripts/diagnostic.sh` reconnaît un script Bash.

**N04.** `ls -lhS bruts` affiche d’abord le plus gros fichier, `communications-2026-09-23.log`. `-l` ajoute les détails, `-h` rend les tailles lisibles et `-S` trie par taille décroissante. `ls -ld scripts` décrit le dossier `scripts` lui-même grâce à `-d`.

## Niveau 2 — Lire les droits

**N05.** Avec `u=,g=r,o=`, le propriétaire n’a aucun droit sur le fichier. `cat` est refusé, même si le propriétaire fait aussi partie du groupe. Linux utilise les droits d’une seule catégorie.

**N06.** Après `chmod u-w laboratoire/depot`, `touch` échoue à créer `nouveau.txt` et `rm` échoue à supprimer `temoin.txt`. Les deux opérations changent la liste des entrées de `depot`. `cat` peut toujours lire le témoin car le dossier est traversable et le fichier est lisible. Restaure l’écriture avec `chmod u+w laboratoire/depot`.

**N07.** `750` donne `rwx r-x ---`. Les chiffres concernent, dans l’ordre, le propriétaire, le groupe et les autres. En mode `640`, le propriétaire a `rw-`. Il lui manque `x` pour lancer directement le script.

## Niveau 3 — Comprendre ce que Bash transmet

**N08.** Avec `echo bruts/*.log`, Bash remplace le motif par les chemins des trois journaux avant de lancer `echo`. Avec `echo "bruts/*.log"`, Bash transmet le motif tel quel. Dans les deux cas, `echo` affiche les arguments reçus. Pour les CSV, utilise `ls bruts/*.csv`.

**N09.** Les guillemets simples conservent le texte `$(date +%H:%M)`. Dans les guillemets doubles, Bash exécute `date +%H:%M` et insère l’heure à la place de `$(...)`.

Pour l’exercice des accolades, Bash construit trois chemins avant de lancer chaque commande.

```bash
touch rapports/rapport-{erreurs,sources,zones}.txt
rm rapports/rapport-{erreurs,sources,zones}.txt
```

## Niveau 4 — Lire le début, la fin et les lignes utiles

**N10.** `head -n 1` affiche l’entête. `tail -n 1` affiche la dernière transmission. `wc -l` compte les lignes. Le 21 septembre commence par le canal **VEGA** et le 23 se termine par le numéro **42**.

**N11.** Dans la commande inversée, `grep` prend `bruts/communications-2026-09-22.log` pour le motif et cherche un fichier nommé `CRITIQUE`. La commande corrigée est `grep -n 'CRITIQUE' bruts/communications-2026-09-22.log`. `-n` ajoute les numéros de ligne sans changer la sélection.

**N12.** Lance ces quatre commandes pour le journal du 23 septembre.

```bash
wc -l bruts/communications-2026-09-23.log
tail -n 1 bruts/communications-2026-09-23.log
grep -n 'CRITIQUE' bruts/communications-2026-09-23.log
grep -v 'INFO' bruts/communications-2026-09-23.log
```

Le journal compte **1 200 lignes**. La dernière contient `FIN-TRANSMISSION=42`. La ligne critique est la **777**. Elle donne `COORDONNEES=47.219,-1.553`. `grep -v 'INFO'` inverse la sélection et affiche les **36 lignes** qui ne contiennent pas `INFO`.

## Niveaux 5 et 6 — Relier les filtres

**N13.** `grep -v 'INFO' bruts/communications-2026-09-21.log | wc -l` affiche **26**. Le tube envoie les lignes retenues par `grep` à l’entrée de `wc`. Celui-ci affiche leur nombre.

**N14.** `grep -h 'ERREUR' bruts/*.log | wc -l` affiche **26**. Lance d’abord `grep` seul pour voir les lignes retenues. Un nombre seul ne te dit pas si le motif ou les fichiers choisis étaient les bons.

**N15.** Dans la conduite ci-dessous, `grep` sélectionne les lignes d’erreur. `-h` masque le nom du fichier. `cut` découpe chaque ligne sur le point-virgule et garde le troisième champ, la source. `sort -u` trie les sources et garde une occurrence de chacune.

```bash
grep -h 'ERREUR' bruts/*.log | cut -d';' -f3 | sort -u
```

**N16.** Voici les quatre conduites dans l’ordre du sujet.

```bash
grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f4 | sort -u
grep ';urgent;' bruts/inventaire.csv | cut -d';' -f1
grep -h 'ERREUR' bruts/*.log | cut -d';' -f3 | sort -u
grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f3,4 | tr ';' ' '
```

| Conduite | Résultat |
|---|---|
| Zones critiques | `DELTA` |
| Matériel urgent | `batterie-balise-7` puis `antenne-secours` |
| Sources d’erreur | `balise-3`, `energie`, `meteo`, `navigation`, `radio`, `stockage` |
| Source et zone des lignes critiques | Deux lignes `balise-7 DELTA`, une par message critique |

Pour la dernière conduite, `cut` utilise encore les points-virgules pour repérer les champs. Remplace-les par des espaces seulement après l’extraction.

## Niveaux 7 et 8 — Enregistrer les résultats et les erreurs

**N17.** `>>` a ajouté une deuxième copie des lignes critiques à la fin du fichier. Utilise `>` pour reconstruire un rapport à chaque lancement. Utilise `>>` pour garder un historique ou ajouter une date à un rapport existant.

**N18.** `liste-bruts.txt` contient les noms du dossier `bruts`. `erreurs.txt` contient le message sur `bruts/fichier-inexistant`. Tu peux ainsi traiter la liste tout en gardant le message pour comprendre l’échec.

**N19.** `<` donne le contenu d’un fichier à la commande. `>` envoie la sortie normale dans un fichier et `2>` y envoie la sortie d’erreur. `2>&1` branche les erreurs sur la destination actuelle de la sortie normale. Dans `> rapports/controle-complet.txt 2>&1`, Bash branche d’abord la sortie normale sur le fichier. Les erreurs la rejoignent ensuite.

## Niveau 9 — Suivre une tâche

**N20.** Avec `sleep 20`, Bash attend au premier plan. Avec `sleep 90 &`, tu récupères l’invite tout de suite. `jobs` affiche les tâches du shell courant et leur état. `fg` ramène une tâche au premier plan. `bg` reprend une tâche suspendue en arrière-plan.

Pour le deuxième essai, tape `sleep 45 &`, puis `jobs`. Si le numéro affiché est `[1]`, tape `fg %1`, puis appuie sur `Ctrl+C`. Adapte le numéro à celui de ta tâche.

## Niveau 10 — Rendre le bilan reproductible

**N21.** Dans `scripts/bilan.sh`, ajoute les deux dernières lignes pour afficher les zones critiques triées et sans doublon.

```bash
#!/usr/bin/env bash
echo "Nombre de lignes ERREUR :"
grep -h 'ERREUR' bruts/*.log | wc -l
echo "Sources concernées :"
grep -h 'ERREUR' bruts/*.log | cut -d';' -f3 | sort -u
echo "Zones critiques :"
grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f4 | sort -u
```

**Dans le terminal**, applique `chmod 750 scripts/bilan.sh`. Le mode donne `rwx r-x ---`. Avec `bash scripts/bilan.sh`, Bash lit le fichier comme une entrée. Avec `./scripts/bilan.sh`, Linux doit pouvoir exécuter le fichier et le shebang indique quel interpréteur lancer.

## Boss final — N22 · Envoyer le rapport d’Aurore

**Dans le terminal**, produis les cinq fichiers demandés. La deuxième conduite répond aussi à l’exercice du niveau 7.2.

```bash
grep -h 'CRITIQUE' bruts/*.log | sort > rapports/critiques.txt
grep -h 'ERREUR' bruts/*.log | cut -d';' -f3 | sort -u > rapports/sources-erreur.txt
grep -h 'CRITIQUE' bruts/*.log | cut -d';' -f4 | sort -u > rapports/zones-critiques.txt
grep ';urgent;' bruts/inventaire.csv | cut -d';' -f1 > rapports/materiel-urgent.txt
./scripts/bilan.sh > rapports/bilan.txt
```

Vérifie que les quatre premiers rapports contiennent respectivement 2, 6, 1 et 2 lignes. Le bilan doit reprendre le total de 26 erreurs, les six sources et la zone `DELTA`.

La première ligne du 21 donne **VEGA**. La ligne critique du 22 donne **POLARIS**. Les deux lignes critiques indiquent **DELTA**. La dernière ligne du 23 donne **42**. Le code est **`VEGA-POLARIS-DELTA-42`**.

Exemple de conclusion. Le signal de détresse vient de `balise-7`, dans la zone `DELTA`. Le message critique du 23 septembre donne les coordonnées `47.219,-1.553`.

Dans tes notes, choisis une conduite que tu sais expliquer et une erreur que tu as rencontrée. Indique aussi la notion que tu souhaites revoir.
