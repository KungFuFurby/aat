;=====================================
; All these routines are called in 8-bit A/X/Y mode and DBR is already set.
; Don't worry about overwriting registers, they'll be restored afterwards (except for direct page :P).
; All the routines must end with rts.
;=====================================

;=====================================
; This routine will be called when loading the title screen.
; It can be used to reset particular RAM addresses for a new save file (see "docs/sram_info.txt").
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
load_title:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called when the level is reset by the retry system or when entering from the overworld.
; Unlike UberASM level init routine, this won't be executed during regular level transitions.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
reset:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be executed everytime the player dies.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
death:
    ; Feel free to put your code here.



    ; Code to reset some stuff related to lx5's Custom Powerups.
    ; You shouldn't need to edit this.
if !custom_powerups == 1
    stz.w ($170B|!addr)+$08
    stz.w ($170B|!addr)+$09
    lda #$00 : sta !projectile_do_dma

    ldx #$07
-   lda $170B|!addr,x : cmp #$12 : bne +
    stz $170B|!addr,x
+   dex : bpl -
    
    lda !item_box_disable : ora #$02 : sta !item_box_disable
endif

    rts

;=====================================
; This routine will be called every time the player touches a midway (vanilla or custom midway object).
; NOTE: on SA-1 roms, this runs on the SA-1 cpu.
;=====================================
midway:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time the player gets a checkpoint through a room transition.
; Remember you can check for $13BF and $010B to know in which trans/sub-level you are.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
room_checkpoint:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time the player selects "exit" on the retry prompt.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
prompt_exit:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time the game is saved (before anything gets saved).
; Remember that you can check for the current save file in $010A.
; NOTE: on SA-1 roms, this may run on either cpu depending on what's calling the save routine.
;=====================================
save_file:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time an existing save file is loaded (before anything gets loaded).
; Remember that you can check for the current save file in $010A.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
load_file:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time a new save file is loaded (before anything gets reset).
; Remember that you can check for the current save file in $010A.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
load_new_file:
    ; Feel free to put your code here.


    
    rts

;=====================================
; This routine will be called during the game over screen.
; This is called after the save file data is loaded from SRAM (only the data put before ".not_game_over" in "tables.asm") but before all the data is saved again to SRAM.
; This can be useful if you want to initialize some addresses for the game over and/or have them saved to SRAM.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
game_over:
    ; Feel free to put your code here.


    
    rts

;=====================================
; This routine will be called when Mario enters a door, every frame during the fade out.
; This could be useful since the door animation is the only one that can't be intercepted
; with level ASM or sprite ASM (since it immediately goes to the fading gamemode).
; If you need some level-specific action here, you can check the sublevel number in $010B (16 bit).
; If you need to only run the code for 1 frame, you can check for $0DB0 equal to 0.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
door_animation:
    ; Feel free to put your code here.


    
    rts

;=====================================
; This routine will be called at the end of the game loop during gamemodes 7 and 14 (title screen and levels),
; just before Retry draws the prompt and AddmusicK's code runs.
; If you have other patches that hijack $00A2EA, you could try to put their freespace code in this routine to solve the conflict.
; NOTE: this runs at the end of the level frame in each level. If you want to run level-specific code, see "level_end_frame.asm".
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
gm14_end:
	; Feel free to put your code here.
	LDA $13E6|!addr		;\
	CMP #$01			;| If the status bar is disabled in the level,
	BEQ +				;/ then branch.
	JSR custom_bar
+
	RTS

;=====================================
; Subroutine to draw the custom status bar.
; Note that we cannot run this during the normal GM14.asm code,
; as sprite tiles cannot be drawn because $7F8000 is called
; shortly after their main code.
;=====================================

!NumTilesMax = $1E		;> Full status bar ($1E = 30 tiles)
!NumTilesMin = $0E		;> Minimal status bar ($0E = 14 tiles)
!Offset = $1010			;> YYXX

custom_bar:
	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDA $13E6|!addr		;\ Determine number of tiles to draw based on status bar type.
	CMP #$02			;/ Y is an input parameter for call to MaxTile.
	BEQ +
	LDY.b #$00+(!NumTilesMax)
	BRA ++
+
	LDY.b #$00+(!NumTilesMin)
++
	REP #$30			;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000		;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0			;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
						;| Returns 16-bit pointer to the OAM general buffer in $3100.
						;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return			;\ Carry clear: Failed to get OAM slots, abort.
						;/ ...should never happen, since this will be executed before sprites, but...
	JSR draw_custom_bar
.return
	SEP #$30
	RTS

draw_custom_bar:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100			;> Main index (16-bit pointer to the OAM general buffer)
	SEP #$20
	LDA $13E6|!addr		;\ Load the loop index depending on status bar type.
	CMP #$02			;/
	BEQ +
	LDY.w #$0000+((!NumTilesMax-1)*2)
	BRA ++
+
	LDY.w #$0000+((!NumTilesMin-1)*2)
++
	REP #$20
-
	LDA TileCoord,y		;\ Load tile X and Y coordinates
	CLC					;| Add offset for the entire status bar.
	ADC #!Offset		;|
	;PHY
	;PHX
	;SEP #$30
	;JSR offsets
	;REP #$30
	;PLX
	;PLY
	STA $400000,x		;/

	LDA TileProps,y		;> Load tile properties.
	PHY					;\
	PHX					;| Need to be in 8-bit mode for the following subroutine.
	SEP #$30			;| Note that the high byte of A will remain preserved,
	JSR counters		;| while the high bytes of X and Y will be cleared.
	REP #$30			;| This shouldn't matter for X and Y if they only contain 8-bit values.
	PLX					;| The subroutine returns the updated tile number in the low byte of A.
	PLY					;/
	STA $400002,x

	INX #4				;\
	DEY #2				;| Move to next slot and loop
	BPL -				;/

	; OAM extra bits
	LDX $3102			;> Bit table index (16-bit pointer to the OAM attribute buffer)
	SEP #$20
	LDA $13E6|!addr		;\ Load the loop index depending on status bar type.
	CMP #$02			;/
	BEQ +
	LDY.w #$0000+((!NumTilesMax-2))
	BRA ++
+
	LDY.w #$0000+((!NumTilesMin-2))
++
	REP #$20
-
	LDA TileExtra,y		;\ Store extra bits for two tiles at a time.
	STA $400000,x		;/ 

	INX #2				;\
	DEY #2				;| Loop to set the remaining OAM extra bits.
	BPL -				;/

	PLB
	RTS

offsets:
	PHA
	LDA $13E6|!addr
	CMP #$02
	BNE +
	PLA
	CPY #$08
	BEQ ++
	CPY #$0A
	BEQ ++
	CPY #$0C
	BEQ ++
	CPY #$0E
	BEQ ++
	CPY #$10
	BEQ ++
	CPY #$12
	BEQ ++
	CPY #$14
	BEQ +++
	CPY #$16
	BEQ +++
	CPY #$18
	BEQ +++
	CPY #$1A
	BNE .return
+++
	XBA
	SEC
	SBC #$04
	XBA
	BRA .return
++
	XBA
	CLC
	ADC #$04
	XBA
	BRA .return
+
	PLA
.return
	RTS

counters:
	CPY #$00			;> Demo/Iris head
	BNE +
	LDA $19				;\ Print a different head based on the current powerup.
	STA $7FC070			;/ Uses Manual 0 Global ExAnimation trigger.
	LDA #$44
	XBA					;\ Since A is overwritten here,
	LDA #$30			;| need to put the properties
	XBA					;/ in the high byte.
+
	CPY #$04			;> Lives counter (tens digit)
	BNE +
	JSR lives
	STX $00
	JSR convert_digit
	JMP .return
+
	CPY #$06			;> Lives counter (ones digit)
	BNE +
	JSR lives
	STA $00
	JSR convert_digit
	JMP .return
+
	CPY #$08			;> Dragon Coin #1
	BNE +
	JSR dragon_coin_check
	BNE +++
	LDA $1420|!addr		;> Load Dragon Coins collected for the current level.
	CMP #$01
	BCC ++
+++
	LDA #$46
	JMP .return
++
	LDA #$47
	JMP .return
+
	CPY #$0A			;> Dragon Coin #2
	BNE +
	JSR dragon_coin_check
	BNE +++
	LDA $1420|!addr		;> Load Dragon Coins collected for the current level.
	CMP #$02
	BCC ++
+++
	LDA #$46
	JMP .return
++
	LDA #$47
	JMP .return
+
	CPY #$0C			;> Dragon Coin #3
	BNE +
	JSR dragon_coin_check
	BNE +++
	LDA $1420|!addr		;> Load Dragon Coins collected for the current level.
	CMP #$03
	BCC ++
+++
	LDA #$46
	JMP .return
++
	LDA #$47
	JMP .return
+
	CPY #$0E			;> Dragon Coin #4
	BNE +
	JSR dragon_coin_check
	BNE +++
	LDA $1420|!addr		;> Load Dragon Coins collected for the current level.
	CMP #$04
	BCC ++
+++
	LDA #$46
	JMP .return
++
	LDA #$47
	JMP .return
+
	CPY #$10			;> Dragon Coin #5
	BNE +
	JSR dragon_coin_check
	BNE +++
	LDA $1420|!addr		;> Load Dragon Coins collected for the current level.
	CMP #$05
	BCC ++
+++
	LDA #$46
	JMP .return
++
	LDA #$47
	JMP .return
+
	CPY #$18			;> Bonus stars counter (tens digit)
	BNE +
	JSR bonus_stars
	STX $00
	JSR convert_digit
	JMP .return
+
	CPY #$1A			;> Bonus stars counter (ones digit)
	BNE +
	JSR bonus_stars
	STA $00
	JSR convert_digit
	JMP .return
+
	CPY #$1E			;> Timer (hundreds digit)
	BNE +
	JSR timer
	JSR convert_digit
	JMP .return
+
	CPY #$20			;> Timer (tens digit)
	BNE +
	JSR timer
	LDA $01
	STA $00
	JSR convert_digit
	JMP .return
+
	CPY #$22			;> Timer (ones digit)
	BNE +
	JSR timer
	LDA $02
	STA $00
	JSR convert_digit
	JMP .return
+
	CPY #$28			;> Coin counter (tens digit)
	BNE +
	JSR coins
	STX $00
	JSR convert_digit
	JMP .return
+
	CPY #$2A			;> Coin counter (ones digit)
	BNE +
	JSR coins
	STA $00
	JSR convert_digit
	JMP .return
+
	CPY #$2C			;\
	BEQ ++				;|
	CPY #$2E			;| Death counter ("demos")
	BEQ ++				;|
	CPY #$30			;|
	BEQ ++				;|
	CPY #$32			;/
	BNE +
++
	PHA
	LDA $0DB3|!addr
	BEQ ++
	PLA
	XBA
	LDA #$3A			;> If Iris, use palette row D.
	XBA
	JMP .return
++
	PLA
	XBA
	LDA #$36			;> If Demo, use palette row B.
	XBA
	JMP .return
+
	CPY #$34			;> Death counter (1,000s digit)
	BNE +
	JSR deaths
	LDA $0A
	STA $00
	JSR convert_digit
	JMP .return
+
	CPY #$36			;> Death counter (100s digit)
	BNE +
	JSR deaths
	STX $00
	JSR convert_digit
	JMP .return
+
	CPY #$38			;> Death counter (10s digit)
	BNE +
	JSR deaths
	STY $00
	JSR convert_digit
	JMP .return
+
	CPY #$3A			;> Death counter (1s digit)
	BNE +
	JSR deaths
	STA $00
	JSR convert_digit
	JMP .return
+
.return
	RTS

digits:
	db $20,$21,$22,$23	;> 0, 1, 2, 3
	db $30,$31,$32,$33	;> 4, 5, 6, 7
	db $38,$39			;> 8, 9

convert_digit:
	LDY $00				;> Load the digit, stored to $00 by the counters subroutine.
	CPY #$0A			;\ If greater than 9,
	BCS .default		;/ then print the default tile.
	LDA digits,y		;> Otherwise, load the digit's tile number.
	BRA .return
.default
	LDA #$0A			;> The default tile is blank.
.return
	XBA					;\ Put the tile properties in the high byte,
	LDA #$30			;| just in case it was overwritten (e.g., by
	XBA					;/ the HexToDecSuper subroutine).
	RTS

lives:
	LDA $0DBE|!addr		;\ Load current player's lives.
	INC A				;/ SMW indexes from zero, so need to add one here to account for that.
	JSL $00974C			;> HexToDec function (returns ones digit in A and tens digit in X)
	CPX #$00			;\ Print a blank tile instead of a leading zero.
	BEQ +				;/
	BRA .return
+
	LDX #$0A
.return
	RTS

timer:
	LDA $0F31|!addr		;> Load hundreds digit of timer
	BNE +				;> If it's not a zero, then branch.
	LDA #$0A			;> Otherwise, print a blank tile instead of a leading zero.
+
	STA $00
	LDA $0F32|!addr		;> Load tens digit of timer
	STA $01
	BNE +				;> If it's not a zero, then branch.
	LDA $00				;\ Otherwise, check if the hundreds digit was also
	CMP #$0A			;/ a zero (in this case, a blank tile).
	BNE +				;> If not, then branch.
	STA $01				;> Otherwise, print a blank tile instead of a leading zero.
+
	LDA $0F33|!addr		;> Load ones digit of timer
	STA $02
	RTS

coins:
	LDA $0DBF|!addr		;> Load current player's coins.
	JSL $00974C			;> HexToDec function (returns ones digit in A and tens digit in X)
	CPX #$00			;\ Print a blank tile instead of a leading zero.
	BEQ +				;/
	BRA .return
+
	LDX #$0A
.return
	RTS

bonus_stars:
	LDA $0DB3|!addr
	BNE .iris
	LDA $0F48|!addr		;> Load Demo's bonus stars.
	BRA +
.iris
	LDA $0F49|!addr		;> Load Iris' bonus stars.
+
	JSL $00974C			;> HexToDec function (returns ones digit in A and tens digit in X)
	CPX #$00			;\ Print a blank tile instead of a leading zero.
	BEQ +				;/
	BRA .return
+
	LDX #$0A
.return
	RTS

deaths:
	LDA $010A|!addr		;\
	ASL					;| Load the current save file number and put it in X.
	CLC					;| X is the offset for the Demo counter of the current save.
	ADC $010A|!addr		;|
	TAX					;/
	REP #$20			;> For the following subroutine: A = 16-bit, XY = 8-bit
	LDA $41C7ED,x		;> Load the first two bytes of the Demo counter as input.
	CMP #$2710			;> Check for 9,999 deaths.
	BCC +				;> If less than 9,999 deaths, then update the counter normally.
	SEP #$20			;\
	LDA #$09			;| Otherwise, cap the counter display at 9,999
	TAY					;| in order to prevent rollover. Need to restore A
	TAX					;| to 8-bit mode here since that would've otherwise
	STA $0A				;| been done in the HexToDecSuper subroutine.
	BRA .return			;/
+
	JSR HexToDecSuper	;> Note: The high byte of the Demo counter is not used here.

	; Handle leading zeroes.
	PHA					;> Preserve the 1s digit.
	LDA $0A				;> Load 1000s digit of death counter.
	BNE +				;> If it's not a zero, then branch.
	LDA #$0A			;\ Otherwise, print a blank tile instead of a leading zero.
	STA $0A				;/
+
	CPX #$00			;\ If the 100s digit of death counter
	BNE +				;/ is not a zero, then branch.
	LDA $0A				;\ Otherwise, check if the 1000s digit was also
	CMP #$0A			;/ a zero (in this case, a blank tile).
	BNE +				;> If not, then branch.
	TAX					;> Otherwise, print a blank tile instead of a leading zero.
+
	CPY #$00			;\ If the 10s digit of death counter
	BNE +				;/ is not a zero, then branch.
	CPX #$0A			;> Otherwise, check if the 100s digit was also a zero (in this case, a blank tile).
	BNE +				;> If not, then branch.
	LDA $0A				;\ Otherwise, check if the 1000s digit was also
	CMP #$0A			;/ a zero (in this case, a blank tile).
	BNE +				;> If not, then branch.
	TAY					;> Otherwise, print a blank tile instead of a leading zero.
+
	PLA					;> Restore the 1s digit.

.return
	RTS

; Check if all Dragon Coins had been collected in a level. Returns A = 0 if true.
; Needed for when the player exits and reenters a level with all Dragon Coins collected.
; Adapted from PassableOnAllDragonCoins.asm block.
dragon_coin_check:
	LDA.W $13BF|!addr              
	LSR #3                    
	TAY                       
	LDA.W $13BF|!addr              
	AND.B #$07                
	TAX                       
	LDA.W $1F2F|!addr,Y             
	AND.L $0DA8A6|!bank,X
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HexToDecSuper: Convert a 16-bit hexadecimal
;                value to decimal.
;
; Input:
; -A = 16-bit value to convert
; -8-bit XY (m = 0, x = 1)
;
; Output:
; -A = 1s digit of the original number
; -Y = 10s digit of the original number
; -X = 100s digit of the original number
; -$0A = 1000s digit of the original number
; -$0B = 10000s digit of the original number
; -8-bit AXY (m = 1, x = 1)
;
; Sources: https://smwc.me/427749
;          https://smwc.me/1031342
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HexToDecSuper:
	STZ $0A
	STZ $0B
	LDY #$00
	LDX #$00

.StartCompare4
	CMP #$2710
	BCC .StartCompare5
	SBC #$2710
	INC $0B
	BRA .StartCompare4

.StartCompare5
	CMP #$03E8
	BCC .StartCompare6
	SBC #$03E8
	INC $0A
	BRA .StartCompare5

.StartCompare6
	CMP #$0064
	BCC .StartCompare7
	SBC #$0064
	INX
	BRA .StartCompare6

.StartCompare7
	CMP #$000A
	BCC .FinishHTD3
	SBC #$000A
	INY
	BRA .StartCompare7

.FinishHTD3
	SEP #$20
	RTS

TileCoord:						; YYXX
	dw $0000,$0410,$0418,$0420	; Lives counter
	dw $0030,$0038,$0040,$0048	; Dragon coins
	dw $0050,$0058				; Dragon coins (continued)
	dw $0834,$083C,$0844,$084C	; Bonus star counter
	dw $0088,$0090,$0098,$00A0	; Timer
	dw $0888,$0890,$0898,$08A0	; Coin counter
	dw $00B4,$00BC,$00C4,$00CC	; Death counter ("demos")
	dw $08B4,$08BC,$08C4,$08CC	; Death counter (digits)

; Y index starts from 58 (decimal), then decrements by 2 each time
TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $3044,$3029,$300A,$300A	; Lives counter				indices 00-06
	dw $300A,$300A,$300A,$300A	; Dragon coins				indices 08-0E
	dw $300A,$300A				; Dragon coins (continued)	indices 10-12
	dw $30EF,$3029,$300A,$300A	; Bonus star counter		indices 14-1A
	dw $307E,$3023,$300A,$300A	; Timer						indices 1C-22
	dw $3046,$3029,$300A,$300A	; Coin counter				indices 24-2A
	dw $360C,$360D,$361A,$361B	; Death counter ("demos")	indices 2C-32
	dw $300A,$300A,$300A,$300A	; Death counter (digits)	indices 34-3A

; Y index starts from 28 (decimal), then decrements by 2 each time
TileExtra:						; High byte = first tile, low byte = second tile
	dw $0200,$0000				; Lives counter				indices 00-02
	dw $0000,$0000				; Dragon coins				indices 04-06
	dw $0000					; Dragon coins (continued)	indices 08-09
	dw $0000,$0000				; Bonus star counter		indices 0A-0C
	dw $0000,$0000				; Timer						indices 0E-10
	dw $0000,$0000				; Coin counter				indices 12-14
	dw $0000,$0000				; Death counter	("demos")	indices 16-18
	dw $0000,$0000				; Death counter (digits)	indices 1A-1C
