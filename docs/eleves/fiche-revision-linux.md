# Fiche de révision Linux

<div id="fiche-revision"></div>

Cette fiche rassemble les connaissances et les savoir-faire du cours Linux, de la navigation aux commandes en C. Choisis un thème dans le sommaire, puis cherche ton besoin dans la première colonne. Les mentions **TP2** signalent les notions nouvelles ou approfondies dans ce TP.

Pour réviser, cache les colonnes de droite : essaie de retrouver la commande, d'expliquer son effet et de prévoir le résultat. Une commande connue doit aussi pouvoir être adaptée à un autre fichier ou à un autre dossier.

!!! info "Lire les exemples"
    Les noms `notes.txt`, `journal.log` et `dossier` sont des exemples à adapter. Les commandes utilisant `bruts`, `rapports` ou `scripts` supposent que tu es à la racine du relais Aurore du TP2. Ne recopie pas le symbole `$` de l'invite.

## 1. Comprendre le terminal et trouver de l'aide

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Terminal, shell, noyau | Terminal → shell → programme ; noyau | Le terminal affiche le texte ; le shell interprète la ligne et lance les commandes ; le noyau gère les ressources et les accès. | Bash prépare `ls /`, puis lance `ls`. | Confondre le terminal avec Bash ou avec le noyau Linux. |
| Invite de commande | `utilisateur@poste:chemin$` | Le shell attend une instruction. L'invite donne souvent des repères sur l'utilisateur, le poste et le dossier. | `alice@poste:~$` | Recopier l'invite ou son `$` avec la commande. |
| Nom, options et arguments | `commande [options] arguments` | Les options changent le comportement ; les arguments précisent sur quoi travailler. Les crochets indiquent ici un élément facultatif. | `head -n 5 journal.log` : cinq lignes de ce fichier. | Oublier `-n` : `head 5 journal.log` tente aussi d'ouvrir un fichier nommé `5`. |
| Consulter une aide | `man commande` ; `commande --help` | L'aide permet de retrouver la syntaxe et les options. Dans `man` : `/mot` cherche, Espace avance, `q` quitte. | `man ls` ; `head --help` | Essayer au hasard sans lire le rôle des arguments. |
| Choisir une section du manuel | `man N nom` | La section 1 décrit les commandes, la 2 les appels système et la 3 les fonctions de bibliothèque. `man man` présente les sections. | `man 2 open` et `man 3 fopen`. | Choisis la section qui correspond à ce que tu cherches. |
| Commande interne ou externe | `type commande` | Une commande interne appartient au shell ; un programme externe est lancé séparément. `cd` doit modifier le dossier du shell courant. | `type cd` ; `type ls` | **TP2** : `type dossier` cherche une commande appelée `dossier`, pas le type de cet objet. |
| Localiser les fichiers d’une commande | `whereis commande` | Cherche ses binaires, ses sources et sa documentation dans les emplacements prévus. | `whereis cat` | Pour savoir ce que Bash lancera sous ce nom, utilise `type`. |
| Examiner un objet | `file chemin` ; `ls -ld chemin` | `file` renseigne sur la nature de l'objet ou du contenu ; `ls -ld` montre notamment son type et ses droits. | `file scripts/diagnostic.sh` | Une extension `.sh` ou `.txt` ne suffit pas à prouver le type ou les droits du fichier. |

## 2. Se repérer et construire un chemin

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Savoir où l'on travaille | `pwd` | Affiche le chemin du dossier courant. Un chemin relatif part de cet endroit. | `pwd` → `/home/alice/base-exploration` | Croire que toutes les commandes partent automatiquement du dossier personnel. |
| Voir ce qui est autour | `ls` ; `ls chemin` | Sans argument, liste le dossier courant ; avec un chemin, liste la cible indiquée. | `ls` ; `ls /` | Confondre le contenu du dossier courant et celui de la racine. |
| Changer de dossier | `cd chemin` | Change le dossier courant du shell. Vérifier avant et après avec `pwd` et `ls`. | `cd mission/briefing` | Tenter d'entrer dans un fichier ordinaire avec `cd`. |
| Racine | `/` | Point de départ de l'unique arborescence Linux. | `cd /` | Confondre `/`, la racine, avec `/root`, le dossier personnel de root. |
| Dossier courant et parent | `.` ; `..` | `.` désigne l'endroit actuel ; `..` remonte d'un niveau. | `cd ../..` remonte de deux niveaux. | Compter les niveaux depuis un autre dossier que le dossier courant. |
| Dossier personnel | `~` ; `cd` ; `cd ~` | Bash développe `~` en chemin vers ton dossier personnel. `cd` sans argument y revient également. | `echo ~` → `/home/alice` | `/~` cherche un vrai dossier nommé `~` dans la racine. |
| Dossier personnel d’un autre compte | `~utilisateur` | Bash développe le tilde non protégé au début du mot en chemin du compte indiqué. | `echo ~alice/projet` → par exemple `/home/alice/projet`. | Si le compte est inconnu, Bash laisse le mot tel quel. |
| Chemin absolu | Commence directement par `/` | Décrit la destination depuis la racine ; ne dépend pas du dossier courant. | `/home/alice/base-exploration/notes.txt` | **TP2** : l'écriture `~/notes.txt` est un raccourci développé par Bash, pas une écriture commençant par `/`. |
| Chemin relatif | Ne commence pas par `/` | Décrit la destination depuis le dossier courant. | Depuis `mission` : `briefing/objectif.txt` | Réutiliser ce chemin depuis `/tmp` en espérant atteindre le même fichier. |
| Plusieurs chemins, une cible | `./` ; `../` dans un chemin | Des itinéraires différents peuvent désigner le même objet. | Depuis la station : `00-LIRE-MOI.txt` et `navigation/../00-LIRE-MOI.txt`. | Un dossier traversé dans le chemin doit exister et être accessible. |

## 3. Connaître les grands dossiers Linux

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Espaces personnels | `/home` | Contient généralement les dossiers des utilisateurs ordinaires. | `/home/alice` | `/home` n'est pas forcément ton dossier personnel lui-même. |
| Administrateur | `/root` | Dossier personnel du compte administrateur `root`. | `ls -ld /root` | Confondre le compte `root`, son dossier `/root` et la racine `/`. |
| Configuration | `/etc` | Réglages de la machine et de ses services. | `/etc/passwd` ; `/etc/group` | `/etc/passwd` liste des comptes ; il ne contient normalement pas leurs mots de passe. |
| Fichiers temporaires | `/tmp` | Espace temporaire dont le contenu peut être nettoyé. | `cd /tmp` | Y conserver la seule copie d'un travail important. |
| Données variables | `/var` | Journaux, caches, files d'attente et autres données qui évoluent. | `/var/log` | Chercher tous les journaux dans `/home`. |
| Programmes installés | `/usr` ; `/bin` | `/usr` contient beaucoup de programmes et de bibliothèques ; `/bin` contient des commandes essentielles et est souvent un lien vers `/usr/bin`. | `ls -ld /bin` | Croire que tous les dossiers de la racine sont des dossiers utilisateur. |
| Administration et bibliothèques | `/sbin` et `/lib` | `/sbin` regroupe traditionnellement des outils système. `/lib` contient des bibliothèques utilisées par les programmes. | `ls -ld /sbin /lib` | Selon la distribution, ces chemins peuvent pointer vers des dossiers sous `/usr`. |

## 4. Créer et manipuler fichiers, dossiers et liens

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Créer un dossier | `mkdir chemin` | Crée un répertoire qui pourra contenir des entrées. | `mkdir travail/enquete` | Le dossier parent `travail` doit déjà exister avec cette forme. |
| Visualiser une arborescence | `tree dossier` | Dessine la hiérarchie des dossiers et des fichiers. | `tree mission` | Si l’outil manque, `ls -R mission` liste aussi les sous-dossiers. |
| Créer un fichier vide | `touch fichier` | Crée le fichier s'il n'existe pas ; sinon met à jour ses dates sans vider son contenu. | `touch notes.txt` | Confondre `touch` et `mkdir`. |
| Fichier caché | Nom commençant par `.` | Caché dans l'affichage habituel de `ls`, mais accessible par son nom. | `touch .progression` puis `ls -a` | « Caché » ne signifie ni chiffré ni protégé. |
| Copier | `cp source destination` | Crée une copie ; conserve la source. | `cp notes.txt notes-secours.txt` | Une destination existante peut être remplacée. |
| Déplacer ou renommer | `mv source destination` | Change le nom ou l'emplacement de l'objet. | `mv brouillon.txt rapport.txt` | Attendre que l'ancien chemin continue de fonctionner. |
| Supprimer un fichier | `rm fichier` | Retire son nom du dossier parent. Relire le chemin avant de valider. | `rm notes-secours.txt` | Compter sur une corbeille automatique ; `rm` n'en utilise pas normalement. |
| Supprimer un dossier | `rmdir dossier` ou `rm -r dossier` | `rmdir` exige un dossier vide. `rm -r` descend dans le dossier et supprime aussi son contenu. | `rmdir dossier-vide` | Vérifie le chemin et le contenu avant une suppression récursive. |
| Lien symbolique | `ln -s cible lien` | Mémorise un chemin vers une cible, sans recopier son contenu. Une cible relative se résout depuis le dossier du lien. | Depuis `mission` : `ln -s briefing/objectif.txt acces-rapide`. | Renommer ou déplacer la cible peut casser le lien ; le lien reste présent. |
| Lien physique | `ln fichier autre-nom` | Ajoute un nom qui désigne le même inode, donc le même fichier. | `ln notes.txt notes-bis.txt`, puis `ls -i notes*.txt`. | Modifier le contenu via un nom se voit via l’autre. Les deux noms doivent rester dans le même système de fichiers. |
| Télécharger et décompresser | `wget URL` ; `unzip archive.zip` | Récupère un fichier dans le dossier courant, puis extrait une archive ZIP. | `unzip tp1-5-station-nadir.zip` | Oublier de vérifier `pwd` avant le téléchargement ou l'extraction. |

## 5. Observer précisément avec ls

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Voir les détails | `ls -l` | Affiche type, droits, propriétaire, groupe, taille et date. | `ls -l notes.txt` | Le premier caractère décrit le type, pas un droit : `-` fichier, `d` dossier, `l` lien. |
| Afficher les entrées cachées | `ls -a` | Inclut les noms commençant par un point. | `ls -a navigation` | Cela change l'affichage, pas les permissions. |
| Lire les tailles | `ls -lh` | `-l` affiche les détails ; `-h` rend les tailles plus lisibles. | `ls -lh bruts` | `-h` seul ne demande pas l'affichage détaillé et ne trie pas par taille. |
| Trier par date | `ls -lt` | Trie par date de modification, du plus récent au plus ancien. | `ls -lt transmissions` | Confondre date de modification et taille. |
| Voir les sous-dossiers | `ls -R` | Liste récursivement les contenus. | `ls -R navigation` | Une longue sortie devient difficile à parcourir. |
| Examiner le dossier lui-même | `ls -ld dossier` | `-d` décrit le dossier au lieu de lister son contenu. | `ls -ld scripts` | `ls -l scripts` décrit les entrées de `scripts`, pas ses propres droits. |
| Combiner des options | `ls -lah` | Réunit ici les effets de `-l`, `-a` et `-h`. | `ls -lah travail` | Choisir une combinaison sans savoir ce que chaque lettre apporte. |

## 6. Lire, rechercher et modifier du texte

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Afficher un petit fichier | `cat fichier` | Affiche tout son contenu sans le modifier. | `cat notes.txt` | Afficher des milliers de lignes quand on cherche seulement un détail. |
| Parcourir un long fichier | `less fichier` | Lecteur interactif : Espace avance, `b` recule, `g` va au début, `G` à la fin, `q` quitte. | `less journal.log` | Confondre consulter avec modifier. |
| Chercher dans less | `/mot` ; `n` ; `N` | Cherche vers le bas ; `n` passe au résultat suivant, `N` au précédent. | Dans `less` : `/PROTOCOLE`, puis `n`. | Ces touches s'utilisent dans le lecteur, pas après l'invite du shell. |
| Voir le début ou la fin | `head -n N fichier` ; `tail -n N fichier` | Affiche les N premières ou dernières lignes. | `tail -n 5 journal.log` | Écrire `head 5 fichier` au lieu de `head -n 5 fichier`. |
| Suivre un journal | `tail -f fichier` | Affiche la fin du fichier, puis les lignes ajoutées. | `tail -f journal.log`, puis `Ctrl+C` pour arrêter. | La commande reste active même si aucune nouvelle ligne n’arrive. |
| Rechercher des lignes | `grep 'motif' fichier` | Affiche les lignes correspondant au motif, sans modifier la source. | `grep 'ERREUR' journal.log` | Inverser le motif et le fichier ; la casse compte par défaut. |
| Numéroter ou ignorer la casse | `grep -n` ; `grep -i` | `-n` ajoute le numéro de ligne ; `-i` ignore majuscules/minuscules. | `grep -ni 'critique' journal.log` | `-n` ne compte pas les résultats. |
| Exclure des lignes | `grep -v 'motif' fichier` | Garde les lignes qui ne correspondent pas au motif. | `grep -v 'INFO' journal.log` | Penser que les lignes sont supprimées du fichier source. |
| Lire plusieurs fichiers | `grep -h 'motif' fichiers` | Sur plusieurs fichiers, `grep` préfixe normalement les lignes avec leur nom ; `-h` retire ce préfixe. | `grep -h 'CRITIQUE' bruts/*.log` | Conserver le préfixe alors qu'un filtre suivant attend seulement les champs de la ligne. |
| Compter les lignes | `wc -l fichier` | Compte les lignes ; avec plusieurs fichiers, affiche un résultat par fichier puis un total. | `wc -l bruts/*.log` | Confondre le nombre de lignes et le nombre de mots ou d'occurrences d'un motif. |
| Compter mots et octets | `wc fichier`, `wc -w fichier`, `wc -c fichier` | Sans option, compte les retours à la ligne, les mots et les octets. `-w` et `-c` sélectionnent un seul compte. | `wc -w notes.txt` | Un caractère accentué peut occuper plusieurs octets. |
| Modifier un texte | `nano fichier` ; `Ctrl+S` ; `Ctrl+X` | Ouvre un éditeur ; `Ctrl+S` enregistre ; `Ctrl+X` quitte. Confirme le nom du fichier si demandé. | `nano rapport.txt` puis `cat rapport.txt`. | Quitter sans avoir enregistré les modifications. |
| Éditer avec Vim | `vim fichier` | Appuie sur `i` pour saisir du texte et sur `Échap` pour revenir au mode normal. | En mode normal, tape `:wq` puis Entrée pour enregistrer et quitter. | Les touches ont des rôles différents selon le mode. |
| Copier et coller du texte | `Ctrl+Shift+C` ; `Ctrl+Shift+V` | Sélectionne le texte à la souris dans le terminal, copie-le, puis place le curseur à la destination et colle-le. | Copier une ligne du rapport et la coller à un autre emplacement. | Coller sans vérifier la position du curseur ou les retours à la ligne. |
| Supprimer une ligne dans nano | `Ctrl+K` | Supprime rapidement toute la ligne où se trouve le curseur. | Supprimer une ligne de brouillon du rapport. | Supprimer la mauvaise ligne sans vérifier la position du curseur. |

## 7. Utiliser l'historique et corriger une ligne

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Rappeler une commande | `↑` ; `↓` ; `history 10` | Parcourt les commandes précédentes ; `history 10` affiche les dix dernières entrées. | Rappeler `ls -la`, puis remplacer `-la` par `-ld`. | L'historique peut rappeler une erreur : relire avant Entrée. |
| Compléter un nom | `Tab` | Complète un nom ; plusieurs possibilités peuvent être proposées. | Saisir `cat doc`, puis Tab. | Valider un chemin incomplet sans vérifier la proposition. |
| Aller au début ou à la fin | `Ctrl+A` ; `Ctrl+E` | Déplace le curseur sur la ligne en cours. | Corriger le nom de la commande avec `Ctrl+A`. | Confondre déplacement du curseur et exécution. |
| Se déplacer par mot | `Ctrl+←` ; `Ctrl+→` | Parcourt les mots ; selon le terminal, utiliser `Alt+B` et `Alt+F`. | Rejoindre un argument sans tout effacer. | Les raccourcis peuvent varier selon le terminal. |
| Effacer le mot précédent | `Ctrl+W` | Supprime le mot situé avant le curseur dans Bash. | Retirer un argument mal saisi. | Effacer un argument utile sans vérifier la position du curseur. |
| Rechercher dans l'historique | `Ctrl+R` | Retrouve une commande à partir d'une partie de son texte. | Chercher `00-LIRE`. | Exécuter immédiatement une ancienne commande qui ne convient plus au contexte. |
| Abandonner ou interrompre | `Ctrl+C` | Annule la ligne en cours ou demande l'interruption de la commande au premier plan. | Interrompre `sleep 30`. | **TP2** : `Ctrl+Z` suspend une tâche, il ne la termine pas. |

## 8. Comprendre les utilisateurs et les permissions

Les règles ci-dessous concernent les permissions ordinaires utilisées dans les TP, avec un utilisateur non administrateur.

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Connaître son identité | `whoami` ; `id` ; `id -gn` | `whoami` donne le nom ; `id` montre UID, GID et groupes ; `id -gn` donne le groupe principal. | `id -un` retrouve le nom d'utilisateur. | L'UID identifie l'utilisateur, pas l'ordinateur ni un processus. |
| Distinguer comptes et groupes | `/etc/passwd` et `/etc/group` | Le premier décrit les comptes locaux. Le second décrit les groupes locaux. Un compte peut avoir un groupe principal et des groupes supplémentaires. | `id` donne le GID du groupe principal et les groupes du compte courant. | La liste de membres dans `/etc/group` ne répète pas forcément les comptes qui ont ce groupe comme groupe principal. |
| Changer d’identité pour une action | `su utilisateur` ou `sudo commande` | `su` ouvre un shell sous un autre compte. `sudo` lance une commande autorisée sous un autre compte, `root` par défaut. | `su alice` ouvre un shell sous le compte Alice si l’accès est autorisé. | Dans les exercices de permissions, garde ton compte habituel. |
| Lire les catégories | `u` ; `g` ; `o` | Dans `ls -l`, trois blocs concernent le propriétaire, le groupe puis les autres. | `-rw-r-----` = fichier ; `u: rw-`, `g: r--`, `o: ---`. | Mélanger l'ordre des catégories ou compter le caractère de type comme un droit. |
| Choisir la catégorie applicable | Propriétaire → sinon groupe → sinon autres | Une seule catégorie s'applique. Le propriétaire ne récupère pas les droits du groupe. | Propriétaire d'un fichier en `040` : pas de lecture par les droits ordinaires. | Additionner `u`, `g` et `o`. |
| Lecture | `r` | Fichier : lire le contenu. Dossier : lire la liste des noms. | `cat notes.txt` ; `ls dossier` | Croire que voir un nom garantit l'accès à son contenu. |
| Écriture | `w` | Fichier : modifier le contenu. Dossier : modifier ses entrées, avec `x` pour les manipulations du TP. | Ajouter une ligne au fichier ; créer un nom dans un dossier. | Penser que `w` sur le fichier suffit pour le supprimer. |
| Exécution ou traversée | `x` | Fichier : permettre son lancement direct. Dossier : le traverser et accéder à des entrées connues. | `./scripts/diagnostic.sh` ; `cd dossier` | « Exécuter un dossier » n'a pas de sens ; il faut le traverser. |
| Supprimer ou renommer | Droits `w` et `x` du dossier parent | Ces actions modifient la liste des noms du dossier. Le droit `w` du fichier n'est pas déterminant. | `rm depot/temoin.txt` dépend des droits de `depot`. | Un fichier en lecture seule n'est pas automatiquement protégé contre la suppression. |
| Ajouter ou retirer un droit | `chmod u+w fichier` ; `chmod u-w fichier` | `u` choisit la catégorie ; `+` ajoute ; `-` retire le droit indiqué. | `chmod u+x scripts/bilan.sh` | Ajouter `x` à tous les fichiers pour résoudre un refus sans comprendre sa cause. |
| Fixer des droits par lettres | `chmod u=rw,g=r,o= fichier` | `=` fixe exactement les droits de la catégorie indiquée. | Propriétaire : lecture/écriture ; groupe : lecture ; autres : aucun. | Confondre `=` avec `+`, qui conserve les autres droits déjà présents. |
| Calculer un chiffre | `r=4` ; `w=2` ; `x=1` | Additionner les droits dans chaque catégorie : `7=rwx`, `6=rw-`, `5=r-x`, `4=r--`, `3=-wx`, `2=-w-`, `1=--x`, `0=---`. | Lecture + écriture = `4+2=6`. | Un chiffre `8` ou `9` n'existe pas dans cette notation octale. |
| Fixer un mode numérique | `chmod 640 fichier` | Trois chiffres dans l'ordre `u`, `g`, `o` fixent les neuf droits ordinaires. | `640` = `rw- r-- ---` ; `750` = `rwx r-x ---`. | Additionner les trois chiffres au lieu de les interpréter séparément. |
| Modes utiles | `600` ; `644` ; `750` ; `755` | `600` : fichier privé ; `644` : fichier lisible par tous ; `750` : exécution/traversée pour propriétaire et groupe ; `755` : aussi pour les autres. | `chmod 600 coffre/secret.txt` | Le même mode n'a pas le même effet sur un fichier et sur un dossier. |
| Changer le propriétaire ou le groupe | `chown utilisateur fichier` ou `chgrp groupe fichier` | Changer le propriétaire exige normalement des privilèges. Le propriétaire peut choisir un groupe dont il est membre. | `chgrp etudiants rapport.txt` si tu possèdes le fichier et appartiens à ce groupe. | `chmod` règle les droits. `chown` et `chgrp` changent les identités auxquelles ils s’appliquent. |
| Accéder via un lien symbolique | Droits de la cible et des dossiers traversés | Si la commande suit le lien, Linux vérifie l’accès à la cible. | `cat acces-rapide` exige que le briefing visé soit lisible. | Les bits `rwx` affichés pour le lien ne donnent aucun accès supplémentaire à la cible. |

## 9. TP2 — Comprendre les transformations de Bash

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Chercher plusieurs noms | `*` | Bash remplace le motif par les chemins existants correspondants avant de lancer la commande. | `echo bruts/*.log` affiche les chemins trouvés. | C'est Bash qui cherche les noms, pas `echo` ; cela ne cherche pas dans le contenu. |
| Préciser un motif de chemin | `?`, `[abc]`, `[a-z]`, `[!abc]` | `?` accepte un caractère. Les crochets acceptent un caractère de la liste ou de l’intervalle. `!` inverse le choix. | `ls mesure-0[1-3].txt` sélectionne les noms existants de `mesure-01.txt` à `mesure-03.txt`. | Un joker ne traverse pas `/`. Par défaut, écris le point initial pour sélectionner les noms cachés, par exemple avec `.rapport*`. |
| Protéger une étoile | `"*.log"` ou `'*.log'` | Les guillemets empêchent le développement de l'étoile par Bash. | `echo "bruts/*.log"` affiche ce texte tel quel. | Mettre des guillemets autour d'un motif alors qu'on voulait fournir plusieurs fichiers à la commande. |
| Protéger un caractère | `\` devant le caractère | La barre oblique inverse protège le caractère suivant. Devant un retour à la ligne, elle prolonge la commande. | `echo \$HOME` affiche `$HOME`. | Pour protéger plusieurs mots en un seul argument, utilise des guillemets. |
| Garder tout comme texte | Guillemets simples : `'...'` | Protègent le texte, notamment `$`, `*` et `$(...)`. | `echo 'Heure : $(date +%H:%M)'` affiche l'expression. | Attendre une heure alors que la substitution est protégée. |
| Conserver un texte groupé avec des substitutions | Guillemets doubles : `"..."` | Gardent le texte en un argument ; permettent notamment `$(...)`, mais protègent `*`. | `echo "Heure : $(date +%H:%M)"` affiche l'heure. | Croire que guillemets simples et doubles produisent toujours le même effet. |
| Réutiliser le résultat d'une commande | `$(commande)` | Exécute la commande et insère sa sortie dans la ligne en préparation. | `echo "Date : $(date +%F)"` | Confondre cette insertion avec un fichier créé par la commande. |
| Produire plusieurs mots | `{mot1,mot2}` | Les accolades développent un modèle en plusieurs mots, même si ces fichiers n'existent pas. | `touch rapport-{matin,soir}.txt` crée deux fichiers. | Confondre accolades et étoile : `*` sélectionne des noms existants. |
| Générer des suites et des combinaisons | `{début..fin..pas}` et plusieurs groupes d’accolades | Le pas est facultatif. La suite peut décroître ou utiliser des lettres. Plusieurs groupes produisent toutes les combinaisons. Ils peuvent aussi s’imbriquer. | `echo {nord,sud}-{3..1..2}` donne `nord-3 nord-1 sud-3 sud-1`. | Avec des guillemets autour du motif, les accolades restent du texte. |

Bash développe les accolades, puis le tilde. Il traite ensuite les variables, les substitutions de commandes et les calculs dans la même phase, de gauche à droite. Viennent le découpage en mots, le développement des chemins et le retrait des guillemets de protection. Sans guillemets, une valeur comme `mon dossier` peut être découpée en deux arguments. Avec `"$chemin"`, elle reste un seul argument.

## 10. Relier les commandes et diriger leurs flux

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Afficher du texte | `echo "texte"` | Écrit ses arguments sur la sortie normale. | `echo "Bonjour"` | Supposer que `echo` crée automatiquement un fichier. |
| Écrire ou remplacer | `commande > fichier` | Branche la sortie normale vers un fichier, créé ou vidé avant l'exécution. | `echo "Bonjour" > notes.txt` | Le contenu précédent est perdu, même si la commande ne produit ensuite rien. |
| Ajouter | `commande >> fichier` | Conserve le contenu et ajoute à la fin ; crée le fichier s'il n'existe pas. | `echo "Suite" >> notes.txt` | Relancer une analyse avec `>>` peut dupliquer tous les résultats. |
| Fournir une entrée | `commande < fichier` | Le shell ouvre le fichier et fournit son contenu sur l'entrée standard. | `wc -l < journal.log` affiche le compte sans le nom du fichier. | Confondre le contenu fourni en entrée et un nom de fichier donné comme argument. |
| Trois canaux standards | `0` entrée ; `1` sortie normale ; `2` erreurs | Une commande peut produire un résultat et des messages d'erreur sur deux canaux différents. | `ls dossier-existant dossier-absent` produit les deux types de sortie. | Tout ce qui apparaît dans le terminal n'appartient pas au résultat normal. |
| Conserver les erreurs séparément | `2>` | Redirige le canal d'erreur, indépendamment de `>`. | `ls bruts absent > liste.txt 2> erreurs.txt` | Penser que `> liste.txt` capture aussi les erreurs. |
| Ajouter à un journal d’erreurs | `2>>` | Ajoute les erreurs du canal 2 à la fin du fichier. Les formes explicites `0<`, `1>` et `1>>` correspondent à `<`, `>` et `>>`. | `ls absent 2>> erreurs.txt` | `2>` remplacerait l’ancien journal. |
| Réunir les deux sorties | `> fichier 2>&1` | `2>&1` dirige les erreurs vers la destination déjà utilisée par la sortie normale. | `ls bruts absent > controle.txt 2>&1` | L'ordre compte : `2>&1 > controle.txt` ne branche pas les canaux de la même manière. |
| Construire une conduite | <code>commande1 &#124; commande2</code> | <code>&#124;</code> relie la sortie normale de gauche à l'entrée standard de droite, sans fichier intermédiaire. | <code>grep 'ERREUR' journal.log &#124; wc -l</code> compte les lignes sélectionnées. | Les erreurs ne passent pas automatiquement dans le tube ; <code>&#124;</code> ne crée pas un fichier. |
| Conserver une conduite | <code>commande1 &#124; commande2 &gt; fichier</code> | La redirection finale enregistre le résultat de la dernière étape. | <code>grep 'ERREUR' journal.log &#124; sort &gt; erreurs-triees.txt</code> | Lire et écrire le même fichier dans une conduite peut vider la source avant sa lecture. |

Dans une conduite, les commandes s’exécutent en parallèle. Le filtre de droite peut commencer à lire avant que celui de gauche ait fini. Un filtre peut lire sur l’entrée standard et sépare son résultat de ses erreurs. Sans argument de fichier, `cat` recopie son entrée standard et `grep 'motif'` y cherche ses lignes.

## 11. TP2 — Extraire, trier et transformer les données

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Extraire un champ | `cut -d';' -fN` | `-d` choisit le séparateur ; `-f` choisit le champ, numéroté à partir de 1. | <code>echo 'balise;zone;urgent' &#124; cut -d';' -f2</code> → `zone`. | Confondre lignes et champs : `grep` sélectionne des lignes, `cut` extrait des champs. |
| Extraire plusieurs champs | `cut -d';' -f3,4` | Conserve les champs demandés et leur séparateur. | Dans le TP2 : champs 3 et 4 = source et zone. | Employer les numéros de colonnes sans vérifier le format du fichier. |
| Trier | `sort` | Range les lignes reçues selon l'ordre de tri de l'environnement. | `sort notes.txt` | Le résultat est affiché ; la source n'est pas réécrite automatiquement. |
| Trier sans doublons | `sort -u` | Trie et conserve une seule occurrence de chaque ligne identique. | <code>cut -d';' -f3 journal.log &#124; sort -u</code> | Deux lignes avec une casse ou un espace différent ne sont pas identiques. |
| Remplacer des caractères | `tr 'origine' 'destination'` | Transforme les caractères reçus sur l'entrée standard. | <code>echo 'a;b' &#124; tr ';' ' '</code> → `a b`. | `tr` ne remplace pas ici un mot entier et ne reçoit pas un fichier comme argument de données. |
| Passer en majuscules | `tr '[:lower:]' '[:upper:]'` | Traduit les caractères minuscules en majuscules. | <code>echo 'aurore' &#124; tr '[:lower:]' '[:upper:]'</code> → `AURORE`. | Oublier les guillemets autour des classes de caractères. |
| Choisir l'ordre des filtres | Sélectionner → extraire → trier → compter | Chaque étape reçoit le résultat de la précédente. Tester la conduite progressivement. | <code>grep -h 'ERREUR' bruts/*.log &#124; cut -d';' -f3 &#124; sort -u</code> donne les sources distinctes. | Trier des lignes complètes avant d'extraire un champ ne déduplique pas forcément ce champ. |

Pour le format simple du TP2, les communications comportent des champs séparés par `;` : consulte leur ordre dans `documentation/format-communications.txt`. `cut` découpe selon ce séparateur ; il ne traite pas toutes les subtilités possibles d'un fichier CSV.

## 12. Programmes, processus et tâches du terminal

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Programme et processus | PID ; PPID | Un programme est un fichier ; un processus est une exécution. PID = identifiant du processus ; PPID = identifiant de son parent. | Deux lancements de `sleep` donnent deux processus distincts. | Un PID n'est pas attaché définitivement au programme et peut être réutilisé. |
| Observer un processus | `ps` | Affiche des informations sur les processus sélectionnés. | `ps -o pid,ppid,stat,etime,cmd -p "$!"` après un lancement en arrière-plan. | `$!` désigne le PID du dernier processus lancé en arrière-plan, pas tous les processus. |
| Avant-plan et arrière-plan | `commande` ; `commande &` | Au premier plan, le shell attend ; avec `&`, l'invite revient pendant que la tâche continue. | `sleep 90 &` | L'arrière-plan n'accélère pas la commande. |
| Voir les tâches du shell | `jobs` | Liste les tâches connues du shell courant et leur état. | `jobs` après `sleep 90 &`. | Ce n'est pas la liste de tous les processus de la machine. |
| Revenir au premier plan | `fg %N` | Ramène la tâche N au premier plan et la reprend si elle était suspendue. | `fg %1` si `jobs` montre la tâche `[1]`. | `%1` est un numéro de tâche local au shell, pas le PID 1. |
| Suspendre et reprendre | `Ctrl+Z` ; `bg %N` | `Ctrl+Z` suspend la tâche au premier plan ; `bg` la reprend en arrière-plan. | `Ctrl+Z`, puis `bg %1`. | Une tâche suspendue est encore présente mais ne continue pas son travail. |
| Demander l'arrêt | `kill PID` ; `kill %N` ; `Ctrl+C` | Envoie un signal au processus ou à la tâche ; `Ctrl+C` vise le premier plan. | `kill %1` après avoir vérifié dans `jobs` le `sleep` de l'exercice. | Viser un PID ou un numéro de tâche sans identifier ce qui sera arrêté. |

## 13. TP2 — Conserver une analyse dans un script

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Script Bash | Fichier texte de commandes | Conserve les étapes d'une analyse pour les rejouer dans leur ordre. Le script contient la recette ; le rapport contient les résultats. | `nano scripts/bilan.sh` | Confondre le fichier de commandes et le fichier produit par leur exécution. |
| Indiquer l'interpréteur | `#!/usr/bin/env bash` | Première ligne du script : indique comment trouver Bash pour son lancement direct. | Placer cette ligne en tête de `bilan.sh`. | L'extension `.sh` ne remplace ni cette indication ni les permissions. |
| Lancer avec Bash | `bash scripts/bilan.sh` | Bash lit les commandes du fichier. Le droit de lecture est nécessaire ; le droit `x` du script ne l'est pas pour cette forme. | `bash scripts/bilan.sh` | Croire que le script est forcément exécutable directement parce que cette commande fonctionne. |
| Lancer directement | `./scripts/bilan.sh` | Nécessite le droit `x` et un interpréteur adapté ; pour ce script Bash, son contenu doit aussi être lisible. | `chmod 750 scripts/bilan.sh`, puis `./scripts/bilan.sh`. | Donner `x` à un fichier de données au lieu de régler le script. |
| Conserver le bilan | `bash script > rapport` | Enregistre la sortie normale de l'exécution, pas le texte du script. | `bash scripts/bilan.sh > rapports/bilan.txt` | Les erreurs restent ailleurs sans redirection du canal 2. |
| Chemins dans un script | Dossier courant au lancement | Les chemins relatifs du script partent du dossier courant, pas automatiquement du dossier qui contient le script. | Depuis le relais : `bash scripts/bilan.sh` peut lire `bruts/*.log`. | Lancer depuis `/tmp` un script utilisant `bruts/*.log` et attendre le même résultat. |

## 14. Diagnostiquer une erreur

Réflexe : **relire la commande → vérifier le dossier courant → identifier l'objet visé → lire le message → tester une correction**. Pour une conduite, vérifier d'abord la partie gauche, puis ajouter les étapes une à une.

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| `No such file or directory` | `pwd` ; `ls chemin` | Le chemin recherché ne mène pas à un objet existant, ou un argument a été pris à tort pour un fichier. | `head 5 journal.log` cherche un fichier nommé `5`. | Conclure que le logiciel n'est pas installé sans relire les arguments. |
| `Permission denied` | `ls -l fichier` ; `ls -ld dossier` | Identifier l'action : lire, écrire, traverser ou exécuter, puis examiner les droits correspondants. | Un script en `640` ne se lance pas directement. | Vérifier seulement les droits du fichier alors qu'un dossier du chemin est bloqué. |
| `command not found` | `type commande` | Le shell ne trouve pas la commande sous le nom indiqué. | Vérifier une faute de frappe dans `grep`. | Utiliser `type` pour diagnostiquer le type d'un dossier. |
| `Is a directory` | Examiner le chemin cible | La commande attendait un fichier à cet endroit. | `echo "test" > travail/enquete` vise un dossier ; ajouter `/test.txt`. | Réessayer la même commande sans ajouter un nom de fichier. |
| Aucun résultat de grep | Vérifier motif, casse et source | Aucune ligne peut correspondre ; un message d'erreur signale un autre problème. | Tester `grep -i 'critique' journal.log`. | Croire qu'une sortie vide prouve que le fichier est vide. |
| Étoile non développée | Examiner guillemets et noms disponibles | En Bash avec les réglages habituels, un motif sans correspondance reste tel quel ; les guillemets peuvent aussi le protéger. | `echo bruts/*.log` ; `ls bruts`. | Penser que `*.log` est toujours remplacé, même sans fichier correspondant. |
| Rapport vide ou résultat incohérent | Tester chaque filtre séparément | Vérifier la sélection, le séparateur, le champ et les redirections. | Tester `grep`, puis ajouter `cut`, puis `sort -u`. | Ajouter des commandes à une conduite dont la première étape est déjà incorrecte. |
| Tâche introuvable | `jobs` | La tâche a pu se terminer ou appartenir à un autre shell. | Vérifier `jobs` avant `fg %1`. | Réutiliser `%1` sans vérifier la tâche actuelle. |

## 15. Compléments facultatifs du TP2

Ces outils figurent dans la partie « Pour aller plus loin » du TP2. Ils complètent les notions du parcours principal.

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Rechercher des fichiers | `find dossier -name 'motif'` | Parcourt l'arborescence à partir du dossier et sélectionne les noms correspondants. | `find . -name '*.log'` | Oublier les guillemets : Bash pourrait développer le motif avant `find`. |
| Compter avec grep | `grep -c 'motif' fichier` | Compte les lignes correspondantes ; avec plusieurs fichiers, donne un compte par fichier. | `grep -c 'CRITIQUE' journal.log` | `-c` compte des lignes, pas toutes les occurrences ; `-n` donne leurs numéros. |
| Écrire plusieurs lignes | `cat << FIN > message.txt` | Le shell fournit les lignes suivantes jusqu'à une ligne contenant uniquement `FIN`. Avec ce délimiteur non cité, `$(...)` est développé. | Écrire le message, puis terminer par `FIN` seul sur sa ligne. | Oublier le délimiteur final ou penser que `>` conserve l'ancien contenu. |
| Garder un document en ligne littéral | `<< 'FIN'` | Si tu protèges le délimiteur d’ouverture, Bash conserve le texte entre les deux délimiteurs. Avec `<< FIN`, il développe les variables, les substitutions de commandes et les calculs. | Entre `<< 'FIN'` et `FIN`, `$HOME` reste écrit tel quel. | Le délimiteur final s’écrit seul sur sa ligne, sans guillemets. |

## 16. Comprendre le système et les processus

Le système d’exploitation donne aux applications des moyens d’utiliser le matériel. Le **noyau** partage les ressources et vérifie les droits. Les **pilotes** lui permettent de communiquer avec les périphériques. Un **appel système** demande un service au noyau.

| Besoin ou notion | Ce qu’il faut retenir | Exemple ou repère |
|---|---|---|
| Simplifier l’accès au matériel | Le système de fichiers présente des noms et des suites d’octets. La mémoire virtuelle donne à chaque processus son propre espace d’adresses. | Un programme lit un fichier sans choisir les blocs du disque. |
| Partager et protéger | Linux est multitâche et multi-utilisateur. Le noyau répartit le temps processeur et la mémoire. Il contrôle l’accès aux ressources de chaque compte. | Deux programmes peuvent avancer par petites tranches sur un même cœur. |
| Démarrer et entretenir la machine | Au démarrage, le noyau initialise le matériel. Le système rend les systèmes de fichiers accessibles et lance les services. En fonctionnement, il peut ajuster la fréquence du processeur. Des services peuvent appliquer les mises à jour selon la configuration. | `init`, souvent `systemd`, est normalement le processus de PID 1. Il lance des services comme `sshd` et peut adopter des processus orphelins. |
| Demander un service au noyau | Le programme passe généralement par une fonction de la bibliothèque C. Le noyau exécute l’opération ou signale un refus, par exemple si les droits manquent. | `mmap` crée un mappage en mémoire, `recv` reçoit des données d’un socket et `write` écrit des octets. Leurs manuels sont en section 2. |
| Situer Linux et Bash | Unix naît aux Bell Labs à la fin des années 1960, puis se décline notamment en BSD et System V. Linus Torvalds publie en 1991 Linux, un noyau de type Unix. | Bash est un shell du projet GNU. Il suit largement les conventions POSIX des shells, avec ses propres extensions. `sh`, `ksh` et `zsh` sont d’autres shells. |
| Lire les métadonnées | Un inode décrit l’objet. Il porte son type, son propriétaire, son groupe, ses droits, sa taille et ses dates. Un dossier associe des noms à des numéros d’inode. | `ls -i fichier` montre l’inode. `stat fichier` montre ses attributs. Le nom vient du dossier parent. |
| Interpréter les dates | `atime` indique le dernier accès, selon les réglages du système. `mtime` indique la dernière modification du contenu. `ctime` indique le dernier changement d’état de l’inode. | Après un `chmod`, `ctime` change. La date de création est distincte et peut manquer. |
| Créer et suivre un enfant | `fork` crée un enfant avec une copie logique des données du parent. `exec` remplace le programme du processus sans changer son PID. `wait` permet au parent d’attendre un enfant et de récupérer son statut. | Pour une commande externe au premier plan, le shell crée généralement un enfant, lui fait lancer la commande et attend sa fin. `SIGCHLD` signale au parent un changement d’état de l’enfant. |
| Observer le contexte | Un processus a un PID, un parent, une identité pour les droits et un dossier courant pour ses chemins relatifs. Plusieurs processus peuvent exécuter le même programme. | `ps -ef` affiche tous les processus visibles au format détaillé. Vérifie le PID, le PPID et la commande. |
| Comprendre les signaux du terminal | `Ctrl+C` envoie `SIGINT` au premier plan. `Ctrl+Z` envoie `SIGTSTP` pour suspendre. `kill` envoie `SIGTERM` par défaut. | Dans un shell interactif, une tâche en arrière-plan qui tente de lire le terminal est normalement suspendue. |

## 17. Utiliser les variables et les arguments en Bash

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre |
|---|---|---|
| Mémoriser une valeur | `nom="Lamia Martin"` | L’affectation crée la variable si besoin. Écris le nom sans `$` et colle le signe `=`. Un nom commence par une lettre ou `_`, puis accepte aussi les chiffres. Bash traite les valeurs ordinaires comme du texte. |
| Lire ou retirer une variable | `"$nom"`, `"${nom}.txt"`, `unset nom` | Les accolades délimitent le nom. Les guillemets préservent les espaces. Avec les réglages habituels, une variable absente se développe en texte vide. `unset` la supprime du shell. |
| Transmettre une valeur | `export MODE=test`, `export -n MODE`, `env` | `export` ajoute la variable à l’environnement transmis aux enfants. `export -n` retire l’export tout en gardant la variable dans le shell. `env` affiche l’environnement. Un enfant travaille avec sa propre copie. |
| Reconnaître les variables usuelles | `HOME`, `PWD`, `USER`, `SHELL`, `PATH` | `HOME` désigne ton dossier personnel et `PWD` le dossier courant. `USER` indique généralement ton nom de compte. `SHELL` indique normalement ton shell de connexion. `PATH` liste des dossiers séparés par `:`. |
| Comprendre la recherche d’une commande | `type ls`, `./script.sh`, `echo "$PATH"` | Pour un nom simple, Bash résout notamment les fonctions et commandes internes, puis cherche les exécutables dans `PATH`. Un nom avec `/` désigne directement un chemin. Le dossier courant est cherché par nom simple seulement s’il figure dans `PATH`. |
| Lire les paramètres | `$0`, `$1`, `${10}`, `$#` | `$0` donne le nom d’appel. Les paramètres commencent à `$1`. À partir de 10, utilise les accolades. `$#` compte les arguments, sans `$0`. |
| Transmettre tous les arguments | `"$@"` ou `"$*"` | `"$@"` conserve chaque argument séparé, même s’il contient des espaces. `"$*"` les réunit en un seul argument, avec un espace entre eux par défaut. |
| Insérer une sortie | `valeur=$(commande)` | Bash récupère la sortie standard et retire les retours à la ligne finaux. Le canal d’erreur reste séparé. Une substitution peut contenir une conduite ou une autre substitution. |
| Lire une ligne et formater une sortie | `IFS= read -r ligne`, `printf '%s\n' "$ligne"` | `read` prend une ligne sur l’entrée standard. Ici, `IFS=` conserve les espaces de bord et `-r` conserve les barres obliques inverses. `printf` insère la valeur à la place de `%s` et `\n` termine la ligne. |

## 18. Tester, choisir et répéter en Bash

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre |
|---|---|---|
| Lire ou fixer un statut | `echo "$?"`, `exit 2` | `$?` donne le statut de la dernière commande ou conduite. Lis-le tout de suite. `0` signifie succès, les autres valeurs de `1` à `255` ont un sens propre à la commande. Un script qui arrive à la fin reprend le statut de sa dernière commande exécutée. |
| Enchaîner selon le statut | `a && b`, <code>a &#124;&#124; b</code> | `&&` lance la suite si la commande de gauche réussit. <code>&#124;&#124;</code> la lance si elle échoue. Par exemple, `mkdir essai && cd essai` entre dans le dossier si la création réussit. |
| Comparer avec `test` | `[ "$n" -ge 3 ]`, `[ "$mot" = "oui" ]` | Pour les entiers, utilise `-eq`, `-ne`, `-lt`, `-le`, `-gt`, `-ge`. Pour le texte, utilise `=` ou `!=`. Laisse des espaces après `[` et avant `]`. |
| Tester un chemin | `test -f "$fichier"`, `[ -r "$fichier" ]` | `-e` teste l’existence, `-f` un fichier ordinaire, `-d` un dossier. `-r`, `-w` et `-x` testent l’accès en lecture, écriture et exécution ou traversée. |
| Calculer avec des entiers | `echo $((n * 2 + 1))` | `$((…))` insère le résultat numérique. Si `n=3`, l’exemple donne `7`. Tu peux écrire les noms de variables sans `$` et utiliser des affectations comme `n += 1`. |
| Tester un calcul | `(( n > 3 ))` | Cette commande renvoie le statut `0` quand l’expression donne un nombre non nul. C’est le statut de réussite que `if` utilise. |
| Choisir une branche | `if …; then …; elif …; then …; else …; fi` | Bash exécute la première branche dont la condition réussit. `elif` ajoute un test et `else` couvre le reste. Les deux sont facultatifs. |
| Répéter tant qu’un test réussit | `while …; do …; done` | Bash reteste avant chaque passage. `while IFS= read -r ligne` parcourt des lignes tant que `read` réussit. |
| Parcourir une liste | `for nom in nord sud; do echo "$nom"; done` | La variable reçoit une valeur par tour. `seq 0 2 4` produit `0`, `2`, `4`, un nombre par ligne. |
| Interrompre une boucle | `break` ou `continue` | `break` sort de la boucle. `continue` passe directement au tour suivant. |

Ces constructions fonctionnent dans le terminal et dans un script. Exemple avec une condition sur les droits et une boucle sur les arguments.

```bash
for fichier in "$@"
do
    if [ -f "$fichier" ] && [ -r "$fichier" ]; then
        printf '%s\n' "$fichier"
    fi
done
```

## 19. Chercher des motifs dans le texte

Le shell développe un motif comme `*.c` en noms de fichiers. `grep -E` interprète une **expression régulière étendue** sur le texte. Protège le motif avec des guillemets simples pour le transmettre à `grep`. Par exemple, `grep -E '.*\.c$' liste.txt` retient les lignes qui se terminent par `.c`.

| Écriture | Ce qu’elle reconnaît | Exemple |
|---|---|---|
| `.` et `\.` | Un caractère quelconque et un point littéral. | `ch.t` reconnaît `chat` et `ch@t`. |
| `[abc]`, `[a-z0-9]`, `[^0-9]` | Un caractère de la liste, d’un intervalle ou hors de la liste. | `[[:blank:]]` reconnaît un espace ou une tabulation. |
| `^` et `$` | Le début et la fin de ligne. Ensemble, ils peuvent imposer que la ligne entière corresponde. | `^$` reconnaît une ligne vide. |
| `x*`, `x+`, `x?` | Zéro répétition ou plus, une ou plus, zéro ou une. Le signe porte sur l’élément précédent. | `chats?` reconnaît `chat` ou `chats`. |
| `x{3}`, `x{2,4}` | Exactement trois occurrences, ou de deux à quatre. | `^[0-9]{5}$` reconnaît une ligne de cinq chiffres. |
| <code>(bash&#124;zsh)$</code> | Les parenthèses groupent les éléments. La barre verticale propose deux possibilités. | Ce motif retient une ligne qui finit par `bash` ou `zsh`. |

| Besoin | Commande / écriture | Ce qu’il faut comprendre |
|---|---|---|
| Chercher un mot entier | `grep -w 'chat' texte.txt` | `chat noir` correspond. Dans `chats`, le motif fait partie d’un mot plus long. |
| Extraire le morceau reconnu | `grep -oE '[0-9]+' journal.log` | Affiche chaque correspondance non vide sur sa propre ligne. |
| Chercher dans des dossiers | `grep -r 'main' projet/` | Parcourt le dossier et ses sous-dossiers. |
| Tester la présence sans afficher | `grep -q '^root:' /etc/passwd` | `grep` donne normalement `0` s’il sélectionne une ligne, `1` s’il n’en sélectionne aucune et `2` en cas d’erreur avec GNU `grep`. `-q` permet de s’en servir dans `if`. |

Pour compter les tentatives SSH échouées par adresse, sélectionne les échecs et extrais les adresses. `sort` rassemble les lignes identiques, `uniq -c` compte chaque groupe consécutif et `sort -rn` classe les comptes du plus grand au plus petit.

```bash
grep 'Failed password' auth.log |
    grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' |
    sort | uniq -c | sort -rn
```

Le motif reconnaît la **forme** d’une IPv4. Pour valider une adresse, il faut aussi vérifier que chacun des quatre nombres est compris entre 0 et 255.

## 20. Traiter des lignes avec awk et sed

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre |
|---|---|---|
| Lire des champs avec `awk` | `awk -F: '{ print $1, $7 }' /etc/passwd` | `awk` lit une ligne à la fois. `$0` est la ligne entière et `$1` son premier champ. Par défaut, les suites de blancs séparent les champs. `-F:` choisit les deux-points. `print a, b` sépare les valeurs, `print a b` les colle. |
| Choisir les lignes à traiter | `awk -F: '$3 >= 1000 { print $1 }' /etc/passwd` | La forme est `motif { action }`. Sans motif, l’action s’applique à toutes les lignes. Sans action, `awk` affiche la ligne retenue. Un motif peut être une condition, `/regex/` sur la ligne, ou `$7 ~ /bash$/` sur un champ. `!~` inverse ce dernier test. |
| Compter et calculer | `awk '/Failed password/ { n++ } END { print n+0 }' auth.log` | Les variables s’utilisent sans `$`. Une variable non initialisée vaut zéro en calcul et une chaîne vide en texte. `NR` donne le numéro de ligne et `NF` le nombre de champs. `$NF` désigne le dernier champ. |
| Agir au début ou à la fin | `BEGIN { … }` et `END { … }` | Ces actions ont lieu avant la lecture et après la dernière ligne. Pour une moyenne, accumule avec `s += $2`, puis divise par `NR` dans `END` si `NR > 0`. `printf` permet de choisir un format comme `%.1f`. Ajoute `\n` pour terminer la ligne. |
| Remplacer avec `sed` | `sed -E 's/[0-9]+/X/g' journal.log` | `s` substitue le motif par le texte indiqué. `g` traite toutes les correspondances de chaque ligne. Sans `g`, seule la première est remplacée. Le résultat s’affiche sur la sortie standard. |

## 21. Écrire une commande en C et observer ses fichiers ouverts

### Entrées, sorties et statut

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre |
|---|---|---|
| Compiler puis lancer | `gcc -Wall -Wextra -o outil outil.c`, puis `./outil` | `-o` choisit le nom du programme compilé. Les deux autres options activent des avertissements. |
| Recevoir les arguments | `int main(int argc, char *argv[])` | `argv[0]` contient normalement le nom d’appel. `argv[1]` correspond à `$1` en Bash. `argc` compte aussi `argv[0]`, contrairement à `$#`. `argv[argc]` vaut `NULL`. Vérifie `argc` avant de lire les arguments. |
| Accéder à l’environnement | `getenv("HOME")`, `setenv`, `environ` | `getenv` et `setenv` se déclarent dans `<stdlib.h>`. `getenv` renvoie `NULL` si le nom est absent. `setenv` change l’environnement du processus. Sous Linux, `environ` et le troisième paramètre possible `envp` de `main` permettent de parcourir des chaînes `NOM=valeur` jusqu’à `NULL`. |
| Lire ou écrire sur les canaux standard | `scanf`, `printf`, `fprintf(stderr, …)` | Avec `<stdio.h>`, `scanf` lit `stdin` (0), `printf` écrit sur `stdout` (1) et `fprintf(stderr, …)` écrit sur le canal 2. Pour une conversion demandée, vérifie que `scanf` retourne `1`. Les redirections du shell peuvent brancher ces canaux sur des fichiers ou des conduites. |
| Renvoyer un statut | `return n;` dans `main`, `exit(n)`, `_exit(n)` | Le shell récupère les huit bits de poids faible. `return 300;` donne `44`. `exit` vide les tampons de la bibliothèque C. `_exit`, déclaré dans `<unistd.h>`, termine sans vider ces tampons. |

### Appels système sur les fichiers

Un **descripteur** est un numéro dans la table des fichiers ouverts du processus. `open` résout le chemin, vérifie les droits et réserve le plus petit numéro libre. Le premier fichier ouvert reçoit souvent `3` car les canaux 0, 1 et 2 sont déjà ouverts.

| Besoin | Appel / écriture | Retour et point à vérifier |
|---|---|---|
| Ouvrir pour lire ou écrire | `open` dans `<fcntl.h>`, avec `O_RDONLY` ou `O_WRONLY` | Retourne un descripteur en cas de succès, `-1` en cas d’erreur. |
| Créer, vider ou ajouter | `O_CREAT`, `O_TRUNC`, `O_APPEND` | Combine les options avec la barre verticale. Avec `O_CREAT`, donne un mode comme `0644` ou une combinaison de constantes comme `S_IRUSR` et `S_IWUSR`. Le masque `umask` peut retirer des droits au fichier créé. En écriture, `O_TRUNC` vide à l’ouverture et `O_APPEND` place chaque écriture à la fin. |
| Lire des octets | `read(fd, tampon, taille)` dans `<unistd.h>` | Retourne le nombre d’octets lus, éventuellement inférieur à la taille demandée. `0` indique la fin de fichier pour une demande de taille positive. `-1` signale une erreur. |
| Écrire des octets | `write(fd, tampon, taille)` dans `<unistd.h>` | Retourne le nombre d’octets écrits. Si le résultat est positif mais inférieur à la taille demandée, poursuis à partir du premier octet restant. `-1` signale une erreur. |
| Déplacer la position courante | `lseek(fd, déplacement, origine)` | Après chaque lecture ou écriture, la position avance du nombre d’octets traités. `lseek` la repositionne dans un fichier adapté. `fseek` fait ce travail sur un flux `FILE *` de la bibliothèque C. |
| Fermer | `close(fd)` dans `<unistd.h>` | Retourne `0` en cas de succès. Le numéro du descripteur peut ensuite être réutilisé. |
| Traiter une erreur | `errno`, `warn`, `err` | Vérifie d’abord le retour prévu par le manuel. Après un échec, `errno` précise la cause, par exemple `ENOENT` pour un chemin introuvable, `EACCES` pour un accès refusé ou `EINVAL` pour un argument invalide. `warn` écrit un diagnostic. `err` écrit le diagnostic puis termine avec le statut indiqué. |

`man 2 read` décrit l’appel système. Consulte le prototype, le rôle des paramètres, la valeur de retour et les causes d’erreur. `man 3 printf` décrit une fonction de bibliothèque. Les fonctions de la bibliothèque C peuvent utiliser des tampons avant d’appeler `read` ou `write`.

Voici un programme qui ouvre `notes.txt` en lecture et compte les octets d’un premier bloc. `sizeof tampon` donne la capacité du tableau. Le retour de `read` indique combien d’octets ont réellement été lus. `err`, déclaré dans `<err.h>`, affiche le diagnostic avec la cause et termine ici avec le statut `2`.

```c
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main(void)
{
    int fd = open("notes.txt", O_RDONLY);
    if (fd == -1)
        err(2, "open notes.txt");

    char tampon[256];
    ssize_t lus = read(fd, tampon, sizeof tampon);
    if (lus == -1)
        err(2, "read notes.txt");

    if (close(fd) == -1)
        err(2, "close notes.txt");
    printf("%zd octets lus\n", lus);
    return 0;
}
```

Enregistre ce code dans `outil.c` et compile-le avec la commande ci-dessus. Avec un `notes.txt` vide, le programme affiche `0 octets lus`. Si le fichier manque, `open` échoue et `err` écrit sur la sortie d’erreur. Le shell donne alors `2` avec `echo "$?"`.

### Observer un programme en cours d’exécution

- **Laisse le programme attendre.** `sleep(n)` en C, dans `<unistd.h>`, attend jusqu’à `n` secondes sans occuper le processeur pendant l’attente.
- **Repère le bon processus.** `ps -ef` permet de chercher son PID. `ls -l /proc/PID/fd` montre ses descripteurs ouverts si tu as les droits. Remplace `PID` par le numéro observé. Dans `ls -l /proc/self/fd`, `self` désigne le processus `ls`. Une cible comme `/dev/pts/1` représente un terminal.
- **Observe le journal.** `tail -f journal.log` affiche les lignes au fur et à mesure. Si le processus s’arrête, les octets déjà transmis au noyau restent lisibles. Des données encore dans un tampon du programme peuvent être perdues.
- **Suis les appels.** `strace -e trace=openat,read,write,close ./outil` montre les appels choisis, leurs arguments et leurs retours. Sur Linux, la bibliothèque peut réaliser `open` avec `openat`. Les premiers appels peuvent venir du chargement des bibliothèques, avant `main`.

## Pour vérifier que tu es prêt

Tu dois pouvoir, sur des noms et des données différents de ceux du TP :

- construire un chemin et expliquer d'où il part ;
- choisir une commande de lecture, de recherche ou de modification ;
- lire des permissions, prévoir une autorisation ou un refus et écrire un `chmod` adapté ;
- expliquer les mots que Bash prépare avant le lancement d'une commande ;
- lire une conduite de gauche à droite et expliquer le résultat de chaque filtre ;
- distinguer le résultat normal, les erreurs, le script et le rapport ;
- expliquer une erreur observée et proposer une correction précise ;
- transmettre des arguments sans perdre leurs espaces, lire un statut et choisir une branche ;
- distinguer un motif de chemin d’une expression régulière et construire un classement à partir d’un journal ;
- expliquer le parcours d’un octet entre un descripteur, un tampon et un fichier, puis interpréter les retours de `open`, `read`, `write` et `close`.
