# TP 2 - Guide tableau et explications globales

Ce document accompagne le TP autonome **Lire les traces d'un poste**. Il sert à expliquer les idées communes lorsque les élèves viennent de les rencontrer dans leurs propres commandes.

## Contrat pédagogique de la séance

- **Public :** élèves ayant réalisé le TP 1 ; ils savent déjà utiliser `ls`, `cd`, `pwd`, `mkdir`, `cat`, `echo` et les redirections simples.
- **Expérience recherchée :** « Je peux faire parler des fichiers, sans lire mille lignes une par une. »
- **Fil rouge :** les élèves transforment de vraies données locales en rapports simples et vérifiables.
- **Rythme :** laisser avancer la classe, puis lancer une pause tableau de 4 à 7 minutes lorsqu'une majorité vient de voir le même effet.
- **Sécurité :** les fichiers créés sont tous dans `~/base-exploration/analyse-traces`. La seule tâche terminée avec `kill` est celle que l'élève vient de créer avec `sleep`.

## Déroulé enseignant

| Pause tableau | Moment déclencheur | Durée | Idée à faire retenir |
|---|---|---:|---|
| 1 | après `*`, guillemets et `$(date)` | 6 min | le shell transforme certains caractères avant de lancer une commande |
| 2 | après le premier `grep ... | wc -l` | 6 min | une conduite relie la sortie d'une commande à l'entrée de la suivante |
| 3 | après `>` et `2>` | 6 min | une commande possède une entrée, une sortie normale et une sortie d'erreur |
| 4 | après `cut`, `sort` et `tr` | 5 min | les filtres résolvent chacun une petite partie du problème |
| 5 | bonus, après `sleep`, `jobs`, `fg` et `bg` | 5 min | avant-plan et arrière-plan concernent les tâches de ce terminal |
| 6 | après `bash scripts/bilan.sh` | 5 min | un script conserve une recette reproductible |

---

## Pause tableau 1 - Le shell prépare les mots

À dessiner :

```text
ce que l'élève tape      ce que Bash prépare        ce que reçoit la commande
echo bruts/*.log   ->    bruts/evenements.log  ->   echo bruts/evenements.log
```

![Le shell transforme une commande avant de la lancer.](../assets/tp2-shell-transformations.svg)

À dire :

> Bash ne transmet pas toujours exactement les caractères tapés. Il reconnaît certains raccourcis : `*`, `~`, les accolades, `$(...)` et les guillemets. Il les interprète avant d'appeler la commande. `echo` est pratique pour observer ce que Bash a préparé.

Ne pas exiger l'ordre complet des sept développements à ce stade. L'objectif est que les élèves puissent prédire deux cas : `*` devient une liste de noms existants ; des guillemets peuvent préserver l'étoile telle quelle.

Question à lancer : « Si `echo "*.log"` affiche une étoile, est-ce `echo` qui a oublié de chercher les fichiers ? »

---

## Pause tableau 2 - Une conduite : plusieurs outils, une seule ligne

À dessiner :

```text
fichier -> grep "ERREUR" -> sort -> terminal
              garde             range
           les lignes utiles    les résultats
```

![Une conduite relie plusieurs filtres.](../assets/tp2-pipeline.svg)

À dire :

> Le caractère `|` est un tuyau. Il ne crée pas forcément un fichier : il branche directement la sortie de gauche sur l'entrée de droite. Chaque filtre fait une action simple. La combinaison produit un résultat plus intéressant.

Faire verbaliser la commande avant d'en montrer une autre : « sélectionne les erreurs, puis compte-les ». Une élève ou un élève doit pouvoir dire à quoi sert chaque moitié de `grep 'ERREUR' ... | wc -l`.

---

## Pause tableau 3 - Trois canaux, pas un seul bloc de texte

À dessiner :

```text
clavier ou fichier  -> entrée standard  (0) ->
                                              commande
terminal ou fichier <- sortie normale   (1) <-
terminal ou fichier <- sortie d'erreur  (2) <-
```

![Les trois canaux d'une commande.](../assets/tp2-flux.svg)

À dire :

> Une commande ne sait pas forcément si elle parle au clavier, au terminal ou à un fichier. Elle lit sur son entrée et écrit sur deux sorties distinctes : son résultat normal et ses erreurs. C'est le shell qui branche ces canaux avec `<`, `>`, `>>`, `2>` et `|`.

Insister sur le cas vu : si `ls` produit une liste et une erreur dans la même commande, `> liste.txt` ne capture que la liste. `2> erreurs.txt` capture l'erreur séparément.

---

## Pause tableau 4 - Une boîte à outils de filtres

À dessiner :

```text
head / tail   choisir le début ou la fin
wc             compter
grep           garder ou exclure des lignes
cut            prendre des colonnes
sort           ranger les lignes
tr             remplacer des caractères
```

![Les filtres de texte Linux : chaque commande transforme les lignes à sa manière.](../assets/tp2-filtres.svg)

À dire :

> Ces commandes sont petites par choix. Une bonne ligne de shell ne demande pas à un énorme programme de tout faire : elle compose des programmes modestes, chacun expert d'une transformation.

Activité orale très courte : donner « je veux les personnes uniques du journal » ; demander aux élèves de proposer, dans l'ordre, les deux ou trois filtres nécessaires. La bonne chaîne est `cut`, puis `sort -u`.

---

## Pause tableau 5 - Les tâches du terminal

À dessiner :

```text
sleep 20       le terminal attend la tâche : avant-plan
sleep 90 &     le terminal redevient disponible : arrière-plan

jobs           voir les tâches du terminal
fg             ramener la tâche au premier plan
bg             reprendre une tâche suspendue en arrière-plan
```

![Avant-plan et arrière-plan dans le terminal.](../assets/tp2-taches.svg)

À dire :

> Les tâches ne sont pas tous les processus de la machine. Ce sont celles que ce shell connaît, car il les a lancées. Le `&` ne rend pas une commande plus rapide : il permet simplement de récupérer l'invite pendant qu'elle continue.

Sécurité : ne faire manipuler `kill %1` qu'après avoir vérifié que les élèves ont lancé `sleep` dans ce même terminal. Ne pas demander de PID ni de signal à ce stade.

---

## Pause tableau 6 - Un script garde la recette

À dessiner :

```text
bilan.sh                         Bash                       bilan.txt
-----------------        -------------------        -----------------
grep ... | wc -l   ->    exécute les lignes   ->    rapport réutilisable
cut ... | sort -u         dans leur ordre
```

![Un script Bash rassemble plusieurs commandes.](../assets/tp2-script.svg)

À dire :

> Le script n'est pas une nouvelle sorte de magie. C'est un fichier texte qui contient les commandes que nous aurions pu taper. `bash scripts/bilan.sh` demande simplement à Bash de lire ce fichier et d'exécuter ses lignes.

Faire distinguer explicitement : le script est la recette, le rapport est le plat obtenu. Si le fichier de départ change, le même script peut produire un nouveau rapport.

---

## Réponses aux difficultés fréquentes

| Situation | Ce qui se passe | Réponse utile |
|---|---|---|
| `grep` n'affiche rien | aucune ligne ne correspond au mot demandé | « Est-ce une erreur, ou une réponse possible ? Vérifie l'orthographe et la casse. » |
| `*.log` est affiché tel quel | aucun fichier ne correspond, ou l'élève a placé des guillemets | « Que donne `ls bruts` ? Les guillemets sont-ils voulus ? » |
| le rapport est vide | une redirection a envoyé ailleurs le résultat attendu | « Relis la commande de gauche à droite : quelle sortie va dans quel fichier ? » |
| un fichier a été remplacé par `>` | `>` vide l'ancien contenu avant d'écrire | « Quel symbole ajoute au lieu de remplacer ? Recrée seulement les données nécessaires. » |
| `fg` répond qu'il n'y a pas de tâche | la tâche est terminée ou n'a pas été lancée avec `&` | « Que montre `jobs` ? Lance un nouveau `sleep 90 &`. » |
| le script affiche des caractères inattendus | les guillemets ont été interprétés au mauvais moment | « Lis d'abord le script avec `cat`. Que devrait Bash interpréter maintenant, et que fallait-il conserver pour plus tard ? » |

## Critères de réussite de la séance

À la fin, un élève doit pouvoir dire :

- « Je sais expliquer à quoi sert une étoile et pourquoi les guillemets changent son comportement. »
- « Je peux lire une conduite de gauche à droite. »
- « Je sais distinguer résultat normal et message d'erreur. »
- « Je peux choisir un filtre adapté pour chercher, compter, extraire ou trier. »
- « Je peux lancer un script et expliquer pourquoi il évite de retaper les mêmes commandes. »

Les notes doivent montrer une explication personnelle d'au moins une conduite et d'une redirection. Elles sont plus utiles que la simple présence des fichiers de sortie.
