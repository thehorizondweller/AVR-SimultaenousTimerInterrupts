;
; Assignment 1.asm
;
; Created: 12-10-2020 08:37:24
; Author : Kshitij Anand
;

.INCLUDE "M32DEF.INC"
.ORG $0
	JMP MAIN
.ORG $12
	JMP T1_OV_ISR
.ORG $14
	JMP T1_OC_ISR
.ORG $16
	JMP T0_OV_ISR

;MAIN PROGRAM FOR INITIALIZATION AND KEEPING THE CPU BUSY WITH GENERAL TASK
.ORG $100
MAIN:
	LDI R20, HIGH(RAMEND)
	OUT SPH, R20
	LDI R20, LOW(RAMEND)
	OUT SPL, R20 ;INITIALIZATION OF STACK POINTER IS COMPLETE
	SBI DDRB, 3  ;PB3 AS OUTPUT
	LDI R20, (1<<TOIE0)|(1<<TOIE1)
	OUT TIMSK, R20 ;ENABLE TIMER0 AND TIMER1 OVERFLOW INTERRUPT FLAGS IN TIMSK REG
	SEI            ;SET I (ENABLE INTERRUPTS GLOBALLY)
	;Timer0----------------------
	LDI R20, (-125) ;value for 0.016 secs
	OUT TCNT0, R20 ;initializing TCNT0 to overflow after 125 clocks
	LDI R20, $05
	OUT TCCR0, R20 ;Normal mode, int clk, prescaler 1:1024
	;Timer1----------------------------
	LDI R20, HIGH(-6250)
	OUT TCNT1H, R20 ;setting high byte
	LDI R20, LOW(-6250)
	OUT TCNT1L, R20 ;setting low byte
	LDI R20, $00
	OUT TCCR1A, R20
	LDI R20, $05
	OUT TCCR1B, R20   ;normal mode with prescaler as 1:1024
	;----------------------
	LDI R20, $FF
	OUT DDRD, R20 ;PORTD as output
	;----------------------
	;Infinite loop which keeps outputing 0x11 on PORTD
HERE:
	LDI R16, $11
	OUT PORTD, R16 ;keep outputing 0x11 in non-interrupted situations
	RJMP HERE
;-----------------------
;ISR for Timer0 Overflow - LOWER PRIORITY
.ORG $200
T0_OV_ISR:
	LDI R20, (-125)
	OUT TCNT0, R20 ;load timer0 for next round
	LDI R20, 1<<TOV0
	IN R22, TIFR
	EOR R22, R20
	OUT TIFR, R22 ;Reset the TOV0 flag in TIFR
	RETI 
;------------------------------
;ISR for Timer1 Overflow - HIGHER PRIORITY
.ORG $300
T1_OV_ISR:
	LDI R20, HIGH(-6250)
	OUT TCNT1H, R20 ;resetting high byte for next round
	LDI R20, LOW(-6250)
	OUT TCNT1L, R20 ;resetting low byte for next round
	IN R20, TIFR
	SBRS R20, TOV0 ;check if Timer0 overflowed
	RETI
	LDI R20, $08 
	IN R22, PORTB
	EOR R22, R20 ;toggle the fourth bit
	OUT PORTB, R22
	SEI
	;Procedure for outputing 0x22 on PORTD after 10 ms
	;For this part we will have to use CTC mode
	;When Compare ISR is executed we shift back to Normal mode
	LDI R20, HIGH(-5000)
	OUT OCR1AH, R20
	LDI R20, LOW(-5000)
	OUT OCR1AL, R20
	LDI R20, $00
	OUT TCCR1A, R20
	LDI R20, $0D
	OUT TCCR1B, R20   ;CTC mode with prescaler as 1:1024
	;Now this will call the Compare ISR as soon as 1250 clocks are clocked
	SEI ; this required because compare match has lower priority than overflow interrupt
	RETI

;-----------------------------
;ISR for Timer1 CTC mode
.ORG $400
T1_OC_ISR:
	LDI R20, $22
	OUT PORTD, R20
	LDI R20, HIGH(-5000);Clock the remaining 5000 clocks
	OUT TCNT1H, R20 ;setting high byte
	LDI R20, LOW(-5000)
	OUT TCNT1L, R20 ;setting low byte
	LDI R20, $00
	OUT TCCR1A, R20
	LDI R20, $04
	OUT TCCR1B, R20   ;shift back to normal mode with prescaler as 1:1024
	RETI
	
