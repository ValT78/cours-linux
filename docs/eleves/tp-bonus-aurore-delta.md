# TP bonus — Aurore, décollage vers DELTA

Grâce au signal retrouvé dans les journaux d’Aurore, on sait où se trouve la balise 7. Une fusée de secours est prête à partir. Au décollage, elle n’a qu’un propulseur manuel. À toi de l’équiper pour rejoindre le secteur DELTA, à 200 km.

**Ton premier défi** tient en une phrase. Fais avancer la fusée de 5 km chaque fois que tu appuies sur **Espace**. Tu lui ajouteras ensuite un tableau de bord, une boutique et des moteurs qui la font avancer pendant que tu lâches le clavier. C’est le principe d’un *idle game*.

Ce TP est facultatif. Essaie chaque exemple, puis réutilise-le dans ton jeu. À la fin de chaque niveau, joue une courte partie et vérifie ce que tu viens d’ajouter.

## Installer l’atelier

**Dans ton terminal Linux**, crée le dossier de travail.

```bash
mkdir -p ~/base-exploration/tp-bonus
cd ~/base-exploration/tp-bonus
```

Télécharge [l’archive de l’atelier](../assets/tp-bonus-aurore.zip) et place-la dans ce dossier. Depuis Linux, tu peux aussi la télécharger avec cette commande.

```bash
wget https://valt78.github.io/cours-linux/assets/tp-bonus-aurore.zip
```

**Dans le terminal**, décompresse et ouvre l’atelier.

```bash
unzip tp-bonus-aurore.zip
cd atelier-aurore-delta
ls
```

`affichage.sh` contient le tableau de bord. `verifier.sh` lance les essais, avec Python 3. Tu écris tout ton jeu dans un seul fichier, **`fusee.sh`**. Garde les fichiers fournis à côté.

**Pour reprendre**, reviens dans `~/base-exploration/tp-bonus/atelier-aurore-delta`. Tu peux directement relancer le jeu avec `bash fusee.sh`.

---

## Niveau 1 — Faire décoller la fusée

### 1.1 Afficher le compteur

**Dans le terminal**, ouvre ton fichier avec `nano fusee.sh`. **Dans l’éditeur**, écris ce premier script.

```bash
#!/usr/bin/env bash
distance=0
printf '%s km\n' "$distance"
```

La première ligne indique quel interpréteur doit lire le fichier si tu le lances directement. `distance=0` donne la valeur `0` à la variable `distance`. Colle le signe `=` à son nom et à sa valeur. `"$distance"` lit cette valeur pour la donner à `printf`. Dans le format, `%s` réserve la place de la valeur et `\n` passe à la ligne.

Enregistre avec **Ctrl+O**, confirme avec **Entrée**, puis quitte avec **Ctrl+X**. **Dans le terminal**, lance le script.

```bash
bash fusee.sh
```

Tu dois voir `0 km`. Essaie avec `distance=12`, puis remets le compteur à zéro.

### 1.2 Lire Espace sans attendre Entrée

**Dans le terminal**, ouvre un Bash en tapant `bash`. Essaie cette commande, puis appuie sur **Espace**. Quand l’invite revient, exécute la seconde ligne.

```bash
IFS= read -r -s -n 1 touche
printf '<%s>\n' "$touche"
```

`read` place ce qu’il a lu dans la variable `touche`.

| Élément | Effet |
|---|---|
| `-n 1` | Lit au plus un caractère. Pour Espace ou une lettre, tu peux agir sans appuyer sur Entrée. |
| `-s` | Garde la touche invisible pendant la saisie. |
| `-r` | Lit un antislash `\` comme un caractère ordinaire. |
| `IFS=` | Désactive la séparation et le retrait des espaces pour cette commande. Un seul espace reste bien dans `touche`. |

Tu dois voir `< >`. Essaie de nouveau avec la lettre `x` et observe `<x>`. Tape `exit` pour revenir à ton shell habituel.

### 1.3 Ajouter 5 km

Dans cet exemple, Bash exécute les lignes entre `then` et `fi` si le texte contenu dans `touche` est égal à un espace. Garde les espaces autour de `[` et `]` et les guillemets autour de `" "`.

```bash
if [ "$touche" = " " ]; then
    printf 'Une impulsion !\n'
fi
```

Le `;` termine le test et permet d’écrire `then` sur la même ligne. Pour calculer une nouvelle valeur, utilise une expression arithmétique comme `distance=$((distance + 5))`. À l’intérieur de `$((…))`, Bash comprend `distance` comme un nombre et renvoie le résultat de l’addition. L’affectation range ce résultat dans `distance`.

**À toi de jouer.** Dans `fusee.sh`, garde l’affichage initial, lis une touche, puis ajoute 5 à `distance` si c’est Espace. Affiche le compteur après le `if`. Relance une fois avec Espace et une fois avec `x`. Tu dois obtenir `0 km` puis `5 km` au premier essai, et rester à `0 km` au second. Les deux essais se terminent après une touche.

Quand ça marche, lance le testeur.

```bash
bash verifier.sh niveau-1
```

Il envoie des touches à ton script et compare le résultat attendu avec le résultat obtenu. En cas d’écart, corrige ton script puis relance le même test. Si Bash signale une erreur de syntaxe, `bash -n fusee.sh` permet de la retrouver sans jouer la partie.

---

## Niveau 2 — Enchaîner les impulsions et faire bouger la fusée

### 2.1 Garder une partie ouverte

**Dans le terminal**, essaie cette boucle en lançant d’abord `bash`.

```bash
compteur=0
while [ "$compteur" -lt 3 ]; do
    printf '%s\n' "$compteur"
    compteur=$((compteur + 1))
done
```

`while` vérifie le test avant chaque tour. `-lt` signifie « inférieur à ». `do` ouvre les commandes à répéter et `done` les ferme. Tu dois voir `0`, `1`, puis `2`. Avec `while true; do`, la condition réussit à chaque tour. Tu peux alors utiliser `break` pour sortir de la boucle.

Quand plusieurs touches déclenchent des actions différentes, `case` permet de leur donner chacune une branche. **Essaie dans le même Bash** une touche quelconque, puis **Q**.

```bash
while true; do
    IFS= read -r -s -n 1 touche || break
    case "$touche" in
        q|Q) break ;;
        *) printf 'Toujours en vol.\n' ;;
    esac
done
```

`q|Q` accepte les deux écritures. Le `)` ouvre l’action et `;;` termine la branche. `*` accepte toute touche restante et `esac` ferme le `case`. `|| break` sort de la boucle si `read` échoue, par exemple si l’entrée se ferme. Termine cet essai avec `exit`.

**Dans `fusee.sh`**, initialise `distance` une fois, **avant** la boucle. Dans la boucle, affiche la distance, puis lis la touche. Remplace ton `if` par un `case`. Ajoute une branche `" ")` pour l’impulsion et garde la branche `q|Q)` pour quitter. Tu peux ignorer les autres touches en omettant `*`.

Essaie avec Espace, `x`, Espace, Espace et **Q**. Le compteur se termine à `15 km`. À chaque tour, il repart de la distance que tu as accumulée.

### 2.2 Relier le compteur à la piste

Sur la piste, chaque segment représente 10 km. Essaie ce calcul **dans le terminal**.

```bash
printf '%s\n' "$((9 / 10))" "$((10 / 10))" "$((19 / 10))"
```

Tu obtiens `0`, `1`, `1`. Bash fait une division entière. À 9 km, la fusée est encore au départ. À 10 km, elle passe au premier segment. Le dernier repère se trouve à 200 km, après 20 segments.

**Dans `fusee.sh`**, sous la première ligne du fichier, charge l’affichage fourni avec `source ./affichage.sh`. `source` lit un fichier Bash dans le script en cours. Il rend ici disponibles les fonctions d’affichage, des groupes de commandes que tu peux appeler par leur nom.

Au début de chaque tour, remplace le `printf` du compteur par ces lignes, juste avant de lire la touche.

```bash
case_fusee=$((distance / 10))
afficher_vol "$case_fusee" "$distance"
printf '  [ESPACE] Impulsion manuelle  +5 km\n'
afficher_commandes
```

`afficher_vol` reçoit la position sur la piste, puis la distance à afficher. Le tableau de bord garde la fusée au dernier repère si le compteur dépasse 200 km. `afficher_commandes` affiche le rappel pour quitter. Lance le jeu et observe le premier déplacement de la fusée au deuxième appui sur Espace.

```bash
bash verifier.sh niveau-2
```

---

## Niveau 3 — Ouvrir la boutique

### 3.1 Gagner des crédits en avançant

Pour l’instant chaque impulsion donne 5 km. Ajoute `credits=0` avant la boucle. Dans la branche Espace, ajoute aussi 5 à `credits`. Chaque kilomètre parcouru rapporte un crédit.

Tu vas dépenser ces crédits sans reculer. Après deux impulsions, tu auras 10 km au compteur et 10 crédits. Après l’achat, tu seras encore à 10 km avec un solde de 0.

Initialise aussi `auto_installe=0` et `message=''` avant la boucle. `auto_installe` vaut `0` si le propulseur est absent et `1` s’il est installé. `message` est le texte que tu veux montrer après une tentative d’achat. Les deux apostrophes accolées créent un texte vide.

**Dans la boucle**, remplace le `printf` qui affiche la commande Espace par la première ligne ci-dessous. Passe ensuite `message` à `afficher_commandes`.

```bash
afficher_boutique "$credits" "$auto_installe"
afficher_commandes "$message"
```

Le tableau indique le solde, la commande Espace et le prix du premier propulseur. Essaie deux impulsions. Le prix passe du gris au jaune quand tu peux l’acheter.

### 3.2 Autoriser l’achat au prix exact

**Dans le terminal**, essaie ce calcul. Puis recommence avec un solde de `9`.

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

`-ge` compare deux entiers et signifie « supérieur ou égal à ». Avec exactement 10 crédits, tu peux payer 10 crédits. `else` s’exécute quand le test est faux.

**Dans `fusee.sh`**, ajoute une branche `1)` à ton `case`. Fais choisir le message et l’action dans cet ordre.

1. Si `[ "$auto_installe" -eq 1 ]`, indique que le propulseur est déjà installé. `-eq` compare deux entiers pour vérifier leur égalité.
2. Sinon, si les crédits suffisent, enlève 10 crédits, mets `auto_installe` à `1` et annonce l’installation. Écris ce deuxième test avec `elif condition; then` dans le même `if`.
3. Sinon, indique qu’il manque des crédits. Ferme le `if` avec `fi`, puis la branche `1` avec `;;`.

Essaie d’acheter à `0` crédit. Puis, à `10` crédits, observe le solde revenir à `0` et le mot `INSTALLÉ` apparaître en vert. Regagne 10 crédits et essaie de racheter le propulseur. Le solde doit rester à 10.

```bash
bash verifier.sh niveau-3
```

---

## Niveau 4 — Avancer même quand tu lâches le clavier

### 4.1 Donner un délai à la lecture

**Dans le terminal**, ouvre un Bash et lance ces deux lignes. À ton premier essai, attends sans toucher au clavier. Pour le second, appuie sur une lettre avant la fin du délai.

```bash
IFS= read -r -s -n 1 -t 1 touche
printf 'Statut %s\n' "$?"
```

Avec `-t 1`, `read` attend au plus une seconde. `$?` donne le statut de la commande juste exécutée. `0` indique que Bash a lu une touche. Observe le statut non nul quand le délai expire. Une entrée fermée donne `1`. Garde le statut tout de suite si tu dois l’utiliser plus loin.

Toujours dans ce Bash, relève la valeur de `SECONDS` à deux moments.

```bash
depart=$SECONDS
sleep 2
printf '%s secondes écoulées\n' "$((SECONDS - depart))"
```

`SECONDS` compte le temps en secondes entières depuis le lancement de Bash. `sleep 2` marque une pause de deux secondes pour l’essai. Dans le jeu, c’est `read` qui attend, tout en restant disponible pour une touche. Tape `exit` pour revenir à ton shell habituel.

### 4.2 Calculer le déplacement dans une fonction

Une fonction regroupe des commandes sous un nom. Essaie cet exemple dans le terminal.

```bash
estimer_trajet() {
    local secondes="$1"
    local trajet=$((secondes * 2))
    printf '%s km\n' "$trajet"
}
estimer_trajet 5
```

`nom() {` ouvre la définition et `}` la ferme. Le code s’exécute à l’appel `estimer_trajet 5`. Dans la fonction, `$1` contient le premier argument, ici `5`. `local` garde une variable dans la fonction. Tu dois voir `10 km`.

**Dans `fusee.sh`**, écris la fonction `avancer_auto` juste après `source`. Elle reçoit le nombre de secondes écoulées. Garde ce nombre dans une variable locale et calcule le gain en le multipliant par `vitesse_auto`. Ajoute le gain à **`distance` et à `credits`**. Ces trois variables sont partagées avec la partie. Garde les deux compteurs modifiables depuis la fonction en évitant de les déclarer avec `local`.

### 4.3 Brancher la fonction sur la boucle

Dans les réglages de départ, ajoute `vitesse_auto=0` et `dernier_temps=$SECONDS` avant la boucle. Dans la branche `1`, passe `vitesse_auto` à `1` au moment de l’achat réussi. Ajoute `"$vitesse_auto"` comme troisième argument de `afficher_boutique` pour afficher la vitesse.

Remplace l’ancienne ligne `read` par ce bloc, entre l’affichage de l’écran et le `case`.

```bash
IFS= read -r -s -n 1 -t 1 touche
statut=$?
if [ "$statut" -eq 1 ] && [ ! -t 0 ]; then
    break
fi

maintenant=$SECONDS
ecoule=$((maintenant - dernier_temps))
avancer_auto "$ecoule"
dernier_temps=$maintenant

if [ "$statut" -ne 0 ]; then
    touche=''
fi
```

`&&` exige que les deux tests réussissent. `[ ! -t 0 ]` vérifie que l’entrée, désignée par `0`, ne vient pas d’un terminal. Le premier `if` permet au jeu de s’arrêter quand le testeur ferme son entrée. Au clavier, le jeu continue même si ta version de Bash renvoie `1` à l’expiration du délai.

La fonction de propulsion reçoit le temps écoulé après chaque lecture, avec ou sans touche. Si plusieurs tours ont lieu dans la même seconde, ils ajoutent 0 km. Le calcul se fait avant l’achat, donc le moteur démarre au moment où tu l’installes. Enfin, `-ne 0` teste si `read` a renvoyé un statut différent de zéro. Dans ce cas, vide `touche` pour qu’aucune commande ne parte au moment où le délai expire.

**Joue une partie.** Attends avant d’acheter et observe `0 km/s`. Achète le propulseur à 10 km, relâche le clavier et regarde la distance et le solde augmenter ensemble. Appuie plusieurs fois sur `x` et observe que les touches inconnues laissent la propulsion continuer à 1 km/s.

### 4.4 Tester cinq secondes sans attendre

Pour que le vérificateur puisse appeler `avancer_auto` directement, place les réglages de départ et ta boucle dans une fonction `jouer`. Laisse `source` et la définition de `avancer_auto` au-dessus de `jouer`. Voici la structure à obtenir avec ton code.

```bash
#!/usr/bin/env bash
source ./affichage.sh

avancer_auto() {
    # Ton calcul de propulsion automatique.
    :
}

jouer() {
    # Tes réglages de départ et ta boucle while.
    :
}

if [ "$1" != '--fonctions' ]; then
    jouer
fi
```

Les lignes `:` servent de repères. Cette commande ne fait rien. Remplace-les par tes commandes. Hors des fonctions, `$1` désigne le premier argument reçu par le script. Avec `bash fusee.sh`, il est vide et `!=` confirme qu’il diffère de `--fonctions`. Le vérificateur charge ton fichier avec cet argument pour disposer de `avancer_auto` sans lancer la partie.

```bash
bash verifier.sh niveau-4
```

Le testeur simule cinq secondes à 0 km/s, puis à 1 km/s. Vérifie aussi que tu peux encore jouer avec `bash fusee.sh`.

---

## Niveau 5 — Équiper la fusée et atteindre DELTA

| Touche | Équipement | Coût | Effet |
|---|---|---:|---|
| **1** | Propulseur automatique | 10 crédits | Ajoute **1 km/s** |
| **2** | Booster | 30 crédits | Fait passer une impulsion d’Espace de **5 à 8 km** |
| **3** | Moteur ionique | 50 crédits | Ajoute **2 km/s** |

### 5.1 Donner plus de force à Espace

**Dans `jouer`**, initialise `impulsion=5` et `booster_installe=0`. Dans la branche Espace, utilise `impulsion` pour calculer le gain de distance et de crédits. Par exemple, `distance=$((distance + impulsion))` ajoute la valeur actuelle d’`impulsion`.

Construis la branche `2)` en reprenant les trois cas de l’achat du premier propulseur. Ici le prix est de 30 crédits. Après l’achat, `booster_installe` passe à `1` et `impulsion` à `8`. Ajoute `"$impulsion" "$booster_installe"` à la fin de ton appel à `afficher_boutique`.

Essaie le booster seul. Pars de 0, fais six impulsions, achète avec **2**, puis appuie sur Espace. Tu dois voir `38 / 200 km` et `8` crédits.

### 5.2 Cumuler deux moteurs automatiques

Initialise `ionique_installe=0` dans `jouer`. Ajoute la branche `3)` et fais payer 50 crédits une seule fois. Pour augmenter la vitesse, utilise `vitesse_auto=$((vitesse_auto + 2))` quand l’achat réussit. Dans la branche du premier propulseur, ajoute `1` à la vitesse au lieu de lui donner la valeur `1`. Essaie les deux ordres d’achat. Dans les deux cas, la vitesse finale doit être de 3 km/s.

Passe maintenant les six valeurs à l’affichage, dans cet ordre.

```bash
afficher_boutique "$credits" "$auto_installe" "$vitesse_auto" "$impulsion" "$booster_installe" "$ionique_installe"
```

Quand la fusée est en vol, tu peux obtenir un écran comme celui-ci.

```text
  AURORE  /  VOL DE SECOURS VERS DELTA

  DÉPART ━━━━━━🚀━━━━━━━━━━━━━━ DELTA
                 65 / 200 km

  Crédits   25              Propulsion auto   +1 km/s

  [ESPACE]  Impulsion manuelle  +8 km
  [1]  Propulseur automatique    INSTALLÉ
  [2]  Booster                   INSTALLÉ
  [3]  Moteur ionique            50 crédits

  > Booster installé. Prochaine impulsion à +8 km.

  [Q] Quitter
```

### 5.3 Terminer le vol

À 197 km, une impulsion de 8 km t’amène directement à 205 km. Utilise `-ge` pour déclencher l’arrivée dès que le compteur atteint **ou dépasse** 200 km.

**Dans la boucle de `jouer`**, ajoute le test d’arrivée après l’affichage du tableau de bord, juste avant de lire une nouvelle touche. Quand le test est vrai, affiche la phrase suivante avec la distance parcourue, puis sors de la boucle avec `break`.

```bash
printf '\nDELTA atteint à %s km !\n' "$distance"
```

Teste un vol au clavier. Puis fais un vol où tu achètes au moins un moteur et le laisses franchir la ligne d’arrivée sans appuyer sur une touche. Dans les deux cas, tu dois voir la fusée au dernier repère, le message d’arrivée et le retour au terminal.

```bash
bash verifier.sh niveau-5
```

Le vérificateur essaie le booster, cumule les deux moteurs et fait passer la fusée de 197 à 205 km. Quand tu peux rejoindre DELTA avec les commandes de ton jeu, ta mission est terminée. Garde `fusee.sh` dans ton atelier pour rejouer ou continuer. Il n’y a rien à déposer sur Moodle pour ce bonus.

## Si tu veux prolonger le vol

### Reprendre une partie sauvegardée

Commence par écrire la distance et les crédits dans un fichier texte. Ajoute l’écriture dans la branche `q|Q)`, juste avant `break`.

```bash
printf '%s\n' "$distance" "$credits" > partie.txt
```

`>` envoie la sortie vers le fichier et remplace son ancien contenu. Joue quelques secondes, quitte avec **Q**, puis relis le fichier avec `cat partie.txt`. Ensuite, dans `jouer`, entre les réglages de départ et la boucle, teste `[ -f partie.txt ]` pour savoir si une sauvegarde existe. À l’intérieur du test, tu peux lire les deux lignes dans l’ordre.

```bash
{
    IFS= read -r distance
    IFS= read -r credits
} < partie.txt
```

`<` donne le contenu du fichier aux deux `read` du groupe. Une fois cette reprise testée, ajoute les trois états d’installation à la sauvegarde et retrouve l’impulsion et la vitesse à partir des achats relus.

### Capter un message à mi-parcours

La balise 7 envoie un message au premier passage à 100 km. Réutilise la comparaison `-ge` de l’arrivée et une variable `signal_recu=0`, comme pour un équipement. Au début de chaque tour, avant l’affichage, utilise `[ "$distance" -ge 100 ] && [ "$signal_recu" -eq 0 ]` dans ton `if`. `&&` exige que les deux tests réussissent. Change alors ton message et passe `signal_recu` à `1`. Essaie de passer de 95 à 103 km avec le booster, puis achète un équipement et vérifie que le message d’achat reste affiché.
