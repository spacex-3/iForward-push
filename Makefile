export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

# Target iOS 14.0+ with arm64 only (arm64e removed due to libcurl incompatibility)
ARCHS = arm64
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
# Link against stub libcurl.dylib (created in GitHub Actions)
# Stub has install_name=/usr/lib/libcurl.dylib so runtime will load system curl
iForward_LDFLAGS = -lsqlite3 -lcurl

# Install path - binary goes to iForward.bin, wrapper script to iForward
iForward_INSTALL_PATH = /usr/bin

include $(THEOS)/makefiles/tool.mk

# Copy additional files from cydia directory structure to deb package
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/iForward$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/Library/PreferenceLoader/Preferences/iForward.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/Library/PreferenceLoader/Preferences/iForwardIcon.png $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(ECHO_END)
	$(ECHO_NOTHING)cp cydia/iForward/Library/LaunchDaemons/com.iforward.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons/$(ECHO_END)
	$(ECHO_NOTHING)touch $(THEOS_STAGING_DIR)/Library/Application\ Support/iForward/iForward.db$(ECHO_END)

# Actions to run after installation on device
after-install::
	install.exec 'mkdir -p "/Library/Application Support/iForward"'
	install.exec 'mkdir -p /var/mobile/Library/Logs'
	install.exec 'chmod 644 /Library/LaunchDaemons/com.iforward.plist'
	install.exec 'sqlite3 "/Library/Application Support/iForward/iForward.db" "CREATE TABLE IF NOT EXISTS call (ROWID INTEGER PRIMARY KEY); CREATE TABLE IF NOT EXISTS message (ROWID INTEGER PRIMARY KEY); CREATE TABLE IF NOT EXISTS voicemail (ROWID INTEGER PRIMARY KEY); INSERT OR REPLACE INTO call (ROWID) VALUES (-1); INSERT OR REPLACE INTO message (ROWID) VALUES (-1); INSERT OR REPLACE INTO voicemail (ROWID) VALUES (-1);"'
	install.exec 'chmod 666 "/Library/Application Support/iForward/iForward.db"'
	install.exec 'launchctl unload /Library/LaunchDaemons/com.iforward.plist 2>/dev/null || true'
	install.exec 'launchctl load -w /Library/LaunchDaemons/com.iforward.plist'
	install.exec 'echo "iForward installation complete. LaunchDaemon should be running."'
	install.exec 'launchctl list | grep -i iforward || echo "WARNING: LaunchDaemon not loaded!"'
