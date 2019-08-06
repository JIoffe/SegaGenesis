*-----------------------------------------------------------
* Title      : 'HELLO WORLD' - Push Buttons, Change Colors
* Written by : Jason Ioffe
* Date       :
* Description: A very simple but fully functioning ROM
*              - Changes background color when pressing ABC
*-----------------------------------------------------------

*==============================================================
* Constants for Genesis
*==============================================================
ram_start               EQU $FF0000
ram_end                 EQU $FFFFFF

* Send interrupt enable/disable to sr
interrupts_enable       EQU $2000
interrupts_disable      EQU $2700

*-------------------------------
* Controls
*-------------------------------
joypad_1_data           EQU $00A10003
joypad_2_data           EQU $00A10005
joypad_x_data           EQU $00A10007
joypad_1_control        EQU $00A10009
joypad_2_control        EQU $00A1000B
joypad_x_control        EQU $00A1000D

* button bitflags
joypad_up               EQU $01
joypad_down             EQU $02
joypad_left             EQU $04
joypad_right            EQU $08
joypad_b                EQU $10
joypad_c                EQU $20
joypad_a                EQU $40
joypad_start            EQU $80


* Note on VDP: Color is X B G R
* VDP port addresses
vdp_control             EQU $00C00004
vdp_data                EQU $00C00000
vdp_register_count      EQU $12 ;18 in decimal!

* VDP Access Commands
; VDP access modes
vdp_cram_read           EQU $20000000
vdp_cram_write          EQU $C0000000
vdp_vram_read           EQU $00000000
vdp_vram_write          EQU $40000000
vdp_vsram_read          EQU $10000000
vdp_vsram_write         EQU $14000000
    
* VDP Screen width and height (in pixels)
vdp_screen_width        EQU $0140
vdp_screen_height       EQU $00F0

*==============================================================
* Memory Map for this ROM
*==============================================================
mem_start               EQU $FFFF0000
frame_state             EQU $FFFF0000       ;LONG
frame_counter           EQU $FFFF0004       ;LONG

MEM_buttons_held        EQU $FFFF0008       ;WORD
MEM_buttons_pressed     EQU $FFFF000A       ;WORD

*==================================
* Flags
*==================================
vblank_on_flag          EQU $00000001

*-----------------------------------------------------------
* CPU VECTORS
* These give the runtime some hints and must be first (address 0)
*-----------------------------------------------------------
	dc.l	$FFFFFE00		; Stack pointer
	dc.l	Main			; Code start
	dc.l	HandleException	; Bus error
	dc.l	HandleException	; Address error
	dc.l	HandleException	; Illegal instruction
	dc.l	HandleException	; Divistion by zero
	dc.l	HandleException	; CHK exception
	dc.l	HandleException	; TRAPV exception
	dc.l	HandleException	; Privilege violation
	dc.l	HandleException	; TRACE exeption
	dc.l	NotHandled	    ; Line 1010 emulator
	dc.l	NotHandled	    ; Line 1111 emulator
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Spurious exception
	dc.l	NotHandled	    ; Interrupt request level 1 (lowest priority)
	dc.l	NotHandled	    ; Interrupt request level 2 (external interrupt)
	dc.l	NotHandled	    ; Interrupt request level 3
	dc.l	HBlank			; Interrupt request level 4 (VDP interrupt/HBlank)
	dc.l	NotHandled	    ; Interrupt request level 5
	dc.l	VBlank			; Interrupt request level 6 (VDP interrupt/VBlank)
	dc.l	NotHandled	    ; Interrupt request level 7 (highest priority)
	dc.l	NotHandled	    ; TRAP #00 exception
	dc.l	NotHandled	    ; TRAP #01 exception
	dc.l	NotHandled	    ; TRAP #02 exception
	dc.l	NotHandled	    ; TRAP #03 exception
	dc.l	NotHandled	    ; TRAP #04 exception
	dc.l	NotHandled	    ; TRAP #05 exception
	dc.l	NotHandled	    ; TRAP #06 exception
	dc.l	NotHandled	    ; TRAP #07 exception
	dc.l	NotHandled	    ; TRAP #08 exception
	dc.l	NotHandled	    ; TRAP #09 exception
	dc.l	NotHandled	    ; TRAP #10 exception
	dc.l	NotHandled	    ; TRAP #11 exception
	dc.l	NotHandled	    ; TRAP #12 exception
	dc.l	NotHandled	    ; TRAP #13 exception
	dc.l	NotHandled	    ; TRAP #14 exception
	dc.l	NotHandled	    ; TRAP #15 exception
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
    
*----------------------------------------------
* Sega Genesis ROM Metadata
* (Reference: https://en.wikibooks.org/wiki/Genesis_Programming)
* ---------------------------------------------
	dc.b	'SEGA GENESIS    '	; console name
	dc.b	'(C)JIOFF'	        ; copyright
 	dc.b	'2019.AUG'			; date
	dc.b	'Hello World                                     ' ; cart name
	dc.b	'Hello World                                     ' ; cart name (alt)
	dc.b	'GM 12345678-00'	; program type / serial number / version
	dc.w	$0000				; ROM checksum
	dc.b	'J               '	; I/O device support (unused)
	dc.l	$00000000			; address of ROM start
	dc.l	RomEnd				; address of ROM end
    dc.l    ram_start
    dc.l    ram_end
    dc.b    '    '
    dc.b    '    '
    dc.b    '    '
    dc.b    '            '                           
    dc.b    '                                        '
    dc.b    'JUE             '
    
Main:
    ValidateTMSS:
        * Must be placed in all files. Satisfies TMSS for some genesis systems
        * $A14000 is reserved in version 0 and cannot be written to          
        move.b  $A10001,d0
        andi.b  #$0F,d0
        beq.b   version_0
        move.l  #'SEGA',$A14000    
        version_0:
        
ClearRegisters:
    move.l  #0,d0
    move.l  d0,d1
	move.l  d0,d2
	move.l  d0,d3
	move.l  d0,d4
    move.l  d0,d5
	move.l  d0,d6
	move.l  d0,d7
	move.l  d0,a0
	move.l  d0,a1
	move.l  d0,a2

	move.l  d0,a3
	move.l  d0,a4
	move.l  d0,a5
	move.l  d0,a6
		
ClearRAM:
	move.w  #$7FF0,d0   ;loop until the stack
	move.l  ram_start,a0 
    clear_ram_loop:
		move.w  #$0000,(a0)+
		dbf     d0, clear_ram_loop
		
SetupVDP:
    lea     VDPSetupArray,a0
    move.w  vdp_register_count,d0     
    vdp_init_loop:
        move.w  (a0)+,vdp_control
        dbf     d0, vdp_init_loop
		
ClearVRAM:

    move.l  #vdp_vram_write, vdp_control
    move.w  #$7fff,d0
    clear_vram_loop:
		move.w #$0000,vdp_data
		dbf d0, clear_vram_loop

    * Clear the background
    move.l  #vdp_cram_write, vdp_control
    move.w  #$0000,vdp_data
    
*=========================================
* Initialize inputs (for actual hardware)
*=========================================
InitJoypads:
    move.b  #$40, d0
    move.b d0, joypad_1_control
    move.b d0, joypad_2_control
    move.b d0, joypad_X_control

BeforeLoop:
    * Need interrupts to react to VBlank
    move.w  #interrupts_enable, sr

MainLoop:
    * Changes the background based on the ABC buttons
    bsr.w   WaitVBlank
    
    move.b	(MEM_buttons_held), d3
    clr.w   d2
    
    move.b	d3, d0
    andi.b  #joypad_a, d0
    sne.b   d1
    lsr.b   #4, d1
    or.w    d1, d2
     
    move.b	d3, d0
    andi.b  #joypad_b, d0
    sne.b   d1
    lsr.b   #4, d1
    lsl.b   #4, d1
    or.w    d1, d2
    
    move.b	d3, d0
    andi.b  #joypad_c, d0
    sne.b   d1
    lsr.b   #4, d1
    lsl.w   #8, d1
    or.w    d1, d2
	
    move.l  #vdp_cram_write, vdp_control
    move.w  d2, vdp_data
    
    bra.s   MainLoop
   
*-----------------------------
* Utility Subroutines
*-----------------------------
WaitVBlank:
	btst	#vblank_on_flag, (frame_state)
	beq.s	WaitVBlank
	bclr	#vblank_on_flag, (frame_state)
	rts
	
* Input code heavily influenced by https://huguesjohnson.com/programming/genesis
* This controller code is essentially the same everywhere you look online - there is no "better" way of doing things
ReadInput:
    move.w	#interrupts_disable, sr
    lea	    joypad_1_data, a0
    bra.s   ReadJoypad
    move.w	#interrupts_enable, sr
    rts
   
ReadJoypad:
	move.b	#0,(a0)
	nop					;NO Ops added to let the bus sync
	nop
	move.b	(a0),d1		; get joypad data - Start/A
	lsl.w	#2,d1		; shift them so they are at the 2 highest bits
	move.b	#$40,(a0)	; read joypad data port again
	nop					; bus synchronization
	nop					; bus synchronization
	move.b	(a0),d0		; get joypad data - C/B/Dpad
	andi.b	#$3F,d0		; C/B/Dpad in low 6 bits
	andi.b	#$C0,d1		; Start/A in high 2 bits
	or.b	d1,d0		; merge values from both registers
	not.b	d0			; flip bits so 0 means not pressed, and 1 means pressed
	move.b	d0,d1		; copy current buttons to d1
	move.b	(MEM_buttons_held),d2		; copy the last previously read buttons
	eor.b	d2,d0		; flip buttons being pressed now
	move.b	d1,(MEM_buttons_held)	; store held buttons
	and.b	d1,d0		; AND with current buttons
	move.b	d0,(MEM_buttons_pressed)	; store pressed buttons
	rts
	
*-----------------------------
* 'Traps' or I/O handlers
*-----------------------------
HBlank:
    rte

VBlank:
	bset	#vblank_on_flag,(frame_state)
	addq	#$1,(frame_counter)
    bsr.s   ReadInput
	rte
    
HandleException:
    stop    #$2700
    rte
    
NotHandled:
    rte

*---------------------
* VDP registers array
*---------------------
VDPSetupArray:
	dc.w    $8004		
	dc.w    $8174   ;Genesis mode, DMA enabled, VBLANK-INT enabled		
	dc.w    $8208	;field A    
	dc.w    $8300	;window
	dc.w    $8401	;field B	
	dc.w    $8518	;sprite
	dc.w    $8600
	dc.w    $8700   ;BG color (0th slot)		
	dc.w    $8800
	dc.w    $8900
	dc.w    $8AFF	;hblanks off	
	dc.w    $8B00		
	dc.w    $8C81	
	dc.w    $8D34		
	dc.w    $8E00
	dc.w    $8F02	;auto increment	
	dc.w    $9001		
	dc.w    $9100		
	dc.w    $9200
VDPSetupArrayEnd:

RomEnd:

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
