# 📦 LowerInstall

**🛠️ A rootless iOS jailbreak tweak that helps install apps when their declared minimum iOS version is newer than the iOS version running on your device.**

Welcome! This is a community-maintained rootless fork of LowerInstall, focused on modern rootless jailbreak environments. It adds a targeted installer minimum-iOS-version bypass and optional App Store User-Agent spoofing.

> 🧪 **Confirmed test:** iPhone X · iOS 16.7.16 · Dopamine (rootless) · ElleKit  
> 🎯 **Intended target:** arm64/arm64e rootless jailbreaks on iOS 15 and later. Other devices and iOS versions are not yet confirmed. Private iOS APIs can change without notice.

## ✨ Features

### 📲 1. Installer minimum-iOS-version bypass

Hooks the private `MIBundle` minimum-OS validation method used by `installd`. When enabled, it allows the installer's minimum-OS check to pass even if an IPA declares a newer `MinimumOSVersion`.

This targets the `DeviceOSVersionTooLow` / `MIInstallerErrorDomain Code 9` rejection observed on iOS 16.7.16.

### 🛍️ 2. Optional App Store User-Agent spoofing

When enabled, rewrites the iOS-version and device tokens in outgoing App Store `User-Agent` headers. This may help request metadata or app variants associated with another device/iOS identity. It is independent of the installer bypass.

### ⚙️ 3. Settings panel

Open **Settings → LowerInstall** to configure:

- 🔘 **Enabled** — master switch for the tweak.
- 📦 **Installer Minimum iOS Bypass** — controls the `installd` minimum-OS hook.
- 🛍️ **App Store User-Agent Spoofing** — controls App Store User-Agent rewriting.
- 📱 **iOS Version** — version string to advertise to App Store metadata services.
- 🧩 **Device Identifier** — hardware identifier to advertise, for example `iPhone11,8`.
- ♻️ **Reset settings** — restores default preferences.

The installer bypass does not require changing the spoofing fields. Keep the actual device identity unless you have a specific reason to change it.

## ⚠️ Important limitations

LowerInstall changes an installation compatibility check. It does **not** magically make a newer-iOS app fully compatible with an older iOS release.

- ❌ It does not add missing APIs, frameworks, entitlements, or system components.
- ❌ It does not guarantee that an app will launch or work correctly after installation.
- ❌ It does not make an app compatible with unsupported CPU, GPU, memory, or hardware.
- ❌ It does not bypass Apple ID, purchase, server-side, or account checks.
- 🛡️ It is not intended to disable code-signing or unrelated package-validation checks.

An IPA may install successfully and still crash, refuse to launch, or malfunction because required system functionality is unavailable.

## 📋 Compatibility

| Item | Status |
|---|---|
| Jailbreak type | Rootless |
| Tested jailbreak | Dopamine |
| Injection compatibility | ElleKit / Substrate compatibility layer |
| Architectures | arm64 / arm64e |
| Intended minimum iOS | iOS 15.0 |
| Confirmed test | iPhone X · iOS 16.7.16 |
| Other devices/iOS versions | Not yet verified |

⚠️ This tweak uses private iOS classes and selectors. Compatibility with other iOS versions must be tested; do not assume universal support.

## ⬇️ Installation

1. Open the **[Releases](https://github.com/mftfm/LowerInstall/releases)** page.
2. Download the latest rootless `.deb` asset.
3. Install it using Sileo or another package manager compatible with your rootless jailbreak.
4. Open **Settings → LowerInstall** and configure the options.

**Important:** Do not install a rootful package on a rootless jailbreak. Only install a release explicitly marked **rootless**.

## 🧰 Build from source

You'll need Theos, an iOS SDK, and a rootless jailbreak package toolchain.

```sh
git clone https://github.com/mftfm/LowerInstall.git
cd LowerInstall
make clean package FINALPACKAGE=1
```

The Makefile configures rootless packaging and arm64/arm64e architectures. The resulting package is written to `packages/`.

📖 See the [Theos installation guide](https://theos.dev/docs/installation) for toolchain setup.

## 🐛 Diagnostics

The tweak writes messages with the `[LowerInstall:` prefix to the system log. When troubleshooting an installation failure, capture logs from `installd` and look for:

- `DeviceOSVersionTooLow`
- `MIBundle`
- `LowerInstall`

Please include your device, iOS version, jailbreak, package version, and relevant logs when opening an issue.

## 🔀 What's different in this fork?

This repository is a maintained fork of [PlayDay-iOS/LowerInstall](https://github.com/PlayDay-iOS/LowerInstall), continuing the work of [julioverne/LowerInstall](https://github.com/julioverne/LowerInstall).

This fork focuses on modern rootless jailbreak support:

- 📦 Rootless package configuration for arm64/arm64e instead of the original rootful package target.
- 🎯 A targeted hook for the private `MIBundle` minimum-OS validation method identified in iOS 16.7.16 installer logs.
- ⚙️ A Settings pane with independent installer-bypass and Store User-Agent controls, plus editable device and iOS-version values.
- 🧰 Rootless-oriented packaging and build/release documentation.
- 👨‍💻 Active maintenance and compatibility work by **[@MftFM](https://github.com/mftfm)**.

The original project's identity and license lineage are retained. This is an independent community-maintained fork, not an official Apple or upstream release.

## 🙌 Credits

- 🧑‍💻 Original LowerInstall project: [julioverne](https://github.com/julioverne/LowerInstall)
- 🧑‍🔧 Rootless development lineage: [PlayDay-iOS](https://github.com/PlayDay-iOS/LowerInstall)
- 🚀 Rootless maintenance, compatibility work, and Settings updates: **[@MftFM](https://github.com/mftfm)**

## ☕ Support / Donations

Donations are completely optional. No payment link is configured yet; a legitimate support link may be added here later. The tweak remains free to use.

## 📄 License

MIT. See [LICENSE](LICENSE). Please retain the original copyright and attribution notices when redistributing.
