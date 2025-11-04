# -*- coding: utf-8 -*-

param (
    [string]$choix,
    [string]$Nom_Ordinateur,
    [string]$Groupe = 'travail'
)

$Switch = 'Default Switch'
$CPU_SRV = 3
$MEM_SRV = 3GB

$CPU_CLI = 1
$MEM_CLI = 1GB

$CPU_UBUNTU = 2
$MEM_UBUNTU = 2GB

$DEF_PATH = 'E:\Hyper_V\VHD'

Clear-Host

# Vérification du groupe
if (-not (Get-VMGroup -Name $Groupe -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor Green "Création du groupe => $Groupe"
    New-VMGroup -Name $Groupe -GroupType VMCollectionType
}

Write-Host -ForegroundColor DarkGray "Groupe actuel => $Groupe"
Write-Host ""

# Choix interactif si non défini
if (-not $choix) {
    Write-Host "1 : Nouveau Serveur Windows"
    Write-Host "2 : Nouveau Client Windows"
    Write-Host "3 : Nouveau Serveur Ubuntu"
    Write-Host "nettoyage : Supprimer les VM du groupe"
    $choix = Read-Host -Prompt "Choix"
}

# Nom de l'ordinateur
if ($Nom_Ordinateur) {
    $Nom = $Nom_Ordinateur
} elseif ($choix -ne 'nettoyage') {
    $Nom = Read-Host -Prompt "Nom de l'ordinateur"
}

$flag = $false
$secureboot = $true

switch ($choix) {
    "1" {
        $smallPath = "$DEF_PATH\Source\Source.Windows.SRV.vhdx"
        $cpu = $CPU_SRV; $memStart = $MEM_SRV; $flag = $true
    }
    "2" {
        $smallPath = "$DEF_PATH\Source\Source.Windows11.Pro.vhdx"
        $cpu = $CPU_CLI; $memStart = $MEM_CLI; $flag = $true
    }
    "3" {
        $smallPath = "$DEF_PATH\Source\Source.Ubuntu24.vhdx"
        $cpu = $CPU_CLI; $memStart = $MEM_UBUNTU; $flag = $true
        $secureboot = $false
    }
    "nettoyage" {
        $ListVM = Get-VMGroup -Name $Groupe -ErrorAction SilentlyContinue
        if (-not $ListVM) {
            Write-Host -ForegroundColor Yellow "Aucun groupe '$Groupe' trouvé."; return
        }
        $confirm = Read-Host "Confirmer la suppression du groupe $Groupe ? (o/n)"
        if ($confirm -ne 'o') { return }

        Write-Host -ForegroundColor Green "Début du nettoyage..."
        foreach ($VM in $ListVM.VMMembers) {
            $pathVHD = Get-VHD -VMId $VM.Id
            Remove-VM $VM -Force
            Remove-Item $pathVHD.Path -Force
        }
        Write-Host -ForegroundColor Green "Fin du nettoyage."
        return
    }
    default {
        Write-Host "Choix invalide."; return
    }
}

if (-not (Test-Path $smallPath)) {
    Write-Error "Le fichier source $smallPath est introuvable."
    exit
}

Write-Host -ForegroundColor Green "Création du disque différencié..."
New-VHD -ParentPath $smallPath -Path "$DEF_PATH\$Groupe.$Nom.vhdx" -Differencing

Write-Host -ForegroundColor Green "Création de la machine virtuelle..."
$vm = New-VM -VHDPath "$DEF_PATH\$Groupe.$Nom.vhdx" -Generation 2 -Name $Nom -MemoryStartupBytes $memStart -SwitchName $Switch

Set-VMProcessor -VMName $Nom -Count $cpu
Add-VMGroupMember -Name $Groupe -VM $vm
if ($secureboot) {
    Set-VMFirmware -VMName $Nom -EnableSecureBoot On
    Write-Host -ForegroundColor Yellow "Secure Boot activé"
}
else {
    Set-VMFirmware -VMName $Nom -EnableSecureBoot Off
    Write-Host -ForegroundColor Yellow "Secure Boot désactivé"
}

Write-Host -ForegroundColor Cyan "VM '$Nom' créée avec succès dans le groupe '$Groupe'"
