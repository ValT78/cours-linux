# TP 1.5 — Reprendre le contrôle du terminal

## Mission — Retrouver le code de la station Nadir

La station scientifique Nadir a transmis plusieurs milliers de lignes de journaux, des documents techniques et une arborescence entière d'archives. Un code en cinq fragments y est caché.

Tu vas fouiller ces fichiers depuis le terminal, retrouver le code et préparer un court compte rendu. Le TP est prévu pour trois heures. S'il reste des étapes, tu les reprendras à la séance suivante.

!!! warning "Périmètre sûr"
    Toutes les modifications doivent rester dans `~/base-exploration/tp1-5`. N'utilise pas `sudo` et ne change jamais les droits d'un fichier système.

## Récupérer les fichiers du TP

- [Terrain de jeu — Station Nadir](../assets/tp1-5-station-nadir.zip)
- [Laboratoire des permissions](../assets/tp1-5-atelier-permissions.zip)
- [Modèle de notes à compléter](../assets/tp1-5-modele-notes.txt)

Ouvre ton terminal WSL ou celui de ta machine virtuelle, puis prépare le dossier du TP :

```bash
cd ~/base-exploration
mkdir tp1-5
cd tp1-5
```

Récupère ensuite les trois fichiers :

```bash
wget https://valt78.github.io/cours-linux/assets/tp1-5-station-nadir.zip
wget https://valt78.github.io/cours-linux/assets/tp1-5-atelier-permissions.zip
wget https://valt78.github.io/cours-linux/assets/tp1-5-modele-notes.txt
```

`wget` télécharge le fichier indiqué par une adresse web et l'enregistre dans le dossier courant. Vérifie que tout est bien arrivé :

```bash
ls
```

Garde `tp1-5-modele-notes.txt` ouvert pendant le TP. Les encadrés `À noter — N01`, `N02`… indiquent les réponses à écrire dans ce fichier. Quand on te demande de prévoir un résultat, réponds avant de lancer la commande, puis ajoute ce que tu as vraiment observé.

À la fin de la séance, dépose le fichier complété sur Moodle.

---

## Niveau 0 — Installer le terrain de jeu

Tu dois être dans `~/base-exploration/tp1-5`. Vérifie-le, puis décompresse la première archive :

```bash
pwd
unzip tp1-5-station-nadir.zip
```

Vérifie le résultat :

```bash
ls
cd station-nadir
pwd
ls
cat 00-LIRE-MOI.txt
```

!!! question "À noter — N01 · Diagnostic de départ"
    Avant de poursuivre, relis les questions suivantes et choisis celle sur laquelle tu étais le moins sûr : que représentent `/`, `~`, `.` et `..` ? Quelle différence entre `ls` et `ls /` ? Quelle différence entre `mkdir` et `touch` ? Écris ta réponse actuelle. Tu la corrigeras si nécessaire pendant le TP.

---

## Niveau 1 — Retrouver ses repères

### 1.1 Observer avant de se déplacer

Quand tu changes de dossier, prends ce réflexe :

```text
avant : pwd puis ls
action : cd vers la destination
après  : pwd puis ls
```

`pwd` te dit où tu es et `ls` montre ce qui se trouve autour de toi. Ces deux commandes évitent beaucoup d'erreurs de chemin.

Observe ton emplacement actuel :

```bash
pwd
ls
ls /
```

!!! tip "À noter — N02 · Avant et après le test"
    Avant d'exécuter `ls` et `ls /`, note ce que chacune devrait afficher. Lance-les, puis complète ta réponse : « La différence vient du fait que… »

Rappel compact :

| Écriture | Point de départ ou signification |
|---|---|
| `/` | racine de toute l'arborescence |
| `~` | dossier personnel, développé par le shell |
| `.` | dossier courant |
| `..` | dossier parent |
| chemin commençant par `/` | chemin absolu |
| autre chemin | chemin relatif au dossier courant |

### 1.2 Un même fichier, plusieurs itinéraires

Depuis la racine de `station-nadir`, les trois commandes suivantes désignent le même fichier :

```bash
cat 00-LIRE-MOI.txt
cat ./00-LIRE-MOI.txt
cat navigation/../00-LIRE-MOI.txt
```

Dans la troisième commande, le chemin passe par `navigation`, puis `..` ramène dans le dossier parent avant d'atteindre le fichier.

### 1.3 Revenir dans son dossier personnel

Tu veux maintenant revenir directement dans ton dossier personnel. Essaie :

```bash
cd /~
```

Lis le message du terminal. Dans `/~`, le premier `/` signifie « pars de la racine ». Linux cherche donc un vrai dossier nommé `~` à cet endroit. Pour revenir dans ton dossier personnel, `~` doit être placé au début du chemin.

!!! question "À noter — N03 · Le chemin `/~`"
    Recopie le message utile, explique pourquoi `/~` ne désigne pas ton dossier personnel, puis écris la commande qui permet vraiment d'y revenir.

### 1.4 Deux chemins vers la même destination

Reviens à la racine de `station-nadir`, puis retrouve les chemins demandés :

1. place-toi dans `navigation/secteur-beta` avec un chemin relatif ;
2. affiche `carte.txt` ;
3. remonte jusqu'à la racine de `station-nadir` uniquement avec `..` ;
4. note le chemin affiché par `pwd` ;
5. va dans `/tmp`, puis reviens à `station-nadir` avec un chemin absolu commençant par `/`.

!!! question "À noter — N04 · Deux chemins vers la même cible"
    Note le chemin relatif et le chemin absolu que tu as utilisés pour atteindre la station. Explique pourquoi l'un dépend du dossier courant alors que l'autre fonctionne depuis `/tmp`.

---

## Niveau 2 — Ne plus tout retaper

Dans Bash, tu peux corriger la commande en cours comme une petite ligne de texte. Tu peux aussi rappeler une ancienne commande au lieu de la retaper.

Affiche d'abord l'historique récent :

```bash
history 10
```

`history` affiche les commandes déjà validées. Les flèches et `Ctrl+R` permettent de les retrouver rapidement.

### 2.1 Rappeler et corriger une commande

Reviens dans la station puis exécute cette commande :

```bash
cd ~/base-exploration/tp1-5/station-nadir
ls -la navigation/secteur-alpha navigation/secteur-beta navigation/secteur-gamma
```

Teste ensuite ces gestes sans utiliser la souris :

| Geste | Effet habituel |
|---|---|
| `↑` et `↓` | parcourir l'historique |
| `Tab` | compléter un nom ou proposer des possibilités |
| `Ctrl+A` | aller au début de la ligne |
| `Ctrl+E` | aller à la fin de la ligne |
| `Ctrl+←` / `Ctrl+→` | se déplacer d'un mot ; selon le terminal, utiliser `Alt+B` / `Alt+F` |
| `Ctrl+W` | supprimer le mot précédent |
| `Ctrl+R` | rechercher une ancienne commande |
| `Ctrl+C` | abandonner la ligne en cours ou interrompre la commande au premier plan |

![Les principaux raccourcis pour compléter, rappeler, parcourir, corriger ou interrompre une ligne de commande.](../assets/tp15-raccourcis-terminal.svg)

Avec `↑`, rappelle la commande précédente. Remplace seulement `-la` par `-ld`, puis exécute-la. Observe que `-d` demande des informations sur les dossiers eux-mêmes plutôt que sur leur contenu.

### 2.2 Réutiliser une commande

Pars de l'historique au lieu de tout retaper :

1. rappelle la commande qui affichait les trois secteurs ;
2. transforme-la pour ne consulter que `secteur-beta` ;
3. rappelle-la encore et remplace `beta` par `gamma` ;
4. retrouve ensuite avec `Ctrl+R` la première commande contenant `00-LIRE` ;
5. annule la commande retrouvée avec `Ctrl+C` au lieu de l'exécuter.

!!! question "À noter — N05 · Raccourcis utiles"
    Quels sont les deux raccourcis qui t'ont évité le plus de saisie ? Décris un cas concret où chacun t'a aidé.

### 2.3 La première pièce cachée

Observe le dossier de navigation :

```bash
ls navigation
ls -a navigation
```

Une entrée supplémentaire apparaît avec `-a`. Entre dans cette entrée, lis le fichier qu'elle contient et reviens à la racine de la station.

!!! question "À noter — N06 · Entrée cachée"
    Note le nom de l'entrée, la raison pour laquelle le premier `ls` ne l'affichait pas et le premier fragment du code découvert.

---

## Niveau 3 — Créer, lire et modifier

Les archives originales restent intactes. Tous tes essais vont dans `station-nadir/travail`.

### 3.1 Fichier et dossier ne sont pas interchangeables

```bash
cd ~/base-exploration/tp1-5/station-nadir
mkdir travail/enquete
touch travail/enquete/observations.txt
ls -ld travail/enquete
ls -l travail/enquete/observations.txt
```

Le premier caractère de la description longue indique le type :

```text
d...  répertoire
-...  fichier ordinaire
l...  lien symbolique
```

!!! question "À noter — N07 · Fichier ou dossier"
    Explique avec tes mots la différence entre `mkdir` et `touch`. Quelle observation te permet de vérifier le type de l'objet créé ?

### 3.2 Écrire puis ajouter

```bash
echo "Enquete ouverte" > travail/enquete/observations.txt
echo "Station : Nadir" >> travail/enquete/observations.txt
cat travail/enquete/observations.txt
```

!!! tip "À noter — N08 · Avant et après le test"
    Sans exécuter de commande supplémentaire, note le contenu que tu penses obtenir après ces deux lignes :

```bash
echo "ancienne hypothese" > travail/enquete/test.txt
echo "nouvelle hypothese" > travail/enquete/test.txt
```

Lance-les après avoir répondu. Vérifie ensuite avec `cat` et explique la différence entre `>` et `>>`.

### 3.3 Copier, déplacer, supprimer dans la zone de travail

```bash
cp rapports/brouillon.txt travail/enquete/rapport-copie.txt
mv travail/enquete/rapport-copie.txt travail/enquete/rapport-final.txt
ls travail/enquete
```

Crée maintenant :

- une copie de `observations.txt` nommée `observations-secours.txt` ;
- un fichier caché `.progression` ;
- un dossier `travail/enquete/indices-valides` ;
- puis supprime uniquement la copie de secours avec `rm`.

Vérifie chaque étape. Avant `rm`, relis toujours le chemin ciblé.

### 3.4 Écrire dans `enquete`

Le dossier `travail/enquete` existe déjà. Essaie d'y écrire directement :

```bash
echo "test" > travail/enquete
```

Le terminal refuse la commande : `>` doit envoyer le texte vers un fichier, pas vers un dossier. Il faut donc ajouter un nom de fichier après `travail/enquete/`.

!!! question "À noter — N09 · Rediriger vers un dossier"
    Recopie le message d'erreur, identifie l'objet qui est un dossier et propose une correction qui écrit `test` dans un nouveau fichier placé à l'intérieur de ce dossier.

---

## Niveau 4 — Voir précisément avec `ls`

`ls` peut donner beaucoup plus d'informations qu'une simple liste de noms. Compare :

```bash
ls transmissions
ls -l transmissions
ls -lh transmissions
ls -la navigation
ls -lt transmissions
ls -R navigation
```

| Option | Information ajoutée ou comportement |
|---|---|
| `-l` | format détaillé : type, droits, propriétaire, groupe, taille, date |
| `-a` | inclut les noms commençant par `.` |
| `-h` | tailles plus lisibles, en complément de `-l` |
| `-t` | tri par date de modification |
| `-R` | parcourt récursivement les sous-dossiers |
| `-d` | décrit le dossier lui-même au lieu de l'ouvrir avec `ls` |

Les options courtes peuvent être réunies : `ls -lah` équivaut ici à `ls -l -a -h`.

### À toi de choisir les options

Choisis toi-même les options nécessaires pour répondre à ces questions :

1. quels sont les fichiers cachés sous `navigation` ?
2. quel journal de `transmissions` occupe le plus d'espace ?
3. quels sont les droits du dossier `travail` lui-même ?
4. quels fichiers se trouvent dans tous les sous-dossiers de `inventaire` ?

!!! question "À noter — N10 · Choisir les options"
    Pour deux des questions précédentes, note la commande construite et explique pourquoi ses options sont adaptées. Ne réponds pas seulement par le nom de l'option.

---

## Niveau 5 — Lire sans se noyer dans le texte

La station contient plusieurs milliers de lignes. `cat` reste utile pour un petit fichier, mais il devient peu pratique pour un journal volumineux.

![Les outils ne répondent pas à la même question : `cat` affiche tout, `head` et `tail` montrent les extrémités, `less` parcourt, `grep` sélectionne et `nano` modifie.](../assets/tp15-outils-lecture.svg)

### 5.1 Lire avec `less`

```bash
less documentation/manuel-station.txt
```

Dans `less` :

| Touche | Action |
|---|---|
| `Espace` | avancer d'un écran |
| `b` | reculer d'un écran |
| `/mot` | chercher vers le bas |
| `n` / `N` | résultat suivant / précédent |
| `g` / `G` | début / fin du fichier |
| `q` | quitter |

Cherche le mot `navigation`, passe au résultat suivant, puis quitte sans modifier le fichier.

!!! question "À noter — N11 · Choisir `cat`, `less` ou `nano`"
    Quel outil choisirais-tu pour lire un fichier de 700 lignes sans le modifier ? Lequel choisirais-tu pour le modifier ? Explique la différence d'usage, pas seulement le nom des commandes.

### 5.2 Voir seulement le début ou la fin

```bash
head -n 5 transmissions/radio-2026-09-15.log
tail -n 5 transmissions/radio-2026-09-16.log
```

!!! tip "À noter — N12 · Avant et après le test"
    Avant de lancer les commandes, note ce que signifie `-n 5` et quelle partie du fichier chacune devrait afficher. Après le test, ajoute les deux fragments découverts au début et à la fin des journaux.

### 5.3 Demander cinq lignes

Tu veux afficher les cinq premières lignes du journal. Essaie :

```bash
head 5 transmissions/radio-2026-09-15.log
```

Le message parle d'un fichier nommé `5`. Sans `-n`, `head` comprend que `5` est un nom de fichier supplémentaire. Retrouve la bonne forme avec l'aide :

```bash
head --help
```

---

## Niveau 6 — Chercher une aiguille avec `grep`

### 6.1 Chercher dans un journal

Le journal du 14 septembre contient presque mille lignes. Inutile de tout lire : cherche directement l'anomalie importante.

```bash
grep 'ANOMALIE-ROUGE' transmissions/radio-2026-09-14.log
grep -n 'ANOMALIE-ROUGE' transmissions/radio-2026-09-14.log
```

L'option `-n` ajoute le numéro de ligne. `grep` ne change pas le fichier : il affiche seulement les lignes qui correspondent au motif.

Une recherche peut ignorer la différence entre majuscules et minuscules :

```bash
grep -i 'anomalie-rouge' transmissions/radio-2026-09-14.log
```

!!! question "À noter — N13 · Recherche avec `grep`"
    Quel secteur est associé à l'anomalie ? À quoi sert `-n` ? Explique pourquoi `grep` est plus adapté que `cat` pour cette recherche.

### 6.2 Retrouver l'ordre des arguments

Tu veux maintenant chercher la même anomalie en écrivant le fichier avant le motif :

```bash
grep transmissions/radio-2026-09-14.log ANOMALIE-ROUGE
```

Observe le message, puis compare avec la forme attendue :

```text
grep [options] 'motif recherché' fichier
```

!!! question "À noter — N14 · Comprendre l'ordre de `grep`"
    Quel argument est pris pour le motif ? Quel argument est pris pour un nom de fichier ? Note le message observé puis écris la commande qui fonctionne.

### 6.3 Retrouver le protocole

À toi de faire les recherches suivantes :

1. cherche le mot `archive` sans tenir compte de la casse dans le journal du 15 septembre ;
2. affiche avec leur numéro toutes les lignes contenant `AVERTISSEMENT` dans ce même journal ;
3. utilise `less` et sa recherche `/` pour retrouver `PROTOCOLE-ORION` dans le manuel ;
4. note le fragment de protocole découvert.

---

## Niveau 7 — Modifier proprement avec `nano`

`nano` est un éditeur de texte dans le terminal. Contrairement à `less`, il peut modifier le fichier ouvert.

```bash
nano travail/enquete/rapport-final.txt
```

Les raccourcis apparaissent en bas de l'écran. Le symbole `^` signifie `Ctrl` :

| Affichage dans nano | Touches | Action |
|---|---|---|
| `^O` | `Ctrl+O` | enregistrer ; confirmer ensuite le nom avec Entrée |
| `^X` | `Ctrl+X` | quitter |
| `^W` | `Ctrl+W` | rechercher dans le fichier |
| `^K` | `Ctrl+K` | couper la ligne courante |
| `^U` | `Ctrl+U` | recoller la ligne coupée |

Ajoute dans le rapport :

- ton nom ;
- les fragments déjà découverts ;
- l'outil utilisé pour chacun ;
- une erreur utile rencontrée.

Enregistre, quitte, puis vérifie avec un outil de lecture :

```bash
cat travail/enquete/rapport-final.txt
```

### Reprendre le rapport

Rouvre le rapport sans recopier la commande : utilise l'historique. Recherche le mot `Code`, déplace la ligne correspondante en haut du fichier avec les raccourcis de `nano`, puis enregistre à nouveau.

!!! question "À noter — N15 · Modifier avec `nano`"
    Note la modification effectuée et les raccourcis utilisés pour enregistrer et quitter. Pourquoi vérifier ensuite avec `cat` ou `less` reste-t-il utile ?

---

## Niveau 8 — Qui possède quoi ?

Décompresse maintenant le second terrain de jeu à côté de la station :

```bash
cd ~/base-exploration/tp1-5
unzip tp1-5-atelier-permissions.zip
cd atelier-permissions
pwd
ls
cat 00-LIRE-MOI.txt
```

### 8.1 Identité Unix

```bash
whoami
id
id -un
id -gn
```

`whoami` affiche le nom de l'utilisateur courant. `id` détaille l'UID, le GID et les groupes. `id -un` redonne le nom d'utilisateur ; `id -gn` donne le nom du groupe principal.

!!! question "À noter — N16 · Identité Unix"
    Note ton utilisateur et ton groupe principal. Explique pourquoi l'UID affiché par `id` n'est pas « l'identifiant du PC ».

### 8.2 Lire une ligne de droits

```bash
ls -l documents/rapport-public.txt
ls -l equipe/partage-equipe.txt
ls -l scripts/diagnostic.sh
```

Une ligne comme celle-ci se découpe ainsi :

```text
- rw- r-- r--
│  │   │   └── autres utilisateurs (o)
│  │   └────── groupe (g)
│  └────────── propriétaire / user (u)
└───────────── type : - fichier, d dossier, l lien
```

Pour un fichier :

| Droit | Effet |
|---|---|
| `r` | lire le contenu |
| `w` | modifier le contenu |
| `x` | demander son exécution comme programme |

---

## Niveau 9 — Modifier les droits avec des lettres

### 9.1 Retirer un droit, puis le remettre

Observe avant de modifier :

```bash
ls -l documents/rapport-public.txt
chmod u-w documents/rapport-public.txt
ls -l documents/rapport-public.txt
```

!!! tip "À noter — N17 · Avant et après le test"
    Avant les deux prochaines commandes, note séparément si tu penses que la lecture et l'écriture vont fonctionner. Ajoute ensuite les résultats obtenus.

```bash
cat documents/rapport-public.txt
echo "nouvelle ligne" >> documents/rapport-public.txt
```

Restaure ensuite le droit d'écriture :

```bash
chmod u+w documents/rapport-public.txt
```

Dans `u-w`, `u` choisit le propriétaire, `-` retire et `w` désigne l'écriture. Avec `u+w`, le même droit est ajouté.

### 9.2 Les droits ne s'additionnent pas entre catégories

Le fichier suivant t'appartient. Donne la lecture au groupe, mais aucun droit au propriétaire ni aux autres :

```bash
chmod u=,g=r,o= laboratoire/groupe-seul.txt
ls -l laboratoire/groupe-seul.txt
```

!!! tip "À noter — N18 · Avant et après le test"
    Tu es propriétaire du fichier et tu appartiens probablement aussi à son groupe. Note si tu penses que `cat` pourra le lire, puis vérifie.

```bash
cat laboratoire/groupe-seul.txt
```

Linux choisit une seule catégorie : si l'utilisateur courant est le propriétaire, les droits `u` s'appliquent. Il ne récupère pas ensuite les droits `g` pour compléter ceux qui manquent.

Restaure un mode utilisable :

```bash
chmod u=rw,g=r,o= laboratoire/groupe-seul.txt
cat laboratoire/groupe-seul.txt
```

### 9.3 Régler les droits du groupe

Règle `equipe/partage-equipe.txt` pour obtenir :

- propriétaire : lecture et écriture ;
- groupe : lecture seulement ;
- autres : aucun droit.

Vérifie avec `ls -l`.

!!! question "À noter — N19 · Forme symbolique"
    Note la commande utilisée et explique chaque partie de l'expression `u=...,g=...,o=...`.

---

## Niveau 10 — Écrire les droits avec des nombres

Chaque droit possède une valeur :

```text
r = 4     w = 2     x = 1
```

Les valeurs s'ajoutent pour chaque catégorie :

| Valeur | Calcul | Droits |
|---:|---:|---|
| `7` | 4 + 2 + 1 | `rwx` |
| `6` | 4 + 2 | `rw-` |
| `5` | 4 + 1 | `r-x` |
| `4` | 4 | `r--` |
| `0` | 0 | `---` |

Ainsi :

```text
640 = rw- r-- ---
750 = rwx r-x ---
755 = rwx r-x r-x
```

![Le mode `640` est obtenu en calculant séparément les droits du propriétaire, du groupe et des autres avec les valeurs 4, 2 et 1.](../assets/tp15-droits-octal.svg)

### 10.1 Lire le mode `640`

```bash
chmod 640 documents/rapport-public.txt
ls -l documents/rapport-public.txt
```

Le premier chiffre concerne `u`, le deuxième `g`, le troisième `o`.

### 10.2 Tester le mode `758`

Applique maintenant ce mode :

```bash
chmod 758 documents/rapport-public.txt
```

Lis le message obtenu. Chaque chiffre regroupe les droits `r`, `w` et `x` d'une catégorie. Il doit rester compris entre `0` et `7` : le chiffre `8` ne correspond à aucune combinaison possible.

### 10.3 Régler les quatre fichiers

Applique les objectifs contenus dans `00-LIRE-MOI.txt` :

| Cible | Mode attendu |
|---|---:|
| `documents/rapport-public.txt` | `644` |
| `equipe/partage-equipe.txt` | `640` |
| `scripts/diagnostic.sh` | `750` |
| `coffre/secret.txt` | `600` |

Vérifie les quatre lignes avec `ls -l`. Puis lance le script :

```bash
./scripts/diagnostic.sh
```

!!! question "À noter — N20 · Formes symbolique et numérique"
    Choisis l'un des quatre fichiers. Note son mode numérique, son écriture `rwx` et une forme symbolique de `chmod` qui produirait le même résultat. Détaille le calcul.

---

## Niveau 11 — Les mêmes lettres, un autre sens pour un dossier

Pour un répertoire :

| Droit | Effet principal |
|---|---|
| `r` | lire la liste des noms |
| `w` | ajouter, supprimer ou renommer des entrées, généralement avec `x` |
| `x` | traverser le répertoire dans un chemin et accéder aux entrées connues |

Observe le laboratoire :

```bash
ls -ld laboratoire/depot
ls -l laboratoire/depot
chmod u-w laboratoire/depot
```

!!! tip "À noter — N21 · Avant et après le test"
    Avant d'exécuter les commandes suivantes, note lesquelles devraient modifier la liste des noms contenue dans `depot`.

```bash
touch laboratoire/depot/nouveau.txt
rm laboratoire/depot/temoin.txt
cat laboratoire/depot/temoin.txt
```

La création et la suppression devraient être refusées : elles changent les entrées du répertoire. La lecture du fichier existant peut encore fonctionner, car son contenu et son nom existent toujours.

Restaure immédiatement le dossier :

```bash
chmod u+w laboratoire/depot
```

Refais ensuite l'expérience dans un nouveau dossier jetable nommé `laboratoire/depot-2`. Crée d'abord un témoin, retire l'écriture au dossier, teste une création et une suppression, puis restaure le droit.

!!! question "À noter — complément N21"
    Compare tes réponses aux résultats. Pourquoi retirer `w` à un dossier n'a-t-il pas le même effet que retirer `w` à un fichier ?

---

## Boss final — Reconstituer la transmission

Il reste à reconstruire le code de la station et à terminer le rapport.

### Les cinq fragments

Dans cet ordre, retrouve :

1. **station** — dans une entrée cachée de `navigation` ;
2. **entête** — sur la première ligne du journal du 15 septembre ;
3. **secteur** — sur la ligne `ANOMALIE-ROUGE` du journal du 14 septembre ;
4. **numéro** — sur la dernière ligne du journal du 16 septembre ;
5. **protocole** — près de `PROTOCOLE-ORION` dans le manuel.

Pour chaque fragment, choisis l'outil le plus pratique parmi les options de `ls`, `head`, `tail`, `grep` et la recherche dans `less`.

Assemble les fragments avec des tirets puis complète `station-nadir/travail/enquete/rapport-final.txt` dans `nano`.

Le rapport doit contenir :

- le code final ;
- l'outil utilisé pour chaque fragment ;
- une commande qui a échoué ;
- l'explication de cette erreur ;
- la correction appliquée ;
- les modes finaux des quatre fichiers de l'atelier des permissions.

### Autovérification

```text
□ Le code comporte cinq fragments dans le bon ordre.
□ Le rapport a été modifié avec nano puis relu avec cat ou less.
□ Les archives originales n'ont pas été supprimées.
□ Le script diagnostic.sh s'exécute.
□ secret.txt possède le mode 600.
□ Aucun dossier du laboratoire n'est resté verrouillé.
```

!!! question "À noter — N22 · Bilan final"
    Note le code obtenu, puis trois réflexes à appliquer lorsqu'une commande échoue. Termine par une erreur qui t'a réellement appris quelque chose, une notion encore incertaine et ta confiance avant/après le TP sur une échelle de 1 à 4.

---

## Ce que tu as consolidé

Tu sais maintenant :

- distinguer `/`, `~`, `.`, `..`, chemin absolu et chemin relatif ;
- observer avant et après un déplacement ;
- utiliser l'historique, la complétion et les raccourcis d'édition ;
- distinguer, créer, lire, copier, déplacer et modifier fichiers et dossiers ;
- choisir des options adaptées de `ls` ;
- lire un gros fichier avec `less`, son début avec `head` et sa fin avec `tail` ;
- rechercher une information avec `grep` ;
- modifier un fichier avec `nano` ;
- lire et transformer les droits `u`, `g`, `o` sous forme symbolique ou numérique ;
- expliquer pourquoi `r`, `w` et `x` ne signifient pas exactement la même chose sur un fichier et sur un dossier ;
- analyser une erreur à partir de la commande, du contexte et du message reçu.
