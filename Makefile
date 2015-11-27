index:
	pandoc -s -c styles/dashed.css index.md -o index.html

clean: 
	rm -rf *.html

all: clean index
