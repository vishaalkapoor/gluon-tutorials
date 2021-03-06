all: html

build/%.ipynb: %.md
	@mkdir -p $(@D)
	cd $(@D); python ../md2ipynb.py ../../$< ../../$@

build/%.md: %.md
	@mkdir -p $(@D)
	@cp $< $@

MARKDOWN = $(wildcard chapter_preface/*.md */index.md)
NOTEBOOK = $(filter-out $(MARKDOWN), $(wildcard chapter*/*.md))

OBJ = $(patsubst %.md, build/%.md, $(MARKDOWN)) \
	$(patsubst %.md, build/%.ipynb, $(NOTEBOOK))

ORIGN_DEPS = $(wildcard img/* data/*) environment.yml utils.py README.md
DEPS = $(patsubst %, build/%, $(ORIGN_DEPS))

PKG = build/_build/html/gluon_tutorials.tar.gz build/_build/html/gluon_tutorials.zip

pkg: $(PKG)

build/_build/html/gluon_tutorials.zip: $(OBJ) $(DEPS)
	cd build; zip -r $(patsubst build/%, %, $@ $(DEPS)) chapter*

build/_build/html/gluon_tutorials.tar.gz: $(OBJ) $(DEPS)
	cd build; tar -zcvf $(patsubst build/%, %, $@ $(DEPS)) chapter*

build/%: %
	@mkdir -p $(@D)
	@cp -r $< $@

html: $(DEPS) $(OBJ)
	make -C build html

SVG=$(wildcard img/*.svg)

build/_build/latex/%.png: img/%.svg
	convert $< $@

pdf: $(DEPS) $(OBJ) $(patsubst img/%.svg, build/_build/latex/%.png, $(SVG))
	make -C build latex
	sed -i s/\.svg/\.png/ build/_build/latex/gluon_tutorials.tex
	cd build/_build/latex; make

clean:
	rm -rf build/chapter* $(DEPS) $(PKG)
