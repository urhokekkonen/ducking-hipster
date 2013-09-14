WRKDIR=$(shell pwd)
TOOLCHAIN=/usr/bin

AS=$(TOOLCHAIN)/vasm68k
ASFLAGS=-Fhunk -I $(WRKDIR)/../include

LD=$(TOOLCHAIN)/vlink
OBJECTS=start.o testface.o makebars.o gradient.o linefix.o

demostart.exe: $(OBJECTS)
	$(LD) -o $@ $(OBJECTS)

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm demostart.exe *.o *~


