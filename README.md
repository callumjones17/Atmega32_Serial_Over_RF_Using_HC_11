# Atmega32 Serial over RF using HC 11
Using the HC 11 module to communicate between 2 OUSB boards (atmega32). Written in Assembler.

There are three levels to this project. First the fundamental pieces of software, followed by 
two projects which implement the first levels code, and finally, the final project.

# Level 1:
  -keypad: Code communicates and decodes a 12 digit (4x3) keypad connected to portc.
  -rs232_rx: Code interprets rs232 serial comming in on portb
  -rs232_tx: Code transmits ascii characters using rs232 protocol.
  -intterupt_test: Code demonstrates how to use an external interrupt on the atmega32
 
# Level 2:
  -TX_WithKeypad
  -rs232_rx_lcd
  -rs232_rx

# Level 3:
  -Full Duplex (not finished yet).
