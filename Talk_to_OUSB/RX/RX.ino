#include <SoftwareSerial.h>

SoftwareSerial OUSB(7,8); // RX, TX

void setup() {
  // put your setup code here, to run once:
 pinMode(13,OUTPUT);
 digitalWrite(13,HIGH);
Serial.begin(9600);
OUSB.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
 if (OUSB.available()>0){
  int r = OUSB.read();
  Serial.write(r);
 }
 delay(30);
}
