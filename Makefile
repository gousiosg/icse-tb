##
# Copyright 2017 - onwards Georgios Gousios <gousiosg@gmail.com>
#
##

R=Rscript -e

.PHONY: all html pdf book

CONTENT_DIRS := .
INPUTS = $(shell find $(CONTENT_DIRS) -type f -name '*.Rmd' | egrep -v "header|footer")

OUTPUTS_HTML = $(INPUTS:.Rmd=.html)
OUTPUTS_PDF = $(INPUTS:.Rmd=.pdf)
OUTPUTS_SLIDES = $(INPUTS:.Rmd=.reveal.html)
OUTPUTS_SLIDES_PDF = $(OUTPUTS_SLIDES:.reveal.html=.reveal.pdf)

%.html: %.Rmd  $(DEPS)
	$(R) "library(rmarkdown); render('$<', output_file=gsub(pattern = '.Rmd', '.html', basename('$<')), output_format = 'html_document')"

%.pdf: %.Rmd $(DEPS)
	$(eval TMP := $(shell mktemp))
	grep -v "\. \. \." < $< > $(TMP)
	$(eval NEWTMP := $(shell dirname $<)/$(shell basename $(TMP)).Rmd)
	mv $(TMP) $(NEWTMP)
	$R "library(rmarkdown); render('$(NEWTMP)', output_file= gsub(pattern = '.Rmd', '.pdf', basename('$<')),  output_format = 'pdf_document')"
	rm $(NEWTMP)

%.reveal.html: %.Rmd  $(DEPS)
	$R "library(rmarkdown); render('$<', output_file=gsub(pattern = '.Rmd', '.reveal.html', basename('$<')), output_format = 'revealjs::revealjs_presentation')"

%.reveal.pdf: %.reveal.html $(DEPS)
	docker run --rm -t -v `pwd`:/home/user astefanutti/decktape /home/user/$< /home/user/$@

all: html slides pdf

html: $(DEPS) $(INPUTS) $(OUTPUTS_HTML)
pdf: $(DEPS) $(INPUTS) $(OUTPUTS_PDF)
slides: $(DEPS) $(INPUTS) $(OUTPUTS_SLIDES)
slides_pdf: $(DEPS) $(OUTPUTS_SLIDES_PDF)

clean:
	- rm *~
	- rm $(OUTPUTS_PDF)
	- rm $(OUTPUTS_HTML)
	- rm $(OUTPUTS_SLIDES)
	- rm $(OUTPUTS_SLIDES_PDF)
