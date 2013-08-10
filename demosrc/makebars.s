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

    move.l  #$1E,d1
    ; a0 points to the face data array
    move.l #testface_data,a0

    ; Read and increment time
    move.l #time,a6
    move.b (a6),d5
    addq #1,d5
    move.b d5,(a6)

loop1:
;color blue
    move.l  #$01800008,(a1)+
;random ugly color based on screen address
    move.w  #$0180,(a1)+
    move.w  d1,(a1)+

    ; Gradient lookup
    ; Get gradient thing
    move.l d1,d0
    add.b d5,d0
    move.l a0,-(a7)
    move.l #gradient1,a0
 ;   jsr color_lookup
    move.l (a7)+,a0

    move.w  #$0180,(a1)+
    move.w  d0,(a1)+

; scrolly register 102
    move.w  #$0102,(a1)+

; crappage with nybble twiddling
    move.b  d2,d3   ; value
    and.b   #$0F,d3 ; clean upper nybble
    swap    d2    ; tempstore
    move.b  d3,d2   ;
    rol.b   #4,d3   ; move to upper nybble
    add.b   d2,d3   ; and add back to lower
;    rol     #8,d3      ; and now to upper half of word
;    move.b  #$00,d3 ; 00 in lower
    move.w  d3,(a1)+    ; store to copperlist

    addq.b  #1,d2   ; yeah we shouldn't overflow here.
    ; note I said shouldn't

; testcarp - 
; we want to alter the "scanline" drawn
; by some offset. Which you need to determine from a list somewhere.
    move.w  $dff0e2,d3
    rol     #1,d2
    add.l   d2,d3
    move.w  #$00E2,(a1)+
    move.w  d3,(a1)+
    ror     #1,d2

; wait for position horizontally (according to face data)
    move.w  d1,d0
    asl.w   #8,d0
    add.b   (a0)+,d0
    or      #1,d0

    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+

; color white
;    move.l  #$01800FFF,(a1)+

; Second gradient for background
    move.l d1,d0
    sub.b d5,d0
    move.l a0,-(a7)
    move.l #gradient2,a0
;    jsr color_lookup
    move.l (a7)+,a0

    move.w #$0180,(a1)+
    move.w d0,(a1)+


; wait for $A0 horizontally
    move.w  d1,d0
    asl.w   #8,d0
    add.w   #$A1,d0
    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+
;color green
    move.l  #$01800080,(a1)+
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

