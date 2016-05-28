TWEAK_NAME = DrunkMode
DrunkMode_FILES = Tweak.xm
DrunkMode_FRAMEWORKS = UIKit

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += drunkprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
