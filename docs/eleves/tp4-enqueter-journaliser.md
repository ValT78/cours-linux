# TP 4 — Enquêter et journaliser sur Aurore

Le relais Aurore reçoit des tentatives de connexion suspectes. Tu vas construire deux scripts pour lire ses traces, puis deux commandes en C pour écrire et suivre un journal en direct.

## Préparer l’atelier

1. Depuis [Linux](../installer-linux.md), télécharge [l’atelier Aurore](../assets/tp4-atelier-journalisation.zip) et décompresse-le **dans ton dossier personnel**.
2. Ouvre un terminal Bash et entre dans le dossier de l’atelier. Tu y trouveras les données et le vérificateur.

```bash
cd ~/atelier-journalisation
ls
```

Travaille dans ce dossier avec ton compte habituel. Si tu reprends le TP plus tard, reviens dans le même dossier.

### Les règles de tes commandes

Écris les résultats sur la sortie standard et les diagnostics sur la sortie d’erreur. Termine avec le statut **0** en cas de succès, **1** si l’appel ou la saisie est incorrect, **2** si le fichier est illisible ou qu’un appel système échoue.

## 1. Écrire un premier filtre

Le fichier `donnees/sonde.txt` mélange alertes, codes et dates. Pour ne retenir que le mot `alerte` seul sur sa ligne, essaie cette commande.

```bash
grep -En '^alerte$' donnees/sonde.txt
```

`grep` affiche les lignes qui correspondent à un motif. `-E` active les expressions régulières étendues et `-n` ajoute les numéros de ligne. `^` marque le début et `$` la fin. Les apostrophes laissent `grep` interpréter le motif.

**Crée `compter_alertes.sh`** dans le dossier de l’atelier. Écris ces deux lignes.

```bash
#!/usr/bin/env bash
grep -Eic '^alerte$' donnees/sonde.txt
```

La première ligne choisit Bash si tu lances le fichier directement. Dans la seconde, `-i` ignore la casse et `-c` compte les lignes au lieu de les afficher.

```bash
bash compter_alertes.sh
```

Tu obtiens `1`. Retire le `$` du motif et relance le script. Tu obtiens `4` car une ligne peut maintenant continuer après `alerte`. Ajoute `-w` pour retenir le mot entier. Le résultat passe à `3`.

### Construire un motif

| Écriture | Ce qu’elle reconnaît |
| --- | --- |
| `.` et `\.` | Un caractère quelconque et un point littéral |
| `[a-z0-9]` et `[^:]` | Une lettre minuscule ou un chiffre ASCII, et un caractère autre que `:` |
| `x*`, `x+` et `x?` | Zéro occurrence ou plus, une ou plus, zéro ou une |
| `x{3}` et `x{2,4}` | Exactement trois occurrences, et deux à quatre |
| <code>(nord&#124;sud)</code> | Un groupe avec deux alternatives, `nord` ou `sud` |
| `[[:blank:]]` | Un espace ou une tabulation |

Dans le motif de chemin `*.txt`, Bash utilise `*` pour une suite de caractères dans un **nom de fichier**. Dans la regex `.*\.txt$`, `grep` utilise `*` pour répéter le `.` et `\.` pour reconnaître un vrai point dans du **texte**.

Dans un nom de fichier, `?` représente un caractère et `[!a-z]` exclut les lettres minuscules. En regex, `?` rend l’élément précédent facultatif et `[^a-z]` exclut ces lettres.

```bash
grep -En '^[0-9]{5}$' donnees/sonde.txt
grep -En '^a.erte$' donnees/sonde.txt
grep -En 'alerte (nord|sud)$' donnees/sonde.txt
```

Le premier filtre garde `75001` seul sur sa ligne. Le deuxième laisse varier un seul caractère. Le troisième choisit une des deux directions. Essaie `-o` pour afficher seulement le morceau reconnu et `-v` pour garder les lignes écartées par le motif. Avec `-r`, `grep` fouille aussi les sous-dossiers.

**Crée `reperer.sh`** pour afficher d’abord les dates seules au format `JJ/MM/AAAA`, puis les heures au format `HH:MM:SS`, même au milieu d’une ligne. Sur `sonde.txt`, tu dois obtenir une date et deux heures.

Ajoute deux filtres sur `donnees/comptes.txt`. Affiche les comptes dont le shell finit par `bash` ou `zsh`, puis ceux dont l’UID, au troisième champ, a quatre chiffres. `[^:]*:` permet de passer un champ. Vérifie que chaque filtre garde trois comptes.

## 2. Construire `lignes_utiles.sh`

Le relais doit pouvoir compter les lignes actives d’une configuration SSH.

**Commande attendue** · `bash lignes_utiles.sh FICHIER`

- Affiche le nombre de lignes utiles avec **un seul appel à `grep`**. Ignore les lignes vides, les lignes faites uniquement d’espaces ou de tabulations et les commentaires, même indentés.
- Exige exactement un argument. Sinon, écris `usage : lignes_utiles.sh FICHIER` sur la sortie d’erreur et termine avec `1`.
- Si le chemin ne désigne pas un fichier ordinaire lisible, écris un diagnostic et termine avec `2`. Vérifie avec `-f` et `-r`.

Commence par afficher les lignes à ignorer avec ton motif. Ancre-le au début, accepte l’indentation, puis cherche un `#` ou la fin de ligne. Inverse la sélection et compte. Pour passer le contenu de n’importe quel fichier à `grep`, utilise `< "$1"`.

Avec GNU `grep`, le statut `0` indique une sélection, `1` une sélection vide, et `2` une erreur. `-q` permet de tester la présence d’une ligne sans l’afficher. Essaie le cas sans correspondance.

```bash
grep -Eq '^intrus$' donnees/sonde.txt
echo "$?"
if grep -Eq '^alerte$' donnees/sonde.txt; then echo 'Alerte détectée'; fi
```

Avec `-c`, `grep` affiche bien `0` quand il ne sélectionne rien, mais renvoie `1`. Récupère `$?` juste après `grep` pour convertir ce cas en succès. En cas d’erreur, garde le statut `2`.

```bash
bash lignes_utiles.sh donnees/sshd_config
bash lignes_utiles.sh donnees/commentaires.conf
echo "$?"
```

Le premier fichier donne `5`. Le second donne `0` avec le statut `0`.

### Vérifier ton script

Après ces essais, lance `bash verifier.sh lignes_utiles`. Le vérificateur compare les résultats et les statuts sur plusieurs fichiers. Relance-le après chaque correction. `bash verifier.sh` affiche les noms disponibles.

Ajoute `#!/usr/bin/env bash` en tête des scripts à rendre. Pour lancer ton script sous la forme `./lignes_utiles.sh FICHIER`, donne-toi le droit de l’exécuter avec `chmod u+x lignes_utiles.sh`.

## 3. Construire `echecs.sh`

Le journal `donnees/auth.log` mélange connexions réussies et échecs. Dans un échec, des mots peuvent s’ajouter avant l’adresse. Extrais donc l’adresse par sa forme.

```bash
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' donnees/auth.log
```

Le groupe « un à trois chiffres suivis d’un point » est répété trois fois, puis viennent les derniers chiffres. Ce motif reconnaît la forme d’une IPv4 et accepte aussi `999.999.999.999`. Dans le journal fourni, chaque échec a une seule adresse source IPv4.

Pour compter des adresses, `sort` rassemble les adresses identiques, puis `uniq -c` compte chaque groupe consécutif. `sort -rn` trie ensuite sur le nombre, en ordre décroissant. `head -n 3` prend les trois premières lignes.

**Commande attendue** · `bash echecs.sh FICHIER`

1. Affiche le nombre de lignes contenant `Failed password`.
2. Affiche les trois adresses les plus fréquentes **dans ces lignes**, chacune précédée de son nombre au format de `uniq -c`. S’il y a moins de trois adresses, affiche celles qui existent. Utilise `sort -rn` pour l’ordre.
3. Applique les mêmes règles d’appel et de lecture que pour `lignes_utiles.sh`. Le message d’usage est `usage : echecs.sh FICHIER`. Un journal sans échec donne uniquement `0` et le statut `0`.

Construis et lance chaque morceau du pipeline avant de l’ajouter au script. Enlève un instant le filtre `Failed password` et compare le classement. Avec le filtre, `bash echecs.sh donnees/auth.log` doit donner ceci.

```text
13
      6 203.0.113.7
      4 198.51.100.23
      2 203.0.113.99
```

Vérifie aussi avec `donnees/sans-echec.log`, puis lance `bash verifier.sh echecs`.

## 4. Écrire et lancer une commande en C

Les deux prochaines commandes utilisent le même principe qu’un script. Le shell leur passe des arguments et récupère leur statut. Pour les compiler et suivre leurs appels système, utilise `gcc` et `strace`. S’ils manquent sur Debian ou Ubuntu, lance `sudo apt update`, puis `sudo apt install build-essential strace man-db manpages-dev`.

### Trois canaux et un statut

Écris `canaux.c`, puis compile-le.

```c
#include <stdio.h>

int main(void)
{
    printf("résultat\n");
    fprintf(stderr, "erreur\n");
    return 300;
}
```

```bash
gcc -Wall -Wextra -Werror -pedantic -o canaux canaux.c
./canaux > sortie.txt
echo "$?"
cat sortie.txt
./canaux 2> erreur.txt > /dev/null && echo succès || echo échec
cat erreur.txt
ls -l /proc/self/fd 2> erreur.txt
```

`-o canaux` nomme l’exécutable et les autres options activent les avertissements et les traitent comme des erreurs. Garde ces options pour les programmes à rendre.

`printf` écrit sur le canal **1**, `fprintf(stderr, …)` sur le **2**. Le shell conserve les huit bits de poids faible du statut, donc `300` donne `44`. `exit(n)`, déclaré dans `<stdlib.h>`, permet aussi de quitter avec un statut. Dans `/proc/self/fd`, `self` désigne ici le processus `ls`. Repère le canal redirigé et celui qui pointe encore vers le terminal.

### Ouvrir, écrire, fermer

Un appel système demande un service au noyau. `open` résout le chemin, vérifie les droits et donne le plus petit **descripteur** libre. C’est généralement `3`, car `0` (entrée), `1` et `2` sont déjà ouverts. Le descripteur est le numéro que tu passes à `read`, `write` et `close`.

| Option de `open` | Effet |
| --- | --- |
| `O_RDONLY` ou `O_WRONLY` | Ouvre en lecture seule ou en écriture seule |
| `O_CREAT` | Crée le fichier s’il manque. Ajoute le mode de création en troisième argument |
| `O_TRUNC` | Vide un fichier ouvert en écriture |
| `O_APPEND` | Place l’écriture à la fin à chaque `write` |

Combine les options avec `|`. `0644` est un mode octal qui demande `rw-r--r--`. Le masque `umask` peut retirer des droits lors de la création. Avec `umask 022`, un nouveau fichier demandé en `0644` a ces droits.

Écris `premier.c`. Il ouvre un fichier, écrit trois octets, puis libère le descripteur.

```c
#include <err.h>
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
    int fd = open("essai.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1)
        err(2, "essai.txt");

    if (write(fd, "abc", 3) == -1)
        err(2, "essai.txt");

    if (close(fd) == -1)
        err(2, "essai.txt");
    return 0;
}
```

`write` reçoit un descripteur, un tampon d’octets et une longueur. Il renvoie le nombre d’octets écrits, parfois inférieur à la demande. `close` rend le numéro disponible et renvoie `0` si tout va bien.

Ces appels renvoient `-1` en cas d’erreur et renseignent `errno`. `err` écrit le nom du programme, le contexte et le message associé à `errno`, puis quitte avec le statut demandé. `warn` affiche ce diagnostic et laisse le programme continuer.

Dans `man 2 open`, la section 2 décrit les appels système. Lis le synopsis pour trouver l’en-tête, puis `RETURN VALUE` et `ERRORS`. Tu y trouveras notamment `ENOENT` pour une entrée introuvable, `EACCES` pour un accès refusé et `EINVAL` pour un argument invalide. Les fonctions de bibliothèque comme `err` sont en section 3.

```bash
gcc -Wall -Wextra -Werror -pedantic -o premier premier.c
./premier
cat essai.txt
```

**Fais évoluer `premier.c`.**

1. Ajoute un second `write` pour écrire `de\n`. Chaque écriture avance la position dans le fichier, de `0` à `3`, puis à `6`. Lance deux fois le programme et vérifie le contenu.
2. Retire `O_TRUNC`, puis teste sur un fichier plus long en lançant `echo 123456789 > essai.txt` avant le programme. Observe la partie qui reste.
3. Modifie le programme pour ajouter une ligne `Bonjour` à la fin de `journal.txt` à chaque appel. Le premier appel doit aussi créer le fichier.

En lecture, avec un descripteur ouvert en `O_RDONLY`, `read(fd, &octet, 1)` essaie de placer un octet dans une variable `char octet`. Il renvoie `1` si l’octet est lu, `0` en fin de fichier ou `-1` en cas d’erreur. Le même déplacement s’applique aux octets lus. `lseek` déplace cette position. `fseek` fait de même pour un flux `FILE *` de la bibliothèque C.

## 5. Construire `ecrire.c`

Pour recevoir les arguments, utilise `int main(int argc, char *argv[])`. `argv[0]` contient le nom de lancement et compte dans `argc`. Avec `./ecrire f.txt Bonjour`, `argc` vaut `3`, `argv[1]` contient le chemin et `argv[2]` le premier mot. `strlen`, déclarée dans `<string.h>`, donne le nombre d’octets d’une chaîne sans le caractère final `\0`.

**Commande attendue** · `./ecrire FICHIER MOT...`

- Avec moins de deux arguments après le nom du programme, affiche `usage : ecrire FICHIER MOT...` sur la sortie d’erreur et renvoie `1`.
- Crée le fichier en demandant `0644` ou vide le fichier existant. Écris les mots dans l’ordre, séparés par un espace, puis un retour à la ligne. Utilise `open`, `write` et `close`. Vérifie chaque appel. En cas de retour `-1`, passe le chemin à `err(2, "%s", argv[1])`.

Commence avec un seul mot. Ajoute ensuite la boucle sur les mots. Pour éviter l’espace final, écris le séparateur **avant** chaque mot à partir du deuxième.

Dans `err(2, "%s", argv[1])`, `"%s"` est le format et `argv[1]` la chaîne à y insérer, comme avec `printf`.

```bash
gcc -Wall -Wextra -Werror -pedantic -o ecrire ecrire.c
./ecrire message.txt Bonjour tout le monde
cat message.txt
./ecrire message.txt 'nouveau message'
cat message.txt
./ecrire dossier-absent/message.txt test
echo "$?"
bash verifier.sh ecrire
```

Le premier contenu est `Bonjour tout le monde`, le second est `nouveau message`. L’ouverture impossible doit donner un diagnostic et le statut `2`.

### Voir ce que le noyau reçoit

```bash
strace -e trace=open,openat,write,close ./ecrire trace.txt Bonjour
```

Cherche l’ouverture de `trace.txt`, puis les écritures et la fermeture sur le même descripteur. `open` peut apparaître comme `openat` dans la trace. Les ouvertures précédentes servent notamment à charger la bibliothèque C. Si ton environnement bloque `strace`, fais l’essai sur le Linux du cours.

## 6. Construire `tictac.c`

`read` en Bash et `scanf` en C lisent l’entrée standard, qu’elle vienne du clavier, d’un fichier ou d’un pipe. `scanf` et `printf` sont des fonctions de bibliothèque. Sous leurs flux, `read` et `write` travaillent avec des descripteurs.

```c
int n;
if (scanf("%d", &n) != 1 || n < 1) {
    fprintf(stderr, "tictac : nombre invalide\n");
    return 1;
}
```

`%d` lit un entier et `&n` donne l’adresse où le ranger. `scanf` doit réussir une conversion avant que tu consultes `n`. Il peut lire un préfixe entier, comme `12` dans `12abc`. Les nombres essayés tiennent dans un `int`.

Prépare chaque ligne dans un tableau de caractères. Par exemple, avec un compteur `i` déjà initialisé à `1` dans le programme.

```c
char ligne[32];
int longueur = snprintf(ligne, sizeof ligne, "tic %d\n", i);
```

`snprintf` (dans `<stdio.h>`) reçoit la capacité du tableau. Ici, la ligne tient dans 32 octets. Sa valeur de retour donne le nombre d’octets à passer à `write`. `sleep(1)`, dans `<unistd.h>`, suspend le processus une seconde sans occuper le processeur.

**Commande attendue** · `./tictac FICHIER`

1. Exige un seul argument. Sinon, écris `usage : tictac FICHIER` sur la sortie d’erreur et renvoie `1`.
2. Affiche `Combien de secondes ?` suivi d’un retour à la ligne. Vide le tampon de sortie avec `fflush(stdout)` pour rendre la question visible avant la lecture, y compris si la sortie est redirigée. Lis `N`. Sur une saisie invalide, affiche `tictac : nombre invalide` sur la sortie d’erreur, renvoie `1` et laisse le fichier intact.
3. Après validation, crée ou vide le fichier comme dans `ecrire`. Écris `tic 1` à `tic N`, une ligne à la fois avec `write`, puis `sleep(1)` à chaque tour. Ferme le fichier, puis affiche `N lignes écrites dans FICHIER` avec les valeurs utilisées. Reprends le traitement des erreurs de `ecrire`.

```bash
gcc -Wall -Wextra -Werror -pedantic -o tictac tictac.c
echo 3 | ./tictac tic.txt
cat tic.txt
echo abc | ./tictac tic.txt
./tictac tic.txt < /dev/null
echo "$?"
bash verifier.sh tictac
```

Après le premier essai, le fichier doit contenir `tic 1`, `tic 2` et `tic 3`. Les deux saisies invalides renvoient `1` et conservent ces trois lignes. Essaie ensuite au clavier.

## 7. Observer ta commande en cours d’exécution

Ouvre deux terminaux dans le même dossier. Note tes observations dans `reponses.txt`.

1. Dans le premier, lance `./tictac obs.txt` et saisis `60`.
2. Dans le second, trouve le processus avec `ps -f -C tictac`. Relève son PID et son PPID. Remplace `PPID` par le numéro du parent dans `ps -fp PPID` pour voir quel programme l’a lancé.
3. Lance `ls -l /proc/PID/fd` en remplaçant `PID` par le numéro de `tictac`. Note vers quoi pointent les descripteurs ouverts et le numéro d’`obs.txt`.
4. Dans le second terminal, lance `tail -f obs.txt`. Dans le premier, fais `Ctrl+Z`, attends cinq secondes puis tape `fg`. Observe le fichier pendant l’arrêt et la reprise. Arrête `tail` avec `Ctrl+C` dans son terminal.
5. Quand la première exécution est terminée, relance `./tictac obs.txt` et saisis `60`. Pendant qu’il écrit, relève son nouveau PID puis lance `kill PID` depuis le second terminal. Relis le fichier et explique ce qu’il reste après l’arrêt.

## Bonus — Résumer et partager les traces

`awk` découpe chaque ligne en champs et applique une action aux lignes sélectionnées. Le séparateur est par défaut une suite de blancs. `-F:` le remplace par `:`. `$0` est la ligne entière, `$1` le premier champ, `NF` le nombre de champs et `NR` le numéro de ligne. `$(NF-1)` désigne l’avant-dernier champ.

```bash
awk -F: '$3 >= 1000 && $7 ~ /bash$/ { print $1, $7 }' donnees/comptes.txt
awk 'BEGIN { print "Bilan" } /Failed password/ { n++ } END { printf "%d échecs sur %d lignes\n", n, NR }' donnees/auth.log
```

Le motif précède `{ action }`. `~` teste une regex sur un champ, `!~` inverse ce test. Sans motif, l’action s’applique à chaque ligne. Sans action, `awk` affiche la ligne retenue. Les variables de calcul, comme `n`, s’utilisent sans `$` et partent de zéro ou d’une chaîne vide selon le contexte. `BEGIN` et `END` s’exécutent une fois, avant et après la lecture. `print` sépare ses arguments par un espace. `printf` utilise le format que tu lui donnes.

`sed -E` accepte les mêmes motifs étendus. `s/motif/remplacement/g` remplace toutes les correspondances de chaque ligne et écrit le résultat sur la sortie standard.

```bash
sed -E 's/[0-9]+/X/g' donnees/sonde.txt
```

**Crée `partager.sh`.** Utilise `awk` pour afficher les échecs et compter leurs lignes, puis réutilise ton motif IPv4 avec `sed` pour masquer les adresses avant de partager le résultat.

## Remettre ton travail

Lance `bash verifier.sh tout`. Dépose **`ecrire.c`, `tictac.c`, `echecs.sh`, `lignes_utiles.sh` et `reponses.txt`** dans l’activité Moodle du TP4. Dépose les cinq fichiers à plat, séparément. Garde les mêmes noms quand tu remplaces une version.

[Manuel de GNU grep](https://www.gnu.org/software/grep/manual/) · [open(2)](https://man7.org/linux/man-pages/man2/open.2.html) · [write(2)](https://man7.org/linux/man-pages/man2/write.2.html) · [scanf(3)](https://man7.org/linux/man-pages/man3/scanf.3.html) · [strace(1)](https://man7.org/linux/man-pages/man1/strace.1.html)
