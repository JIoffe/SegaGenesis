*-----------------------------------------------------------
* Title      : 'Asteroid field' 
* Written by : Jason Ioffe
* Date       :
* Description: A functioning example of with sprites
*               and scrolling background planes
*        
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
frame_state             EQU $FFFF0000       ;WORD
frame_counter           EQU $FFFF0002       ;WORD

MEM_buttons_held        EQU $FFFF0004       ;BYTE
MEM_buttons_pressed     EQU $FFFF0005       ;BYTE

MEM_stars_fade_0        EQU $FFFF0006       ;WORD
MEM_stars_fade_1        EQU $FFFF0008       ;WORD
MEM_stars_fade_2        EQU $FFFF000A       ;WORD

MEM_ship_x              EQU $FFFF000C       ;WORD
MEM_ship_y              EQU $FFFF000E       ;WORD
MEM_ship_gfx            EQU $FFFF0010       ;WORD

*==================================
* Flags
*==================================
vblank_on_flag          EQU $00000001

*==================================
* Game Constants
*==================================
color_star_0            EQU $0EEE
color_star_1            EQU $0ECC
color_star_2            EQU $0E88
color_star_3            EQU $0800

player_speed            EQU $02
ship_initial_x          EQU $0100
ship_initial_y          EQU $0080

ship_tile_index         EQU $020F

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
	dc.b	'Sprite Example - Asteroid Field                 ' ; cart name
	dc.b	'Sprite Example - Asteroid Field                 ' ; cart name (alt)
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
    
*================================================
* Coprocessor and Inputs Setup
*================================================
    ; (Assumes VDPSetupArray has been defined)
    include './init/init_vdp.X68' 
    include './init/init_inputs.X68' 
    include './init/init_clearmem.X68' 
    
InitGraphics:
	lea     Palettes, a0
	moveq   #4, d0
	bsr.w   LoadPalettes
	    
    lea     Tiles, a0
	move.l  #543, d0
	bsr.w   LoadTiles
	
	; Fill the sky with stars!
	move.l  #vdp_write_plane_b, vdp_control
	move.l  #vdp_plane_n_tiles, d0
	subq    #1, d0
	
	; Not so random seed
	moveq   #96, d1
	starfield_loop:
	    ; completely nonsensical and not random but scatters tiles and H/V flip flags
	    move.l  d1, d2
	    ror.l   #8, d2
	    subi.w  #117, d2
	    move.l  d2, d1
	    
	    move.l  d1, d3
	    and.w   #11, d3
	    
	    ; flip the H/V flip flags as well at $1800L / $18W
	    move.l  d1, d2
	    and.l   #$1800, d2
	    or.l    d2, d3
	   
	    move.w  d3, vdp_data
	    dbra    d0, starfield_loop
	    
    init_asteroids:
        ; Drawing twice to fill the frame
        lea     stamp_asteroids, a0
        move.w  #$0800, d0 
        move.l  #vdp_write_plane_a, a1
        move.l  #cram_palette_1_bits, d7
        bsr.w   DrawStamp
        lea     stamp_asteroids, a0
        move.l  #cram_palette_1_bits, d7
        move.w  #$0820, d0 
        bsr.w   DrawStamp
	
	init_spaceship:
	    move.w  #ship_tile_index|cram_palette_2_bits, (MEM_ship_gfx)
	    lea     sprite_ship_right, a0
	    move.l  #vdp_vram_sprite, vdp_control
	    move.w  #ship_initial_x,  vdp_data
	    move.w  #$0F00,  vdp_data
	    move.w  #ship_tile_index|cram_palette_2_bits, vdp_data
	    move.w  #ship_initial_x,  vdp_data
	    
	    
	    
BeforeLoop:
    * Need interrupts to react to VBlank
    move.w  #interrupts_enable, sr
    
    move.l  #frame_counter, a1
    move.w  #$0EEE, (MEM_stars_fade_0)
    move.w  #$0333, (MEM_stars_fade_1)
    move.w  #$0000, (MEM_stars_fade_2)
    
    move.l  #MEM_ship_x, a2
    move.l  #MEM_ship_y, a3
    move.w  #ship_initial_x, (a2)
    move.w  #ship_initial_y, (a3)
    
MainLoop:
    bsr.w   WaitVBlank
    
    moveq   #0, d0
    move.w  (frame_counter), d0
    divu.w  #16, d0
    swap    d0
    tst.w   d0
    bne.s   skip_fade
    
    FadeStars:
    move.l  #MEM_stars_fade_0, a0
    move.l  #vdp_cram_write, vdp_control
    move.w  #0, vdp_data  ; overwrite the first color for some real trippiness!
    
    moveq   #2, d0
    fade_star_loop:
        move.w  (a0), d1
        subi.w  #$0222, d1          ; This is a single step of color
        
        move.w  d1, d2              ; Could loop through these colors...
        and.w   #color_star_0, d2   ; The idea is to AND the brightness with the actual target color
        move.w  d2, vdp_data
        
        move.w  d1, d2              
        and.w   #color_star_1, d2
        move.w  d2, vdp_data
        
        move.w  d1, d2              
        and.w   #color_star_2, d2
        move.w  d2, vdp_data
        
        move.w  d1, d2              
        and.w   #color_star_3, d2
        move.w  d2, vdp_data
        
        cmp.w   #$0666, d1           ; Don't fade all the way to black
        bne.s   next_stars
        move.w  #$0EEE, d1
        next_stars:
        move.w  d1, (a0)+     
        dbra  d0, fade_star_loop
    skip_fade:
    
    ; Scroll stars
    move.w  (a1), d0
    asr.l   #3, d0
    neg.w   d0
    
    move.w  (a1), d1
    asr.l   #1, d1
    neg.w   d1
    
    move.l #vdp_vram_hscroll, vdp_control
    move.w  d1, vdp_data                 ; First word is foreground - asteroids
    move.w  d0, vdp_data                   ; Second word is the background - stars
    
    ; Move Starship
    move.l  #MEM_ship_x, a2
    move.l  #MEM_ship_y, a3
    move.l  #MEM_ship_gfx, a4
    move.b	(MEM_buttons_held), d2
    
    move.w  (a4), d5      ; d5 will hold the graphics property for the ship sprite
    
    move.b	d2, d1
    andi.b  #joypad_right, d1
    beq.s   check_left
    ; MOVING RIGHT
    move.w  #ship_tile_index|cram_palette_2_bits, d5                        ; clear h flip
    addi.w  #player_speed, (a2)
    bra.s   lr_checked
    check_left:
        move.b	d2, d1    
        andi.b  #joypad_left, d1
        beq.s   lr_checked
        ; MOVING LEFT
        move.w  #ship_tile_index|cram_palette_2_bits|sprite_hflip_bit, d5   ; set h flip
        subi.w  #player_speed, (a2)    
    lr_checked:
    
    move.b d2, d1
    andi.b #joypad_up, d1
    beq.s check_down
    subi.w  #player_speed, (a3)
    bra.s ud_checked
    check_down:
        move.b  d2, d1
        andi.b  #joypad_down, d1
        beq.s   ud_checked
        addi.w  #player_speed, (a3)
    ud_checked:
    
    moveq   #0,   d0
    move.l  (a2), d1
    move.w  d5,   d2
    move.w  d5, (a4)
    bsr.w   UpdateSpritePosGfx
    
    bra.w   MainLoop
    
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
	bset	#vblank_on_flag, (frame_state)
	addq    #1, (frame_counter)
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
    include './subroutines/sub_stamps.X68'
    
; USE - Set d0 to sprite index
;       Set d1 to Sprite XXXYYYY
UpdateSpriteXY:
    lsl.l   #3, d0
    move.l  d0, d5
    swap    d5
    add.l   #vdp_vram_sprite, d5
    move.l  d5, vdp_control
    move.w  d1, vdp_data
    
    addq    #6, d0
    swap    d0
    add.l   #vdp_vram_sprite, d0
    move.l  d0, vdp_control
    swap    d1
    move.w  d1, vdp_data
    rts
    
; USE - Set d0 to sprite index
;       Set d1 to graphics word
UpdateSpriteGfx:
    lsl.l   #3, d0
    addq    #4, d0
    swap    d0
    add.l   #vdp_vram_sprite, d0
    move.l  d0, vdp_control
    move.w  d1, vdp_data
    rts

; USE - Set d0 to sprite index
;       Set d1 to Sprite XXXXYYYY
;       Set d2 to graphics word
  
UpdateSpritePosGfx:
    lsl.l   #3, d0
    move.l  d0, d5
    swap    d5
    add.l   #vdp_vram_sprite, d5
    move.l  d5, vdp_control
    move.w  d1, vdp_data
    
    addq    #4, d0
    swap    d0
    add.l   #vdp_vram_sprite, d0
    move.l  d0, vdp_control
    move.w  d2, vdp_data
    swap    d1
    move.w  d1, vdp_data
    rts

*==============================================================
* Art
*==============================================================
    include './assets/palettes/palette_asteroids.X68'  
Tiles:
    include './assets/tilesets/tiles_asteroidfield.X68'

;"Stamps" are rectangular groups of tiles.
;1 byte for width, 1 byte for height, 2 bytes for starting index
;1 stamps(s)
Stamps:
stamp_asteroids:
   dc.b $20
   dc.b $10
   dc.w $000E

sprite_ship_right:
   dc.b $0F
   dc.w $020E
*==============================================================
* Text
*==============================================================
; None in this example


RomEnd:
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
