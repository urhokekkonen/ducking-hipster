; vim: ft=asm68k
; still hate vim
; routine to make the copperbars.
; a1 contains our spottage.
; we start on line 30 ($1E)

* exports
    xdef    makebars
    xref testface_data
    xref color_lookup

time:
  dc.l 0

makebars:

    sub.l   d2,d2
    ; ok wtf if we just zer0'd d2 why do we move 0 into it...
;    move.b  #$00,d2

; this is our raster counter. change from 1e if we start in another spot.
    move.l  #$1E,d1

    ; a0 points to the face data array
    move.l #testface_data,a0

    ; Read and increment time
    move.l #time,a6
    move.b (a6),d5
    addq #1,d5
    move.b d5,(a6)

loop1:
;random ugly color based on screen address
    move.w  #$0180,(a1)+
    move.w  d1,(a1)+

; ok let's just move the diwstart thing
    move.w  #$8e,(a1)+
    move.b  (a0)+,d2
    add.b   #$1e,d2     ; + offset
    move.b  d2,(a1)+
    move.b  #$81,(a1)+

; wait for end of line (or really far)
    move.w  d1,d0
    asl.w   #8,d0
    add.w   #$F1,d0
    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+
; inc and check
    addq    #1,d1
    cmp.w   #$0130,d1   ;line 304 for a bit of 'border'
    blt   loop1
    rts

