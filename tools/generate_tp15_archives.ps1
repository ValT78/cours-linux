$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$tempRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot '.cache\tp15-archive-src'))
$assetsRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'docs\assets'))

if (-not $tempRoot.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Le dossier temporaire doit rester dans le dépôt."
}
if (-not $assetsRoot.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Le dossier de destination doit rester dans le dépôt."
}

if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
New-Item -ItemType Directory -Path $assetsRoot -Force | Out-Null

$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines
    )
    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    [System.IO.File]::WriteAllText($Path, (($Lines -join "`n") + "`n"), $utf8)
}

function New-RadioLog {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Date,
        [Parameter(Mandatory = $true)][int]$Count,
        [hashtable]$SpecialLines = @{}
    )
    $levels = @('INFO', 'INFO', 'INFO', 'CONTROLE', 'AVERTISSEMENT')
    $services = @('navigation', 'energie', 'radio', 'meteo', 'stockage', 'laboratoire')
    $messages = @(
        'synchronisation terminee',
        'controle periodique conforme',
        'paquet recu et archive',
        'mesure ajoutee au journal',
        'liaison stable',
        'verification sans anomalie critique'
    )
    $lines = [System.Collections.Generic.List[string]]::new()
    for ($i = 1; $i -le $Count; $i++) {
        if ($SpecialLines.ContainsKey($i)) {
            $lines.Add([string]$SpecialLines[$i])
            continue
        }
        $hour = [math]::Floor(($i - 1) / 60) % 24
        $minute = ($i - 1) % 60
        $level = $levels[($i * 3) % $levels.Count]
        $service = $services[($i * 5) % $services.Count]
        $message = $messages[($i * 7) % $messages.Count]
        $lines.Add(('{0} {1:00}:{2:00}:{3:00};{4};{5};sequence={6:0000};{7}' -f $Date, $hour, $minute, (($i * 11) % 60), $level, $service, $i, $message))
    }
    Write-Utf8File -Path $Path -Lines $lines
}

# ---------------------------------------------------------------------------
# Archive 1 : station Nadir — navigation, lecture et recherche dans du volume.
# ---------------------------------------------------------------------------
$station = Join-Path $tempRoot 'station-nadir'
$stationDirs = @(
    'navigation\secteur-alpha',
    'navigation\secteur-beta',
    'navigation\secteur-gamma',
    'navigation\.indices',
    'transmissions',
    'documentation\procedures',
    'inventaire\anciens',
    'rapports\archives',
    'travail'
)
foreach ($dir in $stationDirs) {
    New-Item -ItemType Directory -Path (Join-Path $station $dir) -Force | Out-Null
}

Write-Utf8File -Path (Join-Path $station '00-LIRE-MOI.txt') -Lines @(
    'STATION NADIR — ARCHIVES TECHNIQUES',
    '',
    'Une transmission importante est dissimulee dans cette arborescence.',
    'Les fichiers sont nombreux : les lire tous ligne par ligne serait une mauvaise strategie.',
    'Le code final comporte cinq fragments, dans cet ordre :',
    'station - entete - secteur - numero - protocole',
    '',
    'Les fragments peuvent etre caches dans un nom commencant par un point, au debut ou a la fin',
    'd un journal, au milieu d une transmission ou dans le manuel de la station.',
    '',
    'Ne modifiez pas les archives originales. Travaillez dans le dossier travail.'
)

Write-Utf8File -Path (Join-Path $station 'navigation\secteur-alpha\carte.txt') -Lines @(
    'SECTEUR ALPHA',
    'Acces principal : sas nord',
    'Etat : inspecte',
    'Aucun fragment de transmission valide dans ce secteur.'
)
Write-Utf8File -Path (Join-Path $station 'navigation\secteur-beta\carte.txt') -Lines @(
    'SECTEUR BETA',
    'Acces principal : galerie centrale',
    'Etat : inspecte',
    'Une ancienne balise a ete deplacee vers le dossier d indices de navigation.'
)
Write-Utf8File -Path (Join-Path $station 'navigation\secteur-gamma\carte.txt') -Lines @(
    'SECTEUR GAMMA',
    'Acces principal : sas sud',
    'Etat : ferme pour maintenance',
    'Le secteur mentionne dans l anomalie radio n est pas GAMMA.'
)
Write-Utf8File -Path (Join-Path $station 'navigation\.indices\fragment-station.txt') -Lines @(
    'FRAGMENT-STATION=NADIR',
    'Ce fichier etait invisible avec un affichage simple.'
)

$manualLines = [System.Collections.Generic.List[string]]::new()
for ($i = 1; $i -le 720; $i++) {
    if ($i -eq 487) {
        $manualLines.Add('PROTOCOLE-ORION — mot de controle : VEGA — FRAGMENT-PROTOCOLE=VEGA')
    } elseif ($i % 90 -eq 0) {
        $manualLines.Add(('CHAPITRE {0:00} — verification des modules de la station et procedures de reprise.' -f ($i / 90)))
    } else {
        $manualLines.Add(('Ligne {0:0000} — procedure standard : observer le signal, verifier la source, consigner le resultat et poursuivre le diagnostic.' -f $i))
    }
}
Write-Utf8File -Path (Join-Path $station 'documentation\manuel-station.txt') -Lines $manualLines

Write-Utf8File -Path (Join-Path $station 'documentation\procedures\navigation.txt') -Lines @(
    'PROCEDURE DE NAVIGATION',
    '1. Identifier le dossier courant.',
    '2. Observer les entrees disponibles.',
    '3. Choisir un chemin absolu ou relatif.',
    '4. Verifier le nouvel emplacement apres le deplacement.'
)
Write-Utf8File -Path (Join-Path $station 'documentation\procedures\radio.txt') -Lines @(
    'PROCEDURE RADIO',
    'Les journaux les plus longs se trouvent dans transmissions.',
    'Une recherche par motif est plus efficace qu une lecture integrale.',
    'Les termes importants sont parfois en majuscules.'
)

New-RadioLog -Path (Join-Path $station 'transmissions\radio-2026-09-14.log') -Date '2026-09-14' -Count 960 -SpecialLines @{
    318 = '2026-09-14 05:17:42;ALERTE;navigation;ANOMALIE-ROUGE detectee;secteur=DELTA;FRAGMENT-SECTEUR=DELTA'
    702 = '2026-09-14 11:41:16;INFO;radio;ancienne mention anomalie-rouge classee sans suite;secteur=ALPHA'
}
New-RadioLog -Path (Join-Path $station 'transmissions\radio-2026-09-15.log') -Date '2026-09-15' -Count 840 -SpecialLines @{
    1 = 'ENTETE;station=NADIR;canal=7;FRAGMENT-ENTETE=A7'
    466 = '2026-09-15 07:45:25;AVERTISSEMENT;energie;variation mineure sans interruption'
}
New-RadioLog -Path (Join-Path $station 'transmissions\radio-2026-09-16.log') -Date '2026-09-16' -Count 1020 -SpecialLines @{
    247 = '2026-09-16 04:06:21;INFO;stockage;copie de controle terminee'
    1020 = 'FIN;archive=validee;FRAGMENT-NUMERO=42'
}

$inventory = [System.Collections.Generic.List[string]]::new()
$inventory.Add('reference;designation;zone;etat;masse_kg')
for ($i = 1; $i -le 320; $i++) {
    $zone = @('alpha', 'beta', 'gamma', 'delta')[($i - 1) % 4]
    $state = @('operationnel', 'operationnel', 'controle', 'archive')[($i * 3) % 4]
    $inventory.Add(('MAT-{0:0000};module technique {0:0000};{1};{2};{3}' -f $i, $zone, $state, (5 + (($i * 17) % 240))))
}
Write-Utf8File -Path (Join-Path $station 'inventaire\materiel.csv') -Lines $inventory
Write-Utf8File -Path (Join-Path $station 'inventaire\anciens\inventaire-2024.txt') -Lines (1..180 | ForEach-Object { 'ARCH-{0:0000};piece retiree;statut=archivee' -f $_ })
Write-Utf8File -Path (Join-Path $station 'rapports\brouillon.txt') -Lines @(
    'RAPPORT D ENQUETE — BROUILLON',
    'Code final :',
    'Methode utilisee :',
    'Erreur rencontree :',
    'Correction :'
)
Write-Utf8File -Path (Join-Path $station 'rapports\archives\ancien-rapport.txt') -Lines @(
    'Ancien code : POLARIS-BETA-19',
    'Attention : ce rapport date d une mission precedente et sert de leurre.'
)

# ---------------------------------------------------------------------------
# Archive 2 : atelier des permissions — tous les objets sont jetables.
# ---------------------------------------------------------------------------
$permissions = Join-Path $tempRoot 'atelier-permissions'
$permissionDirs = @(
    'documents',
    'equipe',
    'scripts',
    'coffre',
    'laboratoire\depot',
    'resultats'
)
foreach ($dir in $permissionDirs) {
    New-Item -ItemType Directory -Path (Join-Path $permissions $dir) -Force | Out-Null
}

Write-Utf8File -Path (Join-Path $permissions '00-LIRE-MOI.txt') -Lines @(
    'ATELIER DES PERMISSIONS',
    '',
    'Tous les fichiers de cette archive sont jetables.',
    'Les modes initiaux dependent de la machine et de l outil de decompression.',
    'Les exercices demandent donc toujours d observer avant de modifier.',
    '',
    'Objectifs finaux :',
    '- documents/rapport-public.txt : 644',
    '- equipe/partage-equipe.txt : 640',
    '- scripts/diagnostic.sh : 750',
    '- coffre/secret.txt : 600'
)
Write-Utf8File -Path (Join-Path $permissions 'documents\rapport-public.txt') -Lines @(
    'Rapport public de la station Nadir.',
    'Ce document doit rester modifiable par son proprietaire et lisible par tous.'
)
Write-Utf8File -Path (Join-Path $permissions 'equipe\partage-equipe.txt') -Lines @(
    'Document de travail partage.',
    'Le proprietaire doit pouvoir lire et modifier.',
    'Le groupe doit pouvoir lire.',
    'Les autres ne doivent avoir aucun droit.'
)
Write-Utf8File -Path (Join-Path $permissions 'coffre\secret.txt') -Lines @(
    'FRAGMENT-PERMISSIONS=640-750-600',
    'Ce fichier doit rester prive : lecture et ecriture pour son proprietaire seulement.'
)
Write-Utf8File -Path (Join-Path $permissions 'laboratoire\groupe-seul.txt') -Lines @(
    'Si le proprietaire ne possede pas r, Linux ne cumule pas automatiquement les droits du groupe.',
    'Cette phrase devient lisible apres restauration du droit du proprietaire.'
)
Write-Utf8File -Path (Join-Path $permissions 'laboratoire\depot\temoin.txt') -Lines @(
    'Ce fichier sert a observer la suppression d une entree dans un repertoire.'
)
Write-Utf8File -Path (Join-Path $permissions 'scripts\diagnostic.sh') -Lines @(
    '#!/usr/bin/env bash',
    'echo "Diagnostic de la station : OK"',
    'echo "Utilisateur : $(id -un)"',
    'echo "Groupe principal : $(id -gn)"'
)

$audit = [System.Collections.Generic.List[string]]::new()
for ($i = 1; $i -le 540; $i++) {
    $action = @('lecture', 'controle', 'sauvegarde', 'inventaire')[($i - 1) % 4]
    $audit.Add(('AUDIT {0:0000};action={1};resultat=OK;objet=ressource-{2:000}' -f $i, $action, (($i * 13) % 97)))
}
Write-Utf8File -Path (Join-Path $permissions 'documents\audit-complet.log') -Lines $audit

$stationZip = Join-Path $assetsRoot 'tp1-5-station-nadir.zip'
$permissionsZip = Join-Path $assetsRoot 'tp1-5-atelier-permissions.zip'
Compress-Archive -LiteralPath $station -DestinationPath $stationZip -CompressionLevel Optimal -Force
Compress-Archive -LiteralPath $permissions -DestinationPath $permissionsZip -CompressionLevel Optimal -Force

Remove-Item -LiteralPath $tempRoot -Recurse -Force

Write-Output "Archives generees :"
Write-Output $stationZip
Write-Output $permissionsZip
