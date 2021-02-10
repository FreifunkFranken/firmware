include $(TOPDIR)/rules.mk

PKG_NAME:=fff-network
PKG_RELEASE:=40

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken network configuration
	URL:=http://www.freifunk-franken.de
	DEPENDS:= \
		+owipcalc \
		+fff-boardname \
		+fff-firewall
endef

define Package/$(PKG_NAME)/description
	This package configures the network interfaces
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
	test -d ./$(ARCH) && $(CP) ./$(ARCH)/* $(1)/etc/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
