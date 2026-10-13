<#
.SYNOPSIS
    Command reference for: How to Convert Windows 11 Enterprise LTSC to IoT Enterprise LTSC

.DESCRIPTION
    Companion to the Darien's Tips video and its final recording script.
    This is a SELECT-AND-RUN COMMAND REFERENCE, not an unattended deployment script.
    Open this file in an editor, review the relevant notes, customize the example
    values, and copy only the commands for the current step into an elevated
    Windows PowerShell session.

    Original commands, function name, control flow, and section order are retained.
    Edits to command bodies are limited to the update filenames, KB identifiers,
    disposable username, and product-key literal. A safety stop and comments have
    been added outside the command examples. GUI-only steps remain comments.

    Section C: Enterprise LTSC -> IoT Enterprise LTSC (IoTEnterpriseS).
    Section D: Alternative package-removal branches for IoTEnterpriseS and
               already-installed IoTEnterpriseSEval; no evaluation conversion.
    Section F: Separate Home/Pro -> non-LTSC IoT Enterprise (IoTEnterprise) lab.

.NOTES
    File          : windows-11-iot-enterprise-ltsc-command-reference.ps1
    Author        : Darien Howard Hawkins
    Channel       : Darien's Tips
    Website       : https://dariens.tips
    YouTube       : https://www.youtube.com/@darienstips9409
    Version       : 1.0.0
    Created       : 2026-10-13
    Last Updated  : 2026-10-13
    Source        : W11LTSCIOT_Title-Script_20261013.txt
    Main baseline : Windows 11 Enterprise LTSC 2024 / 24H2; source build 26100.1742
    Host shell    : Elevated Windows PowerShell on the target Windows installation
    Prerequisites : Appropriate media, licensing and administrative access;
                    backups/disposable lab; downloaded Microsoft sample and MSUs.
    License       : No repository license specified in the supplied source.

    SAFETY / DISCLAIMER
    Do not execute this file end to end. Commands can change Windows editions,
    remove packages, change execution policy, delete accounts and data, decrypt
    volumes, reboot, generalize Windows, and shut down the computer.
    The all-groups removal is a lab example, not a production baseline.
    Changing the edition or installing a key does not supply a Windows license.
    The original update function and polling loop are not rewritten with new
    error handling, timeout logic, or production safeguards.
    Test and validate selected commands and your final application requirements.

    THIRD-PARTY SAMPLE
    RemoveOnIoTEnterpriseS.ps1 is obtained separately from Microsoft Windows IoT
    Samples. It is linked, not redistributed or rewritten in this reference.

.LINK
    https://github.com/microsoft/Windows-IoT-Samples

.LINK
    https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information
#>

# Safety stop outside the preserved examples. Keep it in this reference file.
throw 'Command reference only. Open in an editor and run reviewed excerpts one step at a time.'

# ============================================================================
# (A) Introduction
# ============================================================================
# No operational commands in this section of the recording script.
# Main task: prepare a customized LTSC installation for fixed-purpose devices.
# Licensing and activation remain separate from an edition-name change.

# ============================================================================
# (B) Install and Inspect Windows 11 Enterprise LTSC
# ============================================================================
# Source B1-B4: install from appropriate media and open an elevated session.
# TemporarySetupUser is a disposable example account name, not a command.
# No passwordless-account creation command was supplied or added.

# B5 - Inspect the installed edition
# BEGIN EXAMPLE B5
Get-WindowsEdition -Online
# END EXAMPLE B5

# B7 - Inspect product, edition, version and build fields
# BEGIN EXAMPLE B7
Get-ItemProperty `
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
    Select-Object ProductName,
                  EditionID,
                  DisplayVersion,
                  CurrentBuild,
                  UBR |
    Format-List
# END EXAMPLE B7

# B10 - Query Win32_OperatingSystem using CIM
# BEGIN EXAMPLE B10
Get-CimInstance Win32_OperatingSystem |
    Select-Object Name,Caption,Version |
    Format-List
# END EXAMPLE B10

# B12 - Compare registry build information with cmd ver
# BEGIN EXAMPLE B12
Get-ItemProperty `
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
    Select-Object EditionID,
                  DisplayVersion,
                  CurrentBuild,
                  UBR |
    Format-List

cmd /c ver
# END EXAMPLE B12

# B13 - Open About Windows
# BEGIN EXAMPLE B13
winver
# END EXAMPLE B13

# ============================================================================
# (C) Convert to Windows 11 IoT Enterprise LTSC
# ============================================================================

# C2 - Open the Sysprep GUI
# GUI alternative: enter System Audit Mode, leave Generalize unchecked, and reboot.
# Use either this GUI method or C4; these are not consecutive setup actions.
# BEGIN EXAMPLE C2
C:\Windows\System32\Sysprep\sysprep.exe
# END EXAMPLE C2

# C4 - Enter Audit Mode using the command line
# RESTARTS THE SYSTEM. Resume after the restart in the Administrator session.
# BEGIN EXAMPLE C4
C:\Windows\System32\Sysprep\sysprep.exe /audit /reboot
# END EXAMPLE C4

# C8 - Inspect the current and target editions
# BEGIN EXAMPLE C8
Get-WindowsEdition -Online
Get-WindowsEdition -Online -Target
# END EXAMPLE C8

# C9 - Change the main LTSC installation to IoTEnterpriseS
# MAIN LTSC BRANCH ONLY. Check the starting edition and licensing first.
# The source describes a restart at C11 before proceeding to section D.
# Restart manually at that point. No extra executable command is inserted here.
# No evaluation-edition conversion is included in this section.
# BEGIN EXAMPLE C9
dism -online /Set-Edition:IoTEnterpriseS /AcceptEula
Get-WindowsEdition -Online
# END EXAMPLE C9

# ============================================================================
# (D) Remove Removable Packages
# ============================================================================

# D7 - Set the execution policy as demonstrated
# SOURCE COMMAND PRESERVED. This changes execution policy; review its scope and
# your organization's policy before use. No session-scoped replacement is added.
# BEGIN EXAMPLE D7
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
# END EXAMPLE D7

# D8 - Go to the folder containing the Microsoft sample
# C:\Temp is an example staging folder. Edit it to match your environment.
# Download and review RemoveOnIoTEnterpriseS.ps1 from the linked Microsoft repo.
# BEGIN EXAMPLE D8
cd C:\Temp
# END EXAMPLE D8

# D9 - List the removal groups defined by the sample
# BEGIN EXAMPLE D9
.\RemoveOnIoTEnterpriseS.ps1 -List
# END EXAMPLE D9

# D10 - Measure disk usage before package removal
# Use the same measurement approach for the later comparisons.
# BEGIN EXAMPLE D10
Get-Volume -DriveLetter ($env:SystemDrive.TrimEnd(':')) |
    Select-Object @{Name='DeviceID'; Expression={"$($_.DriveLetter):"}},
        @{Name='TotalGiB'; Expression={[math]::Round($_.Size / 1GB, 3)}},
        @{Name='FreeGiB'; Expression={[math]::Round($_.SizeRemaining / 1GB, 3)}},
        @{Name='UsedGiB'; Expression={[math]::Round(($_.Size - $_.SizeRemaining) / 1GB, 3)}} |
    Format-List
# END EXAMPLE D10

# D13 - Remove all sample groups on non-evaluation IoT Enterprise LTSC
# DESTRUCTIVE LAB EXAMPLE. The source removes all groups returned by the sample.
# Do not copy this as a blanket production recommendation. Validate dependencies.
# These removals cannot be reversed in-place as described in the source.
# Choose this branch OR D14 according to the installed edition.
# BEGIN EXAMPLE D13
.\RemoveOnIoTEnterpriseS.ps1 -List |
    foreach { .\RemoveOnIoTEnterpriseS.ps1 -isOnline -suppressPrompts -RemoveUnit $_.Name }
# END EXAMPLE D13

# D14 - Alternative: remove groups on IoT Enterprise LTSC Evaluation
# ALTERNATIVE TO D13. For an already-installed IoTEnterpriseSEval installation.
# This is an evaluation package-removal example, NOT an edition conversion.
# The same irreversible-removal warning applies.
# BEGIN EXAMPLE D14
cd c:\Temp
Get-WindowsEdition -Online ; Get-ComputerInfo | Select-Object WindowsEditionID,OSName,OSversion

.\RemoveOnIoTEnterpriseS.ps1 -List |
    foreach { .\RemoveOnIoTEnterpriseS.ps1 -isOnline -os_variant IoTEnterpriseSEval -suppressPrompts -RemoveUnit $_.Name }
# END EXAMPLE D14

# D16 - Restart after package removal
# RESTARTS THE SYSTEM. Resume D21 after the restart.
# The source explains wallpaper replacement and local Group Policy at D17-D20.
# Those are GUI/narration steps; no Group Policy commands were supplied.
# BEGIN EXAMPLE D16
Restart-Computer
# END EXAMPLE D16

# D21 - Clean the Windows component store
# BEGIN EXAMPLE D21
dism.exe /Online /Cleanup-Image /StartComponentCleanup
# END EXAMPLE D21

# D22 - Measure disk usage again after removal and cleanup
# BEGIN EXAMPLE D22
Get-Volume -DriveLetter ($env:SystemDrive.TrimEnd(':')) |
    Select-Object @{Name='DeviceID'; Expression={"$($_.DriveLetter):"}},
        @{Name='TotalGiB'; Expression={[math]::Round($_.Size / 1GB, 3)}},
        @{Name='FreeGiB'; Expression={[math]::Round($_.SizeRemaining / 1GB, 3)}},
        @{Name='UsedGiB'; Expression={[math]::Round(($_.Size - $_.SizeRemaining) / 1GB, 3)}} |
    Format-List
# END EXAMPLE D22

# ============================================================================
# (E) Update IoT and Generalize for Deployment
# ============================================================================

# E3 - Apply the offline OS and .NET Framework updates, then restart
# EDIT BOTH MSU FILENAMES BEFORE USE. Use the actual applicable files you acquired.
# Keep the OS update files under OSUpdates and .NET files under DotNetUpdates.
# The original function name, sequence, invocation and restart are preserved.
# No update-discovery, prerequisite selection, or added error handling is included.
# RESTARTS THE SYSTEM. Review applicability and outcomes; resume E4 after restart.
# BEGIN EXAMPLE E3
# Apply OS and .NET Framework LCU
function update-IoTLTSC {
    $updateBasePath = "C:\Temp"
    Add-WindowsPackage `
        -Online `
        -PackagePath "$updateBasePath\OSUpdates\REPLACE-WITH-OS-UPDATE.msu" `
        -NoRestart
    Add-WindowsPackage `
        -Online `
        -PackagePath "$updateBasePath\DotNetUpdates\REPLACE-WITH-DOTNET-UPDATE.msu" `
        -NoRestart
    Restart-Computer
}
update-IoTLTSC
# END EXAMPLE E3

# E4 - Inspect the installed OS version after servicing
# BEGIN EXAMPLE E4
Get-ItemProperty `
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
    Select-Object DisplayVersion,LCUVer |
    Format-List

cmd /c ver
# END EXAMPLE E4

# E5 - Query the selected .NET and OS update KB identifiers
# Replace both KB placeholders with the identifiers appropriate to your packages.
# The source uses Get-HotFix; no new package-verification implementation is added.
# An inconclusive query requires investigation, not a claim of success.
# BEGIN EXAMPLE E5
Get-HotFix -HFID "KB<NET-KB>","KB<OS-KB>"
# END EXAMPLE E5

# E6 - Remove the disposable setup account, folder and ProfileList entry
# DELETES THE ACCOUNT AND ITS PROFILE DATA. Set the exact disposable username.
# Do not target the account running this session or another required account.
# The source's direct folder and registry deletion method is preserved.
# It assumes C:\Users\<username>; verify the actual path and account before use.
# BEGIN EXAMPLE E6
$userToRemove = "TemporarySetupUser"
$userToRemoveSID = (Get-LocalUser -Name $userToRemove).sid.value
$baseProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$userToRemoveRegProfile = "$baseProfilePath\$userToRemoveSID"
Remove-LocalUser -Name $userToRemove
Remove-Item -Force -Recurse -Path c:\users\$userToRemove
Remove-Item -Force -Recurse -Path $userToRemoveRegProfile
# END EXAMPLE E6

# E8 - Choose Disk Cleanup categories
# Review categories for your image. The source selects all in its disposable lab.
# Use the same sageset/sagerun number for both commands.
# BEGIN EXAMPLE E8
Cleanmgr /sageset:9409
# END EXAMPLE E8

# E9 - Run the saved Disk Cleanup selection
# BEGIN EXAMPLE E9
Cleanmgr /sagerun:9409
# END EXAMPLE E9

# E10 - Measure disk usage after updates and Disk Cleanup
# The source notes that updates can affect the final storage comparison.
# BEGIN EXAMPLE E10
Get-Volume -DriveLetter ($env:SystemDrive.TrimEnd(':')) |
    Select-Object @{Name='DeviceID'; Expression={"$($_.DriveLetter):"}},
        @{Name='TotalGiB'; Expression={[math]::Round($_.Size / 1GB, 3)}},
        @{Name='FreeGiB'; Expression={[math]::Round($_.SizeRemaining / 1GB, 3)}},
        @{Name='UsedGiB'; Expression={[math]::Round(($_.Size - $_.SizeRemaining) / 1GB, 3)}} |
    Format-List
# END EXAMPLE E10

# E12 - Inspect BitLocker volume status
# BEGIN EXAMPLE E12
Get-BitLockerVolume
# END EXAMPLE E12

# E13 - Start BitLocker decryption for the separate GUI workflow
# CHANGES ENCRYPTION. C: is the source example; confirm the actual OS volume.
# E14-E15 then use Sysprep in the GUI after FullyDecrypted is confirmed.
# Use this separate GUI workflow OR the combined E16-E17 block.
# BEGIN EXAMPLE E13
Disable-BitLocker -MountPoint c:
# END EXAMPLE E13

# E16-E17 - Alternative: wait for decryption and run Sysprep
# ALTERNATIVE COMBINED WORKFLOW. GENERALIZES AND SHUTS DOWN THE SYSTEM.
# The source's ten-second polling interval and message are retained unchanged.
# The displayed EncryptionPercentage is the percentage still encrypted.
# This loop has no timeout or added error handling. Supervise it and investigate
# errors or stalled decryption rather than assuming it is production automation.
# Preparing the installation for capture does not itself create a captured image.
# BEGIN EXAMPLE E16-E17
$MountPoint = "C:"
Disable-BitLocker -MountPoint $MountPoint
while ((Get-BitLockerVolume -MountPoint $MountPoint).VolumeStatus -ne "FullyDecrypted") {
    $BitLocker = Get-BitLockerVolume -MountPoint $MountPoint

    Write-Host "Waiting for BitLocker decryption...$($BitLocker.EncryptionPercentage)%"
    Start-Sleep -Seconds 10
}

Write-Host "BitLocker volume is fully decrypted. Generalizing image."
& "$env:windir\System32\Sysprep\sysprep.exe" /oobe /generalize /shutdown
# END EXAMPLE E16-E17

# ============================================================================
# (F) Convert Home or Professional to IoT Enterprise
# ============================================================================

# F3 - Inspect the starting edition on the separate Home/Pro lab system
# SEPARATE NON-LTSC DEMONSTRATION. Do not continue this on the main LTSC image.
# BEGIN EXAMPLE F3
Get-WindowsEdition -Online
# END EXAMPLE F3

# F5 - List target editions for the separate installation
# BEGIN EXAMPLE F5
Get-WindowsEdition -Online -Target
# END EXAMPLE F5

# F7 - Enter Audit Mode for the separate installation
# RESTARTS THE SYSTEM. Continue F8 after the restart.
# BEGIN EXAMPLE F7
C:\Windows\System32\Sysprep\sysprep.exe /audit /reboot
# END EXAMPLE F7

# F8 - Change to non-LTSC IoTEnterprise and inspect the result
# The target is IoTEnterprise, NOT IoTEnterpriseS.
# BEGIN EXAMPLE F8
dism -online /Set-Edition:IoTEnterprise /AcceptEula
Get-WindowsEdition -Online
# END EXAMPLE F8

# F10 - Search the DISM log for the reported error representations
# The EULA-related explanation in the narration is an observation from this lab.
# The reference does not turn it into a general instruction to ignore Error 1168.
# BEGIN EXAMPLE F10
Select-String `
    -Path "$env:windir\Logs\DISM\dism.log" `
    -Pattern '1168','0x80070490'
# END EXAMPLE F10

# F13 - Restart the separate installation
# RESTARTS THE SYSTEM. Continue F14 after the restart.
# BEGIN EXAMPLE F13
Restart-Computer
# END EXAMPLE F13

# F14 - Inspect edition, version and build information after restart
# BEGIN EXAMPLE F14
Get-ItemProperty `
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' |
    Select-Object ProductName,
                  EditionID,
                  DisplayVersion,
                  CurrentBuild,
                  UBR |
    Format-List
# END EXAMPLE F14

# F15 - Open About Windows on the separate installation
# The script reports a 26H2 lab installation; this does not redefine the main
# LTSC 2024 / 24H2 baseline or certify other builds.
# BEGIN EXAMPLE F15
winver
# END EXAMPLE F15

# F17 - Inspect licensing details and the product-key channel
# BEGIN EXAMPLE F17
slmgr /dlv
# END EXAMPLE F17

# F20 - Install the appropriate authorized product key
# CHANGES THE INSTALLED KEY. Replace XXXXX-... with an appropriate authorized key.
# The source's specific key literal is generalized; slmgr syntax is unchanged.
# No key in this reference supplies a license or guarantees activation.
# Confirm edition and activation results separately before deployment.
# BEGIN EXAMPLE F20
slmgr /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
# END EXAMPLE F20

# F21 - Inspect licensing details again
# A reported product-key channel is not by itself proof of activation.
# BEGIN EXAMPLE F21
slmgr /dlv
# END EXAMPLE F21

# ============================================================================
# (G) Obtain Windows 11 Enterprise LTSC
# ============================================================================
# No commands were supplied in this section. The source discusses the Microsoft
# Evaluation Center, eligible Visual Studio subscriptions, and the Microsoft 365
# admin center with appropriate Volume Licensing rights. Verify the actual media
# and edition obtained for the chosen workflow. No acquisition script is added.

# ============================================================================
# (H) Thank You
# ============================================================================
# No commands. Channel: https://www.youtube.com/@darienstips9409
