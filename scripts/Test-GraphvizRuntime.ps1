# Windows PowerShell 5.1 example; operates only on explicit isolated directories.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$BinDir,
    [Parameter(Mandatory=$true)][string]$OutputDir
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$dot = Join-Path $BinDir 'dot.exe'
$configs = @(Get-ChildItem -LiteralPath $BinDir -File -Filter 'config[0-9]*' -ErrorAction Stop)
if (-not (Test-Path -LiteralPath $dot -PathType Leaf)) { throw 'DOT_MISSING' }
if ($configs.Count -ne 1) { throw 'EXPECTED_EXACTLY_ONE_CONFIG_FILE' }
if (Test-Path -LiteralPath $OutputDir) { throw 'OUTPUT_DIR_MUST_NOT_EXIST' }
$source = Join-Path (Split-Path -Parent $PSScriptRoot) 'examples\hello.gv'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw 'DOT_INPUT_MISSING' }
[void](New-Item -ItemType Directory -Path $OutputDir -ErrorAction Stop)
$oldBin = $env:GVBINDIR
$oldPath = $env:PATH
try {
    $env:GVBINDIR = $BinDir
    $env:PATH = "$BinDir;$oldPath"
    $png = Join-Path $OutputDir 'hello.png'
    & $dot '-Kdot' '-Tpng' $source '-o' $png
    if ($LASTEXITCODE -ne 0) { throw 'DOT_RENDER_FAILED' }
    if (-not (Test-Path -LiteralPath $png -PathType Leaf)) { throw 'PNG_MISSING' }
    $bytes = [IO.File]::ReadAllBytes($png)
    $magic = [byte[]]@(137,80,78,71,13,10,26,10)
    if ($bytes.Length -lt 24) { throw 'PNG_TOO_SHORT' }
    for ($i=0; $i -lt 8; $i++) { if ($bytes[$i] -ne $magic[$i]) { throw 'INVALID_PNG_SIGNATURE' } }
    Write-Output ('PNG_FILE=' + $png)
    Write-Output ('PNG_SHA256=' + (Get-FileHash -LiteralPath $png -Algorithm SHA256).Hash)
    Write-Output 'RESULT=PASS_DOT_PNG_RUNTIME'
} finally {
    $env:GVBINDIR = $oldBin
    $env:PATH = $oldPath
}