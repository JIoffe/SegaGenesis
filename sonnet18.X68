*-----------------------------------------------------------
* Title      : 'Sonnet 18' 
* Written by : Jason Ioffe
* Date       :
* Description: A functioning example of outputting font
*              tiles to the scroll/tile planes 
*-----------------------------------------------------------

RomStart:
*======================
* Import Constants
*======================
    ; These are system constants that will be the same or similar for other ROMS
    include './constants/constants_segagenesis.X68'
    include './constants/constants_ascii.X68'

*==============================================================
* Memory Map for this ROM
*==============================================================
mem_start               EQU $FFFF0000
frame_state             EQU $FFFF0000       ;LONG
frame_counter           EQU $FFFF0002       ;WORD

MEM_buttons_held        EQU $FFFF0004       ;BYTE
MEM_buttons_pressed     EQU $FFFF0005       ;BYTE

MEM_player_pos_x        EQU $FFFF0006
MEM_player_pos_y        EQU $FFFF0008

*==================================
* Flags
*==================================
vblank_on_flag          EQU $00000001

*==================================
* Game Constants
*==================================
player_speed            EQU $02

*-----------------------------------------------------------
* CPU VECTORS
* These give the runtime some hints and must be first (address 0)
*-----------------------------------------------------------
    include './init/init_cpuvectors_common.X68'
    
*----------------------------------------------
* Sega Genesis ROM Metadata
* (Reference: https://en.wikibooks.org/wiki/Genesis_Programming)
* ---------------------------------------------
	dc.b	'SEGA GENESIS    '	; console name
	dc.b	'(C)JIOFF'	        ; copyright
 	dc.b	'2019.AUG'			; date
	dc.b	'Font Example - Shakespeare                      ' ; cart name
	dc.b	'Font Example - Shakespeare                      ' ; cart name (alt)
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
    include './init/init_validatetmss.X68'
    include './init/init_clearmem.X68' 
		
*================================================
* Coprocessor and Inputs Setup
*================================================
    ; (Assumes VDPSetupArray has been defined)
    include './init/init_vdp.X68' 
    include './init/init_inputs.X68' 
    
InitGraphics:
	lea   Palettes, a0
	moveq #4, d0
	bsr.w LoadPalettes
	    
    lea    Tiles, a0
	move.l #234, d0
	bsr.w  LoadTiles

	;==============================================================
	; Write the font tiles to VRAM
	;==============================================================
	lea     str_Text, a0                  ;Reference to first character
	move.l  #1, d0                        ;Row offset to start with
	move.l  #cram_palette_0_bits, d1      ;Palette Bits
    bsr.w   PrintStringToPlane
    
	lea     str_Author, a0
	move.l  #8, d0
    move.l  #cram_palette_1_bits, d1
    bsr.w   PrintStringToPlane
    
    lea     str_Footer, a0
	move.l  #20, d0
	move.l  #cram_palette_2_bits, d1
    bsr.w   PrintStringToPlane
     
    lea     stamp_shakespeare, a0
    move.w  #$0818, d0 
    bsr.w   DrawStamp
  
BeforeLoop:
    * Need interrupts to react to VBlank
    move.w  #interrupts_enable, sr 
    move.l  #MEM_player_pos_x, a1
    move.l  #MEM_player_pos_y, a2
    
MainLoop:
    bsr.w   WaitVBlank
    ; It feels criminal to have this empty so may as well allow shakespeare to move around
    move.b	(MEM_buttons_held), d0
        
    move.b	d0, d1
    andi.b  #joypad_right, d1
    beq.s   check_left
    addi.w  #player_speed, (a1)
    bra.s   lr_checked
    check_left:
        move.b	d0, d1    
        andi.b  #joypad_left, d1
        beq.s   lr_checked
        subi.w  #player_speed, (a1)    
    lr_checked:
    
    move.b d0, d1
    andi.b #joypad_up, d1
    beq.s check_down
    addi.w  #player_speed, (a2)
    bra.s ud_checked
    check_down:
        move.b  d0, d1
        andi.b  #joypad_down, d1
        beq.s   ud_checked
        subi.w  #player_speed, (a2)
    ud_checked:
    
    move.l #vdp_vram_hscroll, vdp_control
    move.w  #0,   vdp_data                   ; Send an empty word so that the foreground plane does not scroll
    move.w  (a1), vdp_data                   ; Second word is the background - shakespeare!
    
    move.l #vdp_vram_vscroll, vdp_control
    move.w  #0,   vdp_data                   ; Send an empty word so that the foreground plane does not scroll
    move.w  (a2), vdp_data                   ; Second word is the background - shakespeare!
    
    bra.w     MainLoop
   
*-----------------------------
* Utility Subroutines
*-----------------------------
    include './subroutines/sub_waitvblank.X68' 
    include './subroutines/sub_readinput.X68' 
	
*-----------------------------
* Traps
*-----------------------------
HBlank:
    rte

VBlank:
	bset	#vblank_on_flag,(frame_state)
	addq	#1, (frame_counter)
    bsr.s   ReadInput
	rte
    
HandleException:
    stop    #$2700
    rte
    
NotHandled:
    rte

*===============================
* VDP Registers Array
*=============================== 
    include './init/init_vdp_attributes_basic.X68'

*===============================
* Art Assets Subroutines
*===============================
    include './subroutines/sub_palettes.X68'
    include './subroutines/sub_loadtiles.X68'

*================================================
* String Subroutines
*================================================
* USE: - lea of null-terminated string to a0
*      - Set d0 to row offset
*      - Set d1 to palette bits

;This example does not wrap at the edge of the visible screen
;Keep track of the current column and goto print_endl when it gets too high!
PrintStringToPlane:
    print_nextline:
        move.l  d0, d2
        lsl.l   #7, d2                  ; Times 64 to get row offset, times 2 to move into place for command
        swap    d2                      ; Swap so offset is added to lower byte of upper word
        add.l   #vdp_write_plane_a, d2
        move.l  d2, vdp_control 
    print_string_loop:
        move.b  (a0)+, d2
        beq.s   print_string_end
         
        cmp.b   #CR,   d2
        beq.s   print_endl
        
        subi.b  #32,   d2               ; Tiles are mapped to ASCII values - 32. The tile at 0 is blank and fits the SPACE character.
        or.w    d1,    d2
        move.w  d2,    vdp_data
        bra.s   print_string_loop
    print_endl:
        addi.b  #1, d0
        bra.s   print_nextline
    print_string_end:
        rts
        
*==================================================
* Stamps
* - Stamp is a rectangular region of specific tiles
*==================================================
; USE: lea of stamp to a0
; d0 - 0xYYXX   tile coordinate

; d1 - WIDTH
; d2 - HEIGHT

; d3 - COLUMN
; d4 - ROW

; d5 - tile index (as word, running)

; d7 - temp
DrawStamp:    
    moveq   #0, d3                          ; Clear column/row
    moveq   #0, d4
    
    move.b  (a0)+,  d1                      ; store width and height
    move.b  (a0)+,  d2
    
    move.w  (a0),   d5
    addi.w  #$01,   d5                      ; Add 1 because tileset is offset by 1
    or.w    #cram_palette_3_bits, d5        ; Apply palette, it can stay there
        
    stamp_nextline:
        moveq   #0, d7
        move.w  d0, d7                      ; Add global y offset
        lsr.l   #8, d7
               
        add.w   d4, d7                      ; Add row y Offset
        lsl.l   #6, d7                      ; multiply by 64 (tile width)
        
        move.w  d0, d6
        and.w   #$00FF, d6
        add.w   d6, d7                      ; Add global x offset
        
        add.w   d7, d7                      ; double index for byte offset
        
        swap    d7      
        add.l   #vdp_write_plane_b, d7      ; Add plane offset - it works out almost coincidentally
        move.l  d7, vdp_control        
    stamp_loop:
        move.w  d5, vdp_data
        addq    #1, d5
        
        addq    #1, d3
        cmp.b   d1, d3                      ; end line when column == width
        beq.s   stamp_endl
        
        bra.s   stamp_loop
    stamp_endl:
        moveq   #0, d3                      ; clear column 
        addq    #1, d4
        cmp.b   d2,  d4                     ; end stamp when row == height
        beq.s   stamp_end
        
        bra.s   stamp_nextline              ; otherwise, jump to the next line in the plane
    stamp_end:
        rts

;"Stamps" are rectangular groups of tiles.
;1 byte for width, 1 byte for height, 2 bytes for starting index
;1 stamps(s)
Stamps:
stamp_shakespeare:
   dc.b $0C
   dc.b $0C
   dc.w $005A

*==============================================================
* Art
*==============================================================
; For this sample all the art is uncompressed
    include './assets/palettes/palette_sonnet18.X68'
    include './assets/tilesets/tiles_sonnet18.X68'
   
*=========================
* TEXT
*=========================
; Text is placed last because byte offsets cause strange things to happen
str_Text:
    dc.b    ' "Shall I compare thee', CR
    dc.b    '  to a summer',$27,'s day?', CR
    dc.b    '  Thou art more lovely', CR
    dc.b    '  and more temperate..."', CR, 0
    
str_Author:
    dc.b    '   Sonnet 18', CR
    dc.b    '   William Shakespeare', 0
    
str_Footer:
    dc.b    '  **GENESIS DOES**', CR
    dc.b    ' 16th Century Poetry', 0

*    dc.b    'Shall I compare thee to a summer',$27,'s day?', CR
*    dc.b    'Thou art more lovely and more temperate:', CR
*    dc.b    'Rough winds do shake the darling buds of May,', CR
*    dc.b    'And summer',$27,'s lease hath all too short a date:', CR
*    dc.b    'Sometime too hot the eye of heaven shines,', CR
*    dc.b    'And often is his gold complexion dimm',$27,'d;', CR
*    dc.b    'And every fair from fair sometime declines,', CR
*    dc.b    'By chance, or nature�s changing course, untrimm',$27,'d;', CR
*    dc.b    'But thy eternal summer shall not fade', CR
*    dc.b    'Nor lose possession of that fair thou ow',$27,'st;', CR
*    dc.b    'Nor shall Death brag thou wander',$27,'st in his shade,', CR
*    dc.b    'When in eternal lines to time thou grow',$27,'st;', CR
*    dc.b    'So long as men can breathe or eyes can see,', CR
*    dc.b    'So long lives this, and this gives life to thee.', 0
RomEnd:







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
