include $(TOPDIR)/rules.mk

PKG_NAME:=fff-dhcp
PKG_RELEASE:=5

include $(INCLUDE_DIR)/package.mk

define Package/fff-dhcp
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken dhcp
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+dnsmasq
endef

define Package/fff-dhcp/description
	This is the fff-dhcp for the Freifunk Franken Firmware
	It is used to configure dnsmasq for use as gateway.
endef

define Build/Compile
	# nothing
endef

define Package/fff-dhcp/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-dhcp))
