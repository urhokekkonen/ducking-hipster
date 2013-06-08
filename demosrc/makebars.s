; vim: ft=asm68k
; still hate vim
; routine to make the copperbars.
; a1 contains our spottage.
; we start on line 30 ($1E)

* exports
    xdef    makebars
    xref testface_data
    xref color_lookup

makebars:

    sub.l   d2,d2
    move.b  #$00,d2

    move.l  #$1E,d1
    ; a0 points to the face data array
    move.l #testface_data,a0
loop1:
;color blue
;    move.l  #$01800008,(a1)+
;random ugly color based on screen address
;    move.w  #$0180,(a1)+
;    move.w  d1,(a1)+

    ; Gradient lookup
    ; Get gradient thing
    move.l d1,d0
    jsr color_lookup
    move.w  #$0180,(a1)+
    move.w  d0,(a1)+

; scrolly register
    move.w  #$0102,(a1)+

; crappage with nybble twiddling
    move.b  d2,d3   ; value
    and.b   #$0F,d3 ; clean upper nybble
    swap    d2    ; tempstore
    move.b  d3,d2   ;
    rol.b   #4,d3   ; move to upper nybble
    add.b   d2,d3   ; and add back to lower
    rol     #8,d3      ; and now to upper half of word
    move.b  #$00,d3 ; 00 in lower
    move.w  d3,(a1)+    ; store to copperlist

    addq.b  #1,d2   ; yeah we shouldn't overflow here.
    ; note I said shouldn't

; wait for position horizontally (according to face data)
    move.w  d1,d0
    asl.w   #8,d0
    add.b   (a0)+,d0
    or      #1,d0

    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+
; color white
    move.l  #$01800FFF,(a1)+
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
    blt.s   loop1
    rts

