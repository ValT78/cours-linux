# TP 1 - Guide tableau et explications globales

Ce document est prévu pour l'enseignant. Il accompagne le TP autonome **Premier contact avec Linux**. L'idée n'est pas de refaire un cours de 90 minutes : chaque arrêt collectif répond à une observation que les élèves viennent réellement de faire.

## Contrat pédagogique de la séance

- **Public :** débutants complets, tout juste sortis du lycée.
- **Expérience recherchée :** « Je peux explorer Linux sans avoir peur ; les choses ont une logique. »
- **Règle de sécurité :** aucune commande avec `sudo`, aucune modification hors de `~/base-exploration`, aucun PID système visé par `kill`.
- **Rythme :** laisser les élèves avancer, puis arrêter le groupe quand environ deux tiers sont arrivés à une même étape. Une explication globale dure 4 à 7 minutes.
- **À éviter :** demander aux rapides d'attendre sans rien faire. Les défis optionnels les occupent ; les notes aident les autres à consolider.

## Déroulé enseignant

| Pause tableau | Moment déclencheur | Durée | Idée à faire retenir |
|---|---|---:|---|
| 1 | après `whoami` | 5 min | terminal, shell et noyau ne sont pas la même chose |
| 2 | après `ls /` | 7 min | une arborescence unique, avec des dossiers qui ont chacun un rôle |
| 3 | après les essais avec `cd`, `..` et `~` | 5 min | un chemin est une succession de portes ; absolu et relatif dépendent du point de départ |
| 4 | après `echo`, `>` et `>>` | 4 min | le shell peut envoyer le texte dans un fichier ou l'ajouter à sa fin |
| 5 | après le `man` et `type cd` | 5 min | le shell interprète, lance des programmes, et certaines commandes lui appartiennent |
| 6 | après les droits sur le coffre | 7 min | les droits portent sur des entrées ; écrire dans un répertoire change sa liste de noms |
| 7 | bonus, après le lien cassé | 4 min | un lien symbolique contient un chemin, pas une copie du fichier |
| 8 | bonus, après `sleep 300 &` | 5 min | programme et processus sont différents ; le shell est le parent du programme lancé |

---

## Pause tableau 1 - Terminal, shell, noyau : qui fait quoi ?

À dessiner ou projeter :

```text
toi
 │ tu écris : ls -l
 ▼
terminal
 │ fenêtre qui affiche du texte et transmet le clavier
 ▼
shell (souvent bash)
 │ comprend la commande et demande son exécution
 ▼
noyau Linux
 │ arbitre les droits, la mémoire, le processeur et les périphériques
 ▼
matériel : processeur, disque, réseau, écran...
```

![Du terminal à Linux : l'élève transmet une commande au terminal, au shell puis au noyau Linux.](../assets/tp1-depart-linux.svg)

À dire simplement :

> Le terminal est la fenêtre. Le shell est le traducteur de vos commandes. Linux, au sens strict, est surtout le noyau qui fait respecter les règles et partage le matériel. Ouvrir un terminal ne vous donne donc pas tous les pouvoirs : vous restez l'utilisateur connecté.

Question à lancer : « Si deux élèves lançaient beaucoup de programmes en même temps, qui décide lequel passe en premier sur le processeur ? »

---

## Pause tableau 2 - La carte du territoire

À dessiner :

```text
/
├── home/       les espaces personnels, par exemple /home/alice
├── root/       l'espace personnel de l'administrateur root
├── etc/        réglages et configuration de la machine
├── tmp/        fichiers temporaires
├── usr/        beaucoup de programmes installés, dont usr/bin/
└── var/        données variables : journaux, cache, files d'attente...
```

![La grande arborescence Linux : tous les dossiers partent de `/`, y compris le dossier personnel de l'élève.](../assets/tp1-arborescence.svg)

Deux points importants :

1. Il n'y a qu'un seul grand arbre qui commence avec `/`, pas un disque `C:` puis un disque `D:` comme dans l'habitude Windows.
2. Selon la distribution, un élève peut voir des différences. Sur beaucoup de Linux récents, `/bin` est un lien symbolique vers `/usr/bin`. Ce n'est pas une anomalie : les noms historiques restent disponibles.

Fait intéressant : `/etc` signifie historiquement « et cetera », le lieu où l'on rangeait diverses configurations. Aujourd'hui, il contient encore une énorme partie des réglages système.

Question : « Dans quel dossier chercheriez-vous un journal qui grossit avec le temps ? Pourquoi ? »

---

## Pause tableau 3 - Les chemins comme déplacement dans un bâtiment

À dessiner :

```text
/
└── home/
    └── alice/
        └── base-exploration/
            └── mission/
                └── briefing/
                    └── objectif.txt
```

Si l'élève est dans `base-exploration/` :

```text
mission/briefing/objectif.txt       chemin relatif
./mission/briefing/objectif.txt     même chemin, . = ici
../                                le dossier parent
~/base-exploration/...               ~ = son dossier personnel
/home/alice/base-exploration/...    chemin absolu, depuis /
```

Phrase utile :

> Un chemin n'est pas l'objet lui-même. C'est l'itinéraire utilisé pour l'atteindre. Un chemin relatif commence là où vous êtes ; un chemin absolu commence toujours à la racine.

Précaution débutants : montrer que `cd` seul ramène habituellement à la maison (`~`), mais présenter cela comme une commodité de Bash plutôt qu'une règle mystérieuse à apprendre d'urgence.

---

## Pause tableau 4 - Les flèches : où part le texte ?

À dessiner :

```text
echo "Bonjour"             texte affiché dans le terminal
echo "Bonjour" > note.txt  texte envoyé dans un fichier ; ancien contenu remplacé
echo "Bonjour" >> note.txt texte ajouté à la fin du fichier
cat < note.txt              contenu du fichier envoyé à cat
```

![Les redirections du shell : `>` remplace le contenu d'un fichier, `>>` ajoute à la fin, et `<` enverra plus tard un fichier vers une commande.](../assets/tp1-redirections.svg)

À dire :

> Les flèches ne font pas partie de `echo`. Elles sont comprises par le shell avant le lancement de la commande. `>` peut effacer l'ancien contenu : c'est utile, mais il faut savoir qu'on le fait. `>>` est fait pour compléter un fichier existant.

---

## Pause tableau 5 - Pourquoi certaines commandes sont « dans » le shell

À dessiner :

```text
shell Bash
 ├── cd       commande interne : elle doit modifier le shell courant
 ├── echo     souvent interne aussi
 └── lance /usr/bin/ls  programme externe, puis attend sa fin
```

À dire :

> `ls` peut être lancé dans un petit processus séparé, faire son travail, puis disparaître. `cd`, lui, doit modifier l'endroit où attend votre shell. Si un programme séparé faisait ce changement, seul ce programme voyagerait : votre terminal resterait au même endroit.

Faire remarquer l'autonomie : même des administrateurs utilisent `man`, `--help` et des recherches. Mémoriser la syntaxe exacte n'est pas le but ; savoir retrouver une information fiable en est un.

---

## Pause tableau 6 - Les droits : ce qui semble paradoxal devient logique

À dessiner :

```text
                     fichier                 répertoire
r (read)       lire son contenu          lister les noms
w (write)      modifier son contenu      ajouter, renommer, supprimer des noms
x (execute)    l'exécuter                traverser le dossier dans un chemin
```

Puis insister sur la différence entre fichier et entrée de répertoire :

```text
mission/coffre/          contient la liste des noms : code.txt, ...
        │
        └── code.txt     est le fichier contenant le texte CODE-ALPHA-42
```

![Les droits Linux : `r`, `w` et `x` ont un sens différent sur un fichier et sur un répertoire.](../assets/tp1-droits.svg)

À dire :

> Supprimer `code.txt`, ce n'est pas « effacer son texte caractère par caractère ». C'est retirer le nom `code.txt` de la liste qui appartient à `coffre/`. Voilà pourquoi le droit important pour supprimer est l'écriture sur le répertoire.

Ne pas approfondir immédiatement les ACL, les permissions numériques et les groupes secondaires : ils seront plus faciles à comprendre après l'expérience présente. En revanche, préciser que l'élève est propriétaire des fichiers qu'il vient de créer : les droits `g` et `o` sont donc observables mais pas pleinement expérimentables sans un second compte.

---

## Pause tableau 7 - Lien symbolique : un panneau, pas un second objet

À dessiner :

```text
acces-rapide  ── contient le texte ──>  briefing/objectif.txt
                                              │
                                              ▼
                                      le véritable fichier
```

À dire :

> Le lien symbolique ne possède pas une copie du briefing. Il mémorise seulement une adresse. Si l'adresse devient fausse, le lien existe toujours mais il ne mène plus nulle part.

Question : « Pourquoi un raccourci peut-il être pratique quand on change souvent l'organisation d'un projet ? »

---

## Pause tableau 8 - Programmes, processus et parenté

À dessiner :

```text
programme : /usr/bin/sleep     fichier immobile sur le disque

shell Bash (PID 4210)
└── sleep 300 (PID 4368)       processus vivant, lancé maintenant
```

![Un programme est un fichier ; lorsqu'il est lancé par le shell, il devient un processus avec son propre PID.](../assets/tp1-processus.svg)

À dire :

> Un même programme peut être lancé dix fois : il y aura alors dix processus différents. Chacun possède un PID. Le shell qui lance la commande est son parent. C'est pourquoi `jobs` sait nous parler des processus lancés depuis ce terminal.

Faire le lien avec la sécurité : tuer sans comprendre peut interrompre un service, couper une interface ou faire perdre du travail. Dans le TP, l'élève ne touche qu'à son propre `sleep` : la conséquence est visible et récupérable.

---

## Réponses aux erreurs les plus fréquentes

| Message ou situation | Ce que cela signifie | Réponse à donner plutôt que la solution |
|---|---|---|
| `No such file or directory` | le chemin ne désigne pas une entrée existante depuis l'endroit courant | « Où es-tu ? Que donne `pwd` ? Que donne `ls` dans le dossier précédent ? » |
| `Permission denied` | le système a refusé l'action demandée | « Quelle action essaies-tu de faire : lire, écrire ou traverser ? Sur quel objet ? » |
| `command not found` | shell ne trouve pas cette commande | « Vérifie l'orthographe, puis demande `type` ou `command -v`. » |
| l'élève a peur de `/` | la racine est simplement le départ de l'arbre | « Observer `ls /` ne modifie rien. On revient avec `cd ~`. » |
| le lien est cassé | la cible a changé ou disparu | « Que montre la flèche de `ls -l` ? Cette adresse existe-t-elle encore ? » |
| `sleep` semble ne rien faire | c'est précisément son travail : attendre | « Vérifie avec `jobs` ou `ps`, sans ouvrir une autre commande dangereuse. » |

## Critères de réussite de la séance

À la fin, un élève débutant doit pouvoir dire, sans vocabulaire parfait :

- « Je sais retrouver où je suis et revenir chez moi. »
- « Je sais que `/` est le départ de tous les dossiers. »
- « Je sais chercher l'aide d'une commande. »
- « Je comprends qu'un droit différent n'a pas le même sens pour un fichier et un dossier. »
- « Je sais qu'un processus est un programme en train de tourner. »

Le meilleur indicateur n'est pas la vitesse de fin du TP : c'est la qualité des formulations dans les notes et la capacité des élèves à expliquer une erreur rencontrée.
