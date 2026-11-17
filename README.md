# LowerInstall

**Rootless iOS tweak for testing app compatibility when an app declares a newer minimum iOS version than the device runs.**

This maintained fork modernizes the original LowerInstall project for rootless jailbreak environments. It provides an install-time minimum-iOS-version bypass in `installd` and an optional App Store User-Agent spoof for store metadata requests.

> **Tested configuration:** iPhone X · iOS 16.7.16 · Dopamine rootless · ElleKit.  
> **Intended support:** arm64/arm64e rootless jailbreaks on iOS 15 and later. Other device/iOS combinations are not yet confirmed. Private MobileInstallation APIs can change between iOS releases.

## What it does

### 1. Installer minimum-iOS-version bypass

Hooks the private `MIBundle` minimum-OS validation method used by `installd`. When enabled, the tweak allows the installer's minimum-OS check to pass even when the IPA declares a newer `MinimumOSVersion`.

This is the fix for the `DeviceOSVersionTooLow` / `MIInstallerErrorDomain Code 9` rejection observed on iOS 16.7.16.

### 2. Optional App Store User-Agent spoofing

When enabled, rewrites the iOS-version and device tokens in outgoing App Store `User-Agent` headers. This can help request metadata or app variants associated with a different device/iOS identity. It is independent of the installer bypass.

### 3. Settings

Open **Settings → LowerInstall**.

- **Enabled** — master switch.
- **Install-time bypasses** — controls the `installd` minimum-OS hook.
- **Store User-Agent spoofing** — controls App Store User-Agent rewriting.
- **iOS Version** — version string to advertise to App Store metadata services.
- **Device** — hardware identifier to advertise, for example `iPhone11,8`.
- **Reset settings** — clears custom preferences.

By default, spoof values fall back to the device's actual iOS version and hardware identifier. The installer bypass does not require changing these fields.

## What this does not do

- It does **not** add APIs, frameworks, entitlements, or capabilities missing from the installed iOS version.
- It does **not** guarantee that an app requiring newer system functionality will launch or work correctly.
- It does **not** make an incompatible app compatible with the device's CPU, GPU, memory, or hardware.
- It does **not** bypass Apple ID, purchase, server-side, or account checks.
- It is not intended to disable code-signing or unrelated package-validation checks.

An IPA may install successfully and still crash, refuse to launch, or malfunction because the required OS functionality is absent.

## Compatibility

| Item | Status |
|---|---|
| Jailbreak type | Rootless |
| Jailbreak tested | Dopamine |
| Injection compatibility | ElleKit / Substrate compatibility layer |
| Architecture | arm64 / arm64e |
| Minimum intended iOS | iOS 15.0 |
| Confirmed device test | iPhone X, iOS 16.7.16 |
| Other iOS versions/devices | Not yet verified |

This project uses private iOS classes and selectors. Compatibility with future or different iOS versions must be tested; do not assume universal support.

## Installation

1. Open the **Releases** page.
2. Download the latest `.deb` asset.
3. Install it using Sileo or another package manager compatible with your rootless jailbreak.
4. Open **Settings → LowerInstall** to configure the switches and optional spoof values.

Do not install a rootful package on a rootless jailbreak. Only use a release explicitly marked rootless.

## Building from source

Requires Theos, an iOS SDK, and a rootless jailbreak package toolchain.

```sh
git clone https://github.com/mftfm/LowerInstall.git
cd LowerInstall
make clean package FINALPACKAGE=1
```

The project Makefile sets the rootless package scheme and arm64/arm64e architectures. The resulting package is written to `packages/`.

For a local Theos setup, see [Theos installation documentation](https://theos.dev/docs/installation).

## Diagnostics

The tweak writes messages with the `[LowerInstall:` prefix to the system log. For an installation failure, capture logs from `installd` and look for `DeviceOSVersionTooLow`, `MIBundle`, or `LowerInstall`.

## What's different from the upstream project?

This repository is a maintained fork of [PlayDay-iOS/LowerInstall](https://github.com/PlayDay-iOS/LowerInstall), which continues the work of [julioverne/LowerInstall](https://github.com/julioverne/LowerInstall).

This fork's focus is specifically modern rootless jailbreak support:

- Rootless package configuration for arm64/arm64e instead of the original rootful package target.
- A targeted hook for the private `MIBundle` minimum-OS validation method identified in iOS 16.7.16 installer logs.
- A Settings pane for independently enabling the installer bypass and Store User-Agent spoofing, with editable device and iOS-version values.
- Rootless-oriented packaging and release/build documentation.
- Maintained by **@MftFM**.

The project retains the original project's identity and license lineage. This is a community-maintained compatibility fork, not an official Apple or upstream release.

## Credits

- Original LowerInstall project: [julioverne](https://github.com/julioverne/LowerInstall)
- Rootless development lineage: [PlayDay-iOS](https://github.com/PlayDay-iOS/LowerInstall)
- Rootless maintenance, compatibility work and Settings updates: **[@MftFM](https://github.com/mftfm)**

## Donations

No donation link is configured at this time. If a suitable supported option becomes available, a link can be added here. Donations are optional and are not required to use the project.

## License

MIT. See [LICENSE](LICENSE) and retain the original copyright and attribution notices when redistributing.
