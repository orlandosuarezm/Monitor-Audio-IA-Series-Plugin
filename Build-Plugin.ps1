[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$NoSyntaxCheck
)

$ErrorActionPreference = 'Stop'
$root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$pluginName = 'MonitorAudioIASeries'
$dist = Join-Path $root 'dist'
$output = Join-Path $dist ($pluginName + '.qplug')
$compiler = Join-Path $root 'tools\PluginCompile\PLUGCC.exe'

function Expand-Includes {
    param([string]$Path, [System.Collections.Generic.HashSet[string]]$Stack)

    $fullPath = [IO.Path]::GetFullPath($Path)
    if ($Stack.Contains($fullPath)) {
        throw "Recursive include detected: $fullPath"
    }

    $nextStack = [System.Collections.Generic.HashSet[string]]::new($Stack)
    [void]$nextStack.Add($fullPath)
    $source = Get-Content -Raw -LiteralPath $fullPath
    $base = Split-Path -Parent $fullPath
    $pattern = '--\[\[\s*#include\s+"([^"]+)"\s*\]\]'

    return [regex]::Replace($source, $pattern, {
        param($match)
        $includePath = Join-Path $base $match.Groups[1].Value
        Expand-Includes -Path $includePath -Stack $nextStack
    })
}

if (-not (Test-Path $compiler)) {
    throw "PLUGCC.exe was not found: $compiler"
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null
$rootOutput = Join-Path $root ($pluginName + '.qplug')
Remove-Item -Force -ErrorAction SilentlyContinue $rootOutput
& $compiler $pluginName (Join-Path $root 'plugin.lua')
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $rootOutput)) {
    throw 'PLUGCC failed to create the Q-SYS plugin package.'
}
Copy-Item -Force $rootOutput $output

if (-not $NoSyntaxCheck) {
    $luac = Get-Command luac -ErrorAction SilentlyContinue
    if ($null -eq $luac) {
        throw 'luac was not found. Install Lua or use -NoSyntaxCheck.'
    }
    & $luac.Source -p $output
    if ($LASTEXITCODE -ne 0) { throw "Lua syntax validation failed: $output" }
}

Write-Host "Built: $output"

if ($Install) {
    $pluginRoot = Join-Path $HOME 'Documents\QSC\Q-SYS Designer\Plugins'
    $pluginDirectory = Join-Path $HOME 'Documents\QSC\Q-SYS Designer\Plugins\MonitorAudioIASeries'
    New-Item -ItemType Directory -Force -Path $pluginRoot | Out-Null
    Copy-Item -Force -LiteralPath $output -Destination (Join-Path $pluginRoot ($pluginName + '.qplug'))
    New-Item -ItemType Directory -Force -Path $pluginDirectory | Out-Null
    Copy-Item -Force -LiteralPath $output -Destination (Join-Path $pluginDirectory ($pluginName + '.qplug'))
    Write-Host "Installed: $pluginDirectory"
}