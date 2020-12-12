include $(TOPDIR)/rules.mk

PKG_NAME:=fff-hoods
PKG_RELEASE:=17

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken hoods
	URL:=http://www.freifunk-franken.de
	DEPENDS:= \
		+fff-firewall \
		+fff-hoodutils \
		+fff-macnock \
		+fff-network \
		+fff-timeserver \
		+fff-vpn-select \
		+fff-web-hood \
		+fff-wireless \
		+jshn \
		+@BUSYBOX_CONFIG_WGET \
		+@BUSYBOX_CONFIG_FEATURE_WGET_TIMEOUT
endef

define Package/$(PKG_NAME)/description
	This package load and configures the current hood
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
