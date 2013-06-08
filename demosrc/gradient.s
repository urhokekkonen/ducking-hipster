; vim: ft=asm68k
; still hate vim
; routine to interpolate in a color gradient.
; d0 contains our index value
; d1,d2,d3 return the (8 bit) rgb values.
; d0 returns the reduced 12 bit color value
* exports
    xdef color_lookup
		xdef gradient1
		xdef gradient2

gradient1:
		dc.w 0
		dc.w 65535/50
		dc.b 0
		dc.b 0
		dc.b 0
		dc.b 0

		dc.w 50
		dc.w 65535/120
		dc.b 255
		dc.b 0
		dc.b 0
		dc.b 0

		dc.w 170
		dc.w 65535/220
		dc.b 255
		dc.b 255
		dc.b 0
		dc.b 0

		dc.w 390
		dc.w 0
		dc.b 255
		dc.b 255
		dc.b 255
		dc.b 0

gradient2:
		dc.w 0
		dc.w 65535/400
		dc.b 0
		dc.b 0
		dc.b 255
		dc.b 0

		dc.w 400
		dc.w 0
		dc.b 23
		dc.b 255
		dc.b 234
		dc.b 0

color_lookup:
		movem.l d1-d6/a0-a1,-(a7)   ; Push all registers that will be clobbered

		; a2 points to the gradient
		;move.l #example_gradient,a0
		;move.l a2,a0
		
		; Find the segment of the gradient we're in
		clr.l d1
		bra loop1
looptop1:
		subq #1,d0
		addq #8,a0
loop1:
		move.w (a0),d1
		cmp.w d0,d1
    blt.s   looptop1

		; a1 points to the previous segment
		move.l a0,a1
		subq #8,a1

		; v -= offset
		sub.w (a1),d0
		; v *= multiplier
		mulu.w 2(a1),d0

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

