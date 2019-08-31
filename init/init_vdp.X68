*-----------------------------------------------------------
* VDP Setup
* (Assumes VDPSetupArray has been defined)
*-----------------------------------------------------------
SetupVDP:
    lea     VDPSetupArray, a0
    move.l  #vdp_register_count, d0     
    vdp_init_loop:
        move.w  (a0)+,vdp_control
        dbf     d0, vdp_init_loop
		
ClearVRAM:
    move.l  #vdp_vram_write, vdp_control
    move.w  #$7fff,d0
    clear_vram_loop:
		move.w #$0000,vdp_data
		dbf d0, clear_vram_loop


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
