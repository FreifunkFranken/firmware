include $(TOPDIR)/rules.mk

PKG_NAME:=fff-sysupgrade
PKG_RELEASE:=13

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken sysupgrade
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+fff-boardname +fff-config +fff-hoodutils +@BUSYBOX_CONFIG_WGET
endef

define Package/$(PKG_NAME)/description
	This is the Freifunk Franken Firmware sysupgrade package.
	This packages provides an semi automated sysupgrade script.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
