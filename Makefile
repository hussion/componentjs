##
##  ComponentJS -- Component System for JavaScript <http://componentjs.com>
##  Copyright (c) 2009-2013 Ralf S. Engelschall <http://engelschall.com>
##
##  This Source Code Form is subject to the terms of the Mozilla Public
##  License, v. 2.0. If a copy of the MPL was not distributed with this
##  file, You can obtain one at http://mozilla.org/MPL/2.0/.
##

PERL            = perl
SHTOOL          = shtool
CLOSURECOMPILER = closure-compiler \
	              --warning_level DEFAULT \
	              --compilation_level SIMPLE_OPTIMIZATIONS \
				  --language_in ECMASCRIPT5 \
				  --third_party
UGLIFYJS        = uglifyjs \
                  --no-dead-code \
				  --no-copyright \
				  --max-line-len 512
YUICOMPRESSOR   = yuicompressor \
                  --type js \
				  --line-break 512
GJSLINT         = gjslint
JSLINT          = jslint \
                  +indent=4 +maxerr=100 -anon +browser +continue \
				  +eqeq -evil +nomen +plusplus -passfail +regexp \
				  +unparam +sloppy +vars +white

VERSION_MAJOR   = 0
VERSION_MINOR   = 0
VERSION_MICRO   = 0
VERSION_DATE    = 00000000
VERSION         = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_MICRO)

SOURCE          = component.js \
                  component-0-glob-0-ns.js \
                  component-0-glob-1-version.js \
                  component-1-util-0-runtime.js \
                  component-1-util-1-object.js \
                  component-1-util-2-array.js \
                  component-1-util-3-params.js \
                  component-1-util-4-encoding.js \
                  component-1-util-5-arithmetic.js \
                  component-1-util-6-identifier.js \
                  component-1-util-7-proxy.js \
                  component-1-util-8-attribute.js \
                  component-2-clzz-0-common.js \
                  component-2-clzz-1-api.js \
                  component-3-patt-0-base.js \
                  component-3-patt-1-tree.js \
                  component-3-patt-2-config.js \
                  component-3-patt-3-spool.js \
                  component-3-patt-4-property.js \
                  component-3-patt-5-spec.js \
                  component-3-patt-6-observable.js \
                  component-3-patt-7-event.js \
                  component-3-patt-8-cmd.js \
                  component-3-patt-9-autoattr.js \
                  component-3-patt-A-state.js \
                  component-3-patt-B-service.js \
                  component-3-patt-C-shadow.js \
                  component-3-patt-D-socket.js \
                  component-3-patt-E-hook.js \
                  component-3-patt-F-marker.js \
                  component-3-patt-G-store.js \
                  component-3-patt-H-model.js \
                  component-4-comp-0-define.js \
                  component-4-comp-1-singleton.js \
                  component-4-comp-2-lookup.js \
                  component-4-comp-3-pimpup.js \
                  component-4-comp-4-manage.js \
                  component-4-comp-5-states.js \
                  component-5-dbgr-0-jquery.js \
                  component-5-dbgr-1-view.js \
                  component-6-glob-0-export.js

TARGET          = out/component-$(VERSION).js \
                  out/component-$(VERSION).min.js

all: $(TARGET)

out/component-$(VERSION).js: $(SOURCE)
	@$(SHTOOL) mkdir -f -p -m 755 out
	@echo "++ assembling out/component-$(VERSION).js <- $(SOURCE) (Custom Build Tool)"; \
	$(PERL) build.pl out/component-$(VERSION).js component.js "$(VERSION_MAJOR)" "$(VERSION_MINOR)" "$(VERSION_MICRO)" "$(VERSION_DATE)"

out/component-$(VERSION).min.js: out/component-$(VERSION).js
	@$(SHTOOL) mkdir -f -p -m 755 out
	@echo "++ compressing out/component-$(VERSION).min.js <- out/component-$(VERSION).js (Google Closure Compiler)"; \
	$(CLOSURECOMPILER) \
	    --js_output_file out/component-$(VERSION).min.js \
	    --js out/component-$(VERSION).js && \
	(sed -e '/(function/,$$d' component.js; cat out/component-$(VERSION).min.js) >out/.tmp && \
	cp out/.tmp out/component-$(VERSION).min.js && rm -f out/.tmp

out/component-$(VERSION).min-ug.js: out/component-$(VERSION).js
	@$(SHTOOL) mkdir -f -p -m 755 out
	@echo "++ compressing out/component-$(VERSION).min-ug.js <- out/component-$(VERSION).js (UglifyJS)"; \
	$(UGLIFYJS) \
	    -o out/component-$(VERSION).min-ug.js \
	    out/component-$(VERSION).js && \
	(sed -e '/(function/,$$d' component.js; cat out/component-$(VERSION).min-ug.js) >out/.tmp && \
	cp out/.tmp out/component-$(VERSION).min-ug.js && rm -f out/.tmp

out/component-$(VERSION).min-yc.js: out/component-$(VERSION).js
	@$(SHTOOL) mkdir -f -p -m 755 out
	@echo "++ compressing out/component-$(VERSION).min-ug.js <- out/component-$(VERSION).js (Yahoo UI Compressor)"; \
	$(YUICOMPRESSOR) \
	    -o out/component-$(VERSION).min-yc.js \
	    out/component-$(VERSION).js && \
	(sed -e '/(function/,$$d' component.js; cat out/component-$(VERSION).min-yc.js) >out/.tmp && \
	cp out/.tmp out/component-$(VERSION).min-yc.js && rm -f out/.tmp

lint: lint1

lint1: out/component-$(VERSION).js
	@echo "++ linting out/component-$(VERSION).js (Google Closure Linter)"; \
	$(GJSLINT) out/component-$(VERSION).js |\
	egrep -v "E:(0001|0131|0110)" | grep -v "FILE  :" | sed -e '/^Found/,$$d'

lint2: out/component-$(VERSION).js
	@echo "++ linting out/component-$(VERSION).js (JSLint)"; \
	$(JSLINT) out/component-$(VERSION).js

clean:
	@echo "++ removing out/component-$(VERSION).js"; rm -f out/component-$(VERSION).js
	@echo "++ removing out/component-$(VERSION).min.js"; rm -f out/component-$(VERSION).min.js
	@echo "++ removing out/component-$(VERSION).min-ug.js"; rm -f out/component-$(VERSION).min-ug.js
	@echo "++ removing out/component-$(VERSION).min-yc.js"; rm -f out/component-$(VERSION).min-yc.js
	@echo "++ removing out"; rmdir out >/dev/null 2>&1 || true
