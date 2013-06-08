; vim: ft=asm68k
; still hate vim
; routine to interpolate in a color gradient.

; Input:
; d0 contains our index value, a0 contains the address of the gradient datastructure

; gradients are specified as arrays of:
; struct section {
;   uint16_t position;
;   uint16_t (65535 / distance_to_next_section);
;   uint8_t r,g,b;
; };

; Return Value:
; d0 returns the reduced 12 bit color value


* exports
    xdef color_lookup
		xdef gradient1
		xdef gradient2


; -------- Two macros to specifiy gradients ------------
START_GRADIENT: macro
prev_grad_start: set 0
	endm

GRADIENT_ENTRY: macro ; parameters are (pos, r,g,b)
	ifle \1
prev_grad_start: set 0
	endif
	dc.w \1-prev_grad_start
	if \1-prev_grad_start
		dc.w 65535/(\1-prev_grad_start)
	else
		dc.w 0
	endif
	dc.b \2
	dc.b \3
	dc.b \4
	dc.b 0
prev_grad_start: set \1
	endm
; -----------------------------------------------------

gradient1: ; Red-and-yellow gradient
		START_GRADIENT
		rept 10
		GRADIENT_ENTRY 0,0,0,0
		GRADIENT_ENTRY 20,255,0,0
		GRADIENT_ENTRY 30,255,255,0
		GRADIENT_ENTRY 40,255,255,255
		endr

gradient2: ; Blue-and-cyan gradient
		START_GRADIENT
		rept 10
		GRADIENT_ENTRY	0,0,0,255
		GRADIENT_ENTRY	50,23,255,234
		GRADIENT_ENTRY	100,0,0,255
		endr

color_lookup:
		movem.l d1-d6/a0-a1,-(a7)   ; Push all registers that will be clobbered

		; a2 points to the gradient
		;move.l #example_gradient,a0
		;move.l a2,a0
		
		; Find the segment of the gradient we're in
		clr.l d1
		bra loop1
looptop1:
		sub.l d1,d0
		addq #8,a0
loop1:
		move.w (a0),d1
		cmp.w d0,d1
    blt.s   looptop1

		; a1 points to the previous segment
		move.l a0,a1
		subq #8,a1

		; v *= multiplier
		mulu.w 2(a0),d0

		; Do the actual interpolation
		; left half
		clr.l d1
		clr.l d2
		clr.l d3
		move.b 4(a0),d1
		move.b 5(a0),d2
		move.b 6(a0),d3
		mulu.w d0,d1
		mulu.w d0,d2
		mulu.w d0,d3
		
		; right half
		move.l #65535,d4
		sub.l d0,d4
		move.l d4,d0
		clr.l d4
		clr.l d5
		clr.l d6
		move.b 4(a1),d4
		move.b 5(a1),d5
		move.b 6(a1),d6
		mulu.w d0,d4
		mulu.w d0,d5
		mulu.w d0,d6

		; add them together
		add.l d4,d1
		add.l d5,d2
		add.l d6,d3

		; shift right
		moveq #20,d5
		asr.l d5,d1
		asr.l d5,d2
		asr.l d5,d3
		; stuff together
		move.l d1,d0
		asl.l #4,d0
		add.l d2,d0
		asl.l #4,d0
		add.l d3,d0
		; and we're done

		movem.l (a7)+,d1-d6/a0-a1  ; Pop clobbered registers
    rts

