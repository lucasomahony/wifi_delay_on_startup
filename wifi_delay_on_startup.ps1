# device manager -> your network adapter -> properties -> power management -> 'allow this computer to turn off off this device to save power'
# turn it off so windows won't lose wifi network connection

# find all wireless devices on the system
$NICs = Get-NetAdapter | Where-Object {$_.PhysicalMediaType -eq 'Native 802.11' -or $_.PhysicalMediaType -eq 'Wireless LAN'}

Foreach ($NIC in $NICs)
{
    $PowerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | Where {$_.InstanceName -match [regex]::Escape($NIC.PNPDeviceID)}
    
	
	If ($PowerMgmt.Enable -eq $True)
    {
         $PowerMgmt.Enable = $False
         $PowerMgmt.psbase.Put()
    }
    
}

# local group policy -> computer configuration -> administrative templates > system -> group policy -> 'Specify startup policy processing wait time' and set to 60 seconds
$RegistryPath = 'HKLM:Software\Policies\Microsoft\Windows\System'

If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force
} 
New-ItemProperty -Path $RegistryPath -Name "GpNetworkStartTimeoutPolicyValue" -Value 60  -PropertyType "Dword" -Force


# we need to set the below policy too as windows wont always wait for the network without this
# local group policy -> computer configuration -> administrative templates > system -> logon -> 'always wait for the network at computer startup and logon' set to enabled.

$RegistryPath = 'HKLM:Software\Policies\Microsoft\Windows NT\CurrentVersion\Winlogon'

If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force
} 

New-ItemProperty -Path  $RegistryPath -Name "SyncForegroundPolicy" -Value 1  -PropertyType "Dword" -Force
