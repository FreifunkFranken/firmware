include $(TOPDIR)/rules.mk

PKG_NAME:=fff-layer3
PKG_RELEASE:=$(COMMITCOUNT)

include $(INCLUDE_DIR)/package.mk

define Package/fff-layer3
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken gateway configuration
	URL:=https://www.freifunk-franken.de
	DEPENDS:=+fff-alfred-monitoring-proxy \
	         +fff-babel \
	         +fff-babel-bird2 \
	         +fff-boardname \
	         +fff-dhcp \
	         +fff-layer3-config \
	         +fff-layer3-snat \
	         +fff-mqtt-monitoring \
	         +fff-network \
	         +fff-ra \
	         +fff-web-mqtt \
	         +fff-wireguard \
	         +kmod-sched-cake \
	         +gre \
	         +@PACKAGE_grev4 \
	         +@PACKAGE_grev6 \
	         +iperf3 \
	         +ip-full \
	         +mtr \
	         +nftables \
	         +snmp-utils \
	         +tc \
	         +tcpdump-mini \
	         +vxlan
endef

define Package/fff-layer3/description
	This package provides the packages and settings for the layer 3 firmware
endef

define Build/Compile
	# nothing
endef

define Package/fff-layer3/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,fff-layer3))
