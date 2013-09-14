; vim: ft=asm68k
* I HATE VIM. I'm using my VISUX plugin.
*    ______.
*   /  /   |
* _/  /|   l______
* |  /_|         / BREaKFAST KLUB
* |  .  \     __/_  Demo "System"
* |     /         \
* |____/   \_______\
*      |_____|
*
*  Demo: "en tiedä"

*** includes
    incdir  work:include
    include 'hardware/custom.i'
    include 'exec/exec_lib.i'
    include 'exec/memory.i'
    include 'mathmacros.s'

*** imports
    xref makebars

*** exports
    xdef    hunkaram
; use xdef

*** Macros
waitblit:       macro
wb\@:
    btst #$0e,$dff000
    bne.s wb\@
    endm

* - Program portion
    section BKprogram,code

*** constants
execbase=4
startlist=38

* --- Program Start

bkprogstart:
    move.l  execbase,a6
    jsr     _LVOForbid(a6)
init:   move.l  $dff004,d0 ; vposr
    and.l   #$0001ff00,d0
    cmp.l   #$00001000,d0
    bne.s   init
    move.w  #%0000000000100000,$dff096 ; dmacon

* - music init, other inits before we get going

;       jsr     mt_init

; alloc mem for bitplanes
; 32000 bytes chipmem each

;allocate a hunka ram
    move.l  #10240*2,d0
    move.l  #MEMF_CHIP!MEMF_CLEAR,d1   ;we want chipram
    jsr     _LVOAllocMem(a6)
    move.l  d0,hunkaram
;   errorcheck -if 0 we have no mem
    beq exit0

    move.l  #copper1,a0
    addq    #2,a0
    swap    d0
    move.w  d0,(a0)+
    addq.l  #2,a0
    swap    d0
    move.w  d0,(a0)

; now make a line bit in the bitplane

    pushl   a6
    lea     $dff000,a6
    jsr     DL_Init
    sub.l   d0,d0
    move.l  d0,d1
    move.l  #128,d2
    move.l  #128,d3
;    move.l  #40,d4
    move.l  hunkaram,a0
    jsr     DrawLine

; fill

    popl    a6

; allocate 9200 bytes for copperlist
    move.l  #9200,d0
    move.l  #MEMF_CHIP!MEMF_CLEAR,d1
    jsr     _LVOAllocMem(a6)
    move.l  d0,coppa
    beq exit1


; copy the block to start
    move.l d0,a1
    move.l #copper1,a0
    move.b #((copperend-copper1)/4)-1,d1
.lo1
    move.l (a0)+,(a1)+
    dbra    d1,.lo1
; entering the routine A1 points to the next bit.
    move.l a1,a5
    jsr makebars
    move.l #$FFFFFFFE,(a1)+
;

* copper init
    lea     $dff000,a0
    move.l  coppa,cop1lc(a0)
    move.w  copjmp1(a0),d0

* --- Main Body of Demo
wait:
;    move.l  $dff004,d0 ; vposr
;    and.l   #$0001ff00,d0
;    cmp.l   #$00001000,d0
;    bne.s   wait

		; Update copper list
;		move.l a5,a1
;		jsr makebars
;    move.l #$FFFFFFFE,(a1)+

    btst    #6,$bfe001
    bne.s   wait

* -- End Program
fin:    move.l  execbase,a6
    move.l  #grname,a1
;    clr.l   d0
    sub.l   d0,d0
    jsr     _LVOOpenLibrary(a6)
    move.l  d0,a4
    move.l  startlist(a4),$dff080 ; cop1lch
    clr.w   $dff088 ; copjmp1
; free our ... stuff
exit2:
    move.l coppa,a1
    move.l #1000,d0
    jsr _LVOFreeMem(a6)

exit1:
    move.l hunkaram,a1
    move.l #10240*2,d0  ; you know deallocating the amount we allocated is a GOOD idea
    jsr _LVOFreeMem(a6)

exit0:
    move.w  #%1000000000100000,$dff096 ; dmacon
;       jsr     mt_end
    jsr     _LVOPermit(a6)
    clr.l   d0
    rts

grname: dc.b    "graphics.library",0,0

    even
* locations for 6 bitplanes [which we aren't using and I need to find coppa faster]
;screenmem:
;    dc.l 0,0,0,0,0,0
coppa:
    dc.l 0

    even
; - Includes for various things (code) like replays
;       include fastreplay.s

* Chip stuff, in another section
    section copper-image,data_c

copper1:
;
; Set up pointers to two bit planes
;
     DC.W    $0E0,$0002      ;Move S0002 into register $0E0 (BPL1PTH)
     DC.W    $0E2,$1000      ;Move $1000 into register $0E2 (BPL1PTL)
     DC.W    $0E4,$0002      ;Move $0002 into reqister $0E4 (BPL2PTH)
     DC.W    $0E6,$5000      ;Move $5000 into register $0E6 (BPL2PTL)
;
; Load color registers
;
     DC.W    $180,$0F80      ;Move white into register $180 (COLOR00)
     DC.W    $182,$0F00      ;Move red into register $182 (COLOR01)
     DC.W    $184,$00F0      ;Move green into register $184 (COLOR02)
     DC.W    $186,$000F      ;Move blue into register $186 (COLOR03)
;
; Specify 2 lo-res bitplanes
;
     DC.W    bplcon0,$2200      ;2 lores planes, coloron
; wait for 30 + 16
     DC.W    $1E01,$FF00    ;Wait for line 30, ignore horiz. position
    dc.w    $8E,$1e81       ;move the display window so we know where it is.
    ; and if you want a top raster bordery thing then it would go here.
;    dc.w    $180,$F


copperend

* - music data

;mt_data:       incbin  mod.musique

hunkaram:       dc.l    0,0

* bitplanes
;plane1 blk.b   32000

