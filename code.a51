LCDdatabus EQU 0A0h ;LCD Data Bus P0
LCDrs EQU 0A2h ;LCD RS P2.7
LCDen EQU 0A3h ;LCD EN P2.6
ADC_data_bus equ 90h ; Port 1
ADC_add_a equ 80h ; P0.0
ADC_add_b equ 0B5h ; P3.5
ADC_ale_soc equ B3h ; P3.3
ADC_eoc equ B4h ; P3.4
ADC_oe equ B2h ; P3.2
Relay_temp equ 85h
Relay_humid equ 86h
Buzzer equ 87h
;===========================================================================
LCD_Reg EQU 43h
LCDtempReg EQU 34h
Reg_LCD_swap1 EQU 35h
Reg_LCD_swap2 EQU 36h
ADC_op_temp EQU 30h ;channel 0
ADC_op_humidity EQU 31h ;channel 1
loopcntr EQU 54h
Hex2asc_R0 EQU 55h
Hex2asc_R1 EQU 56h
Hex2asc_R2 EQU 57h
Hex2asc_R3 EQU 58h
LCD_cursor_R1 EQU 5Ah
LCD_cursor_R2 EQU 5Bh
LCD_cursor_R3 EQU 5Ch
;===========================================================================
 org 0000h
 call init
loop:
 call ADC_temp
 call ADC_humidity
 call disp_THLM
 call check_temp
 call check_humidity
 jmp loop
;===========================================================================
check_temp:
 mov a,ADC_op_temp
 
 subb a,#33
 jc chk_low_temp
 setb Relay_temp
 ret 
chk_low_temp:
 clr Relay_temp
 ret
;===========================================================================
check_humidity:
 mov a,ADC_op_humidity
 
 subb a,#50
 jc chk_low_humid
 setb Relay_humid
 ret 
chk_low_humid:
 clr Relay_humid
 ret
;===========================================================================
ADC_temp: clr ADC_add_a ; Channel 0 is ie Temp is selected
 clr ADC_add_b ;Add b = 0, Add a = 0
 
 setb ADC_ale_soc ;ale & soc is made high
 
 
 
 
 clr ADC_ale_soc ;ale & socis made low 
 jb ADC_eoc,$ ;check for eoc 
 setb ADC_oe ;if eoc high,make oe high
 
 
 
 mov a,ADC_data_bus ;Read port0 data to accumulator
 mov ADC_op_temp,a ;Copy data in Register for further 
processing
 clr ADC_oe ;make oe low
 ret
;========================================================================
ADC_humidity: clr ADC_add_a ; Channel 1 is ie humidity is selected
 setb ADC_add_b ;Add b = 0, Add a = 1
 
 setb ADC_ale_soc ;ale & soc is made high
 
 
 
 
 clr ADC_ale_soc ;ale & socis made low 
 jb ADC_eoc,$ ;check for eoc 
 setb ADC_oe ;if eoc high,make oe high
 
 
 
 mov a,ADC_data_bus ;Read port0 data to accumulator
 mov ADC_op_humidity,a ;Copy it in Register for further 
processing
 clr ADC_oe ;make oe low
 ret
;========================================================================
disp_THLM:
 mov scon,#50h
 mov tmod,#21h
 mov th1,#f4h
 mov tl1,#f4h
 setb tr1
 mov a,#'T'
 mov sbuf,a
 jnb ti,$
  mov a,#'E'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'M'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'P'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'='
 mov sbuf,a
 jnb ti,$
 
 mov LCD_cursor_R1,#82h
 mov LCD_cursor_R2,#83h
 mov LCD_cursor_R3,#84h
 mov Hex2asc_R0,ADC_op_temp
 call disp_Hex2asc
 mov a,#dfh
 mov sbuf,a
 jnb ti,$
 
 mov a,#'C'
 mov sbuf,a
 jnb ti,$
 
 mov a,#' '
 mov sbuf,a
 jnb ti,$
 
 mov a,#' '
 mov sbuf,a
 jnb ti,$
 
 mov a,#' '
 mov sbuf,a
 jnb ti,$
 
 mov a,#'H'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'U'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'M'
 mov sbuf,a
 jnb ti,$
 mov a,#'I'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'D'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'I'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'T'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'Y'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'='
 mov sbuf,a
 jnb ti,$
 
 mov LCD_cursor_R1,#8Ah
 mov LCD_cursor_R2,#8Bh
 mov LCD_cursor_R3,#8Ch
 mov Hex2asc_R0,ADC_op_humidity
 call disp_Hex2asc
 mov a,#'%'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'R'
 mov sbuf,a
 jnb ti,$
 
 mov a,#'H'
 mov sbuf,a
 jnb ti,$
 ret
;========================================================================
disp_Hex2asc: mov a,Hex2asc_R0
 mov b,#100
 div ab
 mov Hex2asc_R1,a
 mov a,b
 mov b,#10
 div ab
 mov Hex2asc_R2,a
 mov a,b
 mov Hex2asc_R3,a
 mov LCDtempReg,LCD_cursor_R1
 call LCDcmd
 mov LCDtempReg,Hex2asc_R1
 call LCDdata
 mov LCDtempReg,LCD_cursor_R2
 call LCDcmd
 mov LCDtempReg,Hex2asc_R2
 call LCDdata
 mov LCDtempReg,LCD_cursor_R3
 call LCDcmd
 mov LCDtempReg,Hex2asc_R3
 call LCDdata
 mov a,Hex2asc_R1
 mov sbuf,a
 jnb ti,$
 
 mov a,Hex2asc_R2
 mov sbuf,a
 jnb ti,$
 
 mov a,Hex2asc_R3
 mov sbuf,a
 jnb ti,$
 
 ret
;========================================================================
init:
 clr 01h
 mov scon,#50h
 mov tmod,#21h
 mov th1,#f4h
 mov tl1,#f4h
 setb tr1
 call LCDinit_4bit
 mov dptr,#msgwelcome
 call LCDdisp
 clr Relay_temp
 clr Relay_humid
 call pc_int
 call delay2sec
 mov dptr,#LCDdispval
 call LCDdisp
 clr Relay_temp
 clr Relay_humid
 ret
;===========================================================================
LCDinit_4bit:
 call delayhalf
 mov LCDtempReg,#02h
 call LCDcmd
 mov LCDtempReg,#28h
 call LCDcmd
 mov LCDtempReg,#0Ch
 call LCDcmd
 mov LCDtempReg,#06h
 call LCDcmd
 mov LCDtempReg,#01h
 call LCDcmd
 ret
;========================================================================
LCDcmd:
 mov Reg_LCD_swap1,LCDtempReg
 mov Reg_LCD_swap2,Reg_LCD_swap1
 mov a,Reg_LCD_swap2
 anl a,#F0H
 mov LCDdatabus,a
 clr LCDrs
 setb LCDen
 
 
 clr LCDen
 call LCDdelay
 mov a,Reg_LCD_swap2
 swap a
 anl a,#F0H
 mov LCDdatabus,a
 clr LCDrs
 setb LCDen
 
 
 clr LCDen
 call LCDdelay
 ret 
;========================================================================
LCDdata:
 mov Reg_LCD_swap1,LCDtempReg
 mov Reg_LCD_swap2,Reg_LCD_swap1
 mov a,Reg_LCD_swap2
 anl a,#F0H
 mov LCDdatabus,a
 setb LCDrs
 setb LCDen
 
 
 clr LCDen
 call LCDdelay
 mov a,Reg_LCD_swap2
 swap a
 anl a,#F0H
 mov LCDdatabus,a
 setb LCDrs
 setb LCDen
 
 
 clr LCDen
 call LCDdelay
 ret
;========================================================================
delayhalf: mov 30H,#05
delayhalf1: mov 31H,#200
delayhalf2: mov 32H,#250
 djnz 30H,$
 djnz 31H,delayhalf2
 djnz 32H,delayhalf1
 ret 
;===========================================================================
LCDdelay mov 30H,#08 ;LCD
LCDdelay1 mov 31H,#250
 djnz 30H,$
 djnz 31H,LCDdelay1
 ret
;========================================================================
LCDdisp mov LCD_Reg,#00h
LCDdisp2 mov a,LCD_Reg
 movc a,@a+dptr
 cjne a,#'@',LCDdisp1
 mov LCDtempReg,#c0h
 call LCDcmd
 jmp LCDdisp2
LCDdisp1 cjne a,#'$',LCDdisp3
 ret
LCDdisp3 mov LCDtempReg,a
 call LCDdata
 inc LCD_Reg
 jmp LCDdisp2
;========================================================================
delay1sec: call delayhalf
 call delayhalf
 ret
;========================================================================
delay2sec call delayhalf
 call delayhalf
 call delayhalf
 call delayhalf
 ret
;=======================================================================
; PC INTERFACING 
;=======================================================================
pc_int: mov scon,#50h
 mov tmod,#21h
 mov th1,#f4h
 mov tl1,#f4h
 mov LCD_Reg,#00h
 setb tr1
pc_int2 mov a,LCD_Reg
 movc a,@a+dptr
 cjne a,#'@',pc_int1
 mov a,#' '
 mov sbuf,a
 jnb ti,$
 
 inc LCD_Reg
 jmp pc_int2
pc_int1 cjne a,#'$',pc_int3
 mov tmod,#11h
 ret
pc_int3 mov sbuf,a
 jnb ti,$
 
 inc LCD_Reg
 jmp pc_int2
;========================================================================
LCDdispval DB "T= ",dfh,"c H= %RH"
;========================================================================
 END
