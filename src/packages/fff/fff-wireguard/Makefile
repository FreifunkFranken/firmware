include $(TOPDIR)/rules.mk

PKG_NAME:=fff-wireguard
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-wireguard

include $(INCLUDE_DIR)/package.mk

define Package/fff-wireguard
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken wireguard
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+wireguard \
			 +fff-network \
			 +fff-babeld
endef

define Package/fff-wireguard/description
	This is the Freifunk Franken Firmware wireguard package.
	This package provides configuration scripts for wireguard tunnels.
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

define Package/fff-wireguard/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-wireguard))
