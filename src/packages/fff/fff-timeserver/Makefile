include $(TOPDIR)/rules.mk

PKG_NAME:=fff-timeserver
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken timeserver
	URL:=https://www.freifunk-franken.de
endef

define Package/$(PKG_NAME)/description
	This is the Freifunk Franken Firmware timeserver package.
	This packages configures the timeserver on the device.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
