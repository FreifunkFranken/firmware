include $(TOPDIR)/rules.mk

PKG_NAME:=fff-ra
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-ra
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Router Advertisements
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+odhcpd-ipv6only
endef

define Package/fff-ra/description
	This is the fff-ra for the Freifunk Franken Firmware
	It is used to configure odhcpd to send Router Advertisements for use as gateway.
endef

define Build/Compile
	# nothing
endef

define Package/fff-ra/install
	# nothing
endef

$(eval $(call BuildPackage,fff-ra))
