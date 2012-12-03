
BIN = ./node_modules/.bin
TEST_OPTS = --timeout 100 --reporter list --globals __coverage__ --compilers coffee:coffee-script
COFFEE_OPTS = --bare --compile
ISTANBUL_OPTS = instrument --variable global.__coverage__ --no-compact

SRC_FILES := $(wildcard src/*)
LIB_FILES := $(SRC_FILES:src/%.coffee=lib/%.js)
TEST_FILES = test/*
COV_FILES := $(LIB_FILES:lib/%.js=lib-cov/%.js)


default: test

lib/%.js: src/%.coffee
	$(BIN)/coffee $(COFFEE_OPTS) --output $@ $<

lib-cov:
	mkdir -p ./lib-cov
lib-cov/%.js: lib/%.js
	$(BIN)/istanbul $(ISTANBUL_OPTS) --output $@ $<


all: $(LIB_FILES)

publish: clean all cover
	npm publish


clean:
	rm -Rf html-report
	rm -Rf coverage
	rm -Rf lib-cov
	rm -Rf lib


test:
	$(BIN)/mocha $(TEST_OPTS) $(TEST_FILES)
tdd:
	$(BIN)/mocha $(TEST_OPTS) --watch $(TEST_FILES)

instrument: lib-cov $(COV_FILES)
cover: instrument
	@echo open html-report/index.html to view coverage report.
	COVER=1 $(BIN)/mocha $(TEST_OPTS) --reporter mocha-istanbul $(TEST_FILES)


.PHONY: instrument all default test watch cover clean

