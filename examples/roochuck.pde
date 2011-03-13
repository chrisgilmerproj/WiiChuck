/*
 * RooChuck 
 * --------------
 * Implement the RoombaSerial and WiiChuck library to command a roomba
 * using a WiiChuck.
 * 
 * Arduino pin 3 (RX) is connected to Roomba TXD
 * Arduino pin 4 (TX) is connected to Roomba RXD
 * Arduino pin 5      is conencted to Roomba DD
 * 
 * Arduino pin 6      is connected to WiiChuck Left LED
 * Arduino pin 7      is connected to WiiChuck Right LED
 * Arduino pin 8      is connected to WiiChuck Up LED
 * Arduino pin 9      is connected to WiiChuck Down LED
 * 
 * Created 10 December 2009
 * by Chris P. Gilmer <chris.gilmer@gmail.com>
 * http://blog.chrisgilmer.net/
 */

//--- Include All Libraries
#include <Wire.h>
#include <inttypes.h>
#include "NewSoftSerial.h"
#include "RoombaSerial.h"
#include "WiiChuck.h"

//---- Define all pins
#define rxPin 3 // Roomba rx
#define txPin 4 // Roomba tx
#define ddPin 5 // Roomba dd

#define Lledpin 6 // nunchuck left led
#define Rledpin 7 // nunchuck right led
#define Uledpin 8 // nunchuck up led
#define Dledpin 9 // nunchuck down led

#define ledPin 13 // onboard led

//--- Add the Roomba object
RoombaSerial roomba(rxPin,txPin,ddPin);

//--- Set Roomba information
float velLimit = roomba.getVelocityLimit();
float radLimit = roomba.getRadiusLimit();
float conversion = 128.0; // This is half the byte max
float sensitivity = 90.0; // This is an absolute value surrounding 0.0
float deadzone = 0.05;    // This is an absolute value between 0.0 and 1.0

//--- Add the WiiChuck object
WiiChuck nunchuck;

//--- Set variables for the nunchuck
uint8_t accx,accy,accz,joyx,joyy,zbut,cbut;

//--- Setup Code
void setup()
{
   Serial.begin(57600);
   
   //--- Set the output pins
   pinMode(Lledpin, OUTPUT);
   pinMode(Rledpin, OUTPUT);
   pinMode(Uledpin, OUTPUT);
   pinMode(Dledpin, OUTPUT);
   
   //--- Set the LED pin
   pinMode(ledPin, OUTPUT);
   
   //--- Turn on/off LED to indicate init function
   digitalWrite(ledPin, HIGH);
   
   roomba.init(); // send the initialization handshake
   
   nunchuck.setpowerpins();
   nunchuck.init(); // send the initilization handshake
   
   digitalWrite(ledPin, LOW);
   
   //--- Stop the Roomba from moving on startup
   roomba.stopMoving();
   delay(500);
}

//--- Loop Code
void loop()
{
  //--- Turn on/off LED to indicate sensor function
  digitalWrite(ledPin, HIGH);
  //roomba.updateSensors();
  nunchuck.get_data();
  //nunchuck.print_data();
  digitalWrite(ledPin, LOW);
  
  //--- Get the values for each control
  accx  = nunchuck.accelx();
  accy  = nunchuck.accely();
  accz  = nunchuck.accelz();
  joyx  = nunchuck.joystickx();
  joyy  = nunchuck.joysticky(); 
  zbut = nunchuck.zbutton();
  cbut = nunchuck.cbutton(); 
  
  //--- Indicate the value of the joystick on the LEDs
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
  
  //--- Convert joyx/joyy (0 to 255) value to a signed value (-128 to 127)
  float x = ((float)joyx - conversion); // This is for radius (ie turn)
  float y = ((float)joyy - conversion); // This is for velocity
  
  //--- Correct for sensitivity (about +/-60) and normalize (-1.0 to 1.0)
  if(x >  sensitivity) {
    x = 1.0;
  } else if( x< -sensitivity) {
    x = -1.0;
  } else {
    x = x/sensitivity;
  }
  
  if(y >  sensitivity) {
    y = 1.0;
  } else if(y < -sensitivity){
    y = -1.0;
  } else {
    y = y/sensitivity;
  }
  
  //--- Quadratically correct these values for finer control
  x = (x > 0) ? x * x : x * x * -1;
  y = (y > 0) ? y * y : y * y * -1;
  
  Serial.print("x/y:");
    Serial.print(x);
    Serial.print(",");
    Serial.print(y);
    Serial.print("\r\n");
  
  //--- Determine how to drive the roomba
  int16_t velocity, radius;
  //--- Inside the joystick deadzone stop moving the roomba
  if(abs(x) < deadzone && abs(y) < deadzone) {
    roomba.stopMoving();
  }
  //--- If the velocity is within the deadzone then only turning is important
  else if(abs(y) < deadzone) {
    velocity = abs(x) * velLimit;  // Determine speed from radius control
    radius = (x > 0) ? -1.0 : 1.0; // Spin left or right
    roomba.drive(velocity,radius);
  }
  //--- Drive the roomba normally
  else {
    velocity = y * velLimit;
    radius = x * radLimit;
    radius = (x > 0) ? (radLimit - radius) : (-radLimit - radius);
    roomba.drive(velocity,radius);
  }
 
  //--- Delay before next update
  delay(100);
}
