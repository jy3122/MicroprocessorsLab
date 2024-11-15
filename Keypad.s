#include <xc.inc>
    
global  Keypad_Setup, Keypad_read_input

psect	udata_acs   ; reserve data space in access ram
Keypad_counter: ds    1	    ; reserve 1 byte for variable Keypad_counter
Keypad_row:ds    1;reserve 1 byte for pressed row
Keypad_col:ds    1;reserve 1 byte for pressed columb
Keypad_result:ds    1;reserve the decoded value


psect	keypad_code,class=CODE
    
Keypad_Setup:
    bsf	    REPU	; set up pullups for port E
    clrf    LATE        ; write 0s to LATE register
    movlw   0x0F        ; this is 00001111
    movwf   TRISE       ; assign to port E, 0-3 input, 4-7 output
    
    return
    
Keypad_scan_row:
    movlw   0x0F        ;00001111
    movwf   LATE        ;drive 0-3 high, drive 4-7 low
    movlw   0x0F        ;00001111
    movwf   TRISE       ;0-3 input, 4-7 output 
    movwf   PORTE, W
    andlw   0x0F        ;keep 0-3(rows), and gate
    movwf   Keypad_row  ;save satus of row
    return
    
Keypad_scan_col:
    movlw   0xF0        ;11110000
    movwf   LATE        ;drive column pins (4-7) high, row pins (0-3) low
    movlw   0xF0        ;11110000
    movwf   TRISE       ;0-3 output,4-7 input
    movf    PORTE, W
    andlw   0xF0        ;keep column status (4-7), and gate
    movwf   Keypad_col
    return
    
Keypad_decode:
    ; Check if the row is the 1st row (0x01)
    movf KeyPad_row, W          ; Load row state into W
    xorlw 0x01                  ; Compare with 0x01 (1st row)
    btfss STATUS, Z             ; Skip if not equal
    goto Check_Row2             ; Go to check the 2nd row
 
    ; Check which column in the 1st row
    movf KeyPad_col, W          ; Load column state into W
    xorlw 0x10                  ; Compare with 0x10 (1st column)
    btfss STATUS, Z
    goto Check_Col2_1           ; Not the 1st column
    movlw 0x01                  ; Key '1'
    movwf KeyPad_result         ; Store result
    goto Decode_End
 
Check_Col2_1:
    xorlw 0x20                  ; Compare with 0x20 (2nd column)
    btfss STATUS, Z
    goto Check_Col3_1           ; Not the 2nd column
    movlw 0x02                  ; Key '2'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col3_1:
    xorlw 0x40                  ; Compare with 0x40 (3rd column)
    btfss STATUS, Z
    goto Check_Col4_1           ; Not the 3rd column
    movlw 0x03                  ; Key '3'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col4_1:
    xorlw 0x80                  ; Compare with 0x80 (4th column)
    btfss STATUS, Z
    goto Check_Row2             ; Not the 4th column
    movlw 0x46                  ; Key 'F'
    movwf KeyPad_result
    goto Decode_End
 
Check_Row2:
    ; Check if the row is the 2nd row (0x02)
    movf KeyPad_row, W
    xorlw 0x02
    btfss STATUS, Z
    goto Check_Row3
 
    ; Check which column in the 2nd row
    movf KeyPad_col, W
    xorlw 0x10
    btfss STATUS, Z
    goto Check_Col2_2
    movlw 0x04                  ; Key '4'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col2_2:
    xorlw 0x20
    btfss STATUS, Z
    goto Check_Col3_2
    movlw 0x05                  ; Key '5'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col3_2:
    xorlw 0x40
    btfss STATUS, Z
    goto Check_Col4_2
    movlw 0x06                  ; Key '6'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col4_2:
    xorlw 0x80
    btfss STATUS, Z
    goto Check_Row3
    movlw 0x45                  ; Key 'E'
    movwf KeyPad_result
    goto Decode_End
 
Check_Row3:
    ; Check if the row is the 3rd row (0x04)
    movf KeyPad_row, W
    xorlw 0x04
    btfss STATUS, Z
    goto Check_Row4
 
    ; Check which column in the 3rd row
    movf KeyPad_col, W
    xorlw 0x10
    btfss STATUS, Z
    goto Check_Col2_3
    movlw 0x07                  ; Key '7'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col2_3:
    xorlw 0x20
    btfss STATUS, Z
    goto Check_Col3_3
    movlw 0x08                  ; Key '8'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col3_3:
    xorlw 0x40
    btfss STATUS, Z
    goto Check_Col4_3
    movlw 0x09                  ; Key '9'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col4_3:
    xorlw 0x80
    btfss STATUS, Z
    goto Check_Row4
    movlw 0x44                  ; Key 'D'
    movwf KeyPad_result
    goto Decode_End
 
Check_Row4:
    ; Check if the row is the 4th row (0x08)
    movf KeyPad_row, W
    xorlw 0x08
    btfss STATUS, Z
    goto Decode_End
 
    ; Check which column in the 4th row
    movf KeyPad_col, W
    xorlw 0x10
    btfss STATUS, Z
    goto Check_Col2_4
    movlw 0x41                  ; Key 'A'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col2_4:
    xorlw 0x20
    btfss STATUS, Z
    goto Check_Col3_4
    movlw 0x00                  ; Key '0'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col3_4:
    xorlw 0x40
    btfss STATUS, Z
    goto Check_Col4_4
    movlw 0x42                  ; Key 'B'
    movwf KeyPad_result
    goto Decode_End
 
Check_Col4_4:
    xorlw 0x80
    btfss STATUS, Z
    goto Decode_End
    movlw 0x43                  ; Key 'C'
    movwf KeyPad_result
    goto Decode_End
 
Decode_End:
    return
    
Keypad_read_input:
    call Keypad_scan_row
    call Keypad_scan_col
    call Keypad_decode
    return
    


