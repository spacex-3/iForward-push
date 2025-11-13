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
# On iOS, curl is usually provided by the system or jailbreak environment
# We use -undefined dynamic_lookup to allow linking without the library present
# Do NOT specify -lcurl here - symbols will be resolved at runtime on device
iForward_LDFLAGS = -lsqlite3 -undefined dynamic_lookup

# Install path
iForward_INSTALL_PATH = /usr/bin

include $(THEOS)/makefiles/tool.mk

# Copy plist files and other resources after building
after-install::
	install.exec "mkdir -p /Library/Application\ Support/iForward"
	install.exec "touch /Library/Application\ Support/iForward/iForward.db"
	install.exec "launchctl load /Library/LaunchDaemons/com.iforward.plist"
