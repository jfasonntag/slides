SRC=$(wildcard *.md) 
OBJS=$(SRC:.md=.html)
PDF=$(SRC:.md=.pdf)


slides: $(OBJS)

prints: $(PDF)

$(OBJS) : %.html : %.md 
	pandoc --standalone --mathjax -t slidy --highlight-style pygments --bibliography=../../references/references.bib --csl=../../references/computational-economics.csl $< -o $@

$(PDF) : %.pdf : %.md 
	pandoc -N --template=mytemplate.tex --variable mainfont="Palatino" --variable sansfont="Century Gothic" --variable monofont="Consolas" --variable fontsize=12pt --bibliography=../../references/references.bib $< --latex-engine=pdflatex --toc -o $@

clean:
	rm -rf *.html *.pdf

all: clean slides prints
