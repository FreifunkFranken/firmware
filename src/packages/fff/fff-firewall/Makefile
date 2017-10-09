include $(TOPDIR)/rules.mk

PKG_NAME:=fff-firewall
PKG_VERSION:=2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-firewall

include $(INCLUDE_DIR)/package.mk

define Package/fff-firewall
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:=Freifunk-Franken firewall
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+arptables \
             +ebtables +ebtables-utils \
             +kmod-ebtables-ipv4 +kmod-ebtables-ipv6 \
             +iptables-mod-filter +iptables-mod-ipopt +iptables-mod-conntrack-extra
endef

define Package/fff-firewall/description
    This is the firewall for the Freifunk Franken Firmware
    It is used to configure firewall.
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

define Package/fff-firewall/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-firewall))
