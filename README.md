# How to Convert Windows 11 Enterprise LTSC to IoT Enterprise LTSC

**Darien's Tips — Windows PowerShell and DISM command reference**

A companion to the tutorial based on `W11LTSCIOT_Title-Script_20261013.txt`.
The main workflow starts with **Windows 11 Enterprise LTSC 2024 (24H2)**, changes
the installed edition to **Windows 11 IoT Enterprise LTSC**, customizes the
reference installation, applies offline updates, and prepares it for later
capture and deployment.

**A separate lab demonstration changes Windows 11 Home or Pro to non-LTSC
Windows 11 IoT Enterprise. It is not a Home/Pro-to-LTSC conversion.**

> **Command reference, not an automated installer.** Open the `.ps1` file in an
> editor and run only reviewed, customized excerpts. Its opening `throw` is an
> intentional safety stop; keep it in the reference. The examples themselves
> include restarts, package removal, account deletion, BitLocker decryption,
> and Sysprep generalization/shutdown.

## Video and author

| Item | Value |
|---|---|
| Video title | How to Convert Windows 11 Enterprise LTSC to IoT Enterprise LTSC |
| Video | Publication URL not supplied; add it here after publishing. |
| Author | Darien Howard Hawkins |
| Channel | [Darien's Tips](https://www.youtube.com/@darienstips9409) |
| Website | [dariens.tips](https://dariens.tips) |
| Reference version | 1.0.0 |
| Created / updated | October 13, 2026 |
| Source recording script | `W11LTSCIOT_Title-Script_20261013.txt` |

## Files

| File | Purpose |
|---|---|
| [`windows-11-iot-enterprise-ltsc-command-reference.ps1`](windows-11-iot-enterprise-ltsc-command-reference.ps1) | Section-aligned Windows PowerShell and native Windows command examples. |
| `README.md` | Scope, usage, prerequisites, generalizations, and safety notes. |

The Microsoft `RemoveOnIoTEnterpriseS.ps1` sample, Windows installation media,
Windows update packages, and product keys are **not** included.

## What you'll learn

- Convert Windows 11 Enterprise LTSC 2024 to IoT Enterprise LTSC using DISM.
- Inspect Windows editions, target editions, build numbers, and CIM version information.
- Use Sysprep Audit Mode to customize a Windows IoT reference installation.
- Remove IoT LTSC packages, clean WinSxS, and compare disk usage with Get-Volume.
- Install offline Windows and .NET Framework cumulative updates with Add-WindowsPackage.
- Remove the temporary user account, run Disk Cleanup, and check installed updates.
- Wait for BitLocker decryption, then generalize Windows for OOBE and later image capture.
- Explore the separate non-LTSC Home/Pro conversion, DISM logs, and product-key channels.

## Applies to and scope

| Part | Source-described scope |
|---|---|
| Main conversion | Windows 11 Enterprise LTSC 2024 / 24H2 to `IoTEnterpriseS`. The script identifies the starting build as `26100.1742`. |
| LTSC customization | Listing and removing groups defined by the Microsoft removable-packages sample; component-store cleanup and disk measurements. |
| Evaluation customization | The alternate `-os_variant IoTEnterpriseSEval` example operates on an **already-installed** IoT LTSC evaluation. It is not an evaluation-edition conversion. |
| Image preparation | Offline OS and .NET Framework updates, account cleanup, Disk Cleanup, BitLocker decryption, and Sysprep. |
| Separate Home/Pro lab | Non-LTSC `IoTEnterprise`. The recording script also mentions a 26H2 lab system; that is a recorded observation, not the baseline for the main LTSC workflow. |
| Outside this reference | A complete image-capture/deployment procedure, application qualification, automatic update selection, or production activation implementation. |

**Suggested audience:** system administrators, IT deployment engineers, Windows
support technicians, industrial/embedded IT teams, and hands-on IT students.

**Suggested skill level:** intermediate. Be comfortable with elevated Windows
PowerShell, OS installation, account/profile administration, and basic image
preparation before using the changing/deleting commands.

## Prerequisites

Use the appropriate Windows installation media and licensing for the selected
workflow, administrative access to the target installation, and a restorable
backup or disposable test system. Download and review Microsoft's
`RemoveOnIoTEnterpriseS.ps1` separately. Obtain the applicable OS and .NET
Framework update packages before servicing an intentionally offline installation.

The command examples assume the Windows system path and OS volume used in the
source (`C:\Windows` and `C:` where written literally). Check these assumptions
and confirm the target account, profile path, edition, and update packages before
running a modifying example. Do not use the placeholder username as a command.

The sample staging layout is:

```text
C:\Temp\
    RemoveOnIoTEnterpriseS.ps1
    OSUpdates\
        <actual OS update filename>.msu
    DotNetUpdates\
        <actual .NET Framework update filename>.msu
```

Use actual downloaded filenames in the reference. The placeholder names are not
real packages, do not assert a current KB, and do not mean packages are included.
Review any prerequisite packages and servicing instructions associated with your
chosen updates; this reference does not resolve those requirements automatically.

## Using the command reference

1. Open `windows-11-iot-enterprise-ltsc-command-reference.ps1` in a text editor or VS Code. Do not run the whole file
   or remove its opening safety stop to create an end-to-end installer.
2. Read the notes for the current section and choose the applicable branch.
   Customize the paths, update identifiers, disposable account, and product key.
3. Copy the required example into an **elevated Windows PowerShell session** on
   the intended target. Follow the video for GUI steps and restart boundaries.
4. Inspect the results before the next step. After a restart, reopen the elevated
   session and resume at the indicated point; do not rerun unrelated branches.

Source step labels such as `B5`, `D14`, and `E16-E17` map the command excerpts to
the recording script. The `BEGIN EXAMPLE` / `END EXAMPLE` markers only identify
excerpts; they do not isolate code when selected in an editor. Copy only the
commands required for the current task.

### Branches and important stop points

- **C2 versus C4:** the GUI and command-line Audit Mode methods are alternatives.
  The source then calls for a restart after the edition change before section D.
- **D13 versus D14:** use the non-evaluation or already-installed evaluation
  package-removal example, not both on the same image.
- **E13-E15 versus E16-E17:** choose the separate GUI workflow or the combined
  BitLocker/Sysprep block. The combined block shuts down the system.
- **F is a different installation:** it demonstrates non-LTSC Home/Pro behavior,
  rather than a continuation of the main LTSC image.

## Command map

The A-H organization follows the final recording script.

| Section | Included commands or handling |
|---|---|
| A — Introduction | Scope and licensing notes; no operational commands. |
| B — Install and Inspect Windows 11 Enterprise LTSC | `Get-WindowsEdition`, registry queries, `Get-CimInstance Win32_OperatingSystem`, `cmd /c ver`, `winver`. |
| C — Convert to Windows 11 IoT Enterprise LTSC | Sysprep GUI / Audit Mode, target-edition listing, DISM `/Set-Edition:IoTEnterpriseS`, edition query. No evaluation-conversion branch. |
| D — Remove Removable Packages | Original execution-policy command; Microsoft sample `-List` and removal branches; `Get-Volume` measurements; restart; DISM `/StartComponentCleanup`. |
| E — Update IoT and Generalize for Deployment | Original `update-IoTLTSC` function and call; OS build and hotfix queries; local account/profile deletion; Disk Cleanup; volume measurements; BitLocker commands and original while loop; Sysprep. |
| F — Convert Home or Professional to IoT Enterprise | Separate edition inspection, Audit Mode, DISM `/Set-Edition:IoTEnterprise`, log search, restart, build checks, and `slmgr` examples. |
| G — Obtain Windows 11 Enterprise LTSC | Acquisition sources described in the narration; no commands supplied. |
| H — Thank You | No operational commands. |

Wallpaper and lock-screen customization are mentioned in D17-D20 of the source.
No registry or Group Policy implementation is invented here because the source
supplies no commands for those GUI steps.

## What was generalized — and what was not

The `39` marked command excerpts retain the source command syntax, ordering,
function name, and control flow. Only these input literals were generalized:

| Source-specific value | Reference value / action |
|---|---|
| Recorded OS MSU filename | `REPLACE-WITH-OS-UPDATE.msu` — insert the applicable downloaded filename. |
| Recorded .NET Framework MSU filename | `REPLACE-WITH-DOTNET-UPDATE.msu` — insert the applicable downloaded filename. |
| Recorded KB identifiers in `Get-HotFix` | `"KB<NET-KB>"` and `"KB<OS-KB>"` — insert the identifiers being verified. |
| `IoTDeleteMe(noPW)` cleanup target | `TemporarySetupUser` — replace with the exact disposable setup account. |
| Product-key literal in `slmgr /ipk` | `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX` — supply an appropriate authorized key. |

`C:\Temp`, `C:`, `C:\Windows`, and the shared Disk Cleanup preset number `9409`
remain editable examples. Media-filename placeholders, the audio clipboard
expression, and the author's private VHDX reattachment note are omitted because
they are recording logistics rather than commands for the tutorial workflow.

The top-level safety stop and explanatory comments are additions **outside** the
preserved excerpts. In particular, this is **not** a refactor of the update
function, account/profile removal, execution-policy change, hotfix check, or
BitLocker loop. No new catch blocks, polling timeout, profile-provider deletion,
automatic update download, or invented capture command is inserted.

## Source behavior and review cautions

These notes explain the limits of the supplied examples; they are not replacement
command implementations or a claim that every observed lab outcome generalizes.

**Package removal.** The lab removes all groups returned by the sample. The
recording explicitly warns that removal cannot be reversed within the installation
without reinstalling Windows. Validate application, peripheral, servicing, and
recovery requirements before selecting packages on a production device.

**Execution policy.** The original `Set-ExecutionPolicy -ExecutionPolicy
Unrestricted` is retained. Review its effect and your organization's restrictions
before use. It was not silently changed to a session-only policy.

**Update function.** The original function installs the OS package, installs the
.NET Framework package, and restarts. It does not contain explicit
`-ErrorAction Stop` handling or comprehensive installation-result checks. Review
applicability and failures rather than assuming reaching the restart proves both
updates succeeded. The source's `Get-HotFix` check is preserved; an inconclusive
query should lead to investigation, not an unsupported success claim.

**Account deletion.** The source directly removes the local account, its assumed
`C:\Users\<username>` folder, and its ProfileList entry. Confirm the SID, actual
profile path, session status, and absence of needed data first. This destructive
example is not converted into a new cleanup function.

**BitLocker and Sysprep.** The source waits for `VolumeStatus` to equal
`FullyDecrypted` and then invokes Sysprep. `ProtectionStatus` is a different field.
The message prints `EncryptionPercentage`; interpret it as the percentage still
encrypted. The original loop has no timeout or explicit error handling. Supervise
decryption and investigate errors or stalled progress. Sysprep prepares the
installation for later capture; this reference does not capture or deploy it.

**Error 1168.** The final script's EULA-related explanation is an observation
from the Home/Pro lab demonstration. No matching DISM log is included with this
repository. Do not infer that every occurrence has the same cause or is harmless.

**Licensing.** An edition label or product-key channel is not proof of a license
or successful activation. The source's OEM:DM/GVLK observations are not a promise
of the same outcome on other devices. The placeholder key does not activate
Windows. Confirm the correct edition, key, license, and activation arrangement for
the intended device; a target-edition list is not a license grant.

## Glossary

These eight definitions are reproduced from the supplied glossary without changes.

```text
IoT = Internet of Things
LTSC = Long-Term Servicing Channel
DISM = Deployment Image Servicing and Management
WinSxS = Windows component store
LCU = Latest Cumulative Update
BDE = BitLocker Drive Encryption
OOBE = Out Of Box Experience
KMS = Key Management Services
```

## Source references

### Supplied source material

- `W11LTSCIOT_Title-Script_20261013.txt` — final title, narration, and commands;
  section/step labels in this reference point back to that file.
- `Glossary_20260721.txt` — supplied as `Glossary_20260721(10).txt`; source of the
  eight glossary definitions above.

The recording script and complete glossary are not republished in this bundle.
Earlier drafts are not used as the command source.

### Links included in the recording script

- [Microsoft Windows IoT Samples](https://github.com/microsoft/Windows-IoT-Samples)
  — obtain and review the `samples/RemovablePackages` materials separately.
- [Windows 11 release information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information)
  — the release-reference page used in the demonstration.

Section G also discusses the Microsoft Evaluation Center, eligible Visual Studio
subscriptions, and the Microsoft 365 admin center for organizations with
appropriate Volume Licensing rights. The reference does not assume that every
account has access to the same media or subscriptions.

## Validation and limitations

The marked command bodies were compared programmatically against the final
recording script with only the documented literal substitutions allowed. The
publishing text was checked for its title, eight learning bullets, eight glossary
entries, twelve hashtags, and description length. **The Windows commands have not
been executed as part of producing this companion.** Source lab observations are
not a guarantee for other builds, hardware, activation channels, or update sets.

## Disclaimer and licensing

Educational lab reference. Back up first, use a disposable environment for
experiments, and review every changing/deleting command. Package removal, account
and profile deletion, BitLocker decryption, edition changes, and Sysprep can
materially change the installation. Production use requires appropriate licensing
and validation of the intended workload. This reference does not supply Windows
media, licenses, keys, update packages, or an activation bypass.

No repository-wide software license was specified in the supplied script, so no
license file is invented here. The Microsoft sample remains a separately obtained
resource subject to its own terms. Publication and reuse of any third-party
video/image assets are outside the scope of this command-reference bundle.
