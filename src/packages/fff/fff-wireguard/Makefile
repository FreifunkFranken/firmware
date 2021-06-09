include $(TOPDIR)/rules.mk

PKG_NAME:=fff-wireguard
PKG_RELEASE:=7

include $(INCLUDE_DIR)/package.mk

define Package/fff-wireguard
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken wireguard
	URL:=https://www.freifunk-franken.de
	DEPENDS:= \
		+kmod-wireguard \
		+owipcalc \
		+wireguard-tools \
		+fff-babeld \
		+fff-network
endef

define Package/fff-wireguard/description
	This is the Freifunk Franken Firmware wireguard package.
	This package provides configuration scripts for wireguard tunnels.
endef

define Build/Compile
	# nothing
endef

define Package/fff-wireguard/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-wireguard))
