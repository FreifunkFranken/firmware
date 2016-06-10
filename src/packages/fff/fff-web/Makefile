include $(TOPDIR)/rules.mk

PKG_NAME:=fff-web
PKG_VERSION:=0.0.3
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/fff-web

include $(INCLUDE_DIR)/package.mk

define Package/fff-web
    SECTION:=base
    CATEGORY:=Freifunk
    TITLE:= Freifunk-Franken Webinterface
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+uhttpd +haserl +uhttpd-mod-tls +px5g +simple-tc +fff-boardname
endef

define Package/fff-web/description
    This is the Webinterface for the Freifunk Franken Firmware
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

define Package/fff-web/install
	$(CP) ./files/* $(1)/
ifeq ($(CONFIG_PACKAGE_fff-nodewatcher),y)
	ln -s ../../tmp/crawldata/node.data $(1)/www/public/node.data
endif
endef

$(eval $(call BuildPackage,fff-web))
