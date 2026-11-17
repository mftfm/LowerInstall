ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless
PACKAGE_VERSION = 1.4.1

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += tweak
SUBPROJECTS += settings

include $(THEOS_MAKE_PATH)/aggregate.mk
