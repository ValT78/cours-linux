# TP 1.5 — Reprendre le contrôle du terminal

## Mission — Retrouver le code de la station Nadir

La station scientifique Nadir a transmis plusieurs milliers de lignes de journaux, des documents techniques et une arborescence entière d'archives. Un code en cinq fragments y est caché.

Cette fois, les commandes ne seront pas toutes données. Pour chaque notion, tu rencontreras généralement :

1. une première situation guidée ;
2. une situation voisine à résoudre avec moins d'aide ;
3. parfois une commande volontairement fausse à diagnostiquer.

Les erreurs font partie de l'enquête. Une erreur utile n'est pas seulement une commande qui échoue : c'est une commande dont tu arrives à expliquer **ce que le shell a compris**, **pourquoi le résultat diffère de ton attente** et **quelle correction minimale suffit**.

Le TP est prévu pour une séance de trois heures. S'il reste des étapes, l'enquête pourra se poursuivre à la séance suivante.

!!! warning "Périmètre sûr"
    Toutes les modifications doivent rester dans `~/base-exploration/tp1-5`. N'utilise pas `sudo` et ne change jamais les droits d'un fichier système.

## Téléchargements

- [Terrain de jeu — Station Nadir](../assets/tp1-5-station-nadir.zip)
- [Laboratoire des permissions](../assets/tp1-5-atelier-permissions.zip)
- [Modèle de notes à compléter](../assets/tp1-5-modele-notes.txt)

Télécharge les deux archives et le modèle de notes. Garde le fichier de notes ouvert dans l'application de ton choix, puis dépose-le sur Moodle à la fin de l'enquête.

## Comment reconnaître ce qu'il faut noter ?

Trois repères rythment le TP :

!!! question "📝 Notes — réponse à conserver"
    Une question numérotée `N01`, `N02`… doit être traitée dans le fichier de notes.

!!! tip "🔮 Prédire puis analyser"
    Écris d'abord ta prédiction. Ne l'efface pas si elle est fausse : ajoute ensuite ton observation et ton explication.

!!! danger "🧩 Débogage"
    La commande proposée est volontairement incorrecte ou incomplète. Lis son message, formule une hypothèse, puis corrige-la avec le moins de changements possible.

---

## Niveau 0 — Installer le terrain de jeu

Commence par retrouver le dossier où ton navigateur a enregistré les archives :

```bash
ls ~
```

Le dossier peut s'appeler `Téléchargements` ou `Downloads`. Utilise la touche **Tab** après avoir saisi les premières lettres du nom : le shell peut compléter le chemin à ta place.

Prépare ensuite le dossier du TP :

```bash
cd ~/base-exploration
mkdir tp1-5
cd tp1-5
pwd
```

Décompresse la première archive. Adapte son chemin au nom observé sur ta machine et utilise Tab plutôt que de tout recopier :

```bash
unzip ~/Téléchargements/tp1-5-station-nadir.zip
```

Si ton dossier s'appelle `Downloads`, la commande commencera naturellement par `unzip ~/Downloads/`.

Vérifie le résultat :

```bash
ls
cd station-nadir
pwd
ls
cat 00-LIRE-MOI.txt
```

!!! question "📝 Notes — N01 · Diagnostic de départ"
    Avant de poursuivre, relis les questions suivantes et choisis celle sur laquelle tu étais le moins sûr : que représentent `/`, `~`, `.` et `..` ? Quelle différence entre `ls` et `ls /` ? Quelle différence entre `mkdir` et `touch` ? Écris ta réponse actuelle. Tu la corrigeras si nécessaire pendant le TP.

---

## Niveau 1 — Retrouver ses repères

### 1.1 Observer avant de se déplacer

Pendant les premières missions, utilise ce cycle de navigation :

```text
avant : pwd puis ls
action : cd vers la destination
après  : pwd puis ls
```

Ce cycle n'est pas une règle obligatoire de Linux. C'est un réflexe temporaire pour comparer l'endroit imaginé avec l'endroit réel.

Observe ton emplacement actuel :

```bash
pwd
ls
ls /
```

!!! tip "🔮 Prédire puis analyser — N02"
    Avant d'exécuter les deux commandes `ls` et `ls /`, écris dans tes notes ce que chacune devrait afficher. Après l'exécution, conserve ta prédiction et ajoute : « La différence vient du fait que… »

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

La troisième commande entre symboliquement dans `navigation`, puis `..` revient dans son parent avant d'atteindre le fichier.

### 1.3 Une erreur qui révèle une règle

!!! danger "🧩 Débogage — D01"
    Lance volontairement cette commande et lis entièrement le message :

```bash
cd /~
```

Le `/` placé au début signifie « pars de la racine ». Bash ne développe pas `~` lorsqu'il n'est pas au début du mot : la commande cherche donc une entrée littéralement nommée `~` sous `/`.

!!! question "📝 Notes — N03 · L'erreur `/~`"
    Recopie le message important, explique pourquoi `/~` ne désigne pas ton dossier personnel, puis écris la correction minimale.

### 1.4 Même destination, moins d'aide

Sans commande prête :

1. place-toi dans `navigation/secteur-beta` avec un chemin relatif ;
2. affiche `carte.txt` ;
3. remonte jusqu'à la racine de `station-nadir` uniquement avec `..` ;
4. note le chemin affiché par `pwd` ;
5. va dans `/tmp`, puis reviens à `station-nadir` avec un chemin absolu commençant par `/`.

!!! question "📝 Notes — N04 · Deux chemins vers la même cible"
    Note le chemin relatif et le chemin absolu que tu as utilisés pour atteindre la station. Explique pourquoi l'un dépend du dossier courant alors que l'autre fonctionne depuis `/tmp`.

---

## Niveau 2 — Ne plus tout retaper

Le shell utilise une bibliothèque d'édition de ligne : la commande en cours peut être parcourue et corrigée comme une courte ligne de texte.

Affiche d'abord l'historique récent :

```bash
history 10
```

Chaque terminal Bash conserve une liste numérotée des commandes déjà validées. Les flèches et `Ctrl+R` permettent de réutiliser cette liste sans recopier son contenu.

### 2.1 Première prise en main guidée

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

### 2.2 Variante moins guidée

Sans retaper entièrement une commande :

1. rappelle la commande qui affichait les trois secteurs ;
2. transforme-la pour ne consulter que `secteur-beta` ;
3. rappelle-la encore et remplace `beta` par `gamma` ;
4. retrouve ensuite avec `Ctrl+R` la première commande contenant `00-LIRE` ;
5. annule la commande retrouvée avec `Ctrl+C` au lieu de l'exécuter.

!!! question "📝 Notes — N05 · Raccourcis utiles"
    Quels sont les deux raccourcis qui t'ont évité le plus de saisie ? Décris un cas concret où chacun t'a aidé.

### 2.3 La première pièce cachée

Observe le dossier de navigation :

```bash
ls navigation
ls -a navigation
```

Une entrée supplémentaire apparaît avec `-a`. Sans commande fournie, entre dans cette entrée, lis le fichier qu'elle contient et reviens à la racine de la station.

!!! question "📝 Notes — N06 · Entrée cachée"
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

!!! question "📝 Notes — N07 · Fichier ou dossier"
    Explique avec tes mots la différence entre `mkdir` et `touch`. Quelle observation te permet de vérifier le type de l'objet créé ?

### 3.2 Écrire puis ajouter

```bash
echo "Enquete ouverte" > travail/enquete/observations.txt
echo "Station : Nadir" >> travail/enquete/observations.txt
cat travail/enquete/observations.txt
```

!!! tip "🔮 Prédire puis analyser — N08"
    Sans exécuter de commande supplémentaire, prédis le contenu du fichier après ces deux lignes :

```bash
echo "ancienne hypothese" > travail/enquete/test.txt
echo "nouvelle hypothese" > travail/enquete/test.txt
```

Lance-les seulement après avoir écrit ta prédiction. Compare ensuite avec `cat` et formule la règle qui distingue `>` de `>>`.

### 3.3 Copier, déplacer, supprimer dans la zone de travail

```bash
cp rapports/brouillon.txt travail/enquete/rapport-copie.txt
mv travail/enquete/rapport-copie.txt travail/enquete/rapport-final.txt
ls travail/enquete
```

Crée maintenant, sans commande prête :

- une copie de `observations.txt` nommée `observations-secours.txt` ;
- un fichier caché `.progression` ;
- un dossier `travail/enquete/indices-valides` ;
- puis supprime uniquement la copie de secours avec `rm`.

Vérifie chaque étape. Avant `rm`, relis toujours le chemin ciblé.

### 3.4 Une destination du mauvais type

!!! danger "🧩 Débogage — D02"
    Cette commande essaie d'écrire dans un dossier comme s'il s'agissait d'un fichier :

```bash
echo "test" > travail/enquete
```

!!! question "📝 Notes — N09 · Rediriger vers un dossier"
    Recopie le message d'erreur, identifie l'objet qui est un dossier et propose une correction qui écrit `test` dans un nouveau fichier placé à l'intérieur de ce dossier.

---

## Niveau 4 — Voir précisément avec `ls`

`ls` ne possède pas une seule manière d'afficher les données. Compare progressivement :

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

### Mission moins guidée

Choisis toi-même les options nécessaires pour répondre à ces questions :

1. quels sont les fichiers cachés sous `navigation` ?
2. quel journal de `transmissions` occupe le plus d'espace ?
3. quels sont les droits du dossier `travail` lui-même ?
4. quels fichiers se trouvent dans tous les sous-dossiers de `inventaire` ?

!!! question "📝 Notes — N10 · Choisir les options"
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

!!! question "📝 Notes — N11 · Choisir `cat`, `less` ou `nano`"
    Quel outil choisirais-tu pour lire un fichier de 700 lignes sans le modifier ? Lequel choisirais-tu pour le modifier ? Explique la différence d'usage, pas seulement le nom des commandes.

### 5.2 Voir seulement le début ou la fin

```bash
head -n 5 transmissions/radio-2026-09-15.log
tail -n 5 transmissions/radio-2026-09-16.log
```

!!! tip "🔮 Prédire puis analyser — N12"
    Avant de lancer les commandes, écris ce que signifie `-n 5` et quelle partie du fichier chacune devrait afficher. Après l'exécution, note les deux fragments découverts au début et à la fin des journaux.

### 5.3 Une option oubliée

!!! danger "🧩 Débogage — D03"
    Lance cette commande volontairement incorrecte :

```bash
head 5 transmissions/radio-2026-09-15.log
```

Sans `-n`, `head` interprète `5` comme un nom de fichier supplémentaire. Corrige la commande en utilisant l'aide si nécessaire :

```bash
head --help
```

---

## Niveau 6 — Chercher une aiguille avec `grep`

### 6.1 Première recherche guidée

Le journal du 14 septembre contient presque mille lignes. Cherche directement l'anomalie importante :

```bash
grep 'ANOMALIE-ROUGE' transmissions/radio-2026-09-14.log
grep -n 'ANOMALIE-ROUGE' transmissions/radio-2026-09-14.log
```

L'option `-n` ajoute le numéro de ligne. `grep` ne change pas le fichier : il affiche seulement les lignes qui correspondent au motif.

Une recherche peut ignorer la différence entre majuscules et minuscules :

```bash
grep -i 'anomalie-rouge' transmissions/radio-2026-09-14.log
```

!!! question "📝 Notes — N13 · Recherche avec `grep`"
    Quel secteur est associé à l'anomalie ? À quoi sert `-n` ? Explique pourquoi `grep` est plus adapté que `cat` pour cette recherche.

### 6.2 Une commande dans le mauvais ordre

!!! danger "🧩 Débogage — D04"
    Lance la commande suivante et observe ce que `grep` essaie d'ouvrir :

```bash
grep transmissions/radio-2026-09-14.log ANOMALIE-ROUGE
```

La forme générale attendue est :

```text
grep [options] 'motif recherché' fichier
```

!!! question "📝 Notes — N14 · Comprendre l'erreur `grep`"
    Dans la commande incorrecte, quel argument est pris pour le motif ? Quel argument est pris pour un nom de fichier ? Note le message observé puis écris la correction.

### 6.3 Recherche moins guidée

Sans commande prête :

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

### Modification moins guidée

Rouvre le rapport sans recopier la commande : utilise l'historique. Recherche le mot `Code`, déplace la ligne correspondante en haut du fichier avec les raccourcis de `nano`, puis enregistre à nouveau.

!!! question "📝 Notes — N15 · Modifier avec `nano`"
    Note la modification effectuée et les raccourcis utilisés pour enregistrer et quitter. Pourquoi vérifier ensuite avec `cat` ou `less` reste-t-il utile ?

---

## Niveau 8 — Qui possède quoi ?

Décompresse maintenant le second terrain de jeu à côté de la station :

```bash
cd ~/base-exploration/tp1-5
unzip ~/Téléchargements/tp1-5-atelier-permissions.zip
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

!!! question "📝 Notes — N16 · Identité Unix"
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

### 9.1 Expérience guidée sur le propriétaire

Observe avant de modifier :

```bash
ls -l documents/rapport-public.txt
chmod u-w documents/rapport-public.txt
ls -l documents/rapport-public.txt
```

!!! tip "🔮 Prédire puis analyser — N17"
    Avant les deux prochaines commandes, prédis séparément si la lecture et l'écriture vont fonctionner. Garde ces prédictions dans tes notes.

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

!!! tip "🔮 Prédire puis analyser — N18"
    Tu es propriétaire du fichier et tu appartiens probablement aussi à son groupe. Prédis si `cat` pourra le lire, puis vérifie.

```bash
cat laboratoire/groupe-seul.txt
```

Linux choisit une seule catégorie : si l'utilisateur courant est le propriétaire, les droits `u` s'appliquent. Il ne récupère pas ensuite les droits `g` pour compléter ceux qui manquent.

Restaure un mode utilisable :

```bash
chmod u=rw,g=r,o= laboratoire/groupe-seul.txt
cat laboratoire/groupe-seul.txt
```

### 9.3 Variante moins guidée

Sans commande complète, règle `equipe/partage-equipe.txt` pour obtenir :

- propriétaire : lecture et écriture ;
- groupe : lecture seulement ;
- autres : aucun droit.

Vérifie avec `ls -l`.

!!! question "📝 Notes — N19 · Forme symbolique"
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

### 10.1 Exemple guidé

```bash
chmod 640 documents/rapport-public.txt
ls -l documents/rapport-public.txt
```

Le premier chiffre concerne `u`, le deuxième `g`, le troisième `o`.

### 10.2 Une valeur impossible

!!! danger "🧩 Débogage — D05"
    Lance volontairement :

```bash
chmod 758 documents/rapport-public.txt
```

Chaque chiffre décrit trois bits et doit donc rester compris entre `0` et `7`. Le chiffre `8` ne correspond à aucune combinaison de `r`, `w` et `x`.

### 10.3 Configuration autonome

Sans commandes prêtes, applique les objectifs contenus dans `00-LIRE-MOI.txt` :

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

!!! question "📝 Notes — N20 · Formes symbolique et numérique"
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

!!! tip "🔮 Prédire puis analyser — N21"
    Avant d'exécuter les commandes suivantes, prédis laquelle modifiera la liste des noms contenue dans `depot`.

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

Reproduis ensuite l'expérience, sans commandes fournies, dans un nouveau dossier jetable nommé `laboratoire/depot-2`. Crée d'abord un témoin, retire l'écriture au dossier, teste une création et une suppression, puis restaure le droit.

!!! question "📝 Notes — complément N21"
    Compare tes prédictions aux résultats. Pourquoi retirer `w` à un dossier n'a-t-il pas le même effet que retirer `w` à un fichier ?

---

## Boss final — Reconstituer la transmission

Il reste à reconstruire le code de la station et à terminer le rapport. Aucune commande complète n'est fournie.

### Les cinq fragments

Dans cet ordre, retrouve :

1. **station** — dans une entrée cachée de `navigation` ;
2. **entête** — sur la première ligne du journal du 15 septembre ;
3. **secteur** — sur la ligne `ANOMALIE-ROUGE` du journal du 14 septembre ;
4. **numéro** — sur la dernière ligne du journal du 16 septembre ;
5. **protocole** — près de `PROTOCOLE-ORION` dans le manuel.

Utilise volontairement des outils différents : options de `ls`, `head`, `tail`, `grep` et recherche dans `less`.

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

!!! question "📝 Notes — N22 · Bilan final"
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
