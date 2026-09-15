# Lire les traces d'un poste

## Mission 2 - Des messages à remettre en ordre

Lors du premier TP, tu as découvert un poste Linux, son arborescence et ta base d'exploration. Tu sais maintenant te déplacer, créer des dossiers et lire des fichiers.

Cette fois, le poste te confie un problème plus concret : il produit beaucoup de petits messages. Certains sont utiles, d'autres non. Ils sont rangés dans des fichiers, mais personne n'a pris le temps de les trier.

Ton rôle est de transformer ces traces brutes en un rapport simple et lisible. Tu vas apprendre à demander à Linux :

- « montre-moi seulement les lignes qui parlent d'une erreur » ;
- « compte-les » ;
- « prends seulement cette colonne » ;
- « range le résultat » ;
- « enregistre ce rapport pour pouvoir le refaire demain ».

Tu ne dois pas tout retenir immédiatement. À chaque niveau, une nouvelle commande règle un problème précis. À la fin, tu les assembleras.

Essaye de finir les niveaux 0 à 7. Tu pourras tester les niveaux bonus si tu as le temps.

> Toutes les modifications de ce TP se font dans `~/base-exploration/analyse-traces`. Ne lance pas de commande avec `sudo` et ne supprime rien en dehors de ce dossier.

---

## Tes notes sont importantes

À la fin de chaque niveau, prends quelques lignes de notes sur le support qui te convient : papier, application de notes ou document texte. Ce sont tes traces à toi.

Elles t'aideront à comprendre ce que tu as fait, à réviser et à retrouver tes erreurs utiles. L'enseignant récupérera les notes de tout le monde pour suivre la progression de la classe et adapter son aide ; il ne s'agit pas de pénaliser une étape non terminée.

Après chaque niveau, note par exemple :

```md
## Niveau N - titre
- Ce que j'ai fait :
- Ce que j'ai observé :
- Ce que j'en comprends :
- Ma question éventuelle :
```

---

## Niveau 0 - Retrouver ta base

Retourne dans ta base d'exploration du premier TP :

```bash
cd ~/base-exploration
pwd
ls
```

Crée l'espace de travail de cette mission, puis entre dedans :

```bash
mkdir analyse-traces
cd analyse-traces
mkdir bruts
mkdir rapports
mkdir scripts
ls
```

Les traces originales resteront dans `bruts`. Tes résultats iront dans `rapports`. Les commandes que tu décideras de garder iront dans `scripts`.

### Dans tes notes

Explique le rôle des trois dossiers `bruts`, `rapports` et `scripts`.

---

## Niveau 1 - Préparer les traces à analyser

Les lignes suivantes imitent un journal d'événements. Chaque ligne possède quatre morceaux séparés par des points-virgules : une date, un niveau, un utilisateur ou service, et un message.

Crée le journal, une ligne après l'autre :

```bash
echo '2026-09-18 08:12;INFO;camille;Connexion réussie' > bruts/evenements.log
echo '2026-09-18 08:16;INFO;samir;Connexion réussie' >> bruts/evenements.log
echo '2026-09-18 08:18;ERREUR;camille;Mot de passe refusé' >> bruts/evenements.log
echo '2026-09-18 08:21;INFO;service-web;Mise à jour terminée' >> bruts/evenements.log
echo '2026-09-18 08:23;ERREUR;samir;Accès refusé' >> bruts/evenements.log
echo '2026-09-18 08:27;AVERTISSEMENT;service-web;Espace disque faible' >> bruts/evenements.log
echo '2026-09-18 08:31;INFO;camille;Déconnexion' >> bruts/evenements.log
echo '2026-09-18 08:34;INFO;samir;Déconnexion' >> bruts/evenements.log
```

La première ligne utilise `>` : elle crée le fichier. Toutes les suivantes utilisent `>>` : elles ajoutent une ligne à la fin, sans effacer les précédentes.

Prépare aussi un petit inventaire de fichiers :

```bash
echo 'nom;taille_ko;etat' > bruts/inventaire.csv
echo 'photo-vacances.jpg;1840;archive' >> bruts/inventaire.csv
echo 'rapport-stage.pdf;620;important' >> bruts/inventaire.csv
echo 'notes.txt;12;important' >> bruts/inventaire.csv
echo 'telechargement.tmp;4;a_supprimer' >> bruts/inventaire.csv
```

Affiche ce que tu viens de créer :

```bash
ls bruts
cat bruts/evenements.log
```

### Dans tes notes

Combien de morceaux contient une ligne de `evenements.log` ? Quel caractère les sépare ?

---

## Niveau 2 - Le shell complète tes commandes

Tu as déjà utilisé `~`, le raccourci vers ton dossier personnel. Le shell Bash sait aussi développer d'autres raccourcis avant de lancer une commande.

Commence par demander à `echo` de montrer tous les fichiers dont le nom termine par `.log` :

```bash
echo ~
echo bruts/*.log
```

Le `~` est remplacé par ton dossier personnel. L'étoile `*` veut dire « n'importe quelle suite de caractères ». Bash remplace donc `bruts/*.log` par les vrais noms qui correspondent avant d'envoyer les mots à `echo`.

Compare avec les guillemets :

```bash
echo "bruts/*.log"
```

Cette fois, l'étoile est affichée telle quelle. Les guillemets doubles demandent au shell de ne pas développer l'étoile.

Les guillemets simples protègent encore davantage :

```bash
echo 'Nous sommes le $(date)'
echo "Nous sommes le $(date +%H:%M)"
```

Dans la deuxième commande, `$(date +%H:%M)` est remplacé par le résultat de la commande `date`. C'est une **substitution de commande**. Dans la première, les guillemets simples empêchent ce remplacement.

Enfin, les accolades servent à produire plusieurs mots à partir d'un modèle :

```bash
echo rapports/{jour,nuit}.txt
touch rapports/rapport-{jour,nuit}.txt
ls rapports
```

> Pour l'instant, retiens trois raccourcis : `*` cherche des noms existants, `$(...)` récupère le résultat d'une commande, et les guillemets empêchent certaines interprétations du shell.

### Dans tes notes

Explique ce qui change entre `echo bruts/*.log` et `echo "bruts/*.log"`. À quel moment Bash exécute-t-il `date` dans `$(date)` ?

---

## Niveau 3 - Lire juste ce qu'il faut

Un gros fichier est rarement agréable à lire entièrement. Les commandes suivantes jouent chacune un rôle simple.

```bash
head -n 3 bruts/evenements.log
tail -n 2 bruts/evenements.log
wc -l bruts/evenements.log
```

- `head -n 3` affiche les trois premières lignes ;
- `tail -n 2` affiche les deux dernières lignes ;
- `wc -l` compte les lignes.

Utilise maintenant `grep` pour garder seulement les lignes qui contiennent un mot :

```bash
grep 'ERREUR' bruts/evenements.log
grep -i 'connexion' bruts/evenements.log
```

L'option `-i` signifie *ignore case* : `grep` ne fait plus la différence entre majuscules et minuscules.

### Défi éclair

Sans lancer la commande, prédis le résultat de :

```bash
grep -v 'INFO' bruts/evenements.log
```

L'option `-v` signifie « l'inverse » : elle garde les lignes qui ne correspondent pas au mot recherché.

### Dans tes notes

Quelle commande utiliserais-tu pour savoir rapidement combien de lignes contient un fichier ? Quelle commande utiliserais-tu pour retrouver un mot dans un journal ?

---

## Niveau 4 - Faire circuler les informations

Tu peux déjà trouver les erreurs. Mais tu peux aussi envoyer le résultat de `grep` directement à une autre commande, sans créer de fichier intermédiaire.

Le caractère `|` se lit souvent « pipe » ou « tuyau ». Il relie la sortie de la commande de gauche à l'entrée de la commande de droite.

```bash
grep 'ERREUR' bruts/evenements.log | wc -l
```

Lis cette commande de gauche à droite : « trouve les lignes contenant `ERREUR`, puis compte-les ».

Essaie ensuite :

```bash
grep -v 'INFO' bruts/evenements.log | sort
grep 'ERREUR' bruts/evenements.log | sort > rapports/erreurs-triees.txt
cat rapports/erreurs-triees.txt
```

`sort` range les lignes dans l'ordre alphabétique. La dernière commande ajoute une redirection : le résultat final est enregistré dans un rapport.

> Une commande capable de lire une entrée et d'écrire un résultat est un **filtre**. `grep`, `sort`, `head`, `tail`, `wc`, `cut` et `tr` savent tous participer à une conduite.

### Dans tes notes

Que fait le caractère `|` ? Pourquoi est-il pratique de relier des commandes plutôt que de tout faire à la main ?

---

## Niveau 5 - Extraire, ranger et transformer

Le journal et l'inventaire sont séparés par des `;`. La commande `cut` permet d'extraire certaines colonnes.

```bash
cut -d';' -f2 bruts/evenements.log
cut -d';' -f3 bruts/evenements.log
```

- `-d';'` indique le séparateur ;
- `-f2` demande la deuxième colonne ;
- `-f3` demande la troisième.

Tu peux maintenant créer une liste propre des personnes ou services vus dans le journal :

```bash
cut -d';' -f3 bruts/evenements.log | sort
cut -d';' -f3 bruts/evenements.log | sort -u
```

`sort -u` garde un seul exemplaire de chaque ligne identique.

La commande `tr` remplace des caractères. Essaie :

```bash
echo 'bonjour linux' | tr '[:lower:]' '[:upper:]'
cut -d';' -f2,3 bruts/evenements.log | tr ';' ' '
```

La première commande met les lettres en majuscules. Dans la seconde, `tr` remplace le `;` par un espace dans les deux colonnes extraites.

### Défi - Le répertoire important

Sans chercher de nouvelle commande, produis dans `rapports/fichiers-importants.txt` la liste des noms de fichiers dont l'état est `important`, sans la ligne de titre.

Indice : commence par `grep`, puis utilise `cut`.

### Dans tes notes

Quelle est la différence entre `cut` et `grep` ? À quoi sert `sort -u` ?

---

## Niveau 6 - Résultats normaux et messages d'erreur

Quand une commande fonctionne, elle affiche généralement son résultat dans le terminal. Mais quand elle rencontre un problème, elle affiche un message d'erreur dans un autre canal.

Observe :

```bash
ls bruts
ls bruts/fichier-inexistant
```

La deuxième commande ne trouve pas le fichier. Maintenant, demande au shell de séparer les deux sortes de messages :

```bash
ls bruts bruts/fichier-inexistant > rapports/liste-bruts.txt 2> rapports/erreurs.txt
cat rapports/liste-bruts.txt
cat rapports/erreurs.txt
```

Le `>` habituel redirige la sortie normale, appelée canal `1`. La forme `2>` redirige les messages d'erreur, appelés canal `2`.

Tu connais déjà `>>`, qui ajoute à la fin. Utilise-le pour signer le rapport sans effacer son contenu :

```bash
echo '--- fin du rapport ---' >> rapports/liste-bruts.txt
```

Enfin, `<` peut faire le chemin inverse : il donne un fichier comme entrée à une commande.

```bash
wc -l < bruts/evenements.log
```

Cette commande produit le même nombre de lignes que `wc -l bruts/evenements.log`. Dans le premier cas, `wc` reçoit un nom de fichier ; dans le second, il reçoit directement le contenu du fichier.

### Dans tes notes

Quelle différence fais-tu entre `>` et `2>` ? Pourquoi peut-il être utile de conserver les erreurs dans un fichier séparé ?

---

## Exploration bonus A - Ne pas bloquer le terminal

Certaines commandes prennent du temps. Pour voir ce qui se passe sans danger, lance une attente de vingt secondes :

```bash
sleep 20
```

Pendant ces vingt secondes, le terminal attend : tu ne peux pas écrire de nouvelle commande. Tu peux arrêter l'attente avec `Ctrl+C`.

Lance maintenant une attente plus longue, mais ajoute `&` à la fin :

```bash
sleep 90 &
jobs
```

Le caractère `&` lance la commande en arrière-plan : le shell t'affiche une nouvelle invite immédiatement. `jobs` liste les tâches lancées depuis ce terminal.

Ramène la tâche à l'avant-plan :

```bash
fg
```

Puis utilise `Ctrl+Z`. La tâche est suspendue. Vérifie son état, relance-la en arrière-plan, puis termine uniquement cette tâche de démonstration :

```bash
jobs
bg
jobs
kill %1
```

> Ne lance jamais `kill` sur un numéro trouvé au hasard. Ici, `%1` désigne la première tâche de ton terminal, celle que tu viens de créer.

### Dans tes notes

Quelle différence as-tu observée entre `sleep 20` et `sleep 90 &` ? À quoi sert `jobs` ?

---

## Niveau 7 - Garder une recette : ton premier script

Tu as assemblé plusieurs commandes. Les retaper tous les jours serait fatigant et risqué. Un script est simplement un fichier texte contenant des commandes que Bash exécutera dans l'ordre.

Crée un script qui affiche le nombre d'erreurs et la liste des personnes ou services rencontrés :

```bash
echo 'echo "Nombre d erreurs :"' > scripts/bilan.sh
echo "grep 'ERREUR' bruts/evenements.log | wc -l" >> scripts/bilan.sh
echo 'echo "Utilisateurs et services :"' >> scripts/bilan.sh
echo "cut -d';' -f3 bruts/evenements.log | sort -u" >> scripts/bilan.sh
```

Regarde d'abord ce que contient le script :

```bash
cat scripts/bilan.sh
```

Puis demande à Bash de l'exécuter :

```bash
bash scripts/bilan.sh
```

Enregistre maintenant le résultat dans un rapport :

```bash
bash scripts/bilan.sh > rapports/bilan.txt
cat rapports/bilan.txt
```

Le script est une recette. Le fichier `bilan.txt` est le résultat d'une exécution de cette recette. Si les traces changent demain, tu pourras relancer le même script.

### Dans tes notes

Pourquoi un script peut-il être plus fiable que recopier plusieurs commandes à la main ? Quelle commande lance ton script ?

---

## Boss final - Le rapport est prêt

Sans recopier les réponses précédentes, produis ces trois éléments :

1. `rapports/nombre-erreurs.txt` : le nombre de lignes qui contiennent `ERREUR`.
2. `rapports/utilisateurs.txt` : les utilisateurs et services du journal, une seule fois chacun, triés.
3. `rapports/fichiers-importants.txt` : le nom des fichiers marqués `important` dans l'inventaire, sans la ligne de titre.

Puis complète tes notes :

> Si je voulais analyser demain un autre fichier de journal, quelles commandes garderais-je ? Quel travail ferait chacune ?

Quand tes trois rapports sont prêts, appelle l'enseignant pour une vérification rapide.

---

## Explorations bonus

### Bonus B - Chercher plus loin

`find` cherche dans une arborescence. Essaie :

```bash
find . -name '*.log'
find . -name '*.txt'
```

Les guillemets empêchent le shell de remplacer l'étoile avant que `find` ne commence sa recherche.

### Bonus C - Lire les résultats avec leur numéro

```bash
grep -n 'ERREUR' bruts/evenements.log
grep -c 'ERREUR' bruts/evenements.log
```

`-n` affiche le numéro des lignes. `-c` affiche leur nombre.

### Bonus D - Un rapport unique, même avec les erreurs

```bash
ls bruts bruts/fichier-inexistant > rapports/tout.txt 2>&1
cat rapports/tout.txt
```

`2>&1` demande au shell d'envoyer les erreurs vers la même destination que la sortie normale. La position compte : écris bien `> rapports/tout.txt 2>&1` dans cet ordre.

### Bonus E - Créer plusieurs lignes sans éditeur

La notation `<<` permet de donner plusieurs lignes à une commande. Essaie ce document en ligne :

```bash
cat << FIN > rapports/message.txt
Rapport créé le $(date +%H:%M).
Les données viennent de bruts/evenements.log.
FIN
cat rapports/message.txt
```

Le mot `FIN` est choisi librement : il indique à Bash où s'arrête le texte. Ici, Bash remplace `$(date +%H:%M)` avant que `cat` n'écrive le fichier.

---

## Ce que tu sais maintenant

Tu sais désormais :

- utiliser des motifs comme `*` et les guillemets pour contrôler ce que Bash interprète ;
- récupérer le résultat d'une commande avec `$(...)` ;
- lire une partie d'un fichier avec `head` et `tail` ;
- compter, chercher, extraire, trier et transformer des lignes avec `wc`, `grep`, `cut`, `sort` et `tr` ;
- relier des commandes avec `|` ;
- séparer une sortie normale et une erreur avec `>` et `2>` ;
- lancer une tâche en arrière-plan et la retrouver avec `jobs` ;
- sauvegarder une suite de commandes dans un script Bash.

Tu viens de passer d'une utilisation commande par commande à une manière beaucoup plus puissante de travailler : construire des petites chaînes d'outils qui transforment des informations.
