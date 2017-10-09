include $(TOPDIR)/rules.mk

PKG_NAME:=fff-sysupgrade
PKG_VERSION:=0.0.4
PKG_RELEASE:=4

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-sysupgrade

include $(INCLUDE_DIR)/package.mk

define Package/fff-sysupgrade
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken sysupgrade
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+fff-boardname +@BUSYBOX_CONFIG_WGET
endef

define Package/fff-sysupgrade/description
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

define Package/fff-sysupgrade/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-sysupgrade))
