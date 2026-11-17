/*
 * LowerInstall 1.4.1 — rootless compatibility fork.
 *
 * Installer hook: narrowly bypasses MIBundle's minimum-OS validation.
 * Store hook: optionally rewrites the iOS/device tokens in App Store
 * User-Agent headers. These are independently controlled in Settings.
 *
 * This deliberately does not bypass signing, bundle metadata, entitlement,
 * device-family, or unrelated installer validation.
 */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <notify.h>
#import <sys/utsname.h>
#import <syslog.h>
#import <string.h>
#import <stdint.h>

extern const char *__progname;

#define LILog(lvl, fmt, ...) syslog((lvl), "[LowerInstall:%s] " fmt, (__progname ? __progname : "unknown"), ##__VA_ARGS__)
#define LINotice(fmt, ...)   LILog(LOG_NOTICE, fmt, ##__VA_ARGS__)
#define LIInfo(fmt, ...)     LILog(LOG_INFO, fmt, ##__VA_ARGS__)
#define LIDebug(fmt, ...)    LILog(LOG_DEBUG, fmt, ##__VA_ARGS__)

#define PLIST_PATH "/var/mobile/Library/Preferences/dev.playday3008.lowerinstall.plist"
#define SETTINGS_CHANGED "dev.playday3008.lowerinstall/SettingsChanged"

static struct {
    NSString *currentDevice;
    NSString *currentVersion;
    NSString *spoofDevice;
    NSString *spoofVersion;
} g_state;

static BOOL g_enabled = YES;
static BOOL g_hooksInstalld = YES;
static BOOL g_hooksStore = YES;
static NSObject *g_lock = nil;

static void settingsChanged(CFNotificationCenterRef center,
                            void *observer,
                            CFStringRef name,
                            const void *object,
                            CFDictionaryRef userInfo) {
    (void)center; (void)observer; (void)name; (void)object; (void)userInfo;

    @autoreleasepool {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@PLIST_PATH] ?: @{};

        g_enabled = [(prefs[@"Enabled"] ?: @YES) boolValue];
        g_hooksInstalld = [(prefs[@"HooksInstalld"] ?: @YES) boolValue];
        g_hooksStore = [(prefs[@"HooksStore"] ?: @YES) boolValue];

        NSString *device = prefs[@"SpoofDevice"] ?: g_state.currentDevice ?: @"";
        NSString *version = prefs[@"SpoofVersion"] ?: g_state.currentVersion ?: @"";

        @synchronized(g_lock) {
            [g_state.spoofDevice release];
            g_state.spoofDevice = [device copy];
            [g_state.spoofVersion release];
            g_state.spoofVersion = [version copy];
        }

        LINotice("settings reloaded: enabled=%d installer=%d store=%d",
                 g_enabled, g_hooksInstalld, g_hooksStore);
    }
}

%group InstalldHooks

%hook MIBundle

- (BOOL)_isMinimumOSVersion:(id)minimumOSVersion
       applicableToOSVersion:(id)applicableOSVersion
                   requiredOS:(unsigned long long)requiredOS
                        error:(NSError **)error {
    if (g_enabled && g_hooksInstalld) {
        if (error != NULL) {
            *error = nil;
        }

        LIInfo("bypassing minimum-OS validation: minimum=%s applicable=%s requiredOS=%llu",
               [[minimumOSVersion description] UTF8String] ?: "(null)",
               [[applicableOSVersion description] UTF8String] ?: "(null)",
               requiredOS);
        return YES;
    }

    return %orig;
}

%end
%end

%group StoreHooks

%hook NSMutableURLRequest

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (!g_enabled || !g_hooksStore || value == nil || field == nil ||
        [field caseInsensitiveCompare:@"User-Agent"] != NSOrderedSame ||
        g_state.currentVersion.length == 0 ||
        [value rangeOfString:g_state.currentVersion].location == NSNotFound) {
        %orig(value, field);
        return;
    }

    NSString *spoofVersion = nil;
    NSString *spoofDevice = nil;

    @synchronized(g_lock) {
        spoofVersion = [g_state.spoofVersion copy];
        spoofDevice = [g_state.spoofDevice copy];
    }

    NSString *rewritten = value;
    NSString *currentVersionToken = [NSString stringWithFormat:@"/%@ ", g_state.currentVersion];
    NSString *spoofVersionToken = [NSString stringWithFormat:@"/%@ ", spoofVersion];
    NSString *currentDeviceToken = [NSString stringWithFormat:@"/%@ ", g_state.currentDevice];
    NSString *spoofDeviceToken = [NSString stringWithFormat:@"/%@ ", spoofDevice];

    rewritten = [rewritten stringByReplacingOccurrencesOfString:currentVersionToken
                                                     withString:spoofVersionToken];
    rewritten = [rewritten stringByReplacingOccurrencesOfString:currentDeviceToken
                                                     withString:spoofDeviceToken];

    NSString *versionSuffix = [NSString stringWithFormat:@"/%@", g_state.currentVersion];
    if ([rewritten hasSuffix:versionSuffix]) {
        rewritten = [[rewritten substringToIndex:rewritten.length - versionSuffix.length]
                     stringByAppendingFormat:@"/%@", spoofVersion];
    }

    NSString *deviceSuffix = [NSString stringWithFormat:@"/%@", g_state.currentDevice];
    if ([rewritten hasSuffix:deviceSuffix]) {
        rewritten = [[rewritten substringToIndex:rewritten.length - deviceSuffix.length]
                     stringByAppendingFormat:@"/%@", spoofDevice];
    }

    if (![rewritten isEqualToString:value]) {
        LIInfo("rewrote App Store User-Agent for configured device/iOS identity");
    }

    [spoofVersion release];
    [spoofDevice release];
    %orig(rewritten, field);
}

%end
%end

%ctor {
    @autoreleasepool {
        struct utsname systemInfo;
        uname(&systemInfo);

        g_state.currentDevice = [[NSString alloc] initWithUTF8String:systemInfo.machine];
        NSDictionary *systemVersion = [NSDictionary dictionaryWithContentsOfFile:
            @"/System/Library/CoreServices/SystemVersion.plist"];
        g_state.currentVersion = [systemVersion[@"ProductVersion"] copy];
        g_lock = [NSObject new];

        LINotice("loaded in process '%s' on %s / iOS %s",
                 __progname ? __progname : "unknown",
                 systemInfo.machine,
                 g_state.currentVersion.UTF8String ?: "unknown");

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            NULL, settingsChanged, CFSTR(SETTINGS_CHANGED), NULL,
            CFNotificationSuspensionBehaviorCoalesce);
        settingsChanged(NULL, NULL, NULL, NULL, NULL);

        const char *processName = __progname ? __progname : "";

        if (strcmp(processName, "installd") == 0) {
            Class bundleClass = objc_getClass("MIBundle");
            SEL selector = @selector(_isMinimumOSVersion:applicableToOSVersion:requiredOS:error:);

            if (bundleClass != Nil && class_getInstanceMethod(bundleClass, selector) != NULL) {
                %init(InstalldHooks);
                LINotice("installed targeted MIBundle minimum-OS hook");
            } else {
                LILog(LOG_ERR, "MIBundle minimum-OS selector unavailable; installer hook NOT installed");
            }
        } else if (strcmp(processName, "itunesstored") == 0 ||
                   strcmp(processName, "appstored") == 0) {
            %init(StoreHooks);
            LINotice("installed App Store User-Agent hook");
        }
    }
}
