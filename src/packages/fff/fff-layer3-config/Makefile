include $(TOPDIR)/rules.mk

PKG_NAME:=fff-layer3-config
PKG_RELEASE:=9

include $(INCLUDE_DIR)/package.mk

define Package/fff-layer3-config
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Layer3 firmware configuration tools
	URL:=https://www.freifunk-franken.de
	DEPENDS:= \
		+fff-boardname \
		+fff-config \
		+fff-dhcp \
		+fff-network
endef

define Package/fff-layer3-config/description
	This package provides the means for configuring the gateway
endef

define Build/Compile
	# nothing
endef

define Package/fff-layer3-config/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-layer3-config))
