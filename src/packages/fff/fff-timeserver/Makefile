include $(TOPDIR)/rules.mk

PKG_NAME:=fff-timeserver
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-timeserver

include $(INCLUDE_DIR)/package.mk

define Package/fff-timeserver
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken timeserver
    URL:=http://www.freifunk-franken.de
endef

define Package/fff-timeserver/description
    This is the Freifunk Franken Firmware timeserver package.
    This packages configures the timeserver on the device.
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

define Package/fff-timeserver/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-timeserver))
