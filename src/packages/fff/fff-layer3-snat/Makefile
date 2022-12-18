include $(TOPDIR)/rules.mk

PKG_NAME:=fff-layer3-snat
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-layer3-snat
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken layer3 configuration with SNAT
	URL:=https://www.freifunk-franken.de
	DEPENDS:= \
		+fff-firewall \
		+fff-layer3-config \
		+kmod-nft-nat
endef

define Package/fff-layer3-snat/description
	With this package it is possible to make SNAT with IPv4 on the router
endef

define Build/Compile
	# nothing
endef

define Package/fff-layer3-snat/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-layer3-snat))
