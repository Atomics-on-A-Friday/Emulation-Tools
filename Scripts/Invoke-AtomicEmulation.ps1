<#
.SYNOPSIS
    Execute an adversary emulation plan utilizing Atomic Red Team
.DESCRIPTION
    Reads a YAML file containing various Atomic tests used to emulate technqiues used by adversaries and commodity malware. 
.EXAMPLE Run the emulation plan and specify custom path to Invoke-Atomic and Atomics
    PS/> Invoke-AtomicEmulation -PathToInvoke C:\Path\To\Invoke -PathToAtomicsFolder C:\Path\To\Atomics
.EXAMPLE Run the emulation plan and run clean up command
    PS/> Invoke-AtomicEmulation -Cleanup $true
.NOTES
    Create Atomic Tests from yaml files described in Atomic Red Team. https://github.com/redcanaryco/atomic-red-team/tree/master/atomics
.LINK
    Installation and Usage Wiki: https://github.com/redcanaryco/invoke-atomicredteam/wiki
    Github repo: https://github.com/redcanaryco/invoke-atomicredteam
#>

param(
    [Parameter(Mandatory = $false,
    ParameterSetName = 'technique')]
    [String]
    $PathToAtomicsFolder = $( if ($IsLinux -or $IsMacOS) { $Env:HOME + "/AtomicRedTeam/atomics" } else { $env:HOMEDRIVE + "\AtomicRedTeam\atomics" }),

    [Parameter(Mandatory = $false,
    ParameterSetName = 'technique')]
    [String]
    $PathToInvoke = $( if ($IsLinux -or $IsMacOS) { $Env:HOME + "/AtomicRedTeam/invoke-atomicredteam" } else { $env:HOMEDRIVE + "\AtomicRedTeam\invoke-atomicredteam" }),
    
    [Parameter(Mandatory = $false,
    ParameterSetName = 'technique')]
    [string]
    $Cleanup = $false,

    [Parameter(Mandatory = $true,
    ParameterSetName = 'technique')]
    [string]
    $PathToEmulationPlan = $( if ($IsLinux -or $IsMacOS) { $Env:HOME + "/AtomicRedTeam/emulations" } else { $env:HOMEDRIVE + "\AtomicRedTeam\emulations" })
)

if(Get-Module -ListAvailable -Name powershell-yaml)
{   import-module powershell-yaml }
else
{   Install-Module -Name powershell-yaml -Scope CurrentUser }

function Invoke-AtomicsCheck()
{
    $PathToAtomicsFolder = (Resolve-Path $PathToAtomicsFolder).Path
    if (Test-Path -Path $PathToAtomicsFolder -IsValid)
    { Write-Host -ForegroundColor Cyan "PathToAtomicsFolder = $PathToAtomicsFolder" }
    else
    { Write-Host -ForegroundColor Red "Unable to validate path to Atomic Red Team" }
}

function Invoke-IARTCheck()
{
    $PathToInvoke = (Resolve-Path $PathToInvoke).Path
    if (Test-Path -Path $PathToInvoke -IsValid)
    { 
        Write-Host -ForegroundColor Cyan "PathToInvoke-Atomic = $PathToInvoke"; 
        Import-Module $PathToInvoke\Invoke-AtomicRedTeam.psm1
    }
    else 
    {
        $answer = Read-Host -Prompt "Would you like to install Invoke-AtomicRedTeam and Atomics? Y/N"
        if($answer == "Y" -or $answer == "y")
        {
            Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
            Install-AtomicRedTeam -getAtomics
        }
        else 
        {   break;  }
    }
}

Function Invoke-AtomicPreReqCheck($yaml)
{
    $yaml.atomics | %{
        If($_.input_arguments.count -gt 0)
        {   Invoke-AtomicTest $_.technique -TestGuids $_.guid -InputArgs $_.input_arguments -GetPrereqs }
        else
        {   Invoke-AtomicTest $_.technique -TestGuids $_.guid -GetPrereqs }
    }
}

Function Invoke-CleanUp($yaml)
{
    $yaml.atomics | %{
        If($_.input_arguments.count -gt 0)
        {   Invoke-AtomicTest $_.technique -TestGuids $_.guid -InputArgs $_.input_arguments -Cleanup }
        else
        {   Invoke-AtomicTest $_.technique -TestGuids $_.guid -Cleanup}
    }
}

if (Test-Path -Path $PathToEmulationPlan -PathType Leaf)
{    
    [string[]]$fileContent = Get-Content $PathToEmulationPlan
    $content = ''
    foreach ($line in $fileContent) { $content = $content + "`n" + $line }
    $yaml = ConvertFrom-YAML $content
}
else
{ Write-Host -ForegroundColor Red "Unable to validate path to emulation file"; break; }

Invoke-IARTCheck
Invoke-AtomicsCheck($yaml)
Invoke-AtomicPreReqCheck($yaml)

Write-Host -ForegroundColor Yellow "`nExecuting emulation of: " $yaml.emulation_plan "'n"
$yaml.atomics | %{
    If($_.input_arguments.count -gt 0)
    {   Invoke-AtomicTest $_.technique -TestGuids $_.guid -InputArgs $_.input_arguments }
    else
    {   Invoke-AtomicTest $_.technique -TestGuids $_.guid }
}

If($Cleanup -eq $true)
{ Invoke-CleanUp($yaml) }