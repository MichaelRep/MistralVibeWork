<#
.SYNOPSIS
    Installe le kit Mistral Vibe de la refonte de l'outil de recette sur un poste.

.DESCRIPTION
    - Copie workspace\AGENTS.md et workspace\.vibe\ dans le dossier racine (par défaut C:\Local\Git).
      Les fichiers existants du kit sont sauvegardés dans .vibe-sauvegarde-<date> avant d'être remplacés.
    - Copie repos\outil-recette-api\ et repos\outil-recette-webapp\ dans les repos du même nom,
      SANS écraser les fichiers existants (docs, catalogue Pollen déjà remplis...).
    - Remplace les marqueurs PAQUET_POLLEN et PROJET_REFERENCE_POLLEN par les valeurs fournies.
    - Ne touche jamais au repo legacy Outil-recette.

.EXAMPLE
    .\installer.ps1 -PaquetPollen "@icdc/pollen" -ProjetReferencePollen "autre-projet-webapp"

.EXAMPLE
    .\installer.ps1 -Racine "D:\Git" -PaquetPollen "@icdc/pollen" -ProjetReferencePollen "autre-projet-webapp" -Simulation
#>
[CmdletBinding()]
param(
    [string]$Racine = "C:\Local\Git",
    [Parameter(Mandatory = $true)][string]$PaquetPollen,
    [Parameter(Mandatory = $true)][string]$ProjetReferencePollen,
    [switch]$Simulation
)

$ErrorActionPreference = "Stop"
$kit = $PSScriptRoot
$utf8SansBom = New-Object System.Text.UTF8Encoding $false
$copies = New-Object System.Collections.Generic.List[string]

function Write-Etape([string]$texte) { Write-Host "==> $texte" -ForegroundColor Cyan }

function Copy-Fichier([string]$source, [string]$cible, [bool]$ecraser) {
    if ((Test-Path $cible) -and -not $ecraser) {
        Write-Host "   conservé : $cible" -ForegroundColor DarkGray
        return
    }
    Write-Host "   copie    : $cible"
    if (-not $Simulation) {
        New-Item -ItemType Directory -Force -Path (Split-Path $cible) | Out-Null
        Copy-Item -LiteralPath $source -Destination $cible -Force
    }
    $copies.Add($cible)
}

function Copy-Arbre([string]$dossierSource, [string]$dossierCible, [bool]$ecraser) {
    Get-ChildItem -LiteralPath $dossierSource -Recurse -File -Force | ForEach-Object {
        $relatif = $_.FullName.Substring($dossierSource.Length).TrimStart('\')
        Copy-Fichier $_.FullName (Join-Path $dossierCible $relatif) $ecraser
    }
}

# --- Vérifications ---------------------------------------------------------------
Write-Etape "Vérification de $Racine"
if (-not (Test-Path $Racine)) { throw "Dossier racine introuvable : $Racine" }
foreach ($repo in @("Outil-recette", "outil-recette-api", "outil-recette-webapp", $ProjetReferencePollen)) {
    $chemin = Join-Path $Racine $repo
    if (Test-Path $chemin) { Write-Host "   trouvé   : $chemin" -ForegroundColor Green }
    else { Write-Warning "Introuvable : $chemin (à cloner avant d'utiliser les agents)" }
}

# --- Kit du workspace (remplacé, avec sauvegarde) --------------------------------
Write-Etape "Installation du kit workspace dans $Racine"
$anciens = @((Join-Path $Racine "AGENTS.md"), (Join-Path $Racine ".vibe")) | Where-Object { Test-Path $_ }
if ($anciens.Count -gt 0) {
    $sauvegarde = Join-Path $Racine (".vibe-sauvegarde-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
    Write-Host "   sauvegarde de l'existant dans $sauvegarde"
    if (-not $Simulation) {
        New-Item -ItemType Directory -Force -Path $sauvegarde | Out-Null
        foreach ($a in $anciens) { Copy-Item -LiteralPath $a -Destination $sauvegarde -Recurse -Force }
    }
}
$vibeCible = Join-Path $Racine ".vibe"
if ((Test-Path $vibeCible) -and -not $Simulation) {
    # Remplacement complet pour ne pas laisser d'anciens agents ou skills (l'existant est sauvegardé ci-dessus).
    Remove-Item -LiteralPath $vibeCible -Recurse -Force -Confirm:$false
}
Copy-Fichier (Join-Path $kit "workspace\AGENTS.md") (Join-Path $Racine "AGENTS.md") $true
Copy-Arbre (Join-Path $kit "workspace\.vibe") (Join-Path $Racine ".vibe") $true

# --- Fichiers des repos cibles (jamais écrasés) ----------------------------------
foreach ($repo in @("outil-recette-api", "outil-recette-webapp")) {
    $cible = Join-Path $Racine $repo
    if (Test-Path $cible) {
        Write-Etape "Ajout des fichiers manquants dans $cible"
        Copy-Arbre (Join-Path $kit "repos\$repo") $cible $false
    }
}

# --- Remplacement des marqueurs --------------------------------------------------
Write-Etape "Remplacement des marqueurs Pollen"
foreach ($fichier in $copies) {
    if ($fichier -notmatch '\.(md|toml)$') { continue }
    if ($Simulation) { continue }
    $texte = [System.IO.File]::ReadAllText($fichier, $utf8SansBom)
    $nouveau = $texte.Replace("PAQUET_POLLEN", $PaquetPollen).Replace("PROJET_REFERENCE_POLLEN", $ProjetReferencePollen)
    if ($nouveau -ne $texte) {
        [System.IO.File]::WriteAllText($fichier, $nouveau, $utf8SansBom)
        Write-Host "   mis à jour : $fichier"
    }
}

Write-Etape "Terminé"
if ($Simulation) { Write-Host "Mode simulation : aucun fichier n'a été écrit." -ForegroundColor Yellow }
Write-Host @"
Étapes suivantes :
  1. cd $Racine ; vibe        (puis marquer le dossier comme trusted)
  2. /reload, taper / pour voir les skills, Maj+Tab pour les agents
  3. Commiter les fichiers ajoutés dans outil-recette-api et outil-recette-webapp
"@
