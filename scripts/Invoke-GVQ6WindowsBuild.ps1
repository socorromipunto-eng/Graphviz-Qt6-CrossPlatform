# GVQ6 v0.2.0 candidate - explicit input, no global installation.
# PowerShell 5.1, Windows x64 only. Execution requires -ExecuteBuild.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceDir,
    [Parameter(Mandatory=$true)][string]$BuildDir,
    [Parameter(Mandatory=$true)][string]$QtPrefix,
    [Parameter(Mandatory=$true)][string]$CMakeExe,
    [string]$Generator = 'Visual Studio 17 2022',
    [ValidateSet('x64')][string]$Architecture = 'x64',
    [string]$ExpectedSourceCommit = '',
    [switch]$ExecuteBuild
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Assert-File([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw ('REQUIRED_FILE_MISSING=' + $Path) }
}
function Assert-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw ('REQUIRED_DIRECTORY_MISSING=' + $Path) }
}
try {
    Write-Output 'GVQ6_WINDOWS_BUILD_CANDIDATE=v0.2.0'
    Write-Output 'SUPPORTED_ARCHITECTURE=x64_ONLY'
    Assert-Directory $SourceDir
    Assert-Directory $QtPrefix
    Assert-File $CMakeExe
    Assert-File (Join-Path $SourceDir 'CMakeLists.txt')
    Assert-File (Join-Path $QtPrefix 'lib\cmake\Qt6\Qt6Config.cmake')
    if ([IO.Path]::GetFullPath($SourceDir).TrimEnd('\') -ieq [IO.Path]::GetFullPath($BuildDir).TrimEnd('\')) { throw 'SOURCE_BUILD_COLLISION' }
    if (Test-Path -LiteralPath $BuildDir) { throw 'BUILD_DIRECTORY_EXISTS_NO_OVERWRITE' }
    if (-not [IO.Path]::IsPathRooted($BuildDir)) { throw 'BUILD_DIRECTORY_MUST_BE_ABSOLUTE' }
    if ($ExpectedSourceCommit) {
        $git = (Get-Command git.exe -ErrorAction Stop).Source
        $head = @(& $git -C $SourceDir rev-parse HEAD)
        if ($LASTEXITCODE -ne 0 -or $head.Count -ne 1 -or $head[0] -cne $ExpectedSourceCommit) { throw 'SOURCE_COMMIT_MISMATCH' }
        $dirty = @(& $git -C $SourceDir status --porcelain --untracked-files=no)
        if ($LASTEXITCODE -ne 0 -or $dirty.Count -ne 0) { throw 'TRACKED_SOURCE_MODIFICATIONS_FOUND' }
    }
    $args = @('-S', $SourceDir, '-B', $BuildDir, '-G', $Generator, '-A', $Architecture, '-DCMAKE_PREFIX_PATH=' + $QtPrefix, '-DWITH_GVEDIT=ON')
    Write-Output ('CMAKE_PATH=' + $CMakeExe)
    Write-Output ('SOURCE=' + $SourceDir)
    Write-Output ('BUILD=' + $BuildDir)
    Write-Output ('QT_PREFIX=' + $QtPrefix)
    Write-Output ('EXECUTE_BUILD=' + [bool]$ExecuteBuild)
    if (-not $ExecuteBuild) {
        Write-Output 'RESULT=PASS_PREFLIGHT_NO_MUTATION'
        return
    }
    # The configure step may fail if upstream Graphviz dependencies (Bison/Flex etc.) are unavailable.
    # This runner deliberately never installs, downloads, or silently locates substitutes.
    & $CMakeExe @args
    if ($LASTEXITCODE -ne 0) { throw ('CMAKE_CONFIGURE_FAILED_EXIT=' + $LASTEXITCODE) }
    & $CMakeExe --build $BuildDir --config Release --target gvedit dot gvplugin_core gvplugin_dot_layout gvplugin_gdiplus --parallel 2
    if ($LASTEXITCODE -ne 0) { throw ('CMAKE_BUILD_FAILED_EXIT=' + $LASTEXITCODE) }
    Write-Output 'RESULT=PASS_BUILD_COMMANDS_EXIT_ZERO_RUNTIME_NOT_VALIDATED'
} catch {
    Write-Output ('ERROR=' + $_.Exception.Message)
    Write-Output 'RESULT=HOLD_NO_RETRY'
    exit 1
}
