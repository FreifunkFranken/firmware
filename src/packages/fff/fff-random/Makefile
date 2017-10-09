include $(TOPDIR)/rules.mk

PKG_NAME:=fff-random
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/fff-random
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Random
	URL:=http://www.freifunk-franken.de
endef

define Package/fff-random/description
	This is the Freifunk Franken Firmware Random package
	This packages provides a random function.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
	# nothing
endef

define Build/Compile
	CFLAGS="$(TARGET_CFLAGS)" CPPFLAGS="$(TARGET_CPPFLAGS)" $(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

define Package/fff-random/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/random $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fff-random))
