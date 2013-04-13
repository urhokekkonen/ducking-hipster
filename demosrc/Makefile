WRKDIR=$(shell pwd)
TOOLCHAIN=/opt/amiga/bin

AS=$(TOOLCHAIN)/vasm
ASFLAGS=-Fhunk -I $(WRKDIR)/../include

LD=$(TOOLCHAIN)/vlink

start: start.o
	$(LD) -o $@ $<

start.o: start.s
	$(AS) $(ASFLAGS) $< -o $@
