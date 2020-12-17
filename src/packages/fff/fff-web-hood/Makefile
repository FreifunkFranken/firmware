include $(TOPDIR)/rules.mk

PKG_NAME:=fff-web-hood
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/fff-web-hood
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken web server for hood file
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+uhttpd
endef

define Package/fff-web-hood/description
	This is a tiny web server to serve the hoodfile for
	other nodes
endef

define Build/Compile
	# nothing
endef

define Package/fff-web-hood/install
	$(INSTALL_DIR) $(1)/www/hood
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-web-hood))
