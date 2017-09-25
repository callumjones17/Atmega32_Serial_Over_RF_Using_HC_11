#include <SoftwareSerial.h>

SoftwareSerial OUSB(2,3); // RX, TX

void setup() {
  // put your setup code here, to run once:
 pinMode(13,OUTPUT);
 digitalWrite(13,HIGH);
Serial.begin(9600);
OUSB.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
 if (Serial.available()>0){
  char r = Serial.read();
  OUSB.write(r);
  Serial.write(r);
 }
 delay(20);
}
