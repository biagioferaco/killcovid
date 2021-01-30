;--------------------------------------------------------------
;- KILLCOVID --------------------------------------------------
;--------------------------------------------------------------

		processor 6502
		org $1000

;--------------------------------------------------------------
; General
clear     = $e544
getin     = $ffe4
scnkey    = $ff9f
joystick2 = $dc00

enter	  = $c202
move	  = $c203

temp0     = $0022
temp1     = $0023

timer1    = $d012

; Sprite 0 Controls
spr0_ptr = $07f8
spr0_x   = $d000
spr0_y   = $d001
spr0_col = $d027

; Sprite 1 Controls
spr1_ptr = $07f9
spr1_x   = $d002
spr1_y   = $d003
spr1_col = $d028

; Others Sprite COntrols
spr_mul_col_en     = $D01C
spr_mul_col_1      = $D025
sprx_msb           = $d010
spr_enable         = $d015
spr_spr_collision  = $d01e

;--------------------------------------------------------------
		; Disable interrupts
		lda #<32768
		sta $0318
		lda #>32768
		sta $0319

		; Clear Screen
		jsr clear

		lda #13
		sta enter

		; Set Background color (Black)
		lda #00
		sta $d021

		;--------------------------------------------------------------
		; Enable Sprite0 and Sprite1
		lda #03
		sta spr_enable

    	; Set Multicolor
		lda #01
		sta spr_mul_col_en

		;--------------------------------------------------------------
		; Initialize Spite 0
		lda #$88
		sta spr0_ptr

		; Set Color for for Sprite 0 (Red)
		lda #03
		sta spr0_col
		;--------------------------------------------------------------

		;--------------------------------------------------------------
		; Initialize Spite 1
		lda #$80
		sta spr1_ptr

		; Set Color for for Sprite 1 (Blue)
		lda #02
		sta spr1_col

		; Set Color 2 for for Sprite 1 (White)
		lda #01
		sta spr_mul_col_1
		;--------------------------------------------------------------

		;--------------------------------------------------------------
		; Starting Point Sprite 1 -- FIXME
		lda sprx_msb
		and #%11111110
		sta sprx_msb

		ldx #100
		ldy #70
		stx spr0_x
		sty spr0_y

		;--------------------------------------------------------------
		; Starting Point Sprite 1 -- FIXME
		lda sprx_msb
		and #%11111101
		sta sprx_msb

		ldx #100
		ldy #70
		stx spr1_x
		sty spr1_y

		;--------------------------------------------------------------
		; Initialize X and Y Direction of Covid
		lda #1
		sta temp0
		sta temp1


;--------------------------------------------------------------
; Main Loop
forever
		jsr siringemovement

		jsr covidmovement

		jsr check_collision

		jmp forever
;--------------------------------------------------------------



;--------------------------------------------------------------
; Siringe Movement
siringemovement

		; Timer Delay
		lda #$0f
		cmp timer1
		bne siringemovement

up
		lda joystick2
		and #1
		bne down

		lda #$8b
		sta spr0_ptr

		ldy spr0_y
		cpy #50
		beq down
		dey
		sty spr0_y

down 	lda joystick2
		and #2
		bne left

		lda #$89
		sta spr0_ptr

		ldy spr0_y
		cpy #229
		beq left
		iny
		sty spr0_y

left
		lda joystick2
		and #4
		bne right

		lda #$8a
		sta spr0_ptr

		lda sprx_msb
		and #%00000001
		cmp #0
		bne bleft1
		ldx spr0_x
		cpx #24
		beq right

bleft1
		ldx spr0_x
		dex
		stx spr0_x
		cpx #255
		bne right
		lda #0
		lda sprx_msb
		and #%11111110
		sta sprx_msb

right
		lda joystick2
		and #8
		bne button

		lda #$88
		sta spr0_ptr

		lda sprx_msb
		and #%00000001
		cmp #1
		bne bright1
		ldx spr0_x
		cpx #65
		beq button

bright1
		ldx spr0_x
		inx
		stx spr0_x
		cpx #255
		bne button
		lda sprx_msb
		ora #%00000001
		sta sprx_msb

button
		lda joystick2
		and #16

		bne toend
		jmp end

toend   rts
;--------------------------------------------------------------

;--------------------------------------------------------------
; Covid Movement
covidmovement
		ldy spr1_y
		cpy #50
		bne nexty1
		lda #1
		sta temp1
nexty1
		cpy #229
		bne nexty2
		lda #0
		sta temp1

nexty2
		ldy spr1_y
		lda temp1
		cmp #1
		bne nexty3
		iny
		jmp nexty4
nexty3
		dey

nexty4
		sty spr1_y

		lda sprx_msb
		and #%00000010
		cmp #0
		bne nextx1

		ldx spr1_x
		cpx #24
		bne nextx2

		ldy temp0
		cpy #0
		bne nextx2

		lda #1
		sta temp0
		jmp nextx2

nextx1
		ldx spr1_x
		cpx #64
		bne nextx2

		ldy temp0
		cpy #1
		bne nextx2

		lda #0
		sta temp0

nextx2
		ldx spr1_x
		lda temp0
		cmp #1
		bne nextx3

		cpx #255
		bcc nextx41

		lda sprx_msb
		ora #%00000010
		sta sprx_msb

nextx41
		inx
		stx spr1_x
		jmp nextx4

nextx3
		cpx #1
		bcs nextx42

		lda sprx_msb
		and #%11111101
		sta sprx_msb

nextx42
		dex
		stx spr1_x

nextx4
		rts
;--------------------------------------------------------------

;--------------------------------------------------------------
; Collision
check_collision
		lda spr_spr_collision
		cmp #0
		beq check_collision_end

		; Generate Random Value
		lda timer1
		eor $dc04
		sbc $dc05

		sta spr1_x

		lda sprx_msb   ; FIXME
		and #%11111101
		sta sprx_msb

		; Generate Random Value
		lda timer1
		eor $dc04
		sbc $dc05

		sta spr1_y

check_collision_end
		rts
;--------------------------------------------------------------

;--------------------------------------------------------------
; Clean up at the end
end
		jsr clear
		lda #0
		sta spr_enable
		rts

;--------------------------------------------------------------
		; Include Generated list of Sprites
		org $2000-2
		incbin "Sprites.prg"
;--------------------------------------------------------------
