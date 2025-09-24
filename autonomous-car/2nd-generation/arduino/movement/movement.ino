#include<Embedded_Protocol_2.h>
#include<ArduinoJson.h>
#include<NewPing.h> 

#define d10 10
#define d9 9
#define d8 8

Communication communication;

void setup() {
  Serial.begin(9600);
  pinMode(d10, OUTPUT);
  pinMode(d9, OUTPUT);
  pinMode(d8, OUTPUT);

}

void loop() {
  // String c = Serial.readString();
  // Serial.println(c);
  while(Serial.available() > 0){ //check whether there is some information from the serial (possibly from the agent)
    String s = Serial.readString();
    //s = "move_left";
    Serial.println(s);
    if(s.equals("move_front")){
      digitalWrite(d9, 1);
      delay(150);
      digitalWrite(d9,0);
    } else if(s.equals("move_left")){
      digitalWrite(d10, 1);
      delay(150);
      digitalWrite(d10,0);
    } else if(s.equals("move_right")){
      digitalWrite(d8, 1);
      delay(150);
      digitalWrite(d8,0);
    } else {
      digitalWrite(d10, 1);
      delay(100);
      digitalWrite(d10,0);
      delay(100);
      digitalWrite(d10, 1);
      delay(100);
      digitalWrite(d10,0);
    }
  }
  //  digitalWrite(d10, HIGH);
  //  delay(3000);
  //  digitalWrite(d10, LOW);
  //  delay(3000);

  //delay(800);
}
