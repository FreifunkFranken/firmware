include $(TOPDIR)/rules.mk

PKG_NAME:=fff
PKG_VERSION:=0.0.1
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/fff

include $(INCLUDE_DIR)/package.mk

define Package/fff-base
    SECTION:=base
    CATEGORY:=Freifunk
    DEFAULT:=y
    TITLE:= Freifunk-Franken Base
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+micrond
endef

define Package/fff-base/description
    This is the Freifunk Franken Firmware Base package
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

define Package/fff-base/install
    $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-base))
