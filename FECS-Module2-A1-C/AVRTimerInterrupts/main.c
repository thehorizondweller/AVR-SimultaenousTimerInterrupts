/*
 * AVRTimerInterrupts.c
 *
 * Created: 13-10-2020 14:52:18
 * Author : Kshitij Anand
 */ 


#include <avr/io.h>  //header for avr io
#include <avr/interrupt.h>  // header for interrupt
#include <util/delay.h>   //header to call 10ms delay
//#define F_CPU 1234567UL    // used for delay call
volatile unsigned char flag1, flag2;   // defined as volatile because variable shared by ISR and main

int main(void)
{
	flag1 = 0;   // initialize flag1 with 0
	flag2 = 0;   // initialize flag2 with 0
	DDRB |= (1<<3); // PB3 as output
	DDRD = 0xFF;    // port D as output
	
	TCNT0 = -125; // load timer0 with -125 
	TCCR0 = (1<<CS02) | (1<<CS00);  // Timer0, normal mode, /1024 pre scalar 
	
	TCNT1 = -6250; // load timer1 with -6250
	TCCR1A = 0x00;     // normal mode
	TCCR1B = 0x05;     // internal clock, pre scalar 1024
	
	TIMSK = (1<<TOIE0)|(1<<TOIE1); // enable timer 0 and 1 interrupts
	sei();
	
	while (1)      // run program for infinite
	{
		if(flag1==1 && flag2 == 1)   // check if both the interrupts coincide
		{
			PORTB ^= (1<<3);    // toggle PB3
				
			_delay_ms(10);     // 10ms delay
			
			PORTD = 0x22;      // output 0x22 in port D
			
			flag1 = 0, flag2 = 0;   // setting back flags to 0
		}
		else
		{
			PORTD = 0x11;    // output 0x11 to port D
		}
		flag1 = 0, flag2 = 0;    // setting back flags to 0
	}
	
}
ISR(TIMER1_OVF_vect)    // interrupt service routine for timer 1
{
	TCNT1H = (-25000)>>8;     // the high byte
	TCNT1L = (-25000) & 0xFF;  // overflow after 25000 clocks	
	flag1 = 1;      // set flag1 to 1 on interrupt
}

ISR(TIMER0_OVF_vect)   // interrupt service routine for timer0
{
	TCNT0 = -125; // load timer0 with -125 
	flag2 = 1;    // set flag2 to 1 on interrupt
}
