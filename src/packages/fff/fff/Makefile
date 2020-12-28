include $(TOPDIR)/rules.mk

PKG_NAME:=fff
PKG_RELEASE:=8

include $(INCLUDE_DIR)/package.mk

define Package/fff-base
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
			 +fff-web-ui \
			 +fff-support \
			 +fff-network \
			 +fff-sysupgrade \
			 +fff-wireless \
			 +fff-timeserver \
			 +fff-simple-tc
endef

define Package/fff-base/description
	This is the Freifunk Franken Firmware Base package
endef

$(eval $(call BuildPackage,fff-base))

include $(TOPDIR)/variant.mk
