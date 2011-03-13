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

// ensure this library description is only included once
#ifndef WiiChuck_h
#define WiiChuck_h

// include types & constants of Wiring core API and other libraries
#include <WProgram.h>
#include <Wire.h>
#include <inttypes.h>

// library interface description
class WiiChuck
{

  // library-accessible "private" interface
  private:
    uint8_t _nunchuck_buffer[6];   // array to store nunchuck data,
  
  // user-accessible "public" interface
  public:
    
    // Constructor
    WiiChuck(void);
    
    // Uses port C (analog in) pins as power & ground for Nunchuck
    void setpowerpins();
    
    // initialize the I2C system, join the I2C bus,
    // and tell the nunchuck we're talking to it
    void init();
    
    // Send a request for data to the nunchuck
    // was "send_zero()"
    void send_request();
    
    // Encode data to format that most wiimote drivers except
    // only needed if you use one of the regular wiimote drivers
    uint8_t decode_byte (uint8_t x);
    
    // Receive data back from the nunchuck, 
    // returns 1 on successful read. returns 0 on failure
    uint8_t get_data();
    
    uint8_t* get_buffer();
    
    void set_buffer(uint8_t* buffer, uint8_t length);
    
    // Print the input data we have recieved
    // accel data is 10 bits long
    // so we read 8 bits, then we have to add
    // on the last 2 bits.  That is why I
    // multiply them by 2 * 2
    void print_data();
    
    // returns zbutton state: 1=pressed, 0=notpressed
    uint8_t zbutton();
    
    // returns zbutton state: 1=pressed, 0=notpressed
    uint8_t cbutton();
    
    // returns value of x-axis joystick
    uint8_t joystickx();
    
    // returns value of y-axis joystick
    uint8_t joysticky();
    
    // returns value of x-axis accelerometer
    uint8_t accelx();
    
    // returns value of y-axis accelerometer
    uint8_t accely();
    
    // returns value of z-axis accelerometer
    uint8_t accelz();
};

// Arduino 0012 workaround
#undef int
#undef char
#undef long
#undef byte
#undef float
#undef abs
#undef round 

#endif
