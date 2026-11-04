# Corrigé du TP 1 — Premier contact avec Linux

Suis les niveaux du [sujet](../eleves/tp1-premier-contact-linux.md). Remplace les exemples de nom d’utilisateur et de chemin par ceux de ta session.

## Niveau 0 — Identifier ton utilisateur

`whoami` affiche le nom de l’utilisateur avec lequel tu travailles. Si la commande renvoie `alice`, tes commandes s’exécutent avec les droits d’Alice.

## Niveau 1 — Comparer deux listes

`ls` affiche les noms visibles dans le dossier courant. Au départ, tu peux y voir `Documents` ou `Téléchargements`. `ls /` affiche les noms visibles à la racine de Linux, par exemple `etc`, `home` et `tmp`. Les deux commandes laissent ton dossier courant intact.

## Niveau 2 — Te déplacer

`pwd` affiche ton dossier courant. `cd` change ce dossier. Dans `cd ~`, Bash remplace `~` par le chemin de ton dossier personnel. Après `cd /tmp` puis `cd ..`, `pwd` affiche normalement `/`, le parent de `/tmp`.

## Niveau 3 — Créer et remplir la base

`mkdir` crée un dossier. Ta base se trouve dans ton dossier personnel, par exemple dans `/home/alice/base-exploration`.

`>` crée le fichier cible ou remplace son contenu. `>>` crée aussi le fichier s’il manque, mais ajoute le texte à la fin s’il existe déjà. Le journal contient donc les deux lignes d’indice.

Pour le défi éclair, `ls mission` affiche `briefing`, `coffre` et `preuves`. Les fichiers texte se trouvent un niveau plus bas. `ls` liste ici un seul niveau.

## Niveau 4 — Reconnaître les dossiers système

Par exemple, `/etc` regroupe les réglages du système et de ses services. `/var` contient des données qui évoluent pendant le fonctionnement, comme des journaux. Le point initial de `.message-secret` le masque dans un `ls` ordinaire. `ls -a` le montre.

## Niveau 5 — Lire un chemin

`.` désigne ton dossier courant et `..` son parent. Un chemin qui commence par `/` part de la racine, quel que soit ton dossier courant. Quand tu écris `~/base-exploration`, Bash développe d’abord `~` en chemin absolu.

Pour le défi de navigation, pars de `~/base-exploration` et exécute ces deux commandes.

```bash
cd mission
cd preuves
```

## Niveau 6 — Demander de l’aide

`cd` est une commande interne. Elle s’exécute dans Bash et change le dossier du shell en cours. `ls` est normalement un programme externe que le shell lance.

Pour le mini-défi, `-h` rend les tailles plus lisibles, par exemple avec des unités comme `K` ou `M`. Combine-la avec `-l` pour afficher les tailles.

```bash
ls -lh mission/preuves
```

## Niveau 7 — Expliquer un refus de permission

Après `chmod u-w mission/coffre/code.txt`, tu peux encore lire le code. L’ajout avec `>>` échoue, car tu as retiré le droit d’écrire dans le fichier.

Pour supprimer un fichier, Linux vérifie surtout le droit d’écriture sur **le dossier parent**, car supprimer consiste à retirer un nom de la liste de ses entrées. Il faut aussi pouvoir traverser ce dossier avec `x`. Sans `w` sur `mission/coffre`, la création et la suppression sont refusées. Après avoir restauré le droit avec `chmod u+w mission/coffre`, vérifie que `code.txt` est toujours là.

## Niveau 8 — Suivre un lien symbolique

`acces-rapide` contient le chemin `briefing/objectif.txt`. Ce chemin relatif part du dossier qui contient le lien. Si tu renommes la cible, le lien garde l’ancien chemin et `cat acces-rapide` échoue. Remettre le nom d’origine rend le lien utilisable.

## Niveau 9 — Distinguer programme et processus

`sleep` est un programme. Quand tu lances `sleep 300 &`, Bash démarre une exécution de ce programme. Cette exécution est un **processus** avec son propre numéro, le PID. Son parent est le shell qui l’a lancé. La colonne `PPID` de `ps` donne le PID de ce parent.

## Boss final — Vérifier la base

**Dans le terminal**, exécute les commandes suivantes.

```bash
cd ~/base-exploration
cat mission/briefing/objectif.txt
ls -ld mission/coffre
mkdir -p observations
touch observations/.rapport-final
ls -a observations
```

Tu dois retrouver le message `Bienvenue, explorateur.`, une ligne de droits qui commence par `d` et le nom `.rapport-final`. L’option `-d` décrit le dossier `coffre` lui-même. Si tu as fait le niveau 8, `cat mission/acces-rapide` doit afficher le même message que le briefing.

**Dans tes notes**, dessine la carte avec le vrai nom de ton dossier personnel. Voici un exemple.

```text
/
├── etc/
└── home/
    └── alice/
        └── base-exploration/
```

Sur un poste inconnu, je lancerais `whoami` pour connaître mon utilisateur, `pwd` pour savoir où je suis et `ls` pour voir ce qui m’entoure.
