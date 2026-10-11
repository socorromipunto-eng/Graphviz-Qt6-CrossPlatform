# GVQ6 Windows x64 v0.2.1 candidate: pinned Bison/Flex and independent build directory.
# Windows PowerShell 5.1. Defaults to preflight; -ExecuteBuild configures and builds.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceDir,
    [Parameter(Mandatory=$true)][string]$BuildDir,
    [Parameter(Mandatory=$true)][string]$QtPrefix,
    [Parameter(Mandatory=$true)][string]$CMakeExe,
    [Parameter(Mandatory=$true)][string]$BisonExe,
    [Parameter(Mandatory=$true)][string]$FlexExe,
    [Parameter(Mandatory=$true)][string]$ExpectedSourceCommit,
    [ValidateSet('x64')][string]$Architecture='x64',
    [switch]$ExecuteBuild
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$ExpectedBison='DB9602D654AC90D8CDAEA7E03E82A82AC6CFE13077EB7D1CA13FC788DD97712A'
$ExpectedFlex='14C3741650BF31F1FA24213EABFAF0A84806346E4B6F257D16FB99B7A7966668'
function Assert-File([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw ('REQUIRED_FILE_MISSING=' + $Path) }
}
function Assert-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw ('REQUIRED_DIRECTORY_MISSING=' + $Path) }
}
try {
    Write-Output 'GVQ6_WINDOWS_BUILD_CANDIDATE=v0.2.1'
    Write-Output 'MODE=FAIL_CLOSED'
    Assert-Dir $SourceDir
    Assert-Dir $QtPrefix
    Assert-File $CMakeExe
    Assert-File $BisonExe
    Assert-File $FlexExe
    Assert-File (Join-Path $SourceDir 'CMakeLists.txt')
    Assert-File (Join-Path $QtPrefix 'lib\cmake\Qt6\Qt6Config.cmake')
    if (-not [IO.Path]::IsPathRooted($SourceDir) -or -not [IO.Path]::IsPathRooted($BuildDir) -or -not [IO.Path]::IsPathRooted($QtPrefix)) { throw 'DIRECTORIES_MUST_BE_ABSOLUTE' }
    $src=[IO.Path]::GetFullPath($SourceDir).TrimEnd('\','/')
    $bld=[IO.Path]::GetFullPath($BuildDir).TrimEnd('\','/')
    if ($src -ieq $bld) { throw 'SOURCE_BUILD_COLLISION' }
    if ($bld.StartsWith(($src+'\'),[StringComparison]::OrdinalIgnoreCase)) { throw 'BUILD_INSIDE_SOURCE_NOT_ALLOWED' }
    if (Test-Path -LiteralPath $BuildDir) { throw 'BUILD_DIRECTORY_EXISTS_NO_OVERWRITE' }
    if ((Get-FileHash -LiteralPath $BisonExe -Algorithm SHA256).Hash -cne $ExpectedBison) { throw 'BISON_HASH_MISMATCH' }
    if ((Get-FileHash -LiteralPath $FlexExe -Algorithm SHA256).Hash -cne $ExpectedFlex) { throw 'FLEX_HASH_MISMATCH' }
    if ($ExpectedSourceCommit -cnotmatch '^[0-9a-fA-F]{40}$') { throw 'EXPECTED_SOURCE_COMMIT_INVALID' }
    $git=(Get-Command git.exe -ErrorAction Stop).Source
    $head=@(& $git -C $SourceDir rev-parse HEAD)
    if ($LASTEXITCODE -ne 0 -or $head.Count -ne 1 -or $head[0] -cne $ExpectedSourceCommit) { throw 'SOURCE_COMMIT_MISMATCH' }
    $dirty=@(& $git -C $SourceDir status --porcelain --untracked-files=no)
    if ($LASTEXITCODE -ne 0 -or $dirty.Count -ne 0) { throw 'TRACKED_SOURCE_MODIFICATIONS_FOUND' }
    Write-Output 'GATE=PASS_SOURCE_QT_CMAKE_BISON_FLEX_AND_FRESH_BUILD_DIR'
    Write-Output ('BUILD_DIR='+$BuildDir)
    Write-Output ('BISON_SHA256='+$ExpectedBison)
    Write-Output ('FLEX_SHA256='+$ExpectedFlex)
    Write-Output ('EXECUTE_BUILD='+[bool]$ExecuteBuild)
    if (-not $ExecuteBuild) {
        Write-Output 'RESULT=PASS_PREFLIGHT_NO_MUTATION'
        return
    }
    $cmakeArgs=@('-S',$SourceDir,'-B',$BuildDir,'-G','Visual Studio 17 2022','-A',$Architecture,
        ('-DCMAKE_PREFIX_PATH:PATH='+$QtPrefix),'-DWITH_GVEDIT:BOOL=ON',
        ('-DBISON_EXECUTABLE:FILEPATH='+$BisonExe),('-DFLEX_EXECUTABLE:FILEPATH='+$FlexExe))
    & $CMakeExe @cmakeArgs
    if ($LASTEXITCODE -ne 0) { throw ('CMAKE_CONFIGURE_FAILED_EXIT='+$LASTEXITCODE) }
    $cache=Join-Path $BuildDir 'CMakeCache.txt'
    Assert-File $cache
    $cacheText=[IO.File]::ReadAllText($cache)
    foreach ($pair in @(@('BISON_EXECUTABLE',$BisonExe),@('FLEX_EXECUTABLE',$FlexExe))) {
        $matches=@($cacheText -split "`n" | Where-Object { $_ -match ('^'+$pair[0]+':FILEPATH=') })
        if ($matches.Count -ne 1) { throw ('CACHE_TOOL_MISSING_OR_AMBIGUOUS='+$pair[0]) }
        $actual=($matches[0] -split '=',2)[1].Trim().Replace('/','\')
        if ($actual -ine $pair[1].Replace('/','\')) { throw ('CACHE_TOOL_PATH_MISMATCH='+$pair[0]) }
    }
    $target=Join-Path $BuildDir 'cmd\gvedit\gvedit.vcxproj'
    Assert-File $target
    Write-Output 'GATE=PASS_CONFIGURED_TOOL_PATHS_AND_GVEDIT_TARGET'
    & $CMakeExe --build $BuildDir --config Release --target gvedit dot gvplugin_core gvplugin_dot_layout gvplugin_gdiplus --parallel 2
    if ($LASTEXITCODE -ne 0) { throw ('CMAKE_BUILD_FAILED_EXIT='+$LASTEXITCODE) }
    foreach ($relative in @('cmd\gvedit\Release\gvedit.exe','cmd\dot\Release\dot.exe','plugin\core\Release\gvplugin_core.dll','plugin\dot_layout\Release\gvplugin_dot_layout.dll','plugin\gdiplus\Release\gvplugin_gdiplus.dll')) {
        $file=Join-Path $BuildDir $relative
        Assert-File $file
        Write-Output ('BUILT='+$relative+'|SHA256='+(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)
    }
    Write-Output 'RESULT=PASS_BUILD_OUTPUTS_RUNTIME_NOT_VALIDATED'
} catch {
    Write-Output ('ERROR='+$_.Exception.Message)
    Write-Output 'RESULT=HOLD_NO_RETRY'
    exit 1
}
