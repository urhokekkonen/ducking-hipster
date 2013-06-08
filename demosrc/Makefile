WRKDIR=$(shell pwd)
TOOLCHAIN=/usr/bin

AS=$(TOOLCHAIN)/vasm68k
ASFLAGS=-Fhunk -I $(WRKDIR)/../include

LD=$(TOOLCHAIN)/vlink

demostart.exe: start.o testface.o makebars.o gradient.o
	$(LD) -o $@ $?

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm demostart.exe *.o *~


