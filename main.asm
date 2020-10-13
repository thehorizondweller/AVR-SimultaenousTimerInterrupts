;
; FECS-Module2-A1.asm
;
; Created: 12-10-2020 16:39:47
; Author : Kshitij Anand
;

.include "M32DEF.INC"

.org 0x0
	jmp main
.org 0x12
	jmp t1_ov_isr
.org 0x16
	jmp t0_ov_isr

;main program 
main:
	ldi r20, high(ramend)
	out sph, r20
	ldi r20, low(ramend)
	out spl, r20 ;stack pointer initialised

	sbi ddrb, 3 ;set PB3 as output

	ldi r20, -125 ;time for 0.016 seconds
	out tcnt0, r20
	ldi r20, high(-6250) ;time for 0.8 seconds
	out tcnt1h, r20
	ldi r20, low(-6250)
	out tcnt1l, r20
	ldi r20, 0x00
	out tccr1a, r20
	ldi r20, 0x05
	out tccr1b, r20 ;init clk, normal mode, prescaler 1024
	out tccr0, r20 ;init clk, normal mode, prescaler 1024

	ldi r20, (1<<toie0)|(1<<toie1)
	out timsk, r20 ;enabling overflow interrupts
	sei ;interrupts enabled gloablly

	ldi r20, 0xff
	out portd, r20 ;PORTD as output

	;defining two custom flags to check coincidence
	ldi r24, 0x00 ;will be set when timer0 overflows
	ldi r25, 0x00 ;will be set when timer1 overflows

	;infinite loop to output 0x11 on PORTD
here:
	ldi r20, 0x11
	out portd, r20
	rjmp here

.org 0x100
t0_ov_isr:
	ldi r20, -125 ;load timer0 for next round
	out tcnt0, r20
	ldi r24, 0x01
	call coincidence
	reti

.org 0x200
t1_ov_isr:
	ldi r20, high(-6250) ;load timer1 for next round
	out tcnt1h, r20
	ldi r20, low(-6250)
	out tcnt1l, r20
	ldi r25, 0x01
	sei
	call coincidence
	reti

.org 0x300
coincidence:
	sei
	mov r16, r24
	mov r17, r25
	eor r16, r17 ;check if both last bits are 1
	sbrs r16, 0
	call procedure
	ldi r24, 0x00 ;resetting the flags
	ldi r25, 0x00
	ret

.org 0x400
procedure: ;called only if conincidence occurs
	ldi r20, 0x08
	in r22, portb 
	eor r22, r20 ;toggles bit 3 of port b
	out portb, r22
	call delay
	ldi r20, 0x22
	out portd, r20 ;output 0x22 on portd 10 ms after coincidence
	ret

.org 0x500
delay:
	;we will use timer2 because we cannot disturb timer0 and timer1
	ldi r20, -78 ; time for 10 ms with 1024 as prescaler
	out tcnt2, r20; load timer2
	ldi r20, 0x07
	out tccr2, r20 ;timer2, normal mode, init clk, prescaler 1024
again:
	in r20, tifr ;read tifr register
	sbrs r20, tov2 ;if tov2 is set, skip next instruction
	rjmp again
	ldi r20, 0x00 
	out tccr2, r20 ;stop timer2
	ldi r20, 1<<tov2
	out tifr, r20 ;clear tov2 flag
	ret


	

