include $(TOPDIR)/rules.mk

PKG_NAME:=fff-alfred
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Alfred
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-nodewatcher +alfred +micrond
endef

define Package/$(PKG_NAME)/description
	This is the Freifunk Franken Firmware Alfred package.
	This packages configures the Alfred on the device.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
