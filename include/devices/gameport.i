	IFND	DEVICES_GAMEPORT_I
DEVICES_GAMEPORT_I	SET	1
	IFND	EXEC_IO_I
	INCLUDE	"exec/io.i"
	ENDC
	DEVINIT
	DEVCMD	GPD_READEVENT
	DEVCMD	GPD_ASKCTYPE
	DEVCMD	GPD_SETCTYPE
	DEVCMD	GPD_ASKTRIGGER
	DEVCMD	GPD_SETTRIGGER
GPTB_DOWNKEYS	equ	0
GPTF_DOWNKEYS	equ	1<<0
GPTB_UPKEYS	equ	1
GPTF_UPKEYS	equ	1<<1
	rsreset
GamePortTrigger	rs.b	0
gpt_Keys	rs.w	1
gpt_Timeout	rs.w	1
gpt_XDelta	rs.w	1
gpt_YDelta	rs.w	1
gpt_SIZEOF	rs.w	0
GPCT_ALLOCATED	EQU	-1
GPCT_NOCONTROLLER	EQU	0
GPCT_MOUSE	EQU	1
GPCT_RELJOYSTICK	EQU	2
GPCT_ABSJOYSTICK	EQU	3
GPDERR_SETCTYPE	EQU	1
	ENDC

