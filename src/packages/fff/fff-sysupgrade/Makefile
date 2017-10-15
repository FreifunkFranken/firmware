include $(TOPDIR)/rules.mk

PKG_NAME:=fff-sysupgrade
PKG_VERSION:=5
PKG_RELEASE:=4

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken sysupgrade
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+fff-boardname +fff-hoods +@BUSYBOX_CONFIG_WGET
endef

define Package/$(PKG_NAME)/description
    This is the Freifunk Franken Firmware sysupgrade package.
    This packages provides an semi automated sysupgrade script.
endef

define Build/Prepare
    echo "all: " > $(PKG_BUILD_DIR)/Makefile
endef

define Build/Configure
    # nothing
endef

define Build/Compile
    # nothing
endef

define Package/$(PKG_NAME)/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
