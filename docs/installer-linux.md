# Installer Linux pour les TP

Choisis la partie qui correspond à ton matériel. Ces installations **ne remplacent pas** Windows ou macOS : elles ajoutent un Linux à côté, uniquement pour les TP.

## Windows — installer Debian avec WSL

WSL permet d'utiliser Debian directement dans Windows, sans machine virtuelle compliquée. C'est la solution recommandée sur Windows 10 récent et Windows 11.

1. Enregistre ton travail puis fais un clic droit sur le bouton **Démarrer** de Windows.
2. Choisis **Terminal (administrateur)** ou **Windows PowerShell (administrateur)**. Accepte la demande d'autorisation.
3. Copie cette commande, puis appuie sur Entrée :

```powershell
wsl --install -d Debian
```

4. Attends la fin de l'installation puis redémarre l'ordinateur si Windows le demande.
5. Après le redémarrage, ouvre de nouveau un terminal et entre la commande `wsl`
6. Debian te demande un nom d'utilisateur : choisis un nom court, en minuscules, sans espace (par exemple `lea`). Choisis ensuite un mot de passe. **Rien ne s'affiche quand tu tapes le mot de passe : c'est normal.** Appuie tout de même sur Entrée à la fin.

Tu dois obtenir une ligne qui se termine par `$`. Vérifie que tout fonctionne :

```bash
whoami
pwd
cat /etc/os-release
```

Quand Debian demande ton mot de passe après `sudo`, tape-le puis appuie sur Entrée ; il ne s'affiche pas à l'écran.

Pour revenir à Linux, retape `wsl`, ou bien ouvre **Debian** depuis le menu Démarrer. [Aide officielle WSL](https://learn.microsoft.com/fr-fr/windows/wsl/install)

## Mac — installer Debian avec UTM

UTM crée une petite machine Linux à l'intérieur du Mac. C'est le choix le plus fiable si le TP demande vraiment Linux, plutôt que les commandes Unix propres à macOS.

1. Clique sur le menu  puis **À propos de ce Mac**. Repère si la puce est **Apple** (M1, M2, M3, etc.) ou **Intel**.
2. Télécharge puis installe [UTM](https://mac.getutm.app/) : ouvre le fichier téléchargé et déplace UTM dans le dossier **Applications**.
3. Télécharge l'image d'installation Debian depuis la [page officielle Debian](https://www.debian.org/distrib/netinst) :

    - Mac avec puce Apple : choisis l'image **arm64** ;
    - Mac Intel : choisis l'image **amd64** (ou « 64-bit PC »).

4. Ouvre UTM puis clique sur **+** → **Virtualize** → **Linux**. Choisis le fichier Debian téléchargé.
5. Donne à la machine virtuelle **2 processeurs**, **4 Go de mémoire** (4096 Mo) et **25 Go de disque**, puis clique sur **Save** et sur le bouton de démarrage.
6. Dans l'installateur Debian, choisis **Install**, puis la langue et le clavier français. Tu peux laisser les autres choix par défaut.
7. Crée ton compte avec un nom court, en minuscules et sans espace. Pour le disque, choisis le partitionnement guidé avec le disque entier : il s'agit du disque **virtuel** créé dans UTM, jamais du disque du Mac.
8. Lors du choix des logiciels, garde **standard system utilities**. Une interface graphique n'est pas nécessaire pour les TP et rendrait l'installation plus lourde. Termine l'installation puis redémarre la machine virtuelle.

Après le redémarrage, connecte-toi avec le compte que tu viens de créer, puis vérifie :

```bash
whoami
pwd
cat /etc/os-release
```

Pour les prochains TP, ouvre UTM, démarre la machine **Debian**, puis connecte-toi. [Guide UTM pour Linux](https://docs.getutm.app/guides/ubuntu/)

!!! tip "Mac Apple Silicon"
    Sur un Mac M1, M2, M3 ou plus récent, l'image `arm64` est indispensable. Ne télécharge pas l'image Intel `amd64`.

## Terminal en ligne — solution de secours

Si tu n'es pas sur ton ordinateur ou qu'une installation est impossible, ouvre [WebVM](https://webvm.io/). Il lance un petit environnement Debian directement dans le navigateur, sans compte ni installation, avec les commandes habituelles comme `whoami`, `ls`, `cd`, `grep` et `bash`.

Il est pratique pour commencer ou rattraper une séance, mais ce n'est qu'une solution d'appoint : les fichiers peuvent ne pas être conservés et certaines fonctions réseau ou système sont limitées. Pour un TP entier, préfère Debian avec WSL ou UTM.
