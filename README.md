# Emulation-Tools

This repo contains various scripts and tools that may be useful for assiting in emulating threats. 

## Invoke-AtomicEmulations
This is a wrapper script for Invoke-Atomic, it reads YAML files that contain various Atomics that attempt to emulate various threats. To get started, follow the instructions to install [Invoke-Atomic](https://github.com/redcanaryco/invoke-atomicredteam/wiki/Installing-Invoke-AtomicRedTeam) and then run the test!

```PowerShell
.\Invoke-AtomicEmulation.ps1 -PathToEmulationPlan ..\Emulations\Phosphorus.yml
```

Current implemented parameters:
- `PathToAtomicsFolder`
    - The default Atomics paths are based on the installation of Invoke-Atomic, this can be overridden with this parameter.
- `PathToInvoke`
    - The default Invoke-Atomic path is based on the installation of Invoke-Atomic, this can be overriden with this parameter.
- `PathToEmulationPlan`
    - This is the path to the specific emulation YAML file. Currently, only one emulation can be executed at a time.
- `Cleanup`
    - If you wish for cleanup commands to be executed after the emulation finishes, use this parameter with `-Cleanup $true`