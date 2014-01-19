CWD=$(shell pwd)

AR ?= ar
CC ?= gcc
PREFIX ?= /usr/local
SCANBUILD ?= scan-build

CFLAGS = -c -O3 -Wall -std=c99 # -DNDEBUG

LIST = deps/list
LOGH = deps/log.h

SRCS = $(LIST)/list.c $(LIST)/list_iterator.c $(LIST)/list_node.c src/ee.c
OBJS = $(SRCS:.c=.o)
INCS = -I $(LIST)/ -I $(LOGH)/
CLIB = node_modules/.bin/clib

EE = ee

all: clean $(LIST) $(LOGH) $(EE)

run: all
	@echo "\n\033[1;33m>>>\033[0m"
	./$(EE)
	@echo "\n\033[1;33m<<<\033[0m\n"
	make clean

check:
	$(SCANBUILD) $(MAKE)

$(EE): $(OBJS)
	$(CC) $^ -o $@

# clibs
$(CLIB):
	npm install

$(LIST): $(CLIB)
	$(CLIB) install clibs/list -o deps/

$(LOGH): $(CLIB) 
	$(CLIB) install thlorenz/log.h -o deps/
	
.SUFFIXES: .c .o
.c.o: 
	$(CC) $< $(CFLAGS) $(INCS) -c -o $@

clean-all: clean
	rm -f $(OBJS)

clean:
	find . -name "*.gc*" -exec rm {} \;
	rm -rf `find . -name "*.dSYM" -print`
	rm -f $(EE) src/ee.o 

.PHONY: all check run clean clean-all
