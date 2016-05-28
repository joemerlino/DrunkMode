include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DrunkPrefs
DrunkPrefs_FILES = DMPRootListController.m
DrunkPrefs_INSTALL_PATH = /Library/PreferenceBundles
DrunkPrefs_FRAMEWORKS = UIKit
DrunkPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DrunkPrefs.plist$(ECHO_END)
