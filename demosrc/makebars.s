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
    move.l  #$01800F08,(a1)+
    rts
; wait for $40 position horizontally
    move.w  d1,d0
    or.w   #%1000000000000000,d0
    add.b   #$40,d0
    move.w  d0,(a1)+
    move.w  #$FF00,(a1)+
; color white
    move.l  #$01800FFF,(a1)+
; wait for $A0 horizontally
    add.w   #$60,d0
    move.w  d0,(a1)+
    move.w  #$FF00,(a1)+
;color green
    move.l  #$01800080,(a1)+
; wait for end of line (or really far)
    add.w   #$5F,d0
    move.w  d0,(a1)+
    move.w  #$FF00,(a1)+
; inc and check
    addq    #1,d1
    cmp.w   #$0118,d1
    blt.s   loop1
    rts

