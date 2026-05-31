# Avorax Windows Installers

Build the Windows MSI and EXE installers from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File installer\windows\build-msi.ps1 -Version 0.2.7
```

The script:

- Builds the Flutter Windows release app unless `-SkipFlutterBuild` is passed.
- Builds `zentor_local_core.exe` with Cargo when Cargo is available, and fails release packaging if it is still missing.
- Stages the Flutter runtime DLLs and app assets.
- Copies the Avorax Rust local core beside `Avorax.exe`; this is the local Avorax Native Engine command surface used by the Flutter app.
- Copies `zentor_guard_service.exe` beside `Avorax.exe` and fails release packaging if it is missing.
- Registers the visible `zentor_guard_service` Windows service for post-launch Guard monitoring.
- Copies Avorax Native Engine signatures, rules, ML model assets, and trust packs beside the app.
- Copies safe validation assets, release gates, protection self-tests, performance/false-positive checks, safe simulator tools, and threat-intel import tools.
- Copies Windows minifilter and process-guard driver source, build scripts, signing scripts, install/uninstall scripts, and self-test scripts.
- Writes `install-manifest.json` into the install folder and Flutter release folder so a built MSI/EXE can be audited for included components.
- Skips ClamAV compatibility by default. Avorax Native Engine is the primary scanner.
- Copies Visual C++ runtime DLLs from `C:\Windows\System32` when present.
- Includes local privacy/security/driver/native-engine documentation.
- Uses the local WiX .NET tool from `dotnet-tools.json`.
- Produces `dist\Avorax-AntiVirus-<version>-x64.msi`.
- Produces `dist\Avorax-AntiVirus-<version>-x64-setup.exe`.

Release packaging fails if `zentor_local_core.exe`, `zentor_guard_service.exe`, or required engine assets cannot be included:

```powershell
powershell -ExecutionPolicy Bypass -File installer\windows\build-msi.ps1 -Version 0.2.7 -RequireLocalCore -AllowDevelopmentModel
```

`-AllowIncompletePayload` exists only for local packaging diagnostics and must not be used for release installers. A normal MSI/EXE build installs the app, local core, Guard Service, assets, engine packs, validation tools, docs, and manifest together.

ClamAV compatibility is optional and disabled by default. Use `-IncludeClamAVCompatibility` only when explicitly testing compatibility mode:

```powershell
powershell -ExecutionPolicy Bypass -File installer\windows\build-msi.ps1 -Version 0.2.7 -IncludeClamAVCompatibility
```

When compatibility mode is included, the MSI places ClamAV in `C:\Program Files\Avorax\ClamAV` and the Avorax local core discovers `clamscan.exe` there automatically. Avorax does not install ClamAV as a hidden service and does not silently enable persistence.

The EXE installer is a WiX Burn bootstrapper that contains the MSI. It is useful for GitHub Releases and users who expect a single setup executable. It installs the same files and follows the same privacy and visibility rules as the MSI.

The MSI build requires AI model assets. If model metadata is `production_ready=false`, pass `-AllowDevelopmentModel` for a non-production installer:

```powershell
powershell -ExecutionPolicy Bypass -File installer\windows\build-msi.ps1 -Version 0.2.7 -RequireLocalCore -AllowDevelopmentModel
```

The Guard Service is not a kernel driver and does not provide true pre-execution blocking by itself. It monitors process starts and can stop/quarantine confirmed threats after launch when the user enables that protection mode. High-confidence non-confirmed detections remain review-only. True pre-execution blocking still requires the Windows driver validation workflow.

The MSI packages driver tooling and validation scripts, but it does not silently install unsigned or test-signed drivers and does not silently enable Windows TESTSIGNING. Driver activation must go through the documented driver workflow and self-test.

Set `AVORAX_GUARD_MODE` or `AVORAX_PROTECTION_MODE` to `blockConfirmedThreats`, `monitorOnly`, `disabled`, `balanced`, `lockdown`, or `developerMode` before starting the service to control post-launch behavior. If no mode is configured, the service defaults to blocking confirmed threats only.

The Flutter app also asks local core to write the shared Guard mode file when the protection profile changes. Environment variables take precedence over the file so managed deployments can enforce a mode.
