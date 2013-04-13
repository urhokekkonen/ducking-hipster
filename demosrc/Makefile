WRKDIR=$(shell pwd)
TOOLCHAIN=/usr/bin

AS=$(TOOLCHAIN)/vasm68k
ASFLAGS=-Fhunk -I $(WRKDIR)/../include

LD=$(TOOLCHAIN)/vlink

demostart.exe: start.o makebars.o
	$(LD) -o $@ $?

start.o: start.s
	$(AS) $(ASFLAGS) $< -o $@

makebars.o: makebars.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm demostart.exe *.o *~


