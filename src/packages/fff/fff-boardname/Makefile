include $(TOPDIR)/rules.mk

PKG_NAME:=fff-boardname
PKG_VERSION:=0.0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-boardname

include $(INCLUDE_DIR)/package.mk

define Package/fff-boardname
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken boardname
    URL:=http://www.freifunk-franken.de
endef

define Package/fff-boardname/description
    This is the Freifunk Franken Firmware boardname package.
    This packages configures the boardname in the board config.
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

define Package/fff-boardname/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-boardname))
