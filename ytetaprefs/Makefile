export PREFIX=$(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = YTETAPrefs

YTETAPrefs_FILES = YTETARootListController.m
YTETAPrefs_FRAMEWORKS = UIKit
YTETAPrefs_PRIVATE_FRAMEWORKS = Preferences
YTETAPrefs_INSTALL_PATH = /Library/PreferenceBundles
YTETAPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
