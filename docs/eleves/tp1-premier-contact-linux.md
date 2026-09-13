# Premier contact avec Linux

## Mission 1 - Le poste et son territoire

Tu connais sûrement Windows : tu cliques sur une icône, tu ouvres un dossier « Documents », tu lances une application. Sur un téléphone, tout cela est encore plus caché : les applications font le travail en coulisses.

Aujourd'hui, tu vas passer de l'autre côté du décor.

Ton poste utilise Linux. Au lieu de cliquer partout, tu vas lui parler directement avec le terminal. Tu découvriras où vivent tes fichiers, pourquoi il existe des dossiers étranges comme `/etc` ou `/var`, comment Linux protège tes données et quels programmes sont déjà en train de travailler.

Tu n'as rien à connaître avant de commencer. Tu n'as pas besoin de tout mémoriser. Avance, observe, puis explique ce que tu as compris.

Les niveaux 0 à 7 constituent la mission principale. Si tu les termines, les deux explorations bonus te feront découvrir les liens symboliques et les processus.

---

## Tes notes sont importantes

À la fin de chaque niveau, prends quelques lignes de notes sur le logiciel qui te convient : bloc note, document word, Google Docs, ou VSCode pour ceux qui veulent. Ce n'est pas une punition, ni une dictée de définitions : c'est ton carnet de bord.

Il t'aidera à faire trois choses :

- comprendre ce que tu viens vraiment de faire ;
- retrouver tes découvertes pour réviser ;
- permettre à l'enseignant de voir jusqu'où tu es allé et où il doit t'aider.

L'enseignant récupérera les notes de tout le monde. L'objectif n'est pas de pénaliser une erreur ou une étape non terminée ; il est de comprendre votre progression et de mieux vous accompagner au TP suivant. Pour chaque niveau, essaye de noter :

```md
## Niveau N - titre
- Ce que j'ai fait :
- Ce que j'ai observé :
- Ce que j'en comprends :
- Ma question éventuelle :
```

---

## Niveau 0 - Première conversation

Regarde ton terminal. Tu devrais voir une ligne semblable à celle-ci :

```text
alice@poste-17:~$
```

Cette ligne est une **invite de commande**. Elle signifie : « le shell attend une instruction ». Le symbole `$` ne doit pas être recopié : il sert seulement à montrer où commence la commande.

Pour commencer, pose une seule question à la machine :

```bash
whoami
```

`whoami` signifie littéralement « qui suis-je ? ». Linux te répond par ton nom d'utilisateur. C'est l'identité avec laquelle tu travailles sur ce poste.

Dans la suite, tu verras aussi `hostname` (le nom du poste) et `uname` (des informations sur Linux). Pour l'instant, retiens seulement ceci : le terminal te permet de poser une question courte, puis Linux répond.

### Dans tes notes

Quelle question as-tu posée à Linux ? Quelle réponse as-tu reçue ?

---

## Niveau 1 - Regarder sans toucher

Avant de modifier quoi que ce soit, apprends à regarder. La commande `ls` signifie *list* : elle affiche les noms présents dans l'endroit où tu te trouves.

```bash
ls
```

Tu verras peut-être des dossiers comme `Documents`, `Images` ou `Téléchargements`. C'est ton espace personnel, comparable à ton dossier utilisateur sous Windows.

Linux possède aussi des dossiers communs à toute la machine. Sans quitter ton espace, demande à voir ceux qui partent de `/` :

```bash
ls /
```

Ne cherche pas encore à comprendre tous les noms : pour l'instant, observe qu'il existe un grand espace commun et ton espace personnel à l'intérieur.

### Dans tes notes

Qu'as-tu vu avec `ls` ? Quelle différence imagines-tu entre `ls` et `ls /` ?

---

## Niveau 2 - Se déplacer sans se perdre

Un terminal travaille toujours dans un dossier. Demande d'abord où tu es :

```bash
pwd
```

`pwd` signifie *print working directory* : afficher le dossier dans lequel tu travailles actuellement.

Maintenant, déplace-toi à la racine de Linux avec `cd`, qui signifie *change directory* :

```bash
cd /
pwd
```

Tu es maintenant au point de départ de toute l'arborescence. Reviens chez toi avec `~`, le raccourci vers ton dossier personnel :

```bash
cd ~
pwd
```

Fais un aller-retour vers le dossier temporaire puis remonte d'un étage :

```bash
cd /tmp
pwd
cd ..
pwd
```

`..` veut dire « le dossier parent », celui qui contient le dossier où tu étais. Ici, le parent de `/tmp` est `/`.

### Dans tes notes

Quelle commande permet de savoir où tu es ? Quelle commande permet de changer de dossier ? Que représente `~` ?

---

## Niveau 3 - Installer ta base d'exploration

Un explorateur a besoin d'une base sûre. La tienne sera un dossier personnel nommé `base-exploration`. Toutes les modifications du TP se feront à l'intérieur.

Commence par le créer, puis vérifie qu'il apparaît :

```bash
mkdir ~/base-exploration
ls ~
```

`mkdir` signifie *make directory* : créer un dossier. Va maintenant dans ta base :

```bash
cd ~/base-exploration
pwd
```

Crée un premier dossier de mission, puis regarde le résultat :

```bash
mkdir mission
ls
```

Ajoute trois espaces, une commande à la fois :

```bash
mkdir mission/briefing
mkdir mission/preuves
mkdir mission/coffre
ls mission
```

Tu viens de créer une petite arborescence. Dans la suite, elle servira de terrain de jeu : tu peux expérimenter ici sans risquer de dérégler Linux.

### Écrire un premier message

Quand tu écris une commande, son résultat s'affiche normalement dans le terminal. Les symboles suivants changent la destination du texte :

| Symbole | Exemple | Effet |
|---|---|---|
| rien | `echo "Bonjour"` | affiche le texte dans le terminal |
| `>` | `echo "Bonjour" > note.txt` | crée `note.txt` ou remplace entièrement son contenu |
| `>>` | `echo "Bonjour" >> note.txt` | ajoute le texte à la fin de `note.txt` |
| `<` | `cat < note.txt` | donne le contenu de `note.txt` à la commande `cat` |

> Attention avec `>` : s'il vise un fichier déjà rempli, son ancien contenu est remplacé. `>>` est le symbole prudent lorsqu'on veut ajouter une nouvelle ligne.

Commence par observer `echo` sans flèche :

```bash
echo 'Bienvenue, explorateur.'
```

Puis crée les fichiers de mission :

```bash
echo 'Bienvenue, explorateur.' > mission/briefing/objectif.txt
echo 'Premier indice : le chemin compte.' > mission/preuves/journal.txt
echo 'CODE-ALPHA-42' > mission/coffre/code.txt
echo 'Deuxième indice : observe avant d'agir.' >> mission/preuves/journal.txt
```

Tu viens d'utiliser `echo` pour écrire un message et les flèches pour l'envoyer dans un fichier. Ne cherche pas encore à tout retenir : observe que les trois fichiers existent.

```bash
ls mission/briefing
ls mission/preuves
ls mission/coffre
```

Compare maintenant ces deux manières d'afficher le journal. Elles produisent le même résultat :

```bash
cat mission/preuves/journal.txt
cat < mission/preuves/journal.txt
```

`cat` affiche le contenu d'un fichier dans le terminal. La première commande lui indique le fichier directement. Dans la seconde, le symbole `<` prend le contenu du fichier et le donne à `cat`. Nous réutiliserons cette idée lorsque les commandes pourront travailler ensemble.

### Défi éclair

Sans lancer de commande, prédis le résultat de :

```bash
ls mission
```

Puis vérifie. Pourquoi ne vois-tu pas directement les trois fichiers texte ?

### Dans tes notes

Que fait `mkdir` ? Où se trouve ta base d'exploration ? Explique avec tes mots la différence entre `>` et `>>`.

---

## Niveau 4 - La grande carte de Linux

Jusqu'ici, tu es resté chez toi. Explorons prudemment la racine du système. Le caractère `/` seul désigne le point de départ de toute l'arborescence Linux.

```bash
cd /
ls
```

Tu devrais notamment rencontrer plusieurs de ces dossiers :

```text
/bin   /etc   /home   /root   /tmp   /usr   /var
```

Ils ne sont pas là par hasard.

| Dossier | À quoi il sert, en version courte |
|---|---|
| `/home` | les dossiers personnels des utilisateurs ordinaires |
| `/root` | le dossier personnel de l'administrateur `root` |
| `/etc` | la configuration de la machine et de ses services |
| `/tmp` | des fichiers temporaires ; ils peuvent disparaître après un redémarrage |
| `/var` | des données qui changent souvent : journaux, cache, files d'attente... |
| `/usr` | beaucoup de programmes, bibliothèques et données installés |
| `/bin` | programmes essentiels ; sur des systèmes récents, c'est souvent un lien vers `/usr/bin` |

> **Minute culture :** tout n'est pas un « dossier utilisateur ». Linux a une organisation commune entre distributions. Elle permet à un administrateur de retrouver rapidement les programmes, les réglages et les journaux, même sur une machine qu'il ne connaît pas.

Regarde ton dossier personnel sans le modifier :

```bash
ls /home
ls ~
```

Retourne ensuite dans ta base d'exploration, avec une seule commande :

```bash
cd ~/base-exploration
```

### Le piège des fichiers invisibles

Crée un fichier dont le nom commence par un point :

```bash
touch .message-secret
ls
ls -a
```

`touch` crée ici un fichier vide. La commande peut aussi servir à modifier la date d'un fichier déjà existant ; nous garderons cette deuxième utilisation pour plus tard.

Le premier `ls` le cache, le second l'affiche. Linux n'a pas rendu ce fichier secret : c'est seulement `ls` qui choisit de ne pas l'afficher par défaut.

### Dans tes notes

Choisis deux dossiers système parmi `/etc`, `/home`, `/tmp`, `/usr` et `/var`. Explique leur rôle sans recopier le tableau.

---

## Niveau 5 - Les chemins : raccourcis, demi-tours et coordonnées

Dans une ville, une adresse peut être complète ou donnée par rapport à l'endroit où tu te trouves. C'est exactement la même chose ici.

```text
Chemin absolu : commence par / et marche depuis la racine.
Chemin relatif : marche depuis le dossier où tu es actuellement.
```

Depuis `~/base-exploration`, teste lentement les commandes suivantes :

```bash
pwd
cd mission
pwd
cd briefing
pwd
cd ..
pwd
cd ../..
pwd
```

Le nom spécial `.` désigne le dossier actuel. `..` désigne son parent : le dossier un niveau au-dessus.

Reviens dans ta base puis consulte le briefing :

```bash
cd ~/base-exploration
cat mission/briefing/objectif.txt
cat ./mission/briefing/objectif.txt
cat ~/base-exploration/mission/briefing/objectif.txt
```

Les trois commandes désignent le même fichier. Les deux premières sont relatives ; la dernière est absolue.

### Défi de navigation

Sans utiliser la touche flèche vers le haut, place-toi dans `mission/preuves` en exactement deux commandes à partir de `~/base-exploration`. Il existe plusieurs bonnes réponses.

### Dans tes notes

Quelle est la différence entre `.` et `..` ? Pourquoi un chemin commençant par `/` peut-il fonctionner même si tu es perdu dans l'arborescence ?

---

## Niveau 6 - Parler le langage des commandes

Tu n'auras jamais besoin de mémoriser toutes les options de Linux. Les personnes expérimentées cherchent régulièrement dans le manuel.

Demande de l'aide pour `ls` :

```bash
man ls
```

Le manuel s'ouvre dans un lecteur. Tu peux chercher avec `/mot`, passer à la page suivante avec espace, et quitter avec `q`.

Cherche l'option `-a`, puis quitte. Essaie ensuite :

```bash
ls --help
type cd
type ls
command -v ls
```

`type` révèle la nature d'une commande. Tu devrais constater que `cd` est intégré au shell, alors que `ls` correspond à un programme extérieur.

> **Pourquoi `cd` est-il spécial ?** Changer de dossier doit modifier le shell qui attend tes commandes. Si `cd` était un programme séparé, il changerait de dossier pour lui-même, puis disparaîtrait aussitôt : ton shell ne bougerait pas.

### Mini-défi

Utilise l'aide pour découvrir une option de `ls` qui permet d'afficher les tailles dans une forme plus agréable à lire. Teste-la dans ta base.

### Dans tes notes

Avec tes mots : quelle différence fais-tu entre une commande interne et une commande externe ?

---

## Niveau 7 - Qui a le droit de faire quoi ?

Linux est fait pour plusieurs utilisateurs. Même seul sur ton poste, tu n'es pas tout-puissant : c'est volontaire.

Commence par regarder ton identité :

```bash
id
```

Tu vois ton identifiant, ton groupe principal et parfois d'autres groupes. Regarde ensuite, sans modifier aucun fichier :

```bash
head -n 5 /etc/passwd
head -n 5 /etc/group
```

`/etc/passwd` ne contient normalement pas les mots de passe. Il liste des comptes et des informations techniques. Certains comptes correspondent à des services du système plutôt qu'à des humains.

Maintenant, examinons les droits de ton coffre :

```bash
cd ~/base-exploration
ls -ld mission/coffre
ls -l mission/coffre/code.txt
```

Dans les premiers caractères, tu rencontreras une forme telle que :

```text
drwxr-xr-x
```

Le premier caractère indique le type : `d` pour un répertoire, `-` pour un fichier, `l` pour un lien symbolique. Les neuf suivants sont trois groupes de trois : droits du propriétaire, de son groupe et des autres utilisateurs.

Pour un fichier :

```text
r = lire       w = modifier le contenu       x = exécuter
```

Pour un répertoire, `x` ne signifie pas « lancer le dossier » : il signifie **pouvoir le traverser** dans un chemin.

### Expérience A - verrouiller le contenu d'un fichier

```bash
chmod u-w mission/coffre/code.txt
echo 'nouveau code' >> mission/coffre/code.txt
cat mission/coffre/code.txt
```

La deuxième commande doit être refusée : tu as retiré ton droit d'écriture (`u-w`) sur le fichier. Tu peux malgré tout le lire.

Restaure ensuite la situation :

```bash
chmod u+w mission/coffre/code.txt
```

### Expérience B - verrouiller le répertoire

```bash
chmod u-w mission/coffre
touch mission/coffre/test-interdit.txt
rm mission/coffre/code.txt
```

Les deux dernières actions doivent être refusées. Le droit d'écriture sur un répertoire permet de modifier sa liste d'entrées : créer, supprimer ou renommer des fichiers.

Restaure immédiatement le droit :

```bash
chmod u+w mission/coffre
```

Vérifie que `code.txt` est toujours présent :

```bash
ls mission/coffre
```

### Dans tes notes

Complète cette phrase : « Pour supprimer un fichier, Linux vérifie surtout le droit d'écriture sur ... car supprimer consiste à ... »

---

## Niveau 8 - Les raccourcis Linux

Un lien symbolique est un petit fichier qui contient le chemin vers une cible. C'est proche d'un raccourci, mais tu vas observer une différence importante : la cible peut disparaître.

Crée un accès rapide vers le briefing :

```bash
cd ~/base-exploration/mission
ln -s briefing/objectif.txt acces-rapide
ls -l acces-rapide
cat acces-rapide
```

La flèche `->` affichée par `ls -l` indique la cible du lien.

Déplace maintenant le fichier cible :

```bash
mv briefing/objectif.txt briefing/objectif-retrouve.txt
cat acces-rapide
```

Tu viens de fabriquer un lien cassé. Ce n'est pas dramatique : le lien garde l'ancien chemin, mais la cible a changé de nom.

Répare-le sans recréer le lien :

```bash
mv briefing/objectif-retrouve.txt briefing/objectif.txt
cat acces-rapide
```

### Minute culture

Les liens symboliques servent beaucoup dans Linux : pour offrir deux chemins vers un programme, conserver un nom stable pendant qu'une version change, ou organiser des projets sans recopier les fichiers.

### Dans tes notes

Quelle information est stockée dans un lien symbolique ? Que se passe-t-il si cette information ne mène plus à une cible existante ?

---

## Niveau 9 - Les programmes qui tournent

Un **programme** est un fichier prêt à être lancé. Un **processus** est une exécution de ce programme, vivante maintenant, avec un numéro appelé PID.

Créons un processus sans danger :

```bash
sleep 300 &
jobs
```

Le caractère `&` demande au shell de lancer la commande en arrière-plan. Le terminal reste disponible.

Affiche le processus avec davantage d'informations :

```bash
ps -o pid,ppid,stat,etime,cmd -p "$!"
```

`$!` signifie ici « le PID du dernier processus lancé en arrière-plan ». Tu n'as pas besoin de retenir ce détail maintenant : observe simplement qu'un processus a un PID et un parent, le shell.

Termine uniquement **ton** processus de démonstration :

```bash
kill "$!"
jobs
```

> **Règle importante :** ne copie jamais un PID trouvé sur Internet et ne lance pas `kill` sur un processus que tu ne comprends pas. Ici, tu viens de créer toi-même le processus visé.

### Expérience facultative : interrompre une tâche au premier plan

Lance `sleep 30` sans `&`, puis utilise `Ctrl+C` avant la fin. Tu envoies une demande d'interruption à la commande qui occupe le premier plan.

### Dans tes notes

Donne un exemple de programme et de processus observé pendant ce TP. Qui était le parent de ton processus `sleep` ?

---

## Boss final - Le poste est sous contrôle

Tu dois vérifier que ta mission est prête. Sans regarder les étapes précédentes, réalise ces actions :

1. Reviens dans `~/base-exploration`.
2. Affiche le contenu de `mission/briefing/objectif.txt`.
3. Affiche les droits du dossier `mission/coffre`.
4. Crée un fichier caché `.rapport-final` dans `~/base-exploration/observations`.
5. Affiche ce fichier caché avec une commande adaptée.
6. Dessine dans tes notes une mini-carte de Linux : `/`, `/home`, `/etc`, ton répertoire personnel et ta base d'exploration.

Si tu as réalisé l'exploration bonus A, vérifie aussi que `mission/acces-rapide` permet de lire le briefing.

Quand tu as fini, appelle l'enseignant pour une vérification rapide. Ensuite, réponds à cette question finale :

> Tu arrives devant un ordinateur Linux inconnu. Quelles sont les trois premières commandes que tu lancerais, et pourquoi ?

---

## Ce que tu sais maintenant

Tu sais déjà :

- utiliser un terminal et reconnaître une invite de commande ;
- te repérer avec `pwd`, `cd` et `ls` ;
- comprendre l'idée d'une arborescence unique qui commence à `/` ;
- distinguer chemin absolu et chemin relatif ;
- consulter une aide avec `man` et `--help` ;
- créer, déplacer, lire et examiner des fichiers ;
- reconnaître un lien symbolique ;
- expliquer l'idée générale des droits Linux ;
- distinguer programme et processus.

Ce n'est que le début. Le prochain TP te fera utiliser le shell comme un véritable outil pour filtrer, relier et transformer des informations.
