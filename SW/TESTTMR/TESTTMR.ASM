;
;
;
	output TESTTMR.BIN

ENASLT	= #0024
CHGCPU	= #0180
ROMSLT	= #FFF7


; -----------------------------------------------------------

	db	#FE
	dw	start
	dw	end
	dw	start

	ORG	#9000

start:
	ld	a, 2
	call	CHGCPU
	di
	ld	a, #01
	ld	h, #40
	call	ENASLT
	di
	ld	a, #07
	ld	(#6000), a
	ld	a, #80
	ld	(#7FF1), a
	ld	a, (ROMSLT)
	ld	h, #40
	call	ENASLT
	di
	ld	a, 2
	call	CHGCPU
	ei
	ld	a, #01
	ld	h, #40
	call	ENASLT
	di
	ld	a, #07
	ld	(#6000), a
	ld	a, (#7FF1)
	ld	(#8FFF), a
	ld	a, (ROMSLT)
	ld	h, #40
	call	ENASLT
	ld	a, 2
	call	CHGCPU

	ret
end:
