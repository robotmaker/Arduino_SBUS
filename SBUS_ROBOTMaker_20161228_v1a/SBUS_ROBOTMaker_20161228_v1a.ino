

/* ROBOTmaker 28.12.2016
 * This example decodes a Futaba SBUS or compatible stream and convert it to soft switches or PPM.
 * 
 * Thanks goes to https://www.ordinoscope.net/index.php/Electronique/Protocoles/SBUS for the arduino code which was converted to for our use
 * It is based on a verion found  :
 * - https://github.com/zendes/SBUS
 * - http://forum.arduino.cc/index.php?topic=99708.0
 * - https://mbed.org/users/Digixx/notebook/futaba-s-bus-controlled-by-mbed/
 * 
 * There are some inexpensibe SBUS to PPM decoders, such as
 * http://www.hobbyking.com/hobbyking/store/__37953__frsky_4_channel_s_bus_to_pwm_decoder.html
 * This code is more a proof of concept than a real alternative.
 *
 *Further details on our website:
 *http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
 *
 * This code uses the RX0 as input. It's not possible to use a software serial port, because
 * there are too many conflicting interrupts between serial input and PWM generation.
 *
 * Since RX0 is also used to communicate with the FTDI, the SBUS must be disconnected while
 * flashing the Arduino.
 *
 * Furthermore, the SBUS uses an inverted serial communication. Why should the Futaba designers of the SBUS make life simple when
 * it's so much fun to make it more difficult? Inverting the signal is easy and can be done with a simple transistor / resistor (see our website) or an inverter:
 * http://www.hobbyking.com/hobbyking/store/__24523__ZYX_S_S_BUS_Connection_Cable.html
 * (the shortest end goes to the receiver, the longest to the Arduino)
 * Alternatively, if you use an X4R you can tap directly into the inverted signal provided on the PCB for a side connector. Details of how to do this are on our website. 
 * See http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
 * 
 * The code works on an Arduino Pro Mini. It will probably work on others too, but I haven't tried on other versions yet
 * Ensure to Download the library ->  <SoftwareSerial.h> and <Servo.h> via the Arduino IDE otherwise the code won't compile
 * 
 * 
 * 
 * 
  */
#include <SoftwareSerial.h>
//#include <SoftwareServo.h>
#include <Servo.h>
#define rxPin 7
#define txPin 8
Servo myservo8;  // create servo object to control a servo
int pos = 0;    // variable to store the servo position

//Not used in the Demo
//Servo myservo9;  // create servo object to control a servo 
//Servo myservo10;  // create servo object to control a servo 
//Servo myservo11;  // create servo object to control a servo 
//SoftwareSerial InvertedSerialPort =  SoftwareSerial(rxPin, txPin, true); //(Tx,TX, Inverted mode ping this device uses inverted signaling
//For Piezo Buzzer

//***********************************************************************
//     Setup 
//***********************************************************************
void setup () 
{ 

  //The pins on the Arduino need to be defined. In this demo pin 9-13 are used. Pin 13 is the LED on the Arduino which is 
  //a simple mehod for debugging. The demo turns this on when the Channel 1 (often used for throttle) exceeds a predefined SBUS level. 
     pinMode(13, OUTPUT); //Debug with LED
     pinMode(12, OUTPUT); //Debug with LED
     pinMode(11, OUTPUT); //Debug with LED
     pinMode(10, OUTPUT); //Debug with LED
     pinMode(9, OUTPUT); //Debug with LED
     pinMode(rxPin, INPUT);
     pinMode(txPin, OUTPUT);
     myservo8.attach(8);  // attaches the servo on pin 8 to the servo object
     //myservo11.attach(11);  // attaches the servo on pin 11 to the servo object
     Serial.begin(100000,SERIAL_8E2); //The SBUS is a non standard baud rate which can be confirmed using an oscilloscope  
  }

//***********************************************************************
//     Loop
//***********************************************************************
void loop () 
{
  
  //Declare the variabes
  static byte          buffer[25];
  static int           channels[18];
  static int           errors = 0;
  static bool          failsafe = 0;
  static int           idx;
  static unsigned long last_refresh = 0;
  static int           lost = 0;
  byte b;
  int  i;
  int redPin = 3;
  int greenPin = 5;
  int bluePin = 6;
  word results;
  


 //Check the serial port for incoming data
 //This could also be done via the serialEvent()
  if (Serial.available ()) {
      b = Serial.read ();
       
     //this is a new package and it' not zero byte then it's probably the start byte B11110000 (sent MSB)
     //so start reading the 25 byte package
      if (idx == 0 && b != 0x0F) {  // start byte 15?
       // error - wait for the start byte
        
      } else {
        buffer[idx++] = b;  // fill the buffer with the bytes until the end byte B0000000 is recived
      }
   
    if (idx == 25) {  // If we've got 25 bytes then this is a good package so start to decode
      idx = 0;
      if (buffer[24] != 0x00) {
        errors++;
      } else 
      {
            //  Serial.println("Found Packet");
            // 25 byte packet received is little endian. Details of how the package is explained on our website:
            //http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
            channels[1]  = ((buffer[1]    |buffer[2]<<8)                 & 0x07FF);
            channels[2]  = ((buffer[2]>>3 |buffer[3]<<5)                 & 0x07FF);
            channels[3]  = ((buffer[3]>>6 |buffer[4]<<2 |buffer[5]<<10)  & 0x07FF);
            channels[4]  = ((buffer[5]>>1 |buffer[6]<<7)                 & 0x07FF);
            channels[5]  = ((buffer[6]>>4 |buffer[7]<<4)                 & 0x07FF);
            channels[6]  = ((buffer[7]>>7 |buffer[8]<<1 |buffer[9]<<9)   & 0x07FF);
            channels[7]  = ((buffer[9]>>2 |buffer[10]<<6)                & 0x07FF);
            channels[8]  = ((buffer[10]>>5|buffer[11]<<3)                & 0x07FF);
            channels[9]  = ((buffer[12]   |buffer[13]<<8)                & 0x07FF);
            channels[10]  = ((buffer[13]>>3|buffer[14]<<5)                & 0x07FF);
            channels[11] = ((buffer[14]>>6|buffer[15]<<2|buffer[16]<<10) & 0x07FF);
            channels[12] = ((buffer[16]>>1|buffer[17]<<7)                & 0x07FF);
            channels[13] = ((buffer[17]>>4|buffer[18]<<4)                & 0x07FF);
            channels[14] = ((buffer[18]>>7|buffer[19]<<1|buffer[20]<<9)  & 0x07FF);
            channels[15] = ((buffer[20]>>2|buffer[21]<<6)                & 0x07FF);
            channels[16] = ((buffer[21]>>5|buffer[22]<<3)                & 0x07FF);
            channels[17] = ((buffer[23])      & 0x0001) ? 2047 : 0;
            channels[18] = ((buffer[23] >> 1) & 0x0001) ? 2047 : 0;
     
            failsafe = ((buffer[23] >> 3) & 0x0001) ? 1 : 0;
            if ((buffer[23] >> 2) & 0x0001) lost++;
            //serialPrint (lost); debg the signals lost

          
            //For this demo, the corresponding channels mapped below need to be also configured on the FrSky Taranis tranmitter accordingly.
            //Any of the Channels can of course be used trigger any of the pins on the Arduino 
            //Channels used in the demo are 5,6,7. Mapped these to the sliders on the transmitter to change RGB LED values
            //Channel 1 set to trigger the Internal Arduino LED on pin 13 once the threshold exceeds 1500
            //Channel 10 needs to be mapped to one of the switches on the Taranis which triggers a buzzer on pin 10 of the Arduino 
            //Channel 1 also triggers a servo connected to pin 8 on the Arduino. So moving the throttle will also move the servo accordingly
            
            
            //***********************************************************************
            //Create RGB 3 colour LED display using PWM on pins mapped to Ch5=S1, Ch6=S2 Ch7=LS 
            //The channels used in the demo are 5,6,7. Mapped these to the sliders on the transmitter to change
            //The amount of RGB values          
            //***********************************************************************
            int RedLed = map(channels[5],0,2000,0,255);
            int GreenLed = map(channels[6],0,2000,0,255);
            int BlueLed = map(channels[7],0,2000,0,255);
            analogWrite(redPin, RedLed);
            analogWrite(greenPin, GreenLed);
            analogWrite(bluePin, BlueLed);  

        
            //***********************************************************************
            //Turn on internal Arduino LED 13 if channel 1 (thrust) exceeds 1500.
            //***********************************************************************
             results=channels[1];
              Serial.write (results);
            if (channels[1] > 1500){
              
              digitalWrite(13, HIGH);
             }
             else 
             {
              digitalWrite(13, LOW);
             }
            
            //***********************************************************************
            //Turn on LED. Channel 16 mapped to switch SF to trigger Buzzer on pin 12
            //***********************************************************************
            serialPrint (channels[1]);
             if (channels[16] > 500){
             digitalWrite(12, HIGH);
             }
             else 
             {
              digitalWrite(12, LOW);
             }    
             
             
             
             //*********************************************************************** 
             //Drive a Servo connected to channel 1 (which is mapped to thrust if you are using Mode 2) 
             //Servo connected to pin 8 on the Arduino
             //***********************************************************************  
               // Proportionaly Map the position of the S.BUS channel to the server position
                int servoPosition = map(channels[1],0,2000,0,180);
                myservo8.write(servoPosition ); // tell servo to go to position in variable servoPosition
    
              //***********************************************************************
              //Turn on or off a buzzer. Channel 10 is mapped to switch SH.
              // Buzzer connected to pin 10 on Arduino
              //***********************************************************************
              if (channels[10] > 1500){
                  digitalWrite(10, HIGH);  
                 }
               else 
                 {
                  digitalWrite(10, LOW); 
                 }
          } //closing - else
      } //closing - if (idx == 25)
    } //closing - if (Serial.available ())
} //closing void loop
