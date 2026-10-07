# TP 2.5 — Construire ses premiers scripts Bash

## Mission 4 — Préparer la boîte à outils d'Aurore

Tu as retrouvé le signal de détresse du relais Aurore. Les commandes fonctionnent, mais l'équipe doit encore les retaper chaque fois qu'elle veut un résultat.

Aujourd'hui, tu vas lui préparer dix petits outils. Certains donnent une information, d'autres créent un projet, lisent une grille ou rangent des résultats. Le dernier conservera la liste des connexions dans un journal.

Tu n'as pas besoin de savoir écrire tous ces scripts en arrivant. Chaque niveau commence par de petites commandes à essayer. Tu regardes leur résultat, tu changes une chose, puis tu assembles les pièces dans ton propre script. Si une conduite ne fonctionne pas, reviens à sa première commande : c'est souvent là que tu comprendras ce qui se passe.

Ce TP reprend les dix exercices de scripts de l'ancien TP2, dans le même ordre. Il est prévu pour plusieurs séances : avance jusqu'au niveau que tu peux expliquer, puis reprends à cet endroit la fois suivante.

!!! warning "Périmètre sûr"
    Toutes tes créations et modifications restent dans `~/base-exploration/tp2-5/atelier-aurore`. Les fichiers `/etc/passwd` et le dossier `/etc` seront uniquement consultés. Au niveau 9, tu supprimeras seulement des fichiers jetables du dossier `nettoyage`. N'utilise pas `sudo`.

## Avant le TP — préparer le document de notes

- [Modèle de notes du TP2.5](../assets/tp2-5-modele-notes.txt)

Télécharge ce document sur ton ordinateur habituel et ouvre-le avec l'outil qui te convient : Bloc-notes, Word, Google Docs, VS Code…

Les encadrés `Question - N01`, `N02`… indiquent les réponses à y écrire. Quand on te demande de prévoir un résultat, réponds avant de lancer la commande. Ajoute ensuite ce que tu as vraiment observé. À la fin de la séance, dépose tes notes sur Moodle.

## Récupérer le terrain de jeu dans Linux

- [Terrain de jeu — Atelier Aurore](../assets/tp2-5-atelier-aurore.zip)

Prépare le dossier du TP, puis récupère l'archive :

```bash
mkdir -p ~/base-exploration/tp2-5
cd ~/base-exploration/tp2-5
wget https://valt78.github.io/cours-linux/assets/tp2-5-atelier-aurore.zip
unzip tp2-5-atelier-aurore.zip
cd atelier-aurore
pwd
ls
cat 00-LIRE-MOI.txt
```

`mkdir -p` crée aussi les dossiers parents manquants. `wget` télécharge l'archive ; `unzip` ouvre le terrain de jeu. Si tu reprends le TP à la séance suivante, retourne simplement dans `atelier-aurore` : tu n'as pas besoin de décompresser à nouveau par-dessus ton travail.

---

## Niveau 0 — Une recette que Bash peut relire

### 0.1 Qu'est-ce qu'un script ?

Quand tu tapes trois commandes dans le terminal, Bash les exécute au fur et à mesure. Un **script Bash** est un fichier texte qui conserve ces commandes dans leur ordre d'exécution. Tu peux ainsi relancer la même recette sans tout retaper.

![Un script conserve les commandes ; le rapport conserve le résultat d'une exécution.](../assets/tp2-script.svg)

Ouvre ton premier fichier depuis la racine de l'atelier :

```bash
nano scripts/bonjour.sh
```

Écris ce petit script de découverte :

```bash
#!/usr/bin/env bash
# Un message, puis l'endroit où la recette travaille.
echo "L'atelier est ouvert."
pwd
```

La première ligne, appelée **shebang**, indique quel interpréteur utiliser lorsque le script est lancé directement. Ici, `env` cherche Bash dans les emplacements des commandes. Les autres lignes commençant par `#` sont des commentaires : Bash ne les exécute pas.

Il n'y a pas d'invite `$` à recopier dans le fichier. L'extension `.sh` aide à reconnaître le script ; elle ne suffit pas à le rendre exécutable.

Pour coller un bloc de commandes copié, utilise `Ctrl+Shift+V`. Tu peux copier du texte sélectionné à la souris dans le terminal avec `Ctrl+Shift+C` et supprimer une ligne avec `Ctrl+K`. Enregistre avec `Ctrl+S`, confirme le nom du fichier si demandé, puis quitte avec `Ctrl+X`. Relis ce que tu as enregistré :

```bash
cat scripts/bonjour.sh
bash scripts/bonjour.sh
```

`cat` affiche la recette. `bash` la lit et l'exécute. Pour les dix exercices, tu créeras de la même manière un fichier dans `scripts`, puis tu y écriras tes propres commandes.

### 0.2 Deux façons de lancer la recette

Essaie de lancer le fichier directement :

```bash
./scripts/bonjour.sh
```

Si le droit `x` manque, Linux refuse. Ajoute-le pour le propriétaire, puis recommence :

```bash
chmod u+x scripts/bonjour.sh
./scripts/bonjour.sh
```

`bash scripts/bonjour.sh` demande explicitement à Bash de lire le fichier : le droit de lecture suffit pour le script. `./scripts/bonjour.sh` demande à Linux de l'exécuter : il lui faut aussi le droit `x`. Le `./` donne un chemin ; le dossier courant n'est généralement pas recherché automatiquement parmi les commandes.

### 0.3 Dans quel dossier travaille-t-il ?

```bash
cd essais
bash ../scripts/bonjour.sh
pwd
```

Le script se trouve dans `scripts`, mais il travaille ici dans `essais`, le dossier depuis lequel tu l'as lancé. Un chemin comme `note.txt` dans un script désigne donc un fichier du **dossier courant**, pas automatiquement un voisin du script.

Un script lancé avec `bash` travaille dans un autre processus Bash. Un éventuel `cd` à l'intérieur ne déplace pas ton terminal une fois le script terminé.

!!! question "Question - N01 · Recette et dossier courant"
    Quelle différence entre afficher et exécuter `bonjour.sh` ? Quel droit permet son lancement direct ? Depuis `essais`, quel dossier le script a-t-il affiché, et pourquoi ?

### 0.4 Une légère reprise des redirections

Une commande affiche normalement son résultat dans le terminal. Bash peut envoyer ce texte ailleurs :

| Symbole | Ce qu'il branche |
|---|---|
| `>` | sortie normale vers un fichier, en remplaçant son contenu |
| `>>` | sortie normale ajoutée à la fin d'un fichier |
| `<` | contenu d'un fichier vers l'entrée d'une commande |
| `|` | sortie normale de gauche vers l'entrée de droite |
| `2>` | sortie d'erreur vers un fichier |

Depuis `essais`, essaie une ligne à la fois :

```bash
echo 'premier essai' > message.txt
cat message.txt
echo 'deuxième essai' >> message.txt
cat message.txt
echo 'nouveau départ' > message.txt
cat message.txt
```

Avant la dernière commande `echo`, prévois ce qu'il restera dans le fichier. `>` remplace le contenu, même si tu pensais seulement ajouter une ligne.

Compare ensuite :

```bash
wc -l message.txt
wc -l < message.txt
cat message.txt | wc -l
```

Dans le premier cas, `wc` reçoit un nom de fichier et l'affiche avec le nombre. Dans les deux autres, il reçoit le contenu sur son entrée standard et affiche seulement le nombre. Le tube ne transmet pas un nom de fichier : il transmet du texte.

Enfin, sépare un résultat et une erreur :

```bash
ls couleurs.txt absent.txt > liste.txt 2> erreurs.txt
cat liste.txt
cat erreurs.txt
```

Les deux sorties peuvent être visibles au même endroit sans être le même canal. Tu les retrouveras lorsque tu voudras conserver les données utiles sans les mélanger aux messages d'erreur.

!!! question "Question - N02 · Où va le texte ?"
    Note ce qu'il reste dans `message.txt`. Pourquoi `wc -l < message.txt` n'affiche-t-il pas le nom du fichier ? Dans quel fichier se trouve le message concernant `absent.txt` ?

### Ta méthode pour les dix scripts

1. vérifie ton emplacement avec `pwd` et `ls` ;
2. essaie chaque outil dans le terminal ;
3. assemble les commandes petit à petit ;
4. ouvre le script avec `nano`, commence par le shebang, puis écris ta recette ;
5. lance-le et compare le résultat à ce qui est demandé.

Tu peux vérifier la syntaxe sans exécuter les commandes avec `bash -n ../scripts/bonjour.sh`. Cela repère certaines fautes d'écriture, mais ne prouve pas que le script fait le bon travail.

---

## Niveau 1 — Dire où l'on est : `infos.sh`

### 1.1 Une variable porte une valeur

Reste dans `essais`. Bash connaît déjà quelques informations sur ta session :

```bash
echo "$HOME"
echo "$PWD"
whoami
```

`HOME` contient le chemin de ton dossier personnel. `PWD` contient le chemin du dossier courant. Le `$` demande à Bash de remplacer le nom de la variable par sa valeur. `whoami`, lui, est une commande qui affiche ton nom d'utilisateur.

Compare maintenant :

```bash
echo '$HOME'
echo "$HOME"
echo "Mon dossier personnel est $HOME"
```

Les guillemets simples conservent les caractères tels quels. Les guillemets doubles gardent le texte ensemble, mais laissent Bash remplacer les variables et les substitutions de commandes.

!!! tip "Question - N03 · Le nom ou la valeur"
    Prévois les deux premières sorties avant le test. Quelle écriture affiche le nom `$HOME`, et laquelle affiche sa valeur ?

### 1.2 Demander l'heure à une commande

```bash
date
date +%H
date +%M
date +%S
date '+%H-%M-%S'
```

Le `+` annonce un format : `%H` représente l'heure sur 24 heures, `%M` les minutes et `%S` les secondes. Les caractères placés entre ces codes sont recopiés. Les guillemets permettent de garder un format contenant des espaces dans un seul argument.

Tu peux consulter `man date` : cherche `%H` avec `/`, valide, puis quitte avec `q`.

### 1.3 Insérer un résultat, conserver une étiquette

```bash
echo 'Il est $(date +%H) heures.'
echo "Il est $(date +%H) heures."
echo "L'étiquette \$HOME désigne $HOME"
echo "L'étiquette \$(whoami) est écrite sans lancer whoami."
```

Dans `$(commande)`, Bash exécute la commande et insère sa sortie à cet endroit. Le `\` placé devant un `$` dans des guillemets doubles empêche ce dollar de déclencher un remplacement. C'est utile pour afficher à la fois le **nom** d'une information et sa **valeur**.

### À toi d'écrire `infos.sh`

Crée `scripts/infos.sh`. Il doit afficher une seule ligne, adaptée à ta session. Pour Lamia, depuis `/tmp`, à 12 h 32 min 55 s, la ligne demandée dans l'ancien sujet est :

```text
$HOME=/home/lamia, $PWD=/tmp, $(date)=12 :32.55
```

Respecte les étiquettes littérales `$HOME`, `$PWD` et `$(date)`, les virgules et le format de l'heure, y compris l'espace avant `:`. Les valeurs doivent venir de la session, pas être écrites à la main.

Depuis `essais`, lance `bash ../scripts/infos.sh`. Déplace-toi ensuite dans `projet`, relance le même script, puis reviens dans `essais`. Le script reste au même endroit ; laquelle des valeurs doit changer ?

!!! question "Question - N04 · Ton premier outil"
    Note les sorties obtenues dans les deux dossiers. Explique le rôle de `$HOME`, `$PWD`, `$(...)` et du dollar protégé dans ton script.

---

## Niveau 2 — Construire une arborescence : `projet.sh`

### 2.1 Produire des noms sans créer de fichiers

Depuis `essais`, commence avec `echo` :

```bash
echo secteur-{nord,sud}
echo mesure-{1..4}.txt
echo mesure-{01..04}.txt
echo secteur-{nord,sud}/mesure-{01..03}.txt
```

Les accolades produisent plusieurs mots. La virgule propose des choix ; `..` produit une suite. Avec `01`, les nombres gardent ici deux chiffres. Deux groupes d'accolades produisent toutes les combinaisons : chaque secteur reçoit chaque numéro.

Les noms apparaissent même s'ils n'existent pas. Bash les construit avant de lancer `echo`.

Compare :

```bash
echo secteur-{nord,sud}
echo 'secteur-{nord,sud}'
echo secteur-*
```

Les accolades construisent des noms. L'étoile cherche des noms existants. Les guillemets simples empêchent ici le développement des accolades. S'il n'y a aucun nom correspondant à l'étoile, Bash la laisse normalement telle quelle.

!!! question "Question - N05 · Combien de noms ?"
    Avant le quatrième `echo`, combien de chemins attends-tu ? Après le test, explique la différence entre accolades et étoile.

### 2.2 Donner ces noms à une commande

```bash
mkdir -p essais-accolades/secteur-{nord,sud}
touch essais-accolades/secteur-{nord,sud}/mesure-{01..03}.txt
ls -R essais-accolades
```

`mkdir` peut créer plusieurs dossiers dans le même appel. `touch` peut créer plusieurs fichiers vides, mais il ne crée pas leurs dossiers parents. L'ordre compte donc : les dossiers d'abord, les fichiers ensuite. `ls -R` permet de regarder aussi dans les sous-dossiers.

### À toi d'écrire `projet.sh`

Le script doit créer, dans le dossier depuis lequel tu le lances :

```text
projet_doc/     fic01.txt, fic02.txt, …, fic10.txt
projet_src/     fic01.txt, fic02.txt, …, fic10.txt
projet_test/    fic01.txt, fic02.txt, …, fic10.txt
```

Il doit contenir **exactement deux commandes de travail**, une par ligne : une pour les dossiers, une pour les fichiers. Le shebang et les commentaires ne comptent pas. Avant de créer quoi que ce soit, teste les noms que tu as imaginés avec `echo`.

Enregistre ton script dans `scripts/projet.sh`, puis teste-le dans le terrain prévu :

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/projet
bash ../scripts/projet.sh
ls -R
```

!!! question "Question - N06 · Une arborescence en deux commandes"
    Combien de fichiers as-tu créés au total ? Pourquoi la commande qui crée les dossiers doit-elle passer en premier ? Note ta vérification.

---

## Niveau 3 — Retrouver les comptes : `comptes.sh`

### 3.1 Pourquoi lire `/etc/passwd` ?

Reviens dans `essais` :

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/essais
head -n 5 /etc/passwd
```

`/etc` contient de nombreux fichiers de configuration. `/etc/passwd` décrit les comptes locaux : une ligne par compte, avec sept champs séparés par `:`. Certains comptes correspondent à une personne, d'autres à un service qui fonctionne en arrière-plan.

Voici une ligne fictive :

```text
alice:x:1000:1000:Alice:/home/alice:/bin/bash
```

| Champ | Contenu dans cet exemple |
|---|---|
| 1 | nom de connexion : `alice` |
| 2 | indication du mot de passe : `x` |
| 3 | identifiant numérique du compte : `1000` |
| 4 | identifiant du groupe principal : `1000` |
| 5 | description du compte : `Alice` |
| 6 | dossier personnel : `/home/alice` |
| 7 | shell de connexion : `/bin/bash` |

Le `x` ne contient pas le mot de passe. Sur les systèmes habituels, les empreintes des mots de passe sont dans `/etc/shadow`, dont la lecture est restreinte. Tu n'as pas besoin de ce fichier pour ce TP.

On utilisera ici les comptes présents dans `/etc/passwd`. Sur une machine gérée par un établissement, un annuaire peut fournir d'autres comptes sans les écrire dans ce fichier.

### 3.2 Découper une ligne avec `cut`

Travaille d'abord sur les quatre comptes fictifs du terrain de jeu :

```bash
cat comptes-exemple.txt
cut -d':' -f1 comptes-exemple.txt
cut -d':' -f6 comptes-exemple.txt
cut -d':' -f1,7 comptes-exemple.txt
cut -d':' -f3-5 comptes-exemple.txt
```

`-d` indique le séparateur. `-f` indique les champs à conserver : le premier porte le numéro **1**. Une virgule choisit plusieurs champs ; un tiret choisit une suite de champs. Sans `-d`, le séparateur attendu par `cut -f` est une tabulation, pas un espace.

!!! question "Question - N07 · Une ligne de compte"
    Quel champ faut-il garder pour connaître le nom du compte ? Et son dossier personnel ? Que donne `-f1,7`, et quel caractère sépare encore les deux valeurs ?

### 3.3 Trier, puis transformer les retours à la ligne

```bash
cat couleurs.txt
sort couleurs.txt
sort -u couleurs.txt
```

`sort` trie les lignes selon l'ordre de texte de la machine. `-u` retire les doublons ; le tri ordinaire les conserve. Nous n'avons pas besoin de retirer des comptes différents.

Teste maintenant une transformation séparée :

```bash
printf 'nord\nsud\nest\n' | tr '\n' ' '
printf '\n'
```

`printf` affiche ici trois lignes : `\n` représente un retour à la ligne dans son format. `tr` remplace chaque retour à la ligne par un espace. Il lit son entrée standard : on lui transmet donc le texte avec `|` ou `<`. Le second `printf` termine l'affichage par un retour à la ligne ; sans lui, l'invite du terminal peut rester collée au résultat.

### À toi d'écrire `comptes.sh`

Le script doit afficher les noms des comptes de `/etc/passwd`, triés par ordre alphabétique, **sur une seule ligne**, séparés par des espaces. Termine cette ligne proprement.

Construis ta conduite avec les comptes fictifs avant de l'adapter au fichier réel : commence par les noms, ajoute le tri, puis le passage à une seule ligne. À chaque étape, regarde ce que la commande suivante va recevoir.

!!! question "Question - N08 · De plusieurs lignes à une seule"
    Note les trois transformations de ton script dans l'ordre. Que se passerait-il si tu remplaçais les retours à la ligne avant de demander le tri ?

---

## Niveau 4 — Dater un inventaire : `etc.sh`

### 4.1 Une entrée par ligne

Depuis `essais`, compare :

```bash
ls /etc
ls -1 /etc
ls -1A /etc
```

`-1` est le chiffre **un** : il impose une entrée par ligne. `-A` ajoute les entrées cachées, mais pas les repères `.` et `..`. Dans ce TP, l'inventaire demandé comprend les entrées non cachées, comme un `ls` ordinaire : garde `-1`.

### 4.2 Conserver un nom calculé

```bash
date +%y
date +%m
date +%d
date +%y.%m.%d
rapport="essai-$(date +%H-%M-%S).txt"
echo "$rapport"
echo 'Inventaire de test' > "$rapport"
cat "$rapport"
```

`%y` donne l'année sur deux chiffres, `%m` le mois et `%d` le jour. Ici, la variable `rapport` garde un nom construit avec l'heure.

Une affectation s'écrit `nom=valeur`, **sans espace autour de `=`**. On écrit le nom sans `$` pour lui donner une valeur, puis `"$nom"` pour la lire. Les guillemets gardent la valeur dans un seul argument, même si elle contient des espaces.

Garder le nom dans une variable permet de réutiliser exactement le même fichier pour l'écriture et le comptage, même si la date change entre deux commandes.

### 4.3 Compter ce qui a été enregistré

```bash
ls -1 essais-accolades > inventaire-test.txt
cat inventaire-test.txt
wc -l < inventaire-test.txt
```

Une entrée par ligne permet de compter les entrées en comptant les lignes. `ls -l` ajouterait des détails et une ligne de total : ce n'est pas le format dont tu as besoin ici.

### À toi d'écrire `etc.sh`

Le script doit enregistrer la liste des entrées non cachées de `/etc` dans le dossier courant. Le fichier s'appelle `etc.yy.mm.jj`, avec la date du jour. Par exemple, le 7 octobre 2026, son nom serait `etc.26.10.07`.

Chaque entrée occupe une ligne. Le script affiche ensuite **le nombre d'entrées**, sans le nom du fichier. Si tu le relances le même jour, il doit reconstruire l'inventaire, pas le doubler.

!!! question "Question - N09 · Un nom construit au bon moment"
    Note le nom du fichier créé et le nombre affiché. Pourquoi avoir conservé le nom dans une variable ? Pourquoi as-tu choisi `>` plutôt que `>>` ?

---

## Niveau 5 — Choisir les plus récents : `recents.sh`

### 5.1 La date de modification n'est pas la date de création

Va dans le terrain prévu et prépare des dates différentes :

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/recents
touch -t 202601011000 ancien.txt
touch -t 202601011100 alpha.txt
touch -t 202601011200 beta.txt
touch -t 202601011300 milieu.txt
touch -t 202601011400 zeta.txt
ls -l
```

`touch` peut aussi changer les dates d'un fichier existant. Avec `-t`, on lui donne ici `année mois jour heure minute`, collés ensemble. Les cinq fichiers existent déjà ; leur contenu ne change pas.

La **date de modification** indique quand le contenu a été modifié pour la dernière fois. Elle peut être changée volontairement, comme ici. Elle ne dit donc pas forcément quand le fichier a été créé.

### 5.2 Sélectionner dans le bon ordre

```bash
ls -1
ls -1t
ls -1tr
```

`-t` trie par date de modification, du plus récent au plus ancien. `-r` inverse l'ordre. Avec `-1`, chaque nom reste sur sa propre ligne.

!!! tip "Question - N10 · Prévoir les trois élus"
    Avant de poursuivre, écris les noms des trois fichiers les plus récents. Dans quel ordre devraient-ils apparaître dans le résultat final, si ce résultat est alphabétique ?

Ajoute maintenant une seule étape, puis compare deux conduites :

```bash
ls -1t | head -n 2
ls -1t | head -n 2 | sort
ls -1t | sort | head -n 2
```

`head -n 2` garde les deux premières lignes qu'il reçoit. Les deux dernières conduites ne choisissent pas les mêmes fichiers : trier les noms trop tôt fait perdre le classement par date avant la sélection.

### À toi d'écrire `recents.sh`

Le script doit afficher les **trois entrées non cachées les plus récemment modifiées du dossier courant**, puis trier ces trois noms par ordre alphabétique. Affiche un nom par ligne. S'il y a moins de trois entrées, affiche celles qui existent.

Enregistre le script dans `scripts`, puis lance-le depuis `recents`. Le fichier du script ne doit pas se retrouver parmi les candidats. Après le premier test, rends `ancien.txt` plus récent avec `touch ancien.txt`, puis relance : la sélection doit changer.

!!! question "Question - N11 · Sélectionner avant de ranger"
    Note le résultat avant et après le dernier `touch`. Explique pourquoi le tri alphabétique arrive après la sélection des trois noms.

---

## Niveau 6 — Lire une case de grille : `csv.sh`

### 6.1 Le CSV est du texte avant d'être un tableau

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/csv
cat fichier.csv
cat ligne.txt
cat colonne.txt
```

Un fichier **CSV** stocke une grille sous forme de texte. Chaque ligne contient plusieurs valeurs, séparées par un caractère. Un tableur comme Excel ou LibreOffice Calc peut présenter ces valeurs dans des cellules.

Le séparateur peut varier. Dans cet exercice, c'est le point-virgule `;`, comme dans l'ancien sujet. Nous utilisons une grille simple : aucune valeur ne contient elle-même un point-virgule ou un retour à la ligne. `cut` suffit pour ce format ; il ne sait pas interpréter tous les CSV avec des valeurs entre guillemets.

La première ligne est un en-tête. Pour nos coordonnées, **elle compte comme ligne 1**. Les colonnes commencent aussi à 1.

!!! tip "Question - N12 · Trouver la case à la main"
    Avant toute conduite, lis les numéros dans `ligne.txt` et `colonne.txt`. Quelle valeur se trouve à cette intersection dans `fichier.csv` ?

### 6.2 Isoler une ligne, puis un champ

```bash
head -n 2 fichier.csv
head -n 2 fichier.csv | tail -n 1
cut -d';' -f1 fichier.csv
```

`head` garde le début. `tail -n 1` garde la dernière ligne de ce qu'il reçoit. Ensemble, ils peuvent isoler une ligne à une position précise. `cut`, lui, extrait un champ de **chaque** ligne reçue : si tu lui donnes toute la grille, il ne choisit pas une seule cellule.

Essaie maintenant d'isoler la quatrième ligne, puis sa troisième colonne, en assemblant toi-même ces morceaux. Cette case d'essai est différente de celle demandée dans les fichiers de coordonnées.

### 6.3 Un nombre lu dans un fichier devient un argument

```bash
cat ligne.txt
numero=$(cat ligne.txt)
echo "Le numéro lu est $numero"
head -n "$numero" fichier.csv
```

Tu connais déjà `$(date ...)`. Le même mécanisme fonctionne avec `cat` : la sortie de la commande devient ici la valeur de `numero`. Les retours à la ligne situés à la fin de cette sortie sont retirés par la substitution.

Dans `head -n "$numero"`, Bash remplace la variable avant de lancer `head`. La commande reçoit donc le nombre contenu dans le fichier, pas le nom de la variable. Tu peux appliquer le même principe au numéro de colonne donné à `cut -f`.

### À toi d'écrire `csv.sh`

Le script lit `ligne.txt` et `colonne.txt` dans le dossier courant. Il affiche uniquement la valeur située à leur intersection dans `fichier.csv`.

Les numéros sont des entiers valides : aucune gestion d'erreur n'est demandée. Commence par garder les deux numéros dans deux variables, puis construis la sélection. Lance ton script depuis `csv`.

Change ensuite les coordonnées pour demander la ligne 4, colonne 3, puis la ligne 1, colonne 2. Le script doit suivre les nouveaux fichiers sans que tu modifies sa recette. Restaure enfin les coordonnées d'origine :

```bash
echo 3 > ligne.txt
echo 2 > colonne.txt
```

!!! question "Question - N13 · Une case choisie à l'exécution"
    Note les valeurs obtenues dans les trois cas. Pourquoi les numéros ne doivent-ils pas être écrits directement dans les options de ton script ? Quel outil choisit la ligne, et lequel choisit la colonne ?

---

## Niveau 7 — Ranger les comptes par shell : `shells.sh`

### 7.1 Tous les comptes ne lancent pas Bash

Retourne dans `essais` :

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/essais
cat comptes-exemple.txt
cut -d':' -f7 comptes-exemple.txt
```

Le dernier champ de `/etc/passwd` désigne le programme lancé à l'ouverture de la session du compte. On y trouve souvent `/bin/bash`, mais aussi d'autres shells. Une valeur comme `/usr/sbin/nologin` sert à refuser une session interactive, notamment pour un compte de service.

Le fichier `/etc/shells`, lorsqu'il existe, indique des shells reconnus par le système. Il ne décrit pas le choix de chaque utilisateur : cette information se trouve dans le septième champ de `/etc/passwd`.

### 7.2 Conserver deux champs et changer leur séparateur

```bash
cut -d':' -f1,7 comptes-exemple.txt
printf 'balise-a:NORD\nbalise-b:SUD\n' | tr ':' ' '
```

La première commande garde le nom et le shell. La seconde montre comment remplacer un séparateur par un espace. À toi de relier les deux outils sur les comptes fictifs.

### 7.3 Donner une première et une deuxième clé de tri

Avec un tri ordinaire, la ligne entière sert au classement. Pour ranger d'abord selon une colonne, il faut donner une **clé de tri**.

```bash
printf 'zoe EST\nalice NORD\nsam EST\n' > zones-test.txt
sort zones-test.txt
sort -k2,2 zones-test.txt
sort -k2,2 -k1,1 zones-test.txt
```

Dans ce fichier, les champs sont séparés par des espaces. Sans `-t`, `sort` repère les champs à partir des blancs : des espaces successifs ne créent pas chacun une colonne vide, contrairement à `cut -d' '`.

`-k2,2` demande d'utiliser seulement le deuxième champ comme première clé. `-k1,1` ajoute ensuite le premier champ pour départager les lignes dont la première clé est identique. Les clés sont appliquées dans l'ordre où tu les donnes.

Les deux nombres dans `-k2,2` indiquent le champ de début et le champ de fin de la clé. `-k2` seul étendrait la clé jusqu'à la fin de la ligne.

!!! question "Question - N14 · Deux clés, deux rôles"
    Dans le dernier test, pourquoi `sam` doit-il apparaître avant `zoe`, alors que `alice` est le premier nom dans l'ordre alphabétique ?

### À toi d'écrire `shells.sh`

Le script affiche, pour chaque compte local de `/etc/passwd`, son nom puis son shell de connexion. Les deux colonnes sont séparées par un espace.

Trie d'abord par shell, puis par nom de compte lorsque les shells sont identiques. Teste avec `comptes-exemple.txt` : les deux comptes utilisant Bash doivent être voisins et correctement départagés. Adapte ensuite la source au fichier réel.

!!! question "Question - N15 · Le classement des shells"
    Note les trois transformations de ton script et les clés de tri choisies. Pourquoi un simple `sort` ne répondrait-il pas à la demande ?

---

## Niveau 8 — Mesurer les sources : `production.sh`

### 8.1 Choisir les bons fichiers

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/production
ls
echo *.c
echo *.h
echo '*.c'
```

Les fichiers `.c` sont ici des exemples de sources en langage C ; les `.h` décrivent habituellement des interfaces utilisées par ces sources. Tu n'as pas besoin de comprendre ni de compiler leur contenu : tu vas seulement compter leurs lignes.

Sans guillemets, Bash remplace les motifs par les noms existants. Avec les guillemets simples, il conserve l'étoile. `notes.txt` doit rester en dehors du bilan.

### 8.2 Un nombre seul est plus facile à réutiliser

```bash
wc -l radio.c
wc -l < radio.c
wc -l *.c *.h
```

`wc -l` compte les retours à la ligne. Nos fichiers terminent chaque ligne par un retour à la ligne. Avec plusieurs fichiers passés en arguments, `wc` ajoute une ligne de total, et affiche le nombre avant le nom. Le script demandé doit, lui, afficher le **nom avant le nombre**, sans total.

Pour fabriquer une ligne de rapport, essaie sur un fichier qui n'est pas une source :

```bash
nom='notes.txt'
nombre=$(wc -l < "$nom")
printf '%s %s\n' "$nom" "$nombre"
```

`printf` prend un format, puis les valeurs à insérer. Chaque `%s` reçoit une valeur texte. Les espaces du format restent des espaces, et `\n` termine la ligne. Cette forme permet de garder la même présentation d'un essai à l'autre.

### 8.3 Refaire une action pour chaque fichier

Retourne provisoirement dans `essais` :

```bash
cd ../essais
for fichier in couleurs.txt 'note avec espaces.txt'
do
    printf 'Je regarde : %s\n' "$fichier"
done
```

Une boucle `for` donne successivement chaque nom à la variable `fichier`, puis exécute les commandes entre `do` et `done`. Tu n'as pas besoin d'écrire à nouveau ces commandes pour chaque nom.

Tu peux aussi laisser Bash préparer la liste avec un motif :

```bash
for fichier in *.txt
do
    printf 'Candidat : %s\n' "$fichier"
done
```

Le motif fournit la liste des noms ; `"$fichier"` garde ensuite chaque nom dans un seul argument. C'est pour cela que le fichier contenant des espaces reste un seul candidat.

S'il n'y a aucun fichier correspondant à un motif, Bash garde normalement le motif littéral. Pour une liste de fichiers qui peut être vide, découvre ce réglage :

```bash
echo *.introuvable
shopt -s nullglob
echo *.introuvable
shopt -u nullglob
```

`shopt -s nullglob` fait disparaître les motifs sans correspondance. `-u` désactive ce réglage. Tu pourras l'activer au début de `production.sh` : il s'appliquera au Bash du script, sans changer ton terminal.

### 8.4 Trier des nombres comme des nombres

```bash
cat scores.txt
sort -k2,2 scores.txt
sort -k2,2n scores.txt
sort -k2,2nr scores.txt
```

Le tri de texte peut placer `100` avant `9`. Le `n` de la clé demande un tri **numérique** ; le `r` l'inverse. La dernière commande classe donc les nombres du deuxième champ du plus grand au plus petit.

Une boucle peut alimenter une conduite : place le `|` et la commande suivante après `done`. La commande de droite recevra toutes les lignes produites par la boucle.

!!! question "Question - N16 · Répéter et compter"
    Pourquoi `wc -l < fichier` est-il utile pour fabriquer une ligne `nom nombre` ? Que change `n` dans la clé de tri ? Que devient un motif sans correspondance avec `nullglob` ?

### À toi d'écrire `production.sh`

Le script affiche les fichiers `.c` et `.h` du dossier courant, un par ligne, chacun suivi de son nombre de lignes. Classe le bilan par nombre de lignes décroissant. N'affiche ni total ni fichier `.txt`.

Pour cet exercice, les noms des sources n'ont pas d'espaces et les motifs `.c` et `.h` correspondent à des fichiers ordinaires. Cela permet de trier sur le deuxième champ du rapport.

Avance en trois essais : parcours les noms seuls ; ajoute le comptage pour chacun ; ajoute enfin le tri numérique. Reviens dans `production` avant de lancer le script enregistré dans `scripts`.

Le terrain contient une source de 7 lignes, une de 5 lignes et une de 2 lignes : ton classement doit le montrer. Teste aussi dans un dossier d'essai vide créé dans l'atelier : le script ne doit ni afficher `*.c`, ni chercher à ouvrir ce nom littéral.

!!! question "Question - N17 · Un bilan construit par étapes"
    Note le classement obtenu. Quel est le rôle de la variable de boucle ? Que reçoit la commande de tri après `done` ? Que produit le script dans le dossier vide ?

---

## Niveau 9 — Nettoyer avec confirmation : `nettoyage.sh`

### 9.1 Préparer de vrais cas différents

Le nettoyage ne doit pas être testé sur tes documents. Utilise seulement les fichiers jetables préparés dans l'atelier :

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/nettoyage
touch -d '5 days ago' a-retirer.txt a-garder.txt sous-dossier/ancien-profond.txt
touch recent.txt
touch -d '5 days ago' essais/accepte.txt essais/refuse.txt
touch essais/recent.txt
ls -l
```

`touch -d` reçoit ici une date relative : `5 days ago` signifie « il y a cinq jours ». Le contenu ne change pas. Les noms décrivent les décisions que tu prendras pendant le test : tu accepteras une suppression et tu en refuseras une autre.

### 9.2 Sélectionner sans supprimer

```bash
find essais -maxdepth 1 -type f
find essais -maxdepth 1 -type f -mmin +4320
```

`find` parcourt un point de départ et applique des critères :

| Morceau | Rôle |
|---|---|
| `essais` | point de départ de la recherche |
| `-maxdepth 1` | rester dans ce dossier, sans descendre dans ses sous-dossiers |
| `-type f` | ne garder que les fichiers ordinaires |
| `-mmin +4320` | garder ceux dont l'âge de modification dépasse 4320 minutes |

Trois jours représentent `3 × 24 × 60 = 4320` minutes. `find` arrondit l'âge à la minute inférieure : ce test dépasse donc le seuil de 72 heures avec une précision à la minute, à partir de 4321 minutes complètes.

Tu verras parfois `-mtime +3`. Ce n'est pas le même seuil : `-mtime` arrondit en journées complètes, et `+3` demande plus de trois journées complètes, donc au moins quatre jours. Pour notre nettoyage, nous utiliserons le critère en minutes.

Les critères se cumulent : un candidat doit être un fichier, au bon endroit et assez ancien. À ce stade, rien n'est supprimé.

Pour afficher seulement les noms, essaie :

```bash
find essais -maxdepth 1 -type f -printf '%f\n'
```

Cette fois, le format appartient à **`find`** : `%f` affiche le nom sans son dossier parent ; `\n` termine la ligne. Ce n'est pas le `%s` du `printf` de Bash.

!!! question "Question - N18 · Les candidats au nettoyage"
    Quels fichiers de `essais` sont retenus par le critère d'âge ? Pourquoi le futur script devra-t-il utiliser `-maxdepth 1` ? Pourquoi `-mtime +3` ne représente-t-il pas exactement 72 heures ?

### 9.3 Demander l'accord avant une action

Teste d'abord une action qui se contente de regarder :

```bash
find essais -maxdepth 1 -type f -ok ls -ld -- {} \;
```

`-ok` présente une commande et demande confirmation pour chaque candidat. Réponds `y` pour accepter ou `n` pour refuser ; si ta version utilise une langue différente, suis l'invite affichée.

Dans cette écriture :

- `{}` est remplacé par le chemin du fichier trouvé ;
- `--` indique à `ls` que les mots suivants sont des noms, même s'ils ressemblent à une option ;
- `\;` termine la commande confiée à `find`, en protégeant le point-virgule pour que Bash ne le prenne pas pour sa propre séparation de commandes.

Le refus empêche l'action pour ce candidat. Pour voir ce qui se passe **après** l'action, essaie :

```bash
find essais -maxdepth 1 -type f -ok ls -ld -- {} \; -printf 'Action acceptée et réussie pour %f\n'
```

Accepte une proposition, refuse la suivante. Les actions sont évaluées dans l'ordre. Le `-printf` situé après `-ok` n'est exécuté pour ce candidat que si tu as accepté **et** si la commande a réussi.

### 9.4 Une suppression et son journal sont deux choses

Tu connais déjà `rm`. Supprime maintenant une seule copie jetable avec sa confirmation :

```bash
rm -i -- essais/accepte.txt
ls essais
```

Accepte la suppression. Un fichier effectivement supprimé doit disparaître de la liste. Un nom sélectionné avant la confirmation n'est donc pas encore une preuve de suppression.

Pour conserver du texte produit par une commande, tu connais `>>`. Tu peux d'abord essayer le journal avec un message sans supprimer quoi que ce soit :

```bash
printf 'Essai de journal\n' >> essais/journal-test.log
cat essais/journal-test.log
```

Pour le script, confie la confirmation à **`find -ok`**, puis utilise `rm --` comme action, sans ajouter un second `-i`. La sortie suivante doit contenir uniquement le nom du fichier après l'action réussie. Tu pourras alors l'ajouter au journal avec une redirection.

Écarte le journal lui-même des candidats :

```bash
find essais -maxdepth 1 -type f ! -name 'journal-test.log'
```

`!` inverse le critère qui suit : ici, garder les fichiers dont le nom **n'est pas** `journal-test.log`. Dans le script, adapte cette exclusion au vrai journal. Le nom des fichiers du terrain ne contient pas de retour à la ligne : un nom par ligne suffit pour le suivi.

### À toi d'écrire `nettoyage.sh`

Le script doit supprimer, dans le **dossier courant uniquement**, les fichiers ordinaires modifiés il y a plus de trois jours, avec le seuil en minutes étudié. Il demande une confirmation pour chaque fichier. Il ajoute à `nettoyage.log` le nom de chaque fichier **effectivement supprimé**, un nom par ligne.

Le journal est exclu de la recherche. Les dossiers, les fichiers récents, les fichiers refusés et les fichiers des sous-dossiers restent en place. Les questions de confirmation restent visibles ; le journal ne reçoit que les noms après une suppression réussie.

Construis d'abord la sélection et vérifie-la sans action. Ajoute ensuite la confirmation, puis la suppression. Branche le journal en dernier.

Lance le script seulement depuis `nettoyage`. Accepte `a-retirer.txt` et refuse `a-garder.txt`. Vérifie ensuite :

```bash
ls
ls sous-dossier
cat nettoyage.log
```

Relance le script et refuse le fichier ancien restant : le journal ne doit pas gagner de ligne. Pour rejouer un test accepté, recrée `a-retirer.txt` avec `touch`, puis vieillis-le avec `touch -d` comme au début du niveau.

!!! question "Question - N19 · Enregistrer ce qui a vraiment eu lieu"
    Quels fichiers ont été proposés, supprimés et conservés ? Note le contenu du journal. Pourquoi écrire les noms avant la confirmation donnerait-il un journal faux ? Qu'est-ce qui empêche de supprimer un fichier dans `sous-dossier` ?

---

## Niveau 10 — Voir et conserver les connexions : `quibosse.sh`

### 10.1 Des comptes ne sont pas des connexions

```bash
cd ~/base-exploration/tp2-5/atelier-aurore/connexions
whoami
who
LC_ALL=C who
```

`whoami` donne ton identité. `/etc/passwd` décrit les comptes locaux, même lorsqu'ils ne sont pas connectés. `who` affiche les sessions enregistrées comme ouvertes sur la machine : une même personne peut apparaître plusieurs fois si elle a plusieurs sessions.

Sur certaines machines virtuelles, dans WSL ou dans un terminal en ligne, `who` peut ne rien afficher. Cela ne prouve pas que tu n'utilises pas la machine : ta session n'est pas forcément enregistrée dans le fichier de sessions consulté par cette commande.

Avec GNU `who`, `LC_ALL=C` fixe ici la présentation des dates sous la forme `année-mois-jour heure:minute`. Cette affectation placée **devant** la commande s'applique à cette commande. Elle ne change pas durablement la langue de ton terminal.

Le relevé fictif permet de travailler même lorsque la sortie réelle est vide :

```bash
cat connexions-exemple.txt
```

```text
zoe pts/2 2026-09-22 14:10 (192.0.2.12)
alice pts/0 2026-09-22 08:05 (192.0.2.10)
sam pts/3 2026-09-21 23:50 (192.0.2.13)
alice pts/1 2026-09-22 11:20 (192.0.2.10)
```

Chaque ligne donne un nom de compte, un terminal, une date, une heure et ici une origine de connexion. Les espaces peuvent être répétés dans la sortie réelle : utilise les champs de `sort`, comme au niveau 7.

### 10.2 Trouver les clés de l'heure

```bash
sort connexions-exemple.txt
sort -k4,4 connexions-exemple.txt
```

Le premier tri suit les noms. Le second suit les heures, mais place la connexion de Sam à 23 h 50 après celles du lendemain matin. Pour un classement chronologique, il faut trier **d'abord sur la date, puis sur l'heure**.

Les formats `AAAA-MM-JJ` et `HH:MM` ont des chiffres complétés par des zéros : le tri de texte suit leur ordre chronologique. À toi d'ajouter la bonne première clé à la commande d'essai.

!!! question "Question - N20 · Lire une sortie de `who`"
    Quelle différence entre un compte déclaré et une session ouverte ? Quels sont les numéros des champs de date et d'heure ? Dans quel ordre les quatre connexions fictives doivent-elles apparaître ?

### 10.3 Un embranchement avec `tee`

Une redirection `>` envoie le résultat dans un fichier. Comment le voir **et** le conserver ? `tee` réalise cet embranchement :

```bash
printf 'Premier passage\n' | tee suivi-test.log
cat suivi-test.log
printf 'Deuxième passage\n' | tee -a suivi-test.log
cat suivi-test.log
```

`tee` recopie son entrée vers sa sortie normale **et** vers le fichier. Sans option, il remplace le fichier. Avec `-a`, il ajoute à la fin, comme `>>`. Si tu rediriges ensuite la sortie de `tee` vers un autre fichier, le texte ne s'affichera plus dans le terminal.

Les étapes ont donc des rôles différents :

```text
relevé de connexions → classement chronologique → écran et ajout au journal
```

### À toi d'écrire `quibosse.sh`

Le script affiche les utilisateurs actuellement connectés, en conservant leurs lignes de session et en les classant par date puis heure de connexion croissantes. Il ajoute le **même relevé trié** à la fin de `quibosse.log`, dans le dossier courant.

Teste d'abord ta conduite en prenant `connexions-exemple.txt` comme source avec `cat`. Une fois le classement vérifié, remplace la source par `LC_ALL=C who` dans ton script. Ne remplace pas `who` par la liste des comptes de `/etc/passwd`.

Une seconde exécution ajoute un nouveau relevé à l'ancien : c'est un historique. Il est donc normal qu'une session encore ouverte apparaisse dans plusieurs relevés. Si `who` ne donne aucune ligne, le script ne doit pas inventer d'utilisateur.

!!! question "Question - N21 · Un résultat, deux destinations"
    Avec le relevé fictif, note le classement et le contenu du journal après deux passages. Quel rôle joue `-a` ? Qu'affiche ton script avec les connexions réelles de ta machine ?

---

## Boss final — Livrer les dix outils

Les scripts ne travaillent pas tous sur le même terrain. Avant une dernière vérification, retrouve où lancer chacun :

| Script | Dossier de lancement dans l'atelier | Ce que tu dois vérifier |
|---|---|---|
| `infos.sh` | `essais`, puis `projet` | étiquettes littérales et valeurs adaptées au contexte |
| `projet.sh` | `projet` | trois dossiers, dix fichiers chacun, deux commandes de travail |
| `comptes.sh` | `essais` | noms triés sur une seule ligne |
| `etc.sh` | `essais` | inventaire daté, une entrée par ligne et nombre seul à l'écran |
| `recents.sh` | `recents` | sélection par date, puis affichage alphabétique |
| `csv.sh` | `csv` | valeur choisie par les deux fichiers de coordonnées |
| `shells.sh` | `essais` | nom et shell, tri par shell puis par nom |
| `production.sh` | `production` | noms et nombres, tri numérique décroissant, aucun total |
| `nettoyage.sh` | `nettoyage` | confirmation, périmètre limité, journal des suppressions réussies |
| `quibosse.sh` | `connexions` | relevé trié visible et ajouté au journal |

Depuis chaque terrain, la forme `bash ../scripts/nom-du-script.sh` permet de lancer l'outil. Remplace le nom par celui que tu testes. Les fichiers de données restent dans le dossier de lancement ; tes dix recettes restent dans `scripts`.

### Autovérification

```text
□ Chaque script commence par le shebang Bash.
□ Je peux expliquer les commandes de chaque script remis.
□ Les valeurs qui dépendent du contexte ne sont pas écrites en dur.
□ Les variables utilisées comme noms de fichiers sont entre guillemets.
□ J'ai testé les outils séparément avant les conduites complètes.
□ Je distingue le tri de texte, le tri numérique et le tri par date.
□ Un refus de suppression n'ajoute rien au journal de nettoyage.
□ Aucun fichier extérieur au terrain de jeu n'a été modifié.
□ Mon document de notes contient mes observations et mes questions.
```

Dépose les dix fichiers `.sh` demandés sur Moodle, sans sous-dossier ni archive, ainsi que ton document de notes dans l'espace prévu. Garde les noms demandés pour que l'enseignant puisse retrouver chaque exercice. `bonjour.sh` est un essai de découverte : il ne fait pas partie des dix scripts à remettre.

!!! question "Question - N22 · Ta boîte à outils"
    Choisis un script dont tu peux expliquer chaque étape et raconte le trajet des données avec tes mots. Ajoute une erreur qui t'a aidé à comprendre, le niveau où tu t'es arrêté et une notion que tu souhaites reprendre à la prochaine séance.

---

## Ce que tu sais maintenant

Tu sais désormais :

- écrire, relire et lancer un script Bash ;
- expliquer son dossier de travail et ses droits de lancement ;
- distinguer du texte littéral, une variable et le résultat d'une commande ;
- construire des noms avec les accolades et la date ;
- lire les champs d'un compte local ou d'une grille simple ;
- choisir des lignes avant de trier leur affichage ;
- trier selon plusieurs champs ou selon des nombres ;
- répéter une opération pour plusieurs fichiers ;
- sélectionner des fichiers anciens, demander confirmation et conserver les suppressions réussies ;
- afficher un résultat tout en l'ajoutant à un journal avec `tee`.

Tu n'as pas à retenir toutes les options aujourd'hui. Ton carnet de bord et tes essais te permettront de retrouver pourquoi tu les as choisies.
