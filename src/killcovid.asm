//--------------------------------------------------------------
//- KILLCOVID --------------------------------------------------
//--------------------------------------------------------------
.cpu _65c02
.pc= $1000

//--------------------------------------------------------------
// General
.label clear              = $e544
.label getin              = $ffe4
.label scnkey             = $ff9f
.label joystick2          = $dc00

.label enter              = $c202
.label move               = $c203

.label temp0              = $0022
.label temp1              = $0023

.label points1            = $0024
.label points2            = $0025

.label timer1             = $d012

.label border             = $d020
.label backgrd            = $d021
.label textcolor          = $0286

.label screen_ram         = $0400

// Sprite 0 Controls
.label spr0_ptr           = $07f8
.label spr0_x             = $d000
.label spr0_y             = $d001
.label spr0_col           = $d027

// Sprite 1 Controls
.label spr1_ptr           = $07f9
.label spr1_x             = $d002
.label spr1_y             = $d003
.label spr1_col           = $d028

// Others Sprite Controls
.label spr_mul_col_en     = $D01C
.label spr_mul_col        = $D025
.label sprx_msb           = $d010
.label spr_enable         = $d015
.label spr_spr_collision  = $d01e


		//--------------------------------------------------------------
		// Disable interrupts
		lda #<32768
		sta $0318
		lda #>32768
		sta $0319

		// Clear Screen
		jsr clear

		lda #13
		sta enter

		// Set Background color (Black), Border (Red) and Text (White)
		lda #00
		sta backgrd
		lda #02
		sta border
		lda #$01
		sta textcolor
		jsr clear

		//Initial Message

		ldx #$00
killcovidmessage:
		lda killcovid,x
		sta screen_ram+8+11*40,x
		inx
		cpx #$09
		bne killcovidmessage

		ldx #$00
		ldy #$00
buttonmessage:
		lda press_message,x
		sta screen_ram+8+16*40,x
		inx
		cpx #$10
		bne buttonmessage

		//--------------------------------------------------------------
		// Enable Sprite1
		lda #02
		sta spr_enable

		//--------------------------------------------------------------
		// Initialize Spite 1
		lda #$80
		sta spr1_ptr

		// Set Color for for Sprite 1 (Red)
		lda #02
		sta spr1_col

		//--------------------------------------------------------------
		// Starting Point Sprite 1 -- FIXME
		lda sprx_msb
		and #%11111101
		sta sprx_msb

		ldx #190
		ldy #80
		stx spr1_x
		sty spr1_y

		//--------------------------------------------------------------
		// Initialize X and Y Direction of Covid
		lda #1
		sta temp0
		sta temp1

waitforstart:

		// Timer Delay
		lda #$0f
		cmp timer1
		bne waitforstart

		jsr covidmovement_simple

		lda joystick2
		and #16
		bne waitforstart

start:
		// Clear Screen
		jsr clear

		lda #13
		sta enter

		//--------------------------------------------------------------
		// Enable Sprite0 and Sprite1
		lda #03
		sta spr_enable

		// Set Multicolor
		lda #01
		sta spr_mul_col_en

		//--------------------------------------------------------------
		// Initialize Spite 0
		lda #$88
		sta spr0_ptr

		// Set Color for for Sprite 0 (Blue)
		lda #03
		sta spr0_col

		// Set Color 2 for for Sprite 0 (White)
		lda #01
		sta spr_mul_col
		//--------------------------------------------------------------

		//--------------------------------------------------------------
		// Initialize Spite 1
		lda #$80
		sta spr1_ptr

		// Set Color for for Sprite 1 (Red)
		lda #02
		sta spr1_col

		//--------------------------------------------------------------

		//--------------------------------------------------------------
		// Starting Point Sprite 0 -- FIXME
		lda sprx_msb
		and #%11111110
		sta sprx_msb

		ldx #190
		ldy #80
		stx spr0_x
		sty spr0_y

		//--------------------------------------------------------------
		// Starting Point Sprite 1 -- FIXME
		lda sprx_msb
		and #%11111101
		sta sprx_msb

		ldx #100
		ldy #70
		stx spr1_x
		sty spr1_y

		//--------------------------------------------------------------
		// Initialize X and Y Direction of Covid
		lda #1
		sta temp0
		sta temp1

		//--------------------------------------------------------------
		// Initialize Points
		lda #'1'
		sta points1
		lda #'0'
		sta points2

//--------------------------------------------------------------
// Main Loop
		jsr score
forever:
		jsr siringemovement

		jsr covidmovement

		jsr check_collision

		jmp forever
//--------------------------------------------------------------


//--------------------------------------------------------------
// Siringe Movement
siringemovement:

		// Timer Delay
		lda #$0f
		cmp timer1
		bne siringemovement

up:
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

down:
		lda joystick2
		and #2
		bne left

		lda #$89
		sta spr0_ptr

		ldy spr0_y
		cpy #229
		beq left
		iny
		sty spr0_y

left:
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

bleft1:
		ldx spr0_x
		dex
		stx spr0_x
		cpx #255
		bne right
		lda #0
		lda sprx_msb
		and #%11111110
		sta sprx_msb

right:
		lda joystick2
		and #8
		bne toend

		lda #$88
		sta spr0_ptr

		lda sprx_msb
		and #%00000001
		cmp #1
		bne bright1
		ldx spr0_x
		cpx #65
		beq toend

bright1:
		ldx spr0_x
		inx
		stx spr0_x
		cpx #255
		bne toend
		lda sprx_msb
		ora #%00000001
		sta sprx_msb

toend:
		rts
//--------------------------------------------------------------

//--------------------------------------------------------------
// Covid Movement
covidmovement:
		ldy spr1_y
		cpy #50
		bne nexty1

		// Change direction (Down) and increase RT
		lda #1
		sta temp1
		jsr incpoint
		jsr score

nexty1:
		cpy #229
		bne nexty2

		// Change direction (Up) and increase RT
		lda #0
		sta temp1
		jsr incpoint
		jsr score

nexty2:
		ldy spr1_y
		lda temp1
		cmp #1
		bne nexty3
		iny
		jmp nexty4
nexty3:
		dey
nexty4:
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

		// Change direction (Right) and increase RT
		lda #1
		sta temp0
		jsr incpoint
		jsr score

		jmp nextx2

nextx1:
		ldx spr1_x
		cpx #64
		bne nextx2

		ldy temp0
		cpy #1
		bne nextx2

		// Change direction (Left) and increase RT
		lda #0
		sta temp0
		jsr incpoint
		jsr score

nextx2:
		ldx spr1_x
		lda temp0
		cmp #1
		bne nextx3

		cpx #255
		bcc nextx41

		lda sprx_msb
		ora #%00000010
		sta sprx_msb

nextx41:
		inx
		stx spr1_x
		jmp nextx4

nextx3:
		cpx #1
		bcs nextx42

		lda sprx_msb
		and #%11111101
		sta sprx_msb

nextx42:
		dex
		stx spr1_x

nextx4:
		rts
//--------------------------------------------------------------

//--------------------------------------------------------------
// Covid Movement no Points
covidmovement_simple:
		ldy spr1_y
		cpy #50
		bne nexty1s

		// Change direction (Down)
		lda #1
		sta temp1

nexty1s:
		cpy #229
		bne nexty2s

		// Change direction (Up)
		lda #0
		sta temp1

nexty2s:
		ldy spr1_y
		lda temp1
		cmp #1
		bne nexty3s
		iny
		jmp nexty4s
nexty3s:
		dey
nexty4s:
		sty spr1_y

		lda sprx_msb
		and #%00000010
		cmp #0
		bne nextx1s

		ldx spr1_x
		cpx #24
		bne nextx2s

		ldy temp0
		cpy #0
		bne nextx2s

		// Change direction (Right)
		lda #1
		sta temp0

		jmp nextx2s

nextx1s:
		ldx spr1_x
		cpx #64
		bne nextx2s

		ldy temp0
		cpy #1
		bne nextx2s

		// Change direction (Left)
		lda #0
		sta temp0

nextx2s:
		ldx spr1_x
		lda temp0
		cmp #1
		bne nextx3s

		cpx #255
		bcc nextx41s

		lda sprx_msb
		ora #%00000010
		sta sprx_msb

nextx41s:
		inx
		stx spr1_x
		jmp nextx4s

nextx3s:
		cpx #1
		bcs nextx42s

		lda sprx_msb
		and #%11111101
		sta sprx_msb

nextx42s:
		dex
		stx spr1_x

nextx4s:
		rts
//--------------------------------------------------------------



//--------------------------------------------------------------
// Collision
check_collision:
		lda spr_spr_collision
		cmp #0
		beq check_collision_end

		lda #$81
		sta spr1_ptr

		ldy #$81

		// Nested Timing Loop For Animation
loop1:
		ldx #0
loop2:
		lda #$ff
		cmp timer1
		bne loop2
		inx
		cpx #$0f
		bne loop2
		iny
		sty spr1_ptr
		cpy #$85
		bne loop1

		// Generate Random Value X
		lda timer1
		eor $dc04
		sbc $dc05

		sta spr1_x

		lda sprx_msb   // FIXME
		and #%11111101
		sta sprx_msb

		// Generate Random Value Y
		lda timer1
		eor $dc04
		sbc $dc05

		sta spr1_y

		// Reset Initial Pointer to Sprite 1
		lda #$80
		sta spr1_ptr

		// Clear Interrput Register
		lda spr_spr_collision

		// Increase Points
		jsr decpoint

		jsr score

check_collision_end:
		rts
//--------------------------------------------------------------

//--------------------------------------------------------------
// Score Update
score:
		ldx #$00         //using x register as column counter
print:
		lda rt_index,x   //load a with x bit from message
		sta screen_ram,x //store this bit in row 0 col 0 address
		inx              //x++
		cpx #$09         //is x >= 9?
		bne print        //if not x >= 9, loop again
		lda points1
		sta screen_ram,x
		inx
		lda #'.'
		sta screen_ram,x
		lda points2
		inx
		sta screen_ram,x
		rts

incpoint:
		ldx points1
		ldy points2
		cpx #'1'
		bne inczerocheck
		cpy #'9'
		beq inctwo
		iny
		jmp incload
inctwo:
		ldx #'0'
		ldy #'2'
		stx points1
		sty points2
		jmp end

inczerocheck:
		cpy #'9'
		bne incdecimal
		inx
		ldy #'0'
		jmp incload
incdecimal:
		iny
incload:
		stx points1
		sty points2
		rts

decpoint:
		ldx points1
		ldy points2
		cpx #'1'
		bne deczerocheck
		cpy #'0'
		beq decone
		dey
		jmp decload
decone:
		ldx #'0'
		ldy #'9'
		jmp decload

deczerocheck:
		cpy #'0'
		bne deczero
		ldx #'0'
		ldy #'0'
		jmp decload
deczero:
		dey
decload:
		stx points1
		sty points2
		rts

//--------------------------------------------------------------
// Clean up at the end
end:
		jsr clear
		lda #0
		sta spr_enable

		ldx #$00                    //using x register as column counter
printgameover:
		lda gameover,x              //load a with x bit from message
		sta screen_ram+8+11*40,x    //store this bit in row 0 col 0 address
		inx                         //x++
		cpx #$08                    //is x >= 7?
		bne printgameover           //if not x >= 7, loop again

playagain:
		lda joystick2
		and #16
		bne playagain
		jmp start

//--------------------------------------------------------------
		// Include Generated list of Sprites
		.pc= $2000-2

		// Load the file into the variable ’data’
		.var data = LoadBinary("Sprites.prg")

		// Dump the data to the memory
		myData: .fill data.getSize(), data.get(i)

//--------------------------------------------------------------

killcovid:     .text "killcovid"

press_message: .text "press the button"

rt_index:      .text "rt-index "

gameover:      .text "gameover"
