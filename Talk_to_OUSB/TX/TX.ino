#include <SoftwareSerial.h>

SoftwareSerial OUSB(2,3); // RX, TX, OUSB connected to PIN 3

void setup() {
  // put your setup code here, to run once:
 pinMode(13,OUTPUT);      \\  Set up pin 13 as output.
 digitalWrite(13,HIGH);   \\ Make 13 high (has an led attached).
Serial.begin(9600);       \\ Open serial port with PC
OUSB.begin(9600);         \\ Open Serial port with OUSB
}

void loop() {
  // put your main code here, to run repeatedly:
 if (Serial.available()>0){   \\ If PC sends data through
  char r = Serial.read();     \\ Read it
  OUSB.write(r);              \\ Send it through to OUSB
  Serial.write(r);            \\ And echo it back to PC (proves it made it through).
 }
 delay(20);                   \\ Delay
}
