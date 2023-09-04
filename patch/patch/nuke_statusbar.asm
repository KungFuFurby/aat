lorom

; Note: if you use the powerdown patch, find the line below that mentions that
; AAT edits: Enable all status bar counters (not just the coin counter).

; 1 enables all counters (timer, coins, and bonus stars)
!enable_counters = 1

if read1($00FFD5) == $23
	sa1rom
	!sa1 = 1
	!base2 = $6000
else
	!sa1 = 0
	!base2 = $0000
endif

org $0081F4			; JSR $008DAC
	BRA + : NOP : +
	
org $008275			; this one nukes the IRQ
	JMP NMI_hijack

org $0082E8			; JSR $008DAC
	BRA + : NOP : +
	
org $008C81			; literally nuke the status bar
	pad $009045		; (but skip over hextodec)
org $009051
	pad $0090D1

org $00985A			; JSR $008CFF
	BRA + : NOP : +
	
org $00A2D5			; JSR $008E1A
	if !enable_counters
		JSR counters
	else
		BRA + : NOP : +
	endif

org $00A5A8			; JSR $008CFF
	BRA + : NOP : +
	
org $00A5D5			; JSR $008E1A
	if !enable_counters
		JSR counters
	else
		BRA + : NOP : +
	endif

;org $00F5F8			; don't try dropping anything when getting hurt
;	BRA + : NOP #2 : +	; REMOVE THIS IF YOU USE THE POWERDOWN PATCH

;org $01C540			; don't store items ever
;	BRA + : NOP #11 : +

; use the old status bar area as freespace
org $008C81
NMI_hijack:
	LDA $0D9B|!base2
	BNE .special
	if !sa1
		LDX #$81		; don't do IRQ (lated stored to $4200)
	else
		LDA #$81		; don't do IRQ
		STA $4200
	endif
	LDA $22			; update mirrors
	STA $2111
	LDA $23
	STA $2111
	LDA $24
	STA $2112
	LDA $25
	STA $2112
	LDA $3E
	STA $2105
	LDA $40
	STA $2131
	JMP $82B0
	
.special
	JMP $827A	

; Recovered code (and comments) taken from the disassembly.
if !enable_counters
	counters:
		LDA $1493|!base2	;\
		ORA $9D			;| If level is ending or sprites are locked,
		BNE .coins		;/ don't decrement timer, handle it at 00, etc basically, freeze timer if sprites locked
		LDA $0D9B|!base2	;\
		CMP #$C1		;|
		BEQ .coins		;/ if at bowser, do not worry about time running out
		DEC $0F30|!base2	;\ Decrement timer, basically...decrementing the timer's timer, to be exact
		BPL .coins		;/ if it's not to lower the timer, skip time running out and such
		LDA #$28		;\
		STA $0F30|!base2	;/ reset the timer's timer
		LDA $0F31|!base2	;\
		ORA $0F32|!base2	;| If time is 0,
		ORA $0F33|!base2	;| don't handle time running out, since it's already out
		BEQ .coins		;/
		LDX #$02		;\
	-				;|
		DEC $0F31|!base2,x	;|
		BPL +			;| handle decrementing the timer
		LDA #$09		;|
		STA $0F31|!base2,x	;|
		DEX			;|
		BPL -			;/
	+
		LDA $0F31|!base2	;\
		BNE +			;|
		LDA $0F32|!base2	;|
		AND $0F33|!base2	;| If time is 99, 
		CMP #$09		;| speed up the music 
		BNE +			;|
		LDA #$FF		;|
		STA $1DF9|!base2	;/
	+
		LDA $0F31|!base2	;\
		ORA $0F32|!base2	;|
		ORA $0F33|!base2	;| If time is 0,
		BNE .coins		;| run the death routine
		JSL $00F606		;/

	.coins
		LDA $13CC|!base2	; add up coins
		BEQ .bonus_stars
		DEC $13CC|!base2
		INC $0DBF|!base2
		LDA $0DBF|!base2
		CMP #$64		; only give a reward with 100 coins
		BCC .bonus_stars
		INC $18E4|!base2	; REWARD (1UP)
		STZ $0DBF|!base2

	.bonus_stars
		LDX $0DB3|!base2	;> Get bonus stars (X = 0 for Demo, 1 for Iris).
		LDA $0F48|!base2,x	;\
		CMP #$64		;| If bonus stars are less than 100,
		BCC .return		;/ then branch.
		LDA #$FF		;\ Otherwise, start bonus game when the level ends.
		STA $1425|!base2	;/
		LDA $0F48|!base2,x	;\ Zero out bonus stars.
		STZ $0F48|!base2,x	;/

	.return
		RTS
endif

warnpc $009045
