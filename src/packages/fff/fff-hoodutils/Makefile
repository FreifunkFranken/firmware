include $(TOPDIR)/rules.mk

PKG_NAME:=fff-hoodutils
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken hoodutils
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-network +fff-config
endef

define Package/$(PKG_NAME)/description
	This package contains hood-related code that may
	may be used outside of configurehood
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
