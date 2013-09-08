** Math Macros

x2: macro
; apparently this is faster with add...
    add.\1  \2,\2
;    asl.\1   #1,\2
    endm

div2: macro
    asr.\1  #1,\2
    endm

x3: macro
    move.\1  \2,\3
    asl.\1   #1,\2
    add.\1   \3,\2
    endm

x4: macro
    asl.\1   #2,\2
    endm

div4:   macro
    asr.\1  #2,\2
    endm

x5: macro
    move.\1  \2,\3
    asl.\1   #2,\2
    add.\1   \3,\2
    endm

x6: macro
    x3  \1,\2,\3
    x2  \1,\2
    endm

x7: macro
;    move.\1 \2,\3  ; as x3 does this no need to repeat
    x6  \1,\2,\3
    add.\1  \2,\2
    endm

x8: macro
    asl.\1  #3,\2
    endm

x9: macro
    move.\1 \2,\3
    x8  \1,\2,\3
    add.\1  \2,\3
    endm

x10:    macro
;   move.\1 \2,\3   ; again no need to as x5 does this
    x5  \1,\2,\3
    x2  \1,\2
    endm

x100: macro
    move.\1 \2,\3
    move.\1 \3,\4
    asl.\1  #6,\2
    asl.\1  #5,\3
    asl.\1  #2,\4
    add.\1  \4,\2
    add.\1  \3,\2
    endm

div4096:    macro
    asr.\1  #8,\2
    asr.\1  #4,\2
    endm

div2048:    macro
    asr.\1  #8,\2
    asr.\1  #1,\2
    endm


