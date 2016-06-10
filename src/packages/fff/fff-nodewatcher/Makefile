include $(TOPDIR)/rules.mk

PKG_NAME:=fff-nodewatcher
PKG_VERSION:=38
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-nodewatcher

include $(INCLUDE_DIR)/package.mk

define Package/fff-nodewatcher
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken Nodewatcher
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+alfred +micrond +fff-random +ip +ip-bridge
endef

define Package/fff-nodewatcher/description
    This is the Nodewatcher for the Freifunk Franken Firmware
    It is used to send node status information to
    monitoring.freifunk-franken.de and
    netmon.freifunk-franken.de
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

define Package/fff-nodewatcher/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-nodewatcher))
