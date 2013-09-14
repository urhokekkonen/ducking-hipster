*******************************************************************************
*	fixed version: DrawLine V1.01' By TIP/SPREADPOINT		      *
* Truck fixed version
*******************************************************************************

    xdef    DrawLine, DL_Init,fillpage
    include 'constants.s'
    include 'mathmacros.s'
    include 'hardware/custom.i'

; set DL_Width to the same as d4 (planewidth)
; used for speedup shifts below

DL_Fill		=	1		; 0=NOFILL / 1=FILL
	IFEQ	DL_Fill
DL_MInterns	=	$CA
	ELSE
DL_MInterns	=	$4A
	ENDC


;	A0 = PlanePtr, A6 = $DFF002, D0/D1 = X0/Y0, D2/D3 = X1/Y1
;	D4 = PlaneWidth > Kills: D0-D4/A0-A1 (+D5 in Fill Mode)

DrawLine:	cmp.w	d1,d3		; Drawing only from Top to Bottom is
		bge.s	.y1ly2		; necessary for:
		exg	d0,d2		; 1) Up-down Differences (same coords)
		exg	d1,d3		; 2) Blitter Invert Bit (only at top of
					;    line)
.y1ly2:		sub.w	d1,d3		; D3 = yd

    IF  DL_WIDTH = 40
        x4  l,d1
        x10 l,d1,d4
    ELSE
        IF  DL_WIDTH = 60
            x6  l,d1,d4
            x10 l,d1,d4
        ELSE
            IF  DL_WIDTH=80
                x8  l,d1
                x10 l,d1,d4
            ELSE
		        mulu	d4,d1		; Use muls for neg Y-Vals
            ENDC
        ENDC
    ENDC

		add.l	d1,a0		; Please don't use add.w here !!!
		moveq	#0,d1		; D1 = Quant-Counter
		sub.w	d0,d2		; D2 = xd
		bge.s	.xdpos
		addq.w	#2,d1		; Set Bit 1 of Quant-Counter (here it
					; could be a moveq)
		neg.w	d2
.xdpos:		moveq	#$f,d4		; D4 full cleaned (for later oktants
					; move.b)
		and.w	d0,d4
	IFNE	DL_Fill
		move.b	d4,d5		; D5 = Special Fill Bit
		not.b	d5
	ENDC
		lsr.w	#3,d0		; Yeah, on byte (necessary for bchg)...
		add.w	d0,a0		; ...Blitter ands automagically
		ror.w	#4,d4		; D4 = Shift
		or.w	#$B00+DL_MInterns,d4	; BLTCON0-codes
		swap	d4
		cmp.w	d2,d3		; Which Delta is the Biggest ?
		bge.s	.dygdx
		addq.w	#1,d1		; Set Bit 0 of Quant-Counter
		exg	d2,d3		; Exchange xd with yd
.dygdx:		add.w	d2,d2		; D2 = xd*2
		move.w	d2,d0		; D0 = Save for $52(a6)
		sub.w	d3,d0		; D0 = xd*2-yd
		addx.w	d1,d1		; Bit0 = Sign-Bit
		move.b	Oktants(PC,d1.w),d4	; In Low Byte of d4
						; (upper byte cleaned above)
		swap	d2
		move.w	d0,d2
		sub.w	d3,d2		; D2 = 2*(xd-yd)
		moveq	#6,d1		; D1 = ShiftVal (not necessary) 
					; + TestVal for the Blitter
		lsl.w	d1,d3		; D3 = BLTSIZE
		add.w	#$42,d3
		lea	bltapt(a6),a1	; A1 = CUSTOM+$52 ($52-2 = bltapt)

; WARNING : If you use FastMem and an extreme DMA-Access (e.g. 6
; Planes and Copper), you should Insert a tst.b (a6) here (for the
; shitty AGNUS-BUG)

.wb:		btst	d1,(a6)		; Waiting for the Blitter...
		bne.s	.wb
	IFNE	DL_Fill
		bchg	d5,(a0)		; Inverting the First Bit of Line
	ENDC
		move.l	d4,bltcon0-2(a6)	; Writing to the Blitter Regs as fast
		move.l	d2,bltbmod-2(a6)	; as possible
		move.l	a0,bltcpt-2(a6)
		move.w	d0,(a1)+
		move.l	a0,(a1)+	; Shit-Word Buffer Ptr...
		move.w	d3,(a1)
		rts
;­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­
	IFNE	DL_Fill
SML		= 	2
	ELSE
SML		=	0
	ENDC

Oktants:	dc.b	SML+1,SML+1+$40
		dc.b	SML+17,SML+17+$40
		dc.b	SML+9,SML+9+$40
		dc.b	SML+21,SML+21+$40

;­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­­
*** INIT PART ***
;       Optimized Init Part... A6 = $DFF000 > Kills : D0-D1

DL_Init:
	addq.w	#2,a6		; A6 = $DFF002 for DrawLine !
	IFGT	DL_WIDTH-127
		move.w	#DL_WIDTH,d0
	ELSE
		moveq	#DL_WIDTH,d0
	ENDC
                waitblit
		moveq	#-1,d1
		move.w	d1,bltafwm-2(a6)
		move.w	d1,bltbdat-2(a6)
		move.w	#$8000,bltadat-2(a6)
		move.w	d0,bltcmod-2(a6)
		move.w	d0,bltdmod-2(a6)
		rts

*** FILL ROUTINE ***

; a6 dff000, d0 bitplane pointer to BOTTOM of fill,
; d1 size(word)

; This is a fill routine that fills a _large_ area
; and the size, which is (64*height) * width in WORDS.
; == WORDS,DAMMIT. ==
;64*256 (height) + 40 (width) = #$8028


fillpage:
    waitblit
;blitlab indicates we don't need FWM or LWM. find out later.
    move.l  #-1,bltafwm(a6)          ;both last&first
;   %00001001111110000      - no A shift; use A,D; "A" minterm
;   %00000000000010010      - desc mode; IFE; no B shift; D on
    move.l  #$09F0000E,bltcon0(a6)  ;both 0 & 1
; A pointer - the bottom of the bitplane area we drew to - so
    move.l  d0,bltapt(a6)
; D pointer is end of the 2nd area. yes, copy+fill.
    move.l  d0,bltdpt(a6)
; NO MODULO
    move.l  #0,bltamod(a6)
    move.w  d1,bltsize(a6)
    rts


; I am not doing this in a routine, macro is better, and screw it

;DL_Exit:	subq.w	#2,a6		; A6 = $DFF000
;		rts

; IF for some reason you don't use the macro file
; then uncomment this macro.

;waitblit:   macro
;    btst #$0e,$dff002
;wb\@:
;    btst #$0e,$dff002
;    bne.s wb\@
;    endm

