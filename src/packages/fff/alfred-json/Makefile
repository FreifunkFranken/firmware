include $(TOPDIR)/rules.mk

PKG_NAME:=alfred-json
PKG_VERSION:=0.3.1
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=e4cacfc791092389f63c36a435d3f1d069f8a13e
PKG_SOURCE_URL:=https://github.com/FreifunkFranken/alfred-json.git

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/alfred-json
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=A.L.F.R.E.D - JSON Client
	URL:=https://github.com/FreifunkFranken/alfred-json
	DEPENDS:=+jansson +zlib +alfred
endef

define Package/alfred-json/install
	$(INSTALL_DIR) $(1)/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/alfred-json $(1)/bin/
endef

$(eval $(call BuildPackage,alfred-json))
