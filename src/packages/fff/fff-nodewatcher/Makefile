include $(TOPDIR)/rules.mk

PKG_NAME:=fff-nodewatcher
PKG_RELEASE:=62

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Nodewatcher
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-config +fff-random +ip-full +ip-bridge
endef

define Package/$(PKG_NAME)/description
	This is the Nodewatcher for the Freifunk Franken Firmware
	It is used to send node status information to
	monitoring.freifunk-franken.de and
	netmon.freifunk-franken.de
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/nodewatcher
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
	printf "$(if $(PKG_VERSION),$(PKG_VERSION).)$(PKG_RELEASE)" >> $(1)/etc/nodewatcher_version
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
