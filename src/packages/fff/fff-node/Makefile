include $(TOPDIR)/rules.mk

PKG_NAME:=fff-node
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-node

include $(INCLUDE_DIR)/package.mk

define Package/fff-node
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken node configuration
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-batman-adv \
	         +fff-fastd \
	         +fff-firewall \
	         +fff-hoods \
	         +fff-uradvd
endef

define Package/fff-node/description
	This package configures the node
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

define Package/fff-node/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-node))
