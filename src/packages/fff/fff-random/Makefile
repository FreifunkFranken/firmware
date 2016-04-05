include $(TOPDIR)/rules.mk

PKG_NAME:=fff-random
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-random

include $(INCLUDE_DIR)/package.mk

define Package/fff-random
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken Random
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+@BUSYBOX_CONFIG_ASH
endef

define Package/fff-random/description
    This is the Freifunk Franken Firmware Random package
    This packages provides a random function.
endef

define Build/Prepare
    echo "all: " > $(PKG_BUILD_DIR)/Makefile
endef

define Build/Configure
    # nothing
endef

define Build/Compile
    # nothing
endef

define Package/fff-random/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-random))
