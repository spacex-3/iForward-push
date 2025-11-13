export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

# Target iOS 14.0+ with arm64 and arm64e support
ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.0

include $(THEOS)/makefiles/common.mk

# Define as a command-line tool
TOOL_NAME = iForward

# Source files
iForward_FILES = Classes/main.m
iForward_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

# Frameworks
iForward_FRAMEWORKS = UIKit Foundation AddressBook CoreGraphics CoreData CoreFoundation QuartzCore

# Libraries
# Bundle libcurl with the package and set rpath to find it at runtime
# The curl library is included in cydia/iForward/usr/local/iForward/lib/
iForward_LDFLAGS = -lsqlite3 -undefined dynamic_lookup -Wl,-rpath,/usr/local/iForward/lib

# Install path
iForward_INSTALL_PATH = /usr/bin

include $(THEOS)/makefiles/tool.mk

# Copy additional files from cydia directory structure to deb package
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/iForward$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/local/iForward/lib$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/Library/PreferenceLoader/Preferences/iForward.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/Library/PreferenceLoader/Preferences/iForwardIcon.png $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/Library/LaunchDaemons/com.iforward.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons/$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/usr/local/iForward/lib/*.dylib $(THEOS_STAGING_DIR)/usr/local/iForward/lib/$(ECHO_END)
	$(ECHO_NOTHING)touch $(THEOS_STAGING_DIR)/Library/Application\ Support/iForward/iForward.db$(ECHO_END)

# Actions to run after installation on device
after-install::
	install.exec "mkdir -p /Library/Application\ Support/iForward"
	install.exec "chmod 644 /Library/LaunchDaemons/com.iforward.plist"
	install.exec "launchctl load /Library/LaunchDaemons/com.iforward.plist"
