include $(TOPDIR)/rules.mk

PKG_NAME:=fff
PKG_VERSION:=0.0.2
PKG_RELEASE:=5

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
             +fff-batman-adv \
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

define Package/fff-node
    $(call Package/fff/base)
    TITLE+=(Home node)
    DEPENDS+=+fff-fastd \
             +fff-firewall \
             +fff-uradvd \
             +fff-hoods
    VARIANT:=homenode
endef

define Package/fff-node/description
    $(call Package/fff/base/description)
endef

define Package/fff-layer3
    $(call Package/fff/base)
    TITLE+=(Layer 3 Gateway)
    DEPENDS+=+fff-dhcp \
             +fff-babeld \
             +fff-ra \
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

define Package/fff-layer3/description
    $(call Package/fff/base/description)
endef

$(eval $(call BuildPackage,fff-node))
$(eval $(call BuildPackage,fff-layer3))

include $(TOPDIR)/variant.mk
