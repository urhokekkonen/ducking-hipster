; vim: ft=asm68k
; still hate vim
; routine to make the copperbars.
; a1 contains our spottage.
; we start on line 30 ($1E)

* exports
    xdef    makebars

makebars:

    move.l  #$1E,d1
loop1:
;color blue
;    move.l  #$01800008,(a1)+
    move.w  #$0180,(a1)+
    move.w  d1,(a1)+
; wait for $40 position horizontally
    move.w  d1,d0
    asl.w   #8,d0
    add.w   #$41,d0
    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+
; color white
    move.l  #$01800FFF,(a1)+
; wait for $A0 horizontally
    move.w  d1,d0
    asl.w   #8,d0
    add.w   #$51,d0
    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+
;color green
    move.l  #$01800080,(a1)+
; wait for end of line (or really far)
    move.w  d1,d0
    asl.w  #8,d0
    add.w   #$61,d0
    move.w  d0,(a1)+
    move.w  #$FFFE,(a1)+
; inc and check
    addq    #1,d1
    cmp.w   #$0118,d1
;    cmp.l   #$2F,d1
    blt.s   loop1
    rts

