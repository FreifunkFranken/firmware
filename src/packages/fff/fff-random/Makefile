include $(TOPDIR)/rules.mk

PKG_NAME:=fff-random
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Random
	URL:=https://www.freifunk-franken.de
endef

define Package/$(PKG_NAME)/description
	This is the Freifunk Franken Firmware Random package
	This packages provides a random function.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/random $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
