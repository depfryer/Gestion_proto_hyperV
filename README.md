Ah, je comprends ! Voici le README **intégralement dans un bloc de code Markdown**, comme demandé :
# miniScript_ecole

## Description
Ce script PowerShell permet de créer et gérer facilement des machines virtuelles Hyper-V pour un environnement scolaire ou de test. Il automatise la création de disques différenciés, l'allocation des ressources (CPU, RAM), la gestion de Secure Boot et la suppression de groupes de VM.

---

## Configuration du script
Avant utilisation, vous devez adapter les variables situées en début de script à votre environnement :

```powershell
$Switch = 'Interne'          # Nom du switch Hyper-V (obtenable via Get-VMNetworkAdapter -All)
$CPU_SRV = 3                  # Nombre de CPU à allouer par serveur
$MEM_SRV = 3GB                # Mémoire initiale pour un serveur
$CPU_CLI = 1                  # Nombre de CPU à allouer par client
$MEM_CLI = 1GB                # Mémoire initiale pour un client
$CPU_UBUNTU = 1                  # Nombre de CPU à allouer pour un serveur Ubuntu
$MEM_UBUNTU = 2GB             # Mémoire initiale pour un serveur Ubuntu
$DEF_PATH = 'E:\Hyper_V\VHD'  # Chemin vers le dossier Hyper-V
$Groupe = 'travail'           # Nom du groupe de VM pour gestion/suppression
````

---

## Création des fichiers maîtres

1. Dans le dossier indiqué par `$DEF_PATH`, créer un sous-dossier `Source` pour stocker les fichiers maîtres.
2. Installer une machine virtuelle Windows ou Ubuntu, configurer et mettre à jour le système.
3. Sauvegarder le disque maître dans le dossier `Source` :

   * Serveur Windows : `Source.Windows.SRV.vhdx`
   * Client Windows : `Source.Windows10.Pro.vhdx`
   * Serveur Ubuntu (optionnel) : `Source.Ubuntu24.vhdx`
4. Généraliser la machine pour créer un disque différencié :

```cmd
C:\Windows\System32\sysprep\sysprep.exe /generalize /shutdown /oobe /mode:vm
```

5. Une fois la VM éteinte, vous pouvez supprimer la VM (le disque maître reste intact).

---

## Utilisation du script

Lancer le script PowerShell, puis suivre les instructions :

* `1` : Créer un nouveau serveur Windows
* `2` : Créer un nouveau client Windows
* `3` : Créer un serveur Ubuntu
* `nettoyage` : Supprimer toutes les VM du groupe ainsi que leurs disques différenciés

Si vous ne spécifiez pas de nom pour la VM, le script vous demandera de le saisir.

---

## Avantages

* Création rapide et automatisée de VM avec allocation de ressources personnalisée.
* Gestion de Secure Boot activé ou désactivé selon le type de VM.
* Suppression simple de toutes les VM d'un groupe sans laisser de fichiers résiduels.
* Gain de temps considérable par rapport à la création manuelle via l'interface Hyper-V.

---

## Remarques

* Vérifiez que les chemins et noms de fichiers maîtres correspondent à votre configuration.
* Les disques différenciés ne doivent jamais être utilisés comme disques maîtres pour éviter la corruption.

