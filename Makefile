ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang:12.2:10.0
INSTALL_TARGET_PROCESSES = crackerxi

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = crackerxisearchbar
crackerxisearchbar_FILES = $(wildcard *.xm *.m)
crackerxisearchbar_EXTRA_FRAMEWORKS = libhdev
crackerxisearchbar_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
