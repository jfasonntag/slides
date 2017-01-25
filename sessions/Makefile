SRC=$(wildcard *.md) 
OBJS=$(SRC:.md=.html)
PDF=$(SRC:.md=.pdf)
MDS=$(SRC:.md=.ipynb)


slides: $(OBJS)

prints: $(PDF)

notebook: $(MDS)

$(MDS) : %.ipynb : %.md 
	notedown $< > ../Notebooks/$@

$(OBJS) : %.html : %.md 
	# pandoc --standalone --mathjax -t revealjs -V revealjs-url=../reveal.js -c ../styles/pandoc-style.css --highlight-style pygments $< -o $@
	pandoc --standalone --mathjax -t slidy --standalone --mathml --highlight-style=kate --filter=pandoc-citeproc --bibliography=../../references/references.bib --csl=../../references/computational-economics.csl $< -o $@
	# pandoc --standalone --mathjax -t slidy --highlight-style pygments $< -o $@

$(PDF) : %.pdf : %.md 
	pandoc -N --template=mytemplate.tex --variable mainfont="Palatino" --variable sansfont="Century Gothic" --variable monofont="Consolas" --variable fontsize=12pt --bibliography=../../references/references.bib $< --latex-engine=pdflatex --toc -o $@

clean:
	rm -rf *.html *.pdf *.ipynb

all: clean slides prints
