# sqlite

SQLITE_VERSION := 3.6.20
SQLITE_URL := http://www.sqlite.org/sqlite-amalgamation-$(SQLITE_VERSION).tar.gz


#FIXME: we don't want to use scripts to determine which libraries should be
#       included, because there is bug in cross compile

# PKGS += sqlite

# ifeq ($(call need_pkg,"sqlite3"),)
# PKGS_FOUND += sqlite
# endif

$(TARBALLS)/sqlite-$(SQLITE_VERSION).tar.gz:
	$(call download,$(SQLITE_URL))

.sum-sqlite: sqlite-$(SQLITE_VERSION).tar.gz

sqlite: sqlite-$(SQLITE_VERSION).tar.gz .sum-sqlite
	$(UNPACK)
	$(MOVE)

.sqlite: sqlite
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF)
	cd $< && $(MAKE) && $(MAKE) install
	touch $@
