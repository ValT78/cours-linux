# TP bonus — Aurore, un idle game dans ton terminal

Tu appuies sur **Espace** pour faire avancer ta fusée. Chaque kilomètre te rapporte un crédit. Avec tes premiers crédits, tu peux acheter un moteur qui fait avancer la fusée quand tu lâches le clavier. Ensuite, tu peux ajouter d’autres moteurs et gagner des primes en passant par des planètes.

On va faire ça en Bash, en commençant par un compteur. À la fin, tu tapes `bash fusee.sh` et tu joues directement dans ton terminal.

```text
  ═══════════════ AURORE · VOL LIBRE ═══════════════
  .....🚀...............

  Distance  128 km     Temps de vol  00:42     Solde  118 cr
  Prochaine planète  Vénus (250 km)

  [ESPACE]  Impulsion +8 km        Propulsion auto +1 km/s
  [1]       Propulseur automatique                 INSTALLÉ
  [2]       Booster                                INSTALLÉ
  [3]       Moteur ionique                            50 cr

  > Mars atteinte ! Prime de 30 cr.
  [Q] Quitter
```

## Préparer ton dossier

**Dans ton terminal Linux**, crée ton dossier de jeu.

```bash
mkdir -p ~/base-exploration/aurore
cd ~/base-exploration/aurore
```

Tu commences avec `fusee.sh`. Tu créeras les autres fichiers au moment de t’en servir. Pour reprendre plus tard, reviens dans ce dossier et lance `bash fusee.sh`.

---

## Niveau 1 — Faire décoller la fusée avec Espace

### 1.1 Afficher la distance

Ouvre `nano fusee.sh`. **Dans l’éditeur**, saisis ce premier script.

```bash
#!/usr/bin/env bash
distance=0
printf '%s km\n' "$distance"
```

La première ligne choisit Bash si ton fichier est lancé directement. `distance=0` range la valeur `0` dans la variable `distance`. Colle le `=` à son nom et à sa valeur. `"$distance"` lit ce que tu y as rangé. Dans le format de `printf`, `%s` insère la valeur et `\n` passe à la ligne.

Enregistre avec **Ctrl+O**, confirme avec **Entrée**, puis quitte avec **Ctrl+X**. Lance `bash fusee.sh`. Tu dois voir `0 km`.

### 1.2 Lire une touche sur-le-champ

**Dans le terminal**, tape `bash`, puis exécute la première ligne ci-dessous. Appuie sur **Espace**, puis lance la seconde ligne quand l’invite revient.

```bash
IFS= read -r -s -n 1 touche
printf '<%s>\n' "$touche"
```

`read` range la saisie dans `touche`.

| Élément | Effet |
|---|---|
| `-n 1` | Lit au plus un caractère. Pour Espace ou une lettre, nul besoin d’appuyer sur Entrée. |
| `-s` | Garde la touche invisible pendant la saisie. |
| `-r` | Lit un antislash `\` comme un caractère ordinaire. |
| `IFS=` | Empêche `read` de retirer les espaces autour de la saisie. |

Tu dois voir `< >`. Essaie avec `x` pour obtenir `<x>`. Tu peux comparer avec la même lecture sans `IFS=`. Tape `exit` quand tu as fini l’essai.

### 1.3 Donner la première impulsion

Ce `if` exécute l’affichage si `touche` contient un espace. Garde les guillemets autour des deux valeurs et les espaces autour des crochets. Le `;` sépare le test de `then` sur la même ligne. `fi` ferme le `if`.

```bash
if [ "$touche" = " " ]; then
    printf 'Impulsion !\n'
fi
```

**Dans `fusee.sh`**, garde l’affichage initial, puis lis une touche. Reprends ce `if` pour faire `distance=$((distance + 5))` si c’est Espace. `$((…))` demande un calcul entier et l’affectation range le résultat dans `distance`. Affiche de nouveau la distance après le `fi`.

**Joue.** Appuie sur Espace. Le compteur doit passer de `0 km` à `5 km`. Relance et essaie `x`. La fusée reste à `0 km`.

---

## Niveau 2 — Jouer en continu et dessiner le cockpit

### 2.1 Piloter et quitter avec Q

Une boucle `while` répète les commandes entre `do` et `done` tant que son test réussit. Essaie cet exemple dans le terminal. `-lt` veut dire « inférieur à ». La boucle affiche `0`, `1` et `2`.

```bash
tour=0
while [ "$tour" -lt 3 ]; do
    printf '%s\n' "$tour"
    tour=$((tour + 1))
done
```

Avec `while true`, le test réussit à chaque tour. Tu peux alors décider de sortir avec `break`. Essaie la structure suivante dans Bash avec quelques lettres, puis avec **Q**.

```bash
while true; do
    IFS= read -r -s -n 1 touche || break
    case "$touche" in
        q|Q) break ;;
        *) printf 'Toujours en vol.\n' ;;
    esac
done
```

`case` choisit une branche selon la touche. `q|Q` accepte les deux écritures. `)` ouvre l’action et `;;` la termine. `*` attrape les autres touches et `esac` ferme le `case`. Avec `|| break`, le programme quitte aussi la boucle si la lecture échoue.

**Dans `fusee.sh`**, laisse `distance=0` **avant** le `while`, pour conserver la distance d’un tour au suivant. Dans la boucle, affiche le compteur, lis une touche et traite-la dans un `case`. Utilise `" ")` pour la branche Espace, garde `q|Q)` et retire la branche `*` pour ignorer les autres touches.

**Joue.** Fais Espace, `x`, Espace, Espace et **Q**. Tu dois finir à `15 km`.

### 2.2 Faire glisser la fusée sur l’écran

Un cockpit redessine les mêmes lignes. **Dans le terminal**, essaie la seconde commande après la première.

```bash
printf 'Ancien écran\n'
printf '\033[H\033[JNouvel écran\n'
```

`\033` envoie le caractère spécial Échap. Avec `[H`, le terminal ramène le curseur en haut à gauche. Avec `[J`, il efface depuis le curseur jusqu’en bas. Tu peux alors dessiner une nouvelle image au même endroit.

**Dans `affichage.sh`**, crée ta première fonction. Une fonction est un groupe de commandes que tu peux lancer par son nom. Les commandes entre `{` et `}` attendent que tu appelles `afficher_vol` pour s’exécuter.

```bash
afficher_vol() {
    printf '\033[H\033[J'
    printf '\n  ═══════════════ AURORE · VOL LIBRE ═══════════════\n'
    printf '\n  🚀\n\n'
    printf '  Distance  %s km\n' "$distance"
    printf '\n  [ESPACE] Impulsion    [Q] Quitter\n'
}
```

Sous la première ligne de `fusee.sh`, ajoute ces deux commandes. Remplace ensuite le `printf` du compteur dans ta boucle par `afficher_vol`.

```bash
cd "$(dirname "$0")" || exit 1
source ./affichage.sh
```

`$0` contient le chemin utilisé pour lancer `fusee.sh`. `dirname` en extrait le dossier et `$(…)` récupère le résultat. Ce `cd` place le jeu dans son propre dossier, même si tu le lances de plus loin. En cas d’échec, `exit 1` arrête le script. `source` lit les définitions d’`affichage.sh` dans le même Bash. La fonction peut alors lire `distance` et dessiner le compteur.

### 2.3 Animer une piste sans fin

**Dans le terminal**, essaie `printf '%s\n' "$((9 / 5))" "$((20 % 20))" "$((21 % 20))"`. Tu obtiens `1`, `0`, puis `1`. La division entière coupe la partie décimale. `%` donne le reste de la division, ce qui permet de revenir au début d’une piste de 20 positions.

Dans `afficher_vol`, remplace le `printf` qui dessine la fusée par ce bloc.

```bash
local piste='....................'
local position=$((distance / 5 % 20))
printf '\n  %s🚀%s\n\n' "${piste:0:position}" "${piste:position}"
```

`local` garde ces deux variables à l’intérieur de la fonction. `${piste:0:position}` prend les points avant la fusée. Bash part du caractère `0` et en prend `position`. `${piste:position}` prend tous les points restants. Le dessin revient au départ tous les **100 km**, tandis que la distance continue à grimper.

**Joue.** À 100 km, la fusée revient au bord gauche. À 105 km, elle a déjà glissé d’un cran vers la droite.

---

## Niveau 3 — Te faire payer et ouvrir la boutique

### 3.1 Un kilomètre, un crédit

Initialise `credits=0` dans `fusee.sh`, à côté de `distance=0`. Dans `propulsion.sh`, crée la fonction `avancer`. Elle reçoit la distance à ajouter et verse le même montant en crédits.

```bash
avancer() {
    local gain="$1"
    distance=$((distance + gain))
    credits=$((credits + gain))
}
```

Dans une fonction, `$1` contient son premier argument. Avec `avancer 5`, `gain` vaut 5. Les compteurs `distance` et `credits` restent partagés avec `fusee.sh`, pour que la boucle voie les deux nouvelles valeurs.

Charge `source ./propulsion.sh` sous le premier `source`. Dans la branche Espace, remplace l’addition par `avancer 5`. Dans `afficher_vol`, ajoute `Solde %s cr` à la ligne de distance et passe aussi `"$credits"` à `printf`.

### 3.2 Acheter ton premier moteur

**Essaie dans le terminal** un achat avec exactement 10 crédits, puis avec 9.

```bash
bourse=10
prix=10
if [ "$bourse" -ge "$prix" ]; then
    bourse=$((bourse - prix))
    printf 'Il reste %s crédits.\n' "$bourse"
else
    printf 'Crédits insuffisants.\n'
fi
```

`-ge` veut dire « supérieur ou égal à ». Le prix exact suffit. Les lignes après `else` s’exécutent quand le test est faux. Si tu achètes le moteur après deux impulsions, le solde tombe à zéro et la distance reste à 10 km.

**Dans `boutique.sh`**, écris `prix_auto=10`, puis une fonction `acheter_auto`. Dans cette fonction, enchaîne les trois cas suivants.

1. Si `[ "$auto_installe" -eq 1 ]`, écris dans `message` que le moteur est déjà installé. `-eq` compare deux entiers pour vérifier leur égalité.
2. Sinon, si le solde atteint `prix_auto`, paie le prix, passe `auto_installe` à `1` et annonce l’achat dans `message`. Écris ce deuxième test avec `elif condition; then`.
3. Sinon, annonce qu’il manque des crédits. Ferme le `if` avec `fi`.

**Dans `fusee.sh`**, charge `source ./boutique.sh`. Avant la boucle, initialise `auto_installe=0` et `message=''`. Deux apostrophes accolées représentent un texte vide. Ajoute `1) acheter_auto ;;` au `case`.

### 3.3 Allumer la boutique

Dans `affichage.sh`, ajoute une fonction pour dessiner une ligne d’équipement. La même fonction servira pour les trois achats.

```bash
afficher_article() {
    local touche="$1" nom="$2" prix="$3" installe="$4"
    local etat="$prix cr" couleur=90
    if [ "$installe" -eq 1 ]; then
        etat='INSTALLÉ'
        couleur=32
    elif [ "$credits" -ge "$prix" ]; then
        couleur=33
    fi
    printf '  \033[%sm[%s]  %-24s  %s\033[0m\n' "$couleur" "$touche" "$nom" "$etat"
}
```

Les quatre arguments donnent la touche, le nom, le prix et l’état de l’achat. `\033[` suivi du code et de `m` change la couleur. Le prix est gris (90), jaune (33) si tu peux l’acheter, et l’état installé est vert (32). `\033[0m` rétablit la couleur du terminal. `%-24s` réserve au nom au moins 24 caractères et l’aligne à gauche.

Dans `afficher_vol`, sépare le rappel Espace du rappel Q. Entre les deux, appelle `afficher_article 1 'Propulseur automatique' "$prix_auto" "$auto_installe"`, puis ajoute une ligne `printf '  > %s\n' "$message"` pour le retour sur l’achat.

**Joue.** Essaie **1** à 0 crédit. Fais deux impulsions, achète à 10 crédits et regarde le solde revenir à zéro pendant que la distance reste à 10 km. Regagne 10 crédits, puis essaie de racheter le moteur. Tes 10 crédits doivent rester en caisse. Tu viens de poser la boutique. Il reste à faire tourner le moteur.

---

## Niveau 4 — Lâcher le clavier et regarder la fusée filer

### 4.1 Réveiller la boucle chaque seconde

**Dans Bash**, essaie cette lecture et attends sans rien taper. Recommence en appuyant sur une lettre avant la fin du délai.

```bash
IFS= read -r -s -n 1 -t 1 touche
printf '<%s>\n' "$touche"
```

Avec `-t 1`, `read` attend au plus une seconde. La boucle peut donc reprendre la main pour faire avancer la fusée même quand tu ne touches à rien.

Essaie aussi ce petit chronomètre.

```bash
depart=$SECONDS
sleep 2
printf '%s secondes écoulées\n' "$((SECONDS - depart))"
```

`SECONDS` est une variable de Bash qui compte le temps en secondes entières. Soustrais la valeur de départ pour mesurer le temps écoulé. Dans le jeu, `read` se charge de l’attente tout en restant disponible pour le clavier.

### 4.2 Brancher le moteur sur le chronomètre

Dans `fusee.sh`, initialise ces quatre variables avant la boucle.

```bash
vitesse_auto=0
depart_vol=$SECONDS
dernier_temps=$depart_vol
temps_vol=0
```

Dans `boutique.sh`, ajoute 1 à `vitesse_auto` quand l’achat du premier moteur réussit. Dans `propulsion.sh`, écris `avancer_auto`. La fonction reçoit le nombre de secondes écoulées, le multiplie par `vitesse_auto` et donne le résultat à `avancer`. Par exemple, à 1 km/s, `avancer_auto 3` doit faire gagner 3 km et 3 crédits.

**Dans la boucle**, remplace l’ancienne ligne de lecture par ce bloc, juste avant le `case`.

```bash
if ! IFS= read -r -s -n 1 -t 1 touche; then
    [ -t 0 ] || break
    touche=''
fi

maintenant=$SECONDS
temps_vol=$((maintenant - depart_vol))
avancer_auto "$((maintenant - dernier_temps))"
dernier_temps=$maintenant
```

`!` inverse le résultat de `read`. Si aucune touche n’arrive avant la fin du délai, `touche=''` empêche le `case` de rejouer une commande. `[ -t 0 ]` vérifie que l’entrée du programme vient d’un terminal. `|| break` permet de s’arrêter si tu as lancé le jeu avec une entrée redirigée et que la lecture échoue. Le reste du bloc compte le temps passé depuis le dernier tour. Dix touches dans une même seconde ne font pas passer dix secondes. Un achat prend effet à partir du tour où tu le fais.

### 4.3 Afficher le temps de vol

Dans `afficher_vol`, ajoute le temps de vol à côté de la distance et du solde. Essaie d’abord `temps_vol=65` avec ce format dans Bash.

```bash
printf 'Temps de vol  %02d:%02d\n' "$((temps_vol / 60))" "$((temps_vol % 60))"
```

Tu dois voir `01:05`. `%02d` affiche un entier sur au moins deux chiffres, en ajoutant un zéro au besoin. Tu peux combiner les trois valeurs sur la même ligne du cockpit.

```bash
printf '  Distance  %s km     Temps de vol  %02d:%02d     Solde  %s cr\n' \
    "$distance" "$((temps_vol / 60))" "$((temps_vol % 60))" "$credits"
```

Un antislash en fin de ligne permet de continuer la même commande à la ligne suivante. À côté de la commande Espace, affiche aussi la vitesse avec `Propulsion auto +%s km/s` et `"$vitesse_auto"`.

**Joue.** Attends quelques secondes au départ. Le temps avance et la distance reste à zéro. Achète le moteur et lâche le clavier. À chaque seconde, la distance et le solde gagnent tous les deux 1. Tape quelques `x` pendant que la fusée avance et observe que sa vitesse reste à 1 km/s.

---

## Niveau 5 — Monter ta propre configuration de vol

| Touche | Équipement | Coût | Effet |
|---|---|---:|---|
| **1** | Propulseur automatique | 10 cr | Ajoute **1 km/s** |
| **2** | Booster | 30 cr | Une impulsion passe de **5 à 8 km** |
| **3** | Moteur ionique | 50 cr | Ajoute **2 km/s** |

**Construis le booster.** Initialise `impulsion=5` et `booster_installe=0` dans `fusee.sh`. Dans la branche Espace, appelle `avancer "$impulsion"`. Dans `boutique.sh`, ajoute `prix_booster=30` et écris `acheter_booster` avec les trois cas du premier achat. En cas de succès, le booster passe à l’état installé et `impulsion` vaut `8`. Branche la fonction sur **2** et ajoute la ligne correspondante dans `afficher_vol` avec `afficher_article`. Affiche aussi la valeur d’`impulsion` sur la ligne Espace.

**Ajoute le moteur ionique.** Reprends le même principe avec `ionique_installe=0`, `prix_ionique=50` et la fonction `acheter_ionique`, branchée sur **3**. Lors de l’achat, augmente la vitesse de 2 avec `vitesse_auto=$((vitesse_auto + 2))`. Ajoute sa ligne d’achat au cockpit.

**Joue.** Prends le booster seul après six impulsions. L’impulsion suivante t’amène à 38 km et te laisse 8 crédits. Relance et achète les deux moteurs automatiques. Quel que soit l’ordre des achats, la vitesse doit atteindre 3 km/s. Laisse la fusée tourner au-delà de 200 km et regarde le compteur poursuivre sa course.

---

## Niveau 6 — Partir à la chasse aux planètes

Chaque planète est un palier. Lorsque tu l’atteins ou la dépasses, tu encaisses une prime et tu continues ton vol. Choisis leur nom et leur distance dans un fichier que tu peux modifier entre deux parties.

### 6.1 Préparer la carte du vol

**Dans `planetes.txt`**, écris ces trois lignes. Chaque ligne contient la distance en kilomètres, le nom et la prime en crédits. Garde des distances entières, positives et strictement croissantes. Choisis des primes entières positives et écris les nombres sans zéro devant, comme `100`.

```text
100|Mars|30
250|Vénus|70
600|Neptune|150
```

Dans Bash, essaie de lire la première planète.

```bash
IFS='|' read -r seuil nom prime < planetes.txt
printf 'À %s km, %s rapporte %s cr.\n' "$seuil" "$nom" "$prime"
```

`<` donne le fichier à `read`. Avec `IFS='|'`, les barres verticales séparent les trois champs. Bash les range dans `seuil`, `nom` et `prime`.

### 6.2 Charger tous les paliers

Un tableau garde plusieurs valeurs sous un même nom. Essaie `noms=('Mars' 'Vénus')` puis `printf '%s\n' "${noms[0]}" "${noms[1]}"` dans Bash. Le premier élément se trouve à l’indice 0. Dans le jeu, utilise le même indice pour retrouver le seuil, le nom et la prime d’une planète.

**Dans `planetes.sh`**, ajoute la fonction suivante.

```bash
charger_planetes() {
    local seuil nom prime
    seuils=()
    noms=()
    primes=()
    while IFS='|' read -r seuil nom prime || [ -n "$seuil" ]; do
        if [ -n "$seuil" ]; then
            seuils+=("$seuil")
            noms+=("$nom")
            primes+=("$prime")
        fi
    done < "$1"
}
```

`=()` crée un tableau vide. `+=("valeur")` lui ajoute une entrée. La redirection placée après `done` donne le même fichier à toute la boucle. Chaque `read` lit une nouvelle ligne. `-n` vérifie qu’un texte contient au moins un caractère. Le test après `||` récupère aussi la dernière ligne si elle se termine sans retour à la ligne. Une ligne vide est ignorée.

Dans `fusee.sh`, ajoute `source ./planetes.sh` en haut. Avant la boucle, initialise `index_planete=0` et appelle `charger_planetes planetes.txt`.

### 6.3 Verser la prime au bon moment

Dans `planetes.sh`, écris la fonction `visiter_planetes`. Son point de départ est toujours la prochaine planète à visiter.

1. Tant que `[ "$index_planete" -lt "${#seuils[@]}" ]`, il reste une planète. `${#seuils[@]}` donne le nombre de seuils chargés.
2. Récupère le seuil courant avec `"${seuils[index_planete]}"`. Si la fusée est encore en deçà du seuil, utilise `break` pour sortir de cette boucle.
3. À partir du seuil, ajoute `${primes[index_planete]}` à `credits`, écris dans `message` le nom et le montant de la prime, puis augmente `index_planete` de 1. La boucle regarde aussitôt si un autre palier a été franchi.

Dans `propulsion.sh`, appelle `visiter_planetes` à la fin d’`avancer`. Les impulsions et les moteurs automatiques déclenchent donc tous les deux les visites. Le déplacement du curseur vers la planète suivante empêche de toucher deux fois la même prime.

**Dans `afficher_vol`**, reprends le test du nombre de seuils juste sous les compteurs. S’il en reste, affiche `Prochaine planète` avec `"${noms[index_planete]}"` et `"${seuils[index_planete]}"`. Sinon, affiche `Toutes les planètes visitées · Vol libre`. La partie continue jusqu’à ce que tu appuies sur **Q**.

**Joue.** Passe Mars et vérifie que ton solde gagne la prime en plus des crédits du trajet. Pour rendre le cas limite visible, déplace provisoirement les deux premiers paliers à 3 et 4 km dans `planetes.txt`. Au premier Espace, tu dois voir 5 km parcourus, deux primes versées et Neptune comme prochaine planète. Rétablis les distances, puis ajoute ta propre destination après Neptune.

---

## Ton jeu est prêt à décoller

Lance `bash fusee.sh` et fais une démonstration. Donne tes premières impulsions, paie ton moteur, puis laisse quelqu’un regarder le compteur grimper tout seul. Choisis ensuite tes propres prix ou ajoute une planète à la carte.

| Fichier | Ce qu’il contient |
|---|---|
| `fusee.sh` | Les réglages de départ, le chronomètre et les touches du jeu |
| `affichage.sh` | Le cockpit, les couleurs et les lignes de boutique |
| `propulsion.sh` | Les kilomètres et les crédits gagnés en avançant |
| `boutique.sh` | Les prix et les achats |
| `planetes.sh` | Le chargement des paliers, les visites et leurs primes |
| `planetes.txt` | Les destinations que tu as choisies |

Garde ensemble les six fichiers pour rejouer ou montrer ton jeu. Ce bonus est un projet personnel. Aucun dépôt sur Moodle.

### Pour aller plus loin — Reprendre après avoir fermé le terminal

Enregistre les valeurs dans la branche de **Q** avec `printf '%s\n' "$distance" "$credits" > partie.txt`. `>` envoie la sortie vers le fichier et remplace la sauvegarde précédente. Au lancement, teste `[ -f partie.txt ]` et relis les deux lignes dans le même ordre avec `read`. Ajoute ensuite les achats, le temps de vol et l’indice de la prochaine planète. Retrouve la vitesse et la force de l’impulsion à partir des achats. Pour reprendre le chronomètre avec le temps chargé, recule `depart_vol` d’autant et initialise `dernier_temps` à l’heure de reprise. Garde le même fichier de planètes pour cette partie.

Quand la reprise fonctionne, essaie `date +%s`. Cette commande donne un nombre de secondes que tu peux enregistrer en quittant, puis soustraire à la valeur obtenue à la reprise. Tu peux ainsi verser la production automatique pour le temps passé hors du jeu en réutilisant `avancer_auto`.
