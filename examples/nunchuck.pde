/*
 * NunChuck 
 * --------------
 * Implement the WiiChuck library to command a set of LEDs
 * 
 * Arduino pin 6      is connected to WiiChuck Left LED
 * Arduino pin 7      is connected to WiiChuck Right LED
 * Arduino pin 8      is connected to WiiChuck Up LED
 * Arduino pin 9      is connected to WiiChuck Down LED
 * 
 * Created 30 November 2009
 * by Chris P. Gilmer <chris.gilmer@gmail.com>
 * http://blog.chrisgilmer.net/
 */

//--- Include All Libraries
#include <Wire.h>
#include <inttypes.h>
#include "WiiChuck.h"

#define Lledpin 6 // nunchuck left led
#define Rledpin 7 // nunchuck right led
#define Uledpin 8 // nunchuck up led
#define Dledpin 9 // nunchuck down led

#define ledPin 13 // onboard led

//--- Add the WiiChuck object
WiiChuck nunchuck;

//--- Set variables for the nunchuck
uint8_t accx,accy,accz,joyx,joyy,zbut,cbut;

void setup()
{
  // set the serial talk speed
  Serial.begin(57600);
  
  // set the output pins
  pinMode(ledPin, OUTPUT);
  pinMode(Lledpin, OUTPUT);
  pinMode(Rledpin, OUTPUT);
  pinMode(Uledpin, OUTPUT);
  pinMode(Dledpin, OUTPUT);

  nunchuck.setpowerpins();
  nunchuck.init(); // send the initilization handshake
  
  //Serial.print("WiiChuckDemo ready\n");
}

void loop()
{
  nunchuck.get_data();

  accx  = nunchuck.accelx();
  accy  = nunchuck.accely();
  accz  = nunchuck.accelz();
  joyx  = nunchuck.joystickx();
  joyy  = nunchuck.joysticky(); 
  zbut = nunchuck.zbutton();
  cbut = nunchuck.cbutton(); 
  
  //--- Turn on and off ledPin with Z-Button
  if(zbut == 1 ){
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }
  
  if(cbut == 0){
    //Left led accelerometer
    if(accx <= 100){
      digitalWrite(Lledpin, HIGH);
    } else {
      digitalWrite(Lledpin, LOW);}
    //Right led accelerometer  
    if(accx >= 165){
      digitalWrite(Rledpin, HIGH);
    } else {
      digitalWrite(Rledpin, LOW);}
    //Up led accelerometer
    if(accy >= 165){
      digitalWrite(Uledpin, HIGH);
    } else {
      digitalWrite(Uledpin, LOW);}
    //Down led accelerometer
    if(accy <= 100){
      digitalWrite(Dledpin, HIGH);
    } else {
      digitalWrite(Dledpin, LOW);}
    }
  //Enable joystick with C-Button
  else if(cbut == 1){
    //Right led joystick
    if(joyx >= 160){
      digitalWrite(Rledpin, HIGH);
    } else {
      digitalWrite(Rledpin, LOW);}
    //Left led joystick
    if(joyx <= 90){
      digitalWrite(Lledpin, HIGH);
    } else {
      digitalWrite(Lledpin, LOW);}
    //Down led joystick
    if(joyy <= 90){
      digitalWrite(Dledpin, HIGH);
    } else {
      digitalWrite(Dledpin, LOW);}
    //Up led joystick
    if(joyy >= 160){
      digitalWrite(Uledpin, HIGH);
    } else {
      digitalWrite(Uledpin, LOW);}
  }
  
  nunchuck.print_data();
 
  //--- Delay before next update
  delay(100);
}

