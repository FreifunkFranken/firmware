include $(TOPDIR)/rules.mk

PKG_NAME:=fff-wireless
PKG_RELEASE:=20

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken wireless configuration
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+@ATH_USER_REGD +wireless-tools +fff-boardname
endef

define Package/$(PKG_NAME)/description
	This package configures the wireless interfaces.
endef

define Build/Compile
	# nothing
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
