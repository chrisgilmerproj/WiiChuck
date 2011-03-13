/*
 * Nunchuck functions  -- Talk to a Wii Nunchuck
 *
 * This library is from the Bionic Arduino course : 
 *                          http://todbot.com/blog/bionicarduino/
 *
 * 2007 Tod E. Kurt, http://todbot.com/blog/
 *
 * The Wii Nunchuck reading code originally from Windmeadow Labs
 *   http://www.windmeadow.com/node/42
 *
 * Modified 11 December 2009 by Chris P. Gilmer
 *   http://blog.chrisgilmer.net
 *   Code arranged into a C++ library for arduino and cleaned data types
 */

// include core Wiring API
#include <WProgram.h>

// include this library's description file
#include "WiiChuck.h"

// include description files for other libraries used (if any)
#include <Wire.h>
#include <inttypes.h>

//==============================================================================
//==============================================================================
// Private Methods
// Functions only available to other functions in this library
//==============================================================================
//==============================================================================

//==============================================================================
//==============================================================================
// Constructor 
// Function that handles the creation and setup of instances
//==============================================================================
//==============================================================================
WiiChuck::WiiChuck(void){
    // DO NOTHING
}

//==============================================================================
//==============================================================================
// Public Methods 
// Functions available in Wiring sketches, this library, and other libraries
//==============================================================================
//==============================================================================
void WiiChuck::setpowerpins()
{
#define pwrpin PORTC3
#define gndpin PORTC2
    DDRC |= _BV(pwrpin) | _BV(gndpin);
    PORTC &=~ _BV(gndpin);
    PORTC |=  _BV(pwrpin);
    delay(100);  // wait for things to stabilize        
}

//==============================================================================
//==============================================================================
void WiiChuck::init()
{ 
    Wire.begin();                // join i2c bus as master
    Wire.beginTransmission(0x52);// transmit to device 0x52
    Wire.send(0x40);// sends memory address
    Wire.send(0x00);// sends sent a zero.  
    Wire.endTransmission();// stop transmitting
}

//==============================================================================
void WiiChuck::send_request()
{
    Wire.beginTransmission(0x52);// transmit to device 0x52
    Wire.send(0x00);// sends one byte
    Wire.endTransmission();// stop transmitting
}

//==============================================================================
uint8_t WiiChuck::decode_byte (uint8_t x)
{
    x = (x ^ 0x17) + 0x17;
    return x;
}

//==============================================================================
uint8_t WiiChuck::get_data()
{
    int cnt=0;
    Wire.requestFrom (0x52, 6);// request data from nunchuck
    while (Wire.available ()) {
        // receive byte as an integer
        this->_nunchuck_buffer[cnt] = this->decode_byte(Wire.receive());
        cnt++;
    }
    this->send_request();  // send request for next data payload
    // If we recieved the 6 bytes, then go print them
    if (cnt >= 5) {
        return 1;   // success
    }
    return 0; //failure
}


//==============================================================================
uint8_t* WiiChuck::get_buffer()
{
    return this->_nunchuck_buffer;
}

//==============================================================================
void WiiChuck::set_buffer(uint8_t* buffer, uint8_t length)
{
    for(int8_t i = 0; i < length; ++i){
        this->_nunchuck_buffer[i] = buffer[i];
    }
}

//==============================================================================
void WiiChuck::print_data()
{ 
    uint8_t joy_x_axis = this->_nunchuck_buffer[0];
    uint8_t joy_y_axis = this->_nunchuck_buffer[1];
    uint8_t accel_x_axis = this->_nunchuck_buffer[2]; // * 2 * 2; 
    uint8_t accel_y_axis = this->_nunchuck_buffer[3]; // * 2 * 2;
    uint8_t accel_z_axis = this->_nunchuck_buffer[4]; // * 2 * 2;

    uint8_t z_button = 0;
    uint8_t c_button = 0;

    // byte nunchuck_buffer[5] contains bits for z and c buttons
    // it also contains the least significant bits for the accelerometer data
    // so we have to check each bit of byte outnunchuck_buffer[5]
    if ((this->_nunchuck_buffer[5] >> 0) & 1) 
        z_button = 1;
    if ((this->_nunchuck_buffer[5] >> 1) & 1)
        c_button = 1;

    if ((this->_nunchuck_buffer[5] >> 2) & 1) 
        accel_x_axis += 2;
    if ((this->_nunchuck_buffer[5] >> 3) & 1)
        accel_x_axis += 1;

    if ((this->_nunchuck_buffer[5] >> 4) & 1)
        accel_y_axis += 2;
    if ((this->_nunchuck_buffer[5] >> 5) & 1)
        accel_y_axis += 1;

    if ((this->_nunchuck_buffer[5] >> 6) & 1)
        accel_z_axis += 2;
    if ((this->_nunchuck_buffer[5] >> 7) & 1)
        accel_z_axis += 1;

    Serial.print("joy:");
    Serial.print(joy_x_axis,DEC);
    Serial.print(",");
    Serial.print(joy_y_axis, DEC);
    Serial.print("  \t");

    Serial.print("acc:");
    Serial.print(accel_x_axis, DEC);
    Serial.print(",");
    Serial.print(accel_y_axis, DEC);
    Serial.print(",");
    Serial.print(accel_z_axis, DEC);
    Serial.print("\t");

    Serial.print("but:");
    Serial.print(z_button, DEC);
    Serial.print(",");
    Serial.print(c_button, DEC);

    Serial.print("\r\n");  // newline
}

//==============================================================================
//==============================================================================
uint8_t WiiChuck::zbutton()
{
    return ((this->_nunchuck_buffer[5] >> 0) & 1) ? 0 : 1;  // voodoo
}

//==============================================================================
uint8_t WiiChuck::cbutton()
{
    return ((this->_nunchuck_buffer[5] >> 1) & 1) ? 0 : 1;  // voodoo
}

//==============================================================================
uint8_t WiiChuck::joystickx()
{
    return this->_nunchuck_buffer[0]; 
}

//==============================================================================
uint8_t WiiChuck::joysticky()
{
    return this->_nunchuck_buffer[1];
}

//==============================================================================
uint8_t WiiChuck::accelx()
{
    return this->_nunchuck_buffer[2];   // FIXME: this leaves out 2-bits of the data
}

//==============================================================================
uint8_t WiiChuck::accely()
{
    return this->_nunchuck_buffer[3];   // FIXME: this leaves out 2-bits of the data
}

//==============================================================================
uint8_t WiiChuck::accelz()
{
    return this->_nunchuck_buffer[4];   // FIXME: this leaves out 2-bits of the data
}
