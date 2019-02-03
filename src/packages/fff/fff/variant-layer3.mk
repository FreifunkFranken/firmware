define Package/fff-default
    SECTION:=base
    CATEGORY:=Freifunk
    DEFAULT:=y
    TITLE:=Freifunk-Franken Base default switcher
    URL:=http://www.freifunk-franken.de
    DEPENDS:=+fff-layer3
endef

define Package/fff-default/description
    This package is used to switch on of the Freifunk Franken
    package on per default
endef

$(eval $(call BuildPackage,fff-default))
