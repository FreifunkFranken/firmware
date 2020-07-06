include $(TOPDIR)/rules.mk

PKG_NAME:=fff-gateway
PKG_RELEASE:=5

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-gateway

include $(INCLUDE_DIR)/package.mk

define Package/fff-gateway
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken gateway configuration
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-alfred-monitoring-proxy \
	         +fff-babeld \
	         +fff-boardname \
	         +fff-dhcp \
	         +fff-network \
	         +fff-ra \
	         +fff-wireguard \
	         +arptables \
	         +ebtables \
	         +ebtables-utils \
	         +kmod-ebtables-ipv4 \
	         +kmod-ebtables-ipv6 \
	         +gre \
	         +@PACKAGE_grev4 \
	         +@PACKAGE_grev6 \
	         +iperf3 \
	         +ip-full \
	         +iptables-mod-filter \
	         +iptables-mod-ipopt \
	         +iptables-mod-conntrack-extra \
	         +mtr \
	         +tcpdump \
	         +vxlan
endef

define Package/fff-gateway/description
	This package configures the gateway
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

define Package/fff-gateway/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-gateway))
