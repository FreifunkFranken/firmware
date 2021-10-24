include $(TOPDIR)/rules.mk

PKG_NAME:=fff-firewall
PKG_RELEASE:=7

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken firewall
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+arptables \
			 +ebtables +ebtables-utils \
			 +kmod-ebtables-ipv4 +kmod-ebtables-ipv6 \
			 +iptables-mod-filter +iptables-mod-ipopt +iptables-mod-conntrack-extra \
			 +kmod-nf-conntrack6
endef

define Package/$(PKG_NAME)/description
	This is the firewall for the Freifunk Franken Firmware
	It is used to configure firewall.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
