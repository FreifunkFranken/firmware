include $(TOPDIR)/rules.mk

PKG_NAME:=fff-vxlan-node-vpn
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken vxlan-node
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+vxlan
endef

define Package/$(PKG_NAME)/description
	This is the vxlan-node-vpn package for the Freifunk Franken Firmware
	This will configure and set up the VPN via vxlan
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
