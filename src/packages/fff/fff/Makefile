include $(TOPDIR)/rules.mk

PKG_NAME:=fff
PKG_RELEASE:=6

PKG_BUILD_DIR:=$(BUILD_DIR)/fff

include $(INCLUDE_DIR)/package.mk

define Package/fff/base
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken Base
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+iptables \
			 +ip6tables \
			 +odhcp6c \
			 +micrond \
			 +fff-config \
			 +fff-nodewatcher \
			 +fff-web \
			 +fff-support \
			 +fff-network \
			 +fff-sysupgrade \
			 +fff-wireless \
			 +fff-timeserver \
			 +simple-tc
endef

define Package/fff/base/description
	This is the Freifunk Franken Firmware Base package
endef

define Package/fff-variant-node
	$(call Package/fff/base)
	TITLE+=(Home node)
	DEPENDS+=+fff-node \
			 +fff-fastd \
			 +fff-firewall \
			 +fff-uradvd \
			 +fff-batman-adv \
			 +fff-hoods
	VARIANT:=homenode
endef

define Package/fff-variant-node/description
	$(call Package/fff/base/description)
endef

define Package/fff-variant-layer3
	$(call Package/fff/base)
	TITLE+=(Layer 3 Gateway)
	DEPENDS+=+fff-gateway \
			 +fff-dhcp \
			 +fff-babeld \
			 +fff-ra \
			 +fff-wireguard \
			 +iperf3 \
			 +ip-full \
			 +tcpdump \
			 +arptables \
			 +ebtables \
			 +ebtables-utils \
			 +kmod-ebtables-ipv4 \
			 +kmod-ebtables-ipv6 \
			 +iptables-mod-filter \
			 +iptables-mod-ipopt \
			 +iptables-mod-conntrack-extra \
			 +gre \
			 +@PACKAGE_grev4 \
			 +@PACKAGE_grev6 \
			 +fff-alfred-monitoring-proxy
	VARIANT:=layer3
endef

define Package/fff-variant-layer3/description
	$(call Package/fff/base/description)
endef

$(eval $(call BuildPackage,fff-variant-node))
$(eval $(call BuildPackage,fff-variant-layer3))

include $(TOPDIR)/variant.mk
