# TP 1 — Repères visuels et notions clés

Cette annexe rassemble les idées essentielles du TP **Premier contact avec Linux**. Elle relie les commandes observées à une vue d'ensemble du système : qui interprète une commande, comment les fichiers sont organisés et pourquoi les droits ou les processus se comportent ainsi.

## Carte des notions

| Notion | Observation dans le terminal | Idée essentielle |
|---|---|---|
| terminal, shell et noyau | `whoami`, `ls` | l'interface, l'interpréteur et le cœur du système ont des rôles différents |
| arborescence | `ls /` | tous les chemins appartiennent à un arbre unique qui part de `/` |
| chemins | `pwd`, `cd`, `..`, `~` | un chemin décrit un itinéraire absolu ou relatif |
| redirections | `echo`, `>`, `>>`, `<` | le shell choisit où circulent les données |
| commandes internes | `type cd`, `type ls` | certaines commandes modifient le shell lui-même, d'autres sont des programmes séparés |
| droits | `ls -l`, `chmod` | `r`, `w` et `x` changent de sens selon l'objet |
| liens symboliques | `ln -s`, `ls -l` | un lien mémorise un chemin, pas une copie |
| processus | `sleep 300 &`, `jobs`, `ps` | un programme lancé devient un processus identifié par un PID |

!!! warning "Périmètre sûr"
    Les manipulations restent dans `~/base-exploration`, sans `sudo`. La seule cible de `kill` est le processus `sleep` créé dans le terminal pendant le TP.

---

## 1. Terminal, shell, noyau : qui fait quoi ?

![Les logiciels de l'espace utilisateur passent par le noyau Linux pour accéder au processeur, à la mémoire, au disque, au réseau et aux périphériques.](../assets/tp1-depart-linux.svg)

Le **terminal** affiche du texte et transmet les frappes du clavier. Le **shell** — souvent Bash — interprète la ligne saisie, prépare la commande puis lance le programme demandé. Les logiciels ne pilotent pas directement le matériel : ils demandent des services au **noyau Linux** au moyen d'appels système.

Le noyau occupe donc une place centrale. Il arbitre l'accès au processeur, isole la mémoire, contrôle les droits sur les fichiers et dialogue avec les périphériques grâce à des pilotes.

```text
commande saisie
      ↓
terminal → shell → programme
                     ↕ appels système
                 noyau Linux
                     ↕ pilotes
     processeur · mémoire · disque · réseau · écran
```

!!! info "Un nom à double sens"
    Dans la vie courante, « Linux » désigne souvent tout le système. Techniquement, Linux est le noyau ; les commandes comme Bash, `ls` ou `grep` sont d'autres logiciels assemblés autour de lui.

**Question de réflexion :** si dix programmes veulent utiliser le processeur en même temps, quel composant décide quand chacun peut travailler ?

---

## 2. La carte du territoire

![La grande arborescence Linux : tous les dossiers partent de `/`, y compris le dossier personnel.](../assets/tp1-arborescence.svg)

```text
/
├── home/       espaces personnels, par exemple /home/alice
├── root/       espace personnel de l'administrateur root
├── etc/        configuration de la machine
├── tmp/        fichiers temporaires
├── usr/        grande partie des programmes installés
└── var/        données variables : journaux, caches, files d'attente…
```

Linux présente une seule grande arborescence qui commence par `/`. Un disque, une clé USB ou un partage réseau vient se raccorder à cet arbre à un **point de montage** : il n'apparaît pas nécessairement sous une nouvelle lettre comme sous Windows.

Selon la distribution, certains chemins peuvent différer. Sur beaucoup de systèmes récents, `/bin` est un lien symbolique vers `/usr/bin`. Les anciens noms restent ainsi disponibles sans dupliquer les programmes.

!!! info "Pourquoi `/etc` ?"
    Le nom vient historiquement de *et cetera* : ce répertoire accueillait les fichiers système qui n'entraient pas ailleurs. Il est progressivement devenu le lieu principal de la configuration.

**Question de réflexion :** dans quel répertoire chercher un journal qui grossit avec le temps ?

---

## 3. Les chemins sont des itinéraires

![Deux itinéraires mènent au même fichier : le chemin absolu part toujours de la racine, le chemin relatif part du dossier courant.](../assets/tp1-chemins.svg)

Un chemin n'est pas l'objet lui-même : c'est l'itinéraire utilisé pour l'atteindre.

```text
/home/alice/base-exploration/mission/briefing/objectif.txt
└──────────────────── chemin absolu : départ à la racine /

mission/briefing/objectif.txt
└──────────────────── chemin relatif : départ dans le dossier courant
```

| Écriture | Signification |
|---|---|
| `/` | racine de toute l'arborescence |
| `.` | dossier courant |
| `..` | dossier parent |
| `~` | dossier personnel de l'utilisateur |
| `cd` sans argument | retour au dossier personnel dans Bash |

Si le dossier courant est `/home/alice/base-exploration`, les deux chemins suivants désignent le même fichier :

```text
mission/briefing/objectif.txt
/home/alice/base-exploration/mission/briefing/objectif.txt
```

Le premier dépend du point de départ ; le second reste valable quel que soit le dossier courant.

---

## 4. Les redirections : où part le texte ?

![Les redirections du shell : `>` remplace le contenu d'un fichier, `>>` ajoute à la fin et `<` fournit un fichier en entrée.](../assets/tp1-redirections.svg)

```text
echo "Bonjour"             → texte affiché dans le terminal
echo "Bonjour" > note.txt  → texte écrit dans un fichier ; ancien contenu remplacé
echo "Bonjour" >> note.txt → texte ajouté à la fin du fichier
cat < note.txt              → contenu du fichier fourni à cat
```

Les symboles `>`, `>>` et `<` ne sont pas des options de `echo` ou de `cat`. Le shell les traite avant de lancer la commande et branche les flux au bon endroit.

!!! danger "`>` remplace le contenu"
    La redirection `>` vide d'abord le fichier cible s'il existe. `>>` conserve le contenu et ajoute les nouvelles données à la fin.

---

## 5. Commandes internes et programmes externes

```text
shell Bash
 ├── cd                  commande interne : modifie le shell courant
 ├── echo                souvent interne
 └── lance /usr/bin/ls   programme externe : travaille puis se termine
```

`ls` peut travailler dans un processus séparé puis disparaître. `cd`, au contraire, doit modifier le dossier courant du shell qui attend la prochaine commande. Si un programme séparé changeait de dossier, lui seul se déplacerait ; le shell resterait au même endroit.

La commande `type` permet de découvrir ce que Bash lancera réellement :

```bash
type cd
type ls
type echo
```

!!! info "L'aide fait partie du travail"
    Les pages `man`, les options `--help` et la commande `type` ne sont pas des roues de secours pour débutants. Les administrateurs les utilisent quotidiennement : savoir retrouver une information fiable compte davantage que mémoriser toutes les options.

---

## 6. Les droits : trois lettres, deux significations

![Les droits Linux : `r`, `w` et `x` ont un sens différent sur un fichier et sur un répertoire.](../assets/tp1-droits.svg)

| Droit | Sur un fichier | Sur un répertoire |
|---|---|---|
| `r` — read | lire son contenu | lister les noms qu'il contient |
| `w` — write | modifier son contenu | ajouter, renommer ou supprimer des noms |
| `x` — execute | exécuter le fichier | traverser le répertoire dans un chemin |

La différence entre le fichier et son entrée dans un répertoire explique un résultat parfois surprenant :

```text
mission/coffre/          contient une liste de noms
        │
        └── code.txt     désigne le fichier contenant CODE-ALPHA-42
```

Supprimer `code.txt` revient d'abord à retirer le nom `code.txt` de la liste tenue par `coffre/`. Le droit d'écriture du répertoire est donc déterminant, même si le fichier lui-même est en lecture seule.

Les droits affichés par `ls -l` sont répartis entre le propriétaire (`u`), le groupe (`g`) et les autres (`o`). Un fichier créé pendant le TP appartient normalement à la personne connectée.

---

## 7. Lien symbolique : un panneau, pas une copie

![Un lien symbolique mémorise un chemin vers une cible ; si cette cible est déplacée, le lien demeure mais devient cassé.](../assets/tp1-liens-symboliques.svg)

```text
acces-rapide  ── contient le chemin ──>  briefing/objectif.txt
                                                  │
                                                  ▼
                                          véritable fichier
```

Un lien symbolique contient une adresse. Il ne duplique ni le contenu ni les droits de sa cible. Si la cible change de nom ou de place, le lien existe encore mais son itinéraire ne mène plus à un objet valide : il est **cassé**.

Cette indirection est pratique pour conserver un nom stable — par exemple `version-courante` — pendant que la cible réelle évolue de `version-1` à `version-2`.

---

## 8. Programme, processus et parenté

![Un programme est un fichier ; lorsqu'il est lancé par le shell, il devient un processus avec son propre PID.](../assets/tp1-processus.svg)

```text
programme : /usr/bin/sleep     fichier immobile sur le disque

shell Bash (PID 4210)
└── sleep 300 (PID 4368)       processus vivant, lancé maintenant
```

Un même programme peut être lancé dix fois : dix processus distincts existent alors, chacun avec son propre **PID**. Le shell qui lance une commande est le processus parent. La commande `jobs` connaît précisément les tâches lancées depuis ce shell.

!!! info "Que vaut un PID ?"
    Un PID n'est pas l'identité permanente d'un programme. Il est attribué à un processus vivant et pourra être réutilisé après sa fin. Il faut donc toujours vérifier la cible avant d'utiliser `kill`.

---

## Diagnostic rapide

| Message ou situation | Signification probable | Vérification utile |
|---|---|---|
| `No such file or directory` | le chemin ne désigne rien depuis l'endroit courant | contrôler `pwd`, puis `ls` à chaque niveau du chemin |
| `Permission denied` | le système refuse l'action demandée | identifier l'action (`r`, `w` ou `x`) et l'objet concerné |
| `command not found` | le shell ne trouve pas la commande | vérifier l'orthographe, puis utiliser `type` ou `command -v` |
| la racine `/` semble risquée | observer l'arborescence ne la modifie pas | `ls /` ne fait que lire ; `cd ~` ramène au dossier personnel |
| un lien est cassé | la cible a changé ou disparu | lire la flèche de `ls -l` et vérifier le chemin indiqué |
| `sleep` semble ne rien faire | le programme attend, comme demandé | l'observer avec `jobs` ou `ps` |

## À retenir

- Le terminal est une interface, le shell interprète les commandes et le noyau contrôle les ressources.
- `/` est le départ de toute l'arborescence ; `~` désigne le dossier personnel.
- Un chemin relatif dépend du dossier courant, un chemin absolu part de `/`.
- Les redirections sont préparées par le shell.
- Les droits sur un fichier et sur un répertoire ne décrivent pas les mêmes actions.
- Un lien symbolique stocke un chemin ; un processus est un programme en cours d'exécution.
