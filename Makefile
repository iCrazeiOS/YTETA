ARCHS = arm64

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
export SDKVERSION = 14.4

INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTETA

YTETA_FILES = Tweak.xm
YTETA_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += ytetaprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
