include $(TOPDIR)/rules.mk

PKG_NAME:=fff-babel
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/fff-babel
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken babel
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-babel-implementation
endef

define Package/fff-babel/description
	This is the Freifunk Franken Firmware babel package.
endef

define Build/Compile
	# nothing
endef

define Package/fff-babel/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-babel))
