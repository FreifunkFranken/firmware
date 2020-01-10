include $(TOPDIR)/rules.mk

PKG_NAME:=fff-fastd
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=base
	CATEGORY:=Freifunk
	TITLE:=Freifunk-Franken fastd configuration script
	URL:=http://www.freifunk-franken.de
	DEPENDS:=+@BUSYBOX_CUSTOM \
			 +@FASTD_ENABLE_METHOD_NULL \
			 +@FASTD_ENABLE_CIPHER_NULL \
			 +@FASTD_WITH_STATUS_SOCKET \
			 +fastd \
			 +fff-random \
			 +fff-config
endef

define Package/$(PKG_NAME)/description
	This is the fastd for the Freifunk Franken Firmware
	It is used to configure fastd.
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

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
