# Fiche de révision Linux

<div id="fiche-revision"></div>

Cette fiche rassemble les connaissances et les savoir-faire du cours Linux. Choisis un thème dans le sommaire, puis cherche ton besoin dans la première colonne. Les mentions **TP2** signalent les notions nouvelles ou approfondies dans ce TP.

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
| Commande interne ou externe | `type commande` | Une commande interne appartient au shell ; un programme externe est lancé séparément. `cd` doit modifier le dossier du shell courant. | `type cd` ; `type ls` | **TP2** : `type dossier` cherche une commande appelée `dossier`, pas le type de cet objet. |
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

## 4. Créer et manipuler fichiers, dossiers et liens

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Créer un dossier | `mkdir chemin` | Crée un répertoire qui pourra contenir des entrées. | `mkdir travail/enquete` | Le dossier parent `travail` doit déjà exister avec cette forme. |
| Créer un fichier vide | `touch fichier` | Crée le fichier s'il n'existe pas ; sinon met à jour ses dates sans vider son contenu. | `touch notes.txt` | Confondre `touch` et `mkdir`. |
| Fichier caché | Nom commençant par `.` | Caché dans l'affichage habituel de `ls`, mais accessible par son nom. | `touch .progression` puis `ls -a` | « Caché » ne signifie ni chiffré ni protégé. |
| Copier | `cp source destination` | Crée une copie ; conserve la source. | `cp notes.txt notes-secours.txt` | Une destination existante peut être remplacée. |
| Déplacer ou renommer | `mv source destination` | Change le nom ou l'emplacement de l'objet. | `mv brouillon.txt rapport.txt` | Attendre que l'ancien chemin continue de fonctionner. |
| Supprimer un fichier | `rm fichier` | Retire son nom du dossier parent. Relire le chemin avant de valider. | `rm notes-secours.txt` | Compter sur une corbeille automatique ; `rm` n'en utilise pas normalement. |
| Lien symbolique | `ln -s cible lien` | Mémorise un chemin vers une cible, sans recopier son contenu. Une cible relative se résout depuis le dossier du lien. | Depuis `mission` : `ln -s briefing/objectif.txt acces-rapide`. | Renommer ou déplacer la cible peut casser le lien ; le lien reste présent. |
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
| Rechercher des lignes | `grep 'motif' fichier` | Affiche les lignes correspondant au motif, sans modifier la source. | `grep 'ERREUR' journal.log` | Inverser le motif et le fichier ; la casse compte par défaut. |
| Numéroter ou ignorer la casse | `grep -n` ; `grep -i` | `-n` ajoute le numéro de ligne ; `-i` ignore majuscules/minuscules. | `grep -ni 'critique' journal.log` | `-n` ne compte pas les résultats. |
| Exclure des lignes | `grep -v 'motif' fichier` | Garde les lignes qui ne correspondent pas au motif. | `grep -v 'INFO' journal.log` | Penser que les lignes sont supprimées du fichier source. |
| Lire plusieurs fichiers | `grep -h 'motif' fichiers` | Sur plusieurs fichiers, `grep` préfixe normalement les lignes avec leur nom ; `-h` retire ce préfixe. | `grep -h 'CRITIQUE' bruts/*.log` | Conserver le préfixe alors qu'un filtre suivant attend seulement les champs de la ligne. |
| Compter les lignes | `wc -l fichier` | Compte les lignes ; avec plusieurs fichiers, affiche un résultat par fichier puis un total. | `wc -l bruts/*.log` | Confondre le nombre de lignes et le nombre de mots ou d'occurrences d'un motif. |
| Modifier un texte | `nano fichier` ; `Ctrl+S` ; `Ctrl+X` | Ouvre un éditeur ; `Ctrl+S` enregistre ; `Ctrl+X` quitte. Confirme le nom du fichier si demandé. | `nano rapport.txt` puis `cat rapport.txt`. | Quitter sans avoir enregistré les modifications. |
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

## 9. TP2 — Comprendre les transformations de Bash

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Chercher plusieurs noms | `*` | Bash remplace le motif par les chemins existants correspondants avant de lancer la commande. | `echo bruts/*.log` affiche les chemins trouvés. | C'est Bash qui cherche les noms, pas `echo` ; cela ne cherche pas dans le contenu. |
| Protéger une étoile | `"*.log"` ou `'*.log'` | Les guillemets empêchent le développement de l'étoile par Bash. | `echo "bruts/*.log"` affiche ce texte tel quel. | Mettre des guillemets autour d'un motif alors qu'on voulait fournir plusieurs fichiers à la commande. |
| Garder tout comme texte | Guillemets simples : `'...'` | Protègent le texte, notamment `$`, `*` et `$(...)`. | `echo 'Heure : $(date +%H:%M)'` affiche l'expression. | Attendre une heure alors que la substitution est protégée. |
| Conserver un texte groupé avec des substitutions | Guillemets doubles : `"..."` | Gardent le texte en un argument ; permettent notamment `$(...)`, mais protègent `*`. | `echo "Heure : $(date +%H:%M)"` affiche l'heure. | Croire que guillemets simples et doubles produisent toujours le même effet. |
| Réutiliser le résultat d'une commande | `$(commande)` | Exécute la commande et insère sa sortie dans la ligne en préparation. | `echo "Date : $(date +%F)"` | Confondre cette insertion avec un fichier créé par la commande. |
| Produire plusieurs mots | `{mot1,mot2}` | Les accolades développent un modèle en plusieurs mots, même si ces fichiers n'existent pas. | `touch rapport-{matin,soir}.txt` crée deux fichiers. | Confondre accolades et étoile : `*` sélectionne des noms existants. |

## 10. Relier les commandes et diriger leurs flux

| Besoin ou notion | Commande / écriture | Ce qu’il faut comprendre | Exemple | Piège fréquent |
|---|---|---|---|---|
| Afficher du texte | `echo "texte"` | Écrit ses arguments sur la sortie normale. | `echo "Bonjour"` | Supposer que `echo` crée automatiquement un fichier. |
| Écrire ou remplacer | `commande > fichier` | Branche la sortie normale vers un fichier, créé ou vidé avant l'exécution. | `echo "Bonjour" > notes.txt` | Le contenu précédent est perdu, même si la commande ne produit ensuite rien. |
| Ajouter | `commande >> fichier` | Conserve le contenu et ajoute à la fin ; crée le fichier s'il n'existe pas. | `echo "Suite" >> notes.txt` | Relancer une analyse avec `>>` peut dupliquer tous les résultats. |
| Fournir une entrée | `commande < fichier` | Le shell ouvre le fichier et fournit son contenu sur l'entrée standard. | `wc -l < journal.log` affiche le compte sans le nom du fichier. | Confondre le contenu fourni en entrée et un nom de fichier donné comme argument. |
| Trois canaux standards | `0` entrée ; `1` sortie normale ; `2` erreurs | Une commande peut produire un résultat et des messages d'erreur sur deux canaux différents. | `ls dossier-existant dossier-absent` produit les deux types de sortie. | Tout ce qui apparaît dans le terminal n'appartient pas au résultat normal. |
| Conserver les erreurs séparément | `2>` | Redirige le canal d'erreur, indépendamment de `>`. | `ls bruts absent > liste.txt 2> erreurs.txt` | Penser que `> liste.txt` capture aussi les erreurs. |
| Réunir les deux sorties | `> fichier 2>&1` | `2>&1` dirige les erreurs vers la destination déjà utilisée par la sortie normale. | `ls bruts absent > controle.txt 2>&1` | L'ordre compte : `2>&1 > controle.txt` ne branche pas les canaux de la même manière. |
| Construire une conduite | <code>commande1 &#124; commande2</code> | <code>&#124;</code> relie la sortie normale de gauche à l'entrée standard de droite, sans fichier intermédiaire. | <code>grep 'ERREUR' journal.log &#124; wc -l</code> compte les lignes sélectionnées. | Les erreurs ne passent pas automatiquement dans le tube ; <code>&#124;</code> ne crée pas un fichier. |
| Conserver une conduite | <code>commande1 &#124; commande2 &gt; fichier</code> | La redirection finale enregistre le résultat de la dernière étape. | <code>grep 'ERREUR' journal.log &#124; sort &gt; erreurs-triees.txt</code> | Lire et écrire le même fichier dans une conduite peut vider la source avant sa lecture. |

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

## Pour vérifier que tu es prêt

Tu dois pouvoir, sur des noms et des données différents de ceux du TP :

- construire un chemin et expliquer d'où il part ;
- choisir une commande de lecture, de recherche ou de modification ;
- lire des permissions, prévoir une autorisation ou un refus et écrire un `chmod` adapté ;
- expliquer les mots que Bash prépare avant le lancement d'une commande ;
- lire une conduite de gauche à droite et expliquer le résultat de chaque filtre ;
- distinguer le résultat normal, les erreurs, le script et le rapport ;
- expliquer une erreur observée et proposer une correction précise.
