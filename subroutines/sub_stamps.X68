*==================================================
* Stamps
* - Stamp is a rectangular region of specific tiles
*==================================================
; USE: lea of stamp to a0
;      a1   PLANE Address 
;      d0 - 0xYYXX   tile coordinate
;      d7 - cram palette bits

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
    or.w    d7, d5        ; Apply palette, it can stay there
        
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
        add.l   a1, d7      ; Add plane offset - it works out almost coincidentally
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

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
