# 🚀 LowerInstall v1.4.1

A community-maintained **rootless** LowerInstall release focused on modern Dopamine/ElleKit jailbreak environments.

## ✨ What's included

- 🎯 Targeted `installd` hook for the `MIBundle` minimum-iOS-version validation that produces `DeviceOSVersionTooLow`.
- ⚙️ Settings panel with independent controls for the installer bypass and App Store User-Agent spoofing.
- 📱 Editable advertised iOS version and device identifier for App Store metadata requests.
- 📦 Rootless packaging for arm64/arm64e.
- 🧾 Updated documentation and attribution for the maintained fork.

## 🧪 Compatibility

**Confirmed test configuration:** iPhone X · iOS 16.7.16 · Dopamine rootless · ElleKit.

**Intended target:** arm64/arm64e rootless jailbreaks on iOS 15+. Other combinations have not yet been verified.

## ⚠️ Read before installing

Bypassing the installer's minimum-iOS check does not add missing system APIs or guarantee that an app will launch or function correctly. An app may install and still be incompatible with the installed iOS version.

This is a community-maintained fork, not an official Apple or upstream release.

## 🙌 Credits

- Original project: [julioverne/LowerInstall](https://github.com/julioverne/LowerInstall)
- Rootless development lineage: [PlayDay-iOS/LowerInstall](https://github.com/PlayDay-iOS/LowerInstall)
- Rootless maintenance and Settings updates: [@MftFM](https://github.com/mftfm)

## 📦 Package

The rootless DEB package will be attached to this GitHub Release by the maintainer.
