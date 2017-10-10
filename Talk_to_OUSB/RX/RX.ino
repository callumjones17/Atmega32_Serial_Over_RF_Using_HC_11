#include <SoftwareSerial.h>

SoftwareSerial OUSB(7,8); // RX, TX

void setup() {
  // put your setup code here, to run once:
 pinMode(13,OUTPUT);       \\ Set up pin 13 as output
 digitalWrite(13,HIGH);   \\ Make 13 a high (has an led connected).
Serial.begin(9600);       \\ Open Serial Port with PC.
OUSB.begin(9600);         \\ Open Serial Port with OUSB
}

void loop() {
  // put your main code here, to run repeatedly:
 if (OUSB.available()>0){     \\ If OUSB sends data through
  int r = OUSB.read();        \\ Read it 
  Serial.write(r);            \\ And send it to the PC.
 }
 delay(30);                   \\ Delay
}
