.EXPORT_ALL_VARIABLES:

RM=rm -f
TRUE=true
INSTALL_BIN=install -m 0755
INSTALL_DIR=install -d -m 0755

DESTDIR=
PREFIX=/usr/local

.PHONY: all
all: dir300-flash

dir300-flash: dir300-flash.sh
	(head -n 22 -- '$<'; echo "PREFIX='$(PREFIX)'"; tail -n +24 -- '$<') > '$@'
	chmod +x -- '$@'

.PHONY: install
install: all
	$(INSTALL_DIR) -- '$(DESTDIR)$(PREFIX)/share/dir300-flash/'
	$(INSTALL_DIR) -- '$(DESTDIR)$(PREFIX)/sbin/'
	$(INSTALL_BIN) -- dir300-flash '$(DESTDIR)$(PREFIX)/sbin/'
	[ x'$(DESTDIR)' = x ] && '$(PREFIX)/sbin/dir300-flash' --download || $(TRUE)

.PHONY: uninstall
uninstall:
	$(RM) -- '$(DESTDIR)$(PREFIX)/sbin/dir300-flash'
	$(RM) -r -- '$(DESTDIR)$(PREFIX)/share/dir300-flash'
	$(RM) -- '$(DESTDIR)'/tftpboot/*.dir300-flash '$(DESTDIR)'/srv/tftp/*.dir300-flash '$(DESTDIR)'/var/lib/tftpboot/*.dir300-flash

.PHONY: clean
clean:
	$(RM) -- *~ dir300-flash
