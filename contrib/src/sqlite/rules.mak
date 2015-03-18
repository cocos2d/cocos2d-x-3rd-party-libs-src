# sqlite3

SQLITE_VERSION := 3.6.20
SQLITE_URL := http://www.sqlite.org/sqlite-amalgamation-$(SQLITE_VERSION).tar.gz


$(TARBALLS)/sqlite-$(SQLITE_VERSION).tar.gz:
	$(call download,$(SQLITE_URL))

.sum-sqlite: sqlite-$(SQLITE_VERSION).tar.gz

sqlite3: sqlite-$(SQLITE_VERSION).tar.gz .sum-sqlite
	$(UNPACK)
	$(MOVE)

.sqlite3: sqlite3
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF)
	cd $< && $(MAKE) && $(MAKE) install
	touch $@
