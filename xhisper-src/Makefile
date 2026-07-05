# Makefile for xhisper

CC = gcc
CFLAGS = -O2 -Wall -Wextra
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

all: xhispertool test

xhispertool: xhispertool.c
	$(CC) $(CFLAGS) xhispertool.c -o xhispertool
	ln -sf xhispertool xhispertoold

test: test.c
	$(CC) $(CFLAGS) test.c -o test

install: xhispertool xhisper.sh
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(PREFIX)/share/xhisper
	install -m 755 xhispertool $(DESTDIR)$(BINDIR)/xhispertool
	ln -sf xhispertool $(DESTDIR)$(BINDIR)/xhispertoold
	install -m 755 xhisper.sh $(DESTDIR)$(BINDIR)/xhisper
	install -m 644 default_xhisperrc $(DESTDIR)$(PREFIX)/share/xhisper/default_xhisperrc

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/xhisper
	rm -f $(DESTDIR)$(BINDIR)/xhispertool
	rm -f $(DESTDIR)$(BINDIR)/xhispertoold

clean:
	rm -f xhispertool xhispertoold test

.PHONY: all install uninstall clean
