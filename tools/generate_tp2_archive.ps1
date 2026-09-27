Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$buildRoot = Join-Path $repoRoot '.cache\tp2-relais-aurore-build'
$missionRoot = Join-Path $buildRoot 'relais-aurore'
$archivePath = Join-Path $repoRoot 'docs\assets\tp2-relais-aurore.zip'

$expectedBuildRoot = Join-Path $repoRoot '.cache\tp2-relais-aurore-build'
if ($buildRoot -ne $expectedBuildRoot) {
    throw "Dossier de génération inattendu : $buildRoot"
}

if (Test-Path -LiteralPath $buildRoot) {
    Remove-Item -LiteralPath $buildRoot -Recurse -Force
}

@(
    $missionRoot,
    (Join-Path $missionRoot 'bruts'),
    (Join-Path $missionRoot 'documentation'),
    (Join-Path $missionRoot 'laboratoire\depot'),
    (Join-Path $missionRoot 'archives\semaine-38'),
    (Join-Path $missionRoot 'rapports'),
    (Join-Path $missionRoot 'scripts')
) | ForEach-Object { New-Item -ItemType Directory -Path $_ -Force | Out-Null }

$utf8 = [System.Text.UTF8Encoding]::new($false)

function Write-Utf8File {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [AllowEmptyString()] [string[]] $Lines
    )

    [System.IO.File]::WriteAllText($Path, (($Lines -join "`n") + "`n"), $utf8)
}

Write-Utf8File -Path (Join-Path $missionRoot '00-LIRE-MOI.txt') -Lines @(
    'RELAIS AURORE — DOSSIER TECHNIQUE',
    '',
    'Le code retrouve dans les archives de la station Nadir a ouvert ce dossier.',
    'Aurore recoit encore des donnees, mais son rapport automatique ne fonctionne plus.',
    'Les journaux bruts ne doivent pas etre modifies.',
    '',
    'Dossiers :',
    '- bruts : communications, capteurs et inventaire ;',
    '- documentation : format des donnees et procedure d urgence ;',
    '- laboratoire : essais sur les droits ;',
    '- archives : anciens journaux ;',
    '- rapports : resultats a produire ;',
    '- scripts : commandes a conserver.',
    '',
    'Objectif : identifier l origine du signal critique et produire une recette rejouable.'
)

Write-Utf8File -Path (Join-Path $missionRoot '.canal-nadir') -Lines @(
    'CLE-ORIGINE=NADIR-A7-DELTA-42-VEGA',
    'CANAL-SUIVANT=AURORE'
)

function New-CommunicationLog {
    param(
        [Parameter(Mandatory)] [string] $Day,
        [Parameter(Mandatory)] [int] $Count
    )

    $sources = @('radio', 'energie', 'meteo', 'navigation', 'stockage', 'balise-3')
    $zones = @('NORD', 'SUD', 'EST', 'OUEST', 'DELTA')
    $messages = @(
        'paquet recu et archive',
        'controle automatique termine',
        'synchronisation confirmee',
        'niveau stable',
        'mesure transmise',
        'liaison verifiee'
    )
    $lines = [System.Collections.Generic.List[string]]::new()
    $origin = [datetime]::ParseExact("$Day 05:30:00", 'yyyy-MM-dd HH:mm:ss', $null)

    for ($i = 1; $i -le $Count; $i++) {
        $timestamp = $origin.AddSeconds($i * 41).ToString('yyyy-MM-dd HH:mm:ss')
        $source = $sources[$i % $sources.Count]
        $zone = $zones[$i % $zones.Count]
        $message = "$($messages[$i % $messages.Count]) sequence=$('{0:D4}' -f $i)"
        $level = if ($i % 113 -eq 0) { 'ERREUR' } elseif ($i % 47 -eq 0) { 'AVERTISSEMENT' } else { 'INFO' }

        if ($Day -eq '2026-09-21' -and $i -eq 1) {
            $level = 'INFO'; $source = 'relais'; $zone = 'CENTRE'; $message = 'CANAL-OUVERT=VEGA'
        }
        elseif ($Day -eq '2026-09-22' -and $i -eq 512) {
            $level = 'CRITIQUE'; $source = 'balise-7'; $zone = 'DELTA'; $message = 'SIGNAL-URGENCE=POLARIS'
        }
        elseif ($Day -eq '2026-09-23' -and $i -eq 777) {
            $level = 'CRITIQUE'; $source = 'balise-7'; $zone = 'DELTA'; $message = 'COORDONNEES=47.219,-1.553'
        }
        elseif ($Day -eq '2026-09-23' -and $i -eq $Count) {
            $level = 'INFO'; $source = 'relais'; $zone = 'CENTRE'; $message = 'FIN-TRANSMISSION=42'
        }

        $lines.Add("$timestamp;$level;$source;$zone;$message")
    }

    Write-Utf8File -Path (Join-Path $missionRoot "bruts\communications-$Day.log") -Lines $lines
}

New-CommunicationLog -Day '2026-09-21' -Count 900
New-CommunicationLog -Day '2026-09-22' -Count 1050
New-CommunicationLog -Day '2026-09-23' -Count 1200

$inventory = [System.Collections.Generic.List[string]]::new()
$inventory.Add('nom;type;taille_ko;etat;zone')
$types = @('radio', 'energie', 'navigation', 'meteo')
$states = @('actif', 'actif', 'archive', 'a_verifier')
$zones = @('NORD', 'SUD', 'EST', 'OUEST', 'DELTA')
for ($i = 1; $i -le 80; $i++) {
    $inventory.Add(('module-{0:D2};{1};{2};{3};{4}' -f $i, $types[$i % 4], (24 + (($i * 37) % 850)), $states[$i % 4], $zones[$i % 5]))
}
$inventory.Add('batterie-balise-7;energie;420;urgent;DELTA')
$inventory.Add('antenne-secours;radio;180;urgent;DELTA')
$inventory.Add('carte-navigation;navigation;95;important;CENTRE')
Write-Utf8File -Path (Join-Path $missionRoot 'bruts\inventaire.csv') -Lines $inventory

$sensors = [System.Collections.Generic.List[string]]::new()
$sensors.Add('date;capteur;zone;valeur;unite;etat')
for ($i = 1; $i -le 360; $i++) {
    $timestamp = ([datetime]'2026-09-23 08:00:00').AddMinutes($i * 2).ToString('yyyy-MM-dd HH:mm:ss')
    $sensor = 'capteur-{0:D2}' -f (($i % 18) + 1)
    $zone = $zones[$i % 5]
    $value = 10 + (($i * 7) % 240) / 10
    $state = if ($i % 89 -eq 0) { 'alerte' } else { 'normal' }
    $sensors.Add("$timestamp;$sensor;$zone;$value;C;$state")
}
Write-Utf8File -Path (Join-Path $missionRoot 'bruts\capteurs.csv') -Lines $sensors

Write-Utf8File -Path (Join-Path $missionRoot 'documentation\format-communications.txt') -Lines @(
    'FORMAT DES COMMUNICATIONS',
    '',
    'Chaque ligne contient cinq champs separes par un point-virgule :',
    '1. date et heure',
    '2. niveau : INFO, AVERTISSEMENT, ERREUR ou CRITIQUE',
    '3. source',
    '4. zone',
    '5. message',
    '',
    'Exemple :',
    '2026-09-23 08:14:32;ERREUR;navigation;DELTA;route indisponible'
)

Write-Utf8File -Path (Join-Path $missionRoot 'documentation\procedure-urgence.txt') -Lines @(
    'PROCEDURE D URGENCE DU RELAIS AURORE',
    '',
    '1. Conserver les journaux bruts.',
    '2. Isoler les lignes CRITIQUE.',
    '3. Identifier la source et la zone.',
    '4. Relever le code du signal et les coordonnees.',
    '5. Produire un rapport reproductible.',
    '',
    'Un rapport sans commande reproductible est considere comme incomplet.'
)

Write-Utf8File -Path (Join-Path $missionRoot 'laboratoire\categorie-groupe.txt') -Lines @(
    'Ce fichier sert a verifier que les droits du groupe ne completent pas ceux du proprietaire.'
)
Write-Utf8File -Path (Join-Path $missionRoot 'laboratoire\rapport-confidentiel.txt') -Lines @(
    'Rapport interne du relais Aurore.',
    'Ne pas rendre ce fichier executable.'
)
Write-Utf8File -Path (Join-Path $missionRoot 'laboratoire\depot\temoin.txt') -Lines @(
    'Ce temoin permet de distinguer le contenu d un fichier de l entree stockee dans son dossier parent.'
)

for ($day = 16; $day -le 20; $day++) {
    $archiveLines = [System.Collections.Generic.List[string]]::new()
    for ($i = 1; $i -le 120; $i++) {
        $archiveLines.Add("2026-09-$day;INFO;archive;sequence=$('{0:D3}' -f $i);controle termine")
    }
    Write-Utf8File -Path (Join-Path $missionRoot "archives\semaine-38\archive-2026-09-$day.log") -Lines $archiveLines
}

Write-Utf8File -Path (Join-Path $missionRoot 'rapports\LISEZ-MOI.txt') -Lines @(
    'Place ici les rapports produits pendant le TP.',
    'Ne modifie pas les fichiers du dossier bruts.'
)

Write-Utf8File -Path (Join-Path $missionRoot 'scripts\diagnostic.sh') -Lines @(
    '#!/usr/bin/env bash',
    'echo "Diagnostic du relais Aurore"',
    'echo "Journaux de communication :"',
    'find bruts -maxdepth 1 -name "*.log" | wc -l',
    'echo "Lignes critiques :"',
    'grep -h "CRITIQUE" bruts/*.log | wc -l'
)

if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}
Compress-Archive -Path $missionRoot -DestinationPath $archivePath -CompressionLevel Optimal

$lineCount = (Get-ChildItem (Join-Path $missionRoot 'bruts') -File | Get-Content | Measure-Object -Line).Lines
$fileCount = (Get-ChildItem $missionRoot -Recurse -File | Measure-Object).Count
Write-Output "Archive créée : $archivePath"
Write-Output "Fichiers : $fileCount"
Write-Output "Lignes dans bruts : $lineCount"

Remove-Item -LiteralPath $buildRoot -Recurse -Force
