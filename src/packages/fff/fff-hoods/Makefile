include $(TOPDIR)/rules.mk

PKG_NAME:=fff-hoods
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-hoods

include $(INCLUDE_DIR)/package.mk

define Package/fff-hoods
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken hoods
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+fff-network
endef

define Package/fff-hoods/description
    This package load and configures the current hood
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

define Package/fff-hoods/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-hoods))
