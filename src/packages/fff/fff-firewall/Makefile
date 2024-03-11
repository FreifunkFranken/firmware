include $(TOPDIR)/rules.mk

PKG_NAME:=fff-firewall
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken firewall
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+kmod-nft-bridge \
	         +nftables
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
