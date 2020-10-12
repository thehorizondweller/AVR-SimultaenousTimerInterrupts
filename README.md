# AVR-SimultaenousTimerInterrupts

### Problem Statement
Using Timer 0 and Timer 1 interrupts having overflows of 0.016 second and 0.8 second, respectively, every time there is (coincidence) 
an occurrence of both interrupts in the same time, toggle the pin PORTB.3 and then after 10 ms of the instance of coincidence of interrupts, 
write the value 0X22 in PORTD. Else if there is no coincidence of occurrence of both interrupts, continuously write the value of 0X11 in PORTD.

### Approach
* Initialize Stack pointer
* Declare PORTB.3 as output pin
* Intialise Timer0 in normal mode with prescaler as 1024 with 125 clocks required for overflow
* Intialise Timer1 in normal mode with prescaler as 1024 with 6250 clocks required for overflow
* Declare PortD as output

Read Code for ISR Vector details - `main.asm` 
