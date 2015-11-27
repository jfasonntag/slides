SRC=$(wildcard *.md) 
OBJS=$(SRC:.md=.html)
OBJS2=$(SRC:.md=.html)

slides: $(OBJS)

$(OBJS) : %.html : %.md 
	pandoc --standalone --mathjax -t slidy --highlight-style pygments $< -o $@

clean:
	rm -rf *.html

all: clean slides
