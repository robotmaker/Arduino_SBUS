// Graphical represetentation of Futuba SBUS - also used in FrySky Receivers 
// Example by Colin Bacon
// ROBOTmaker
// www.robotmaker.eu

//Thanks goes to Futaba for making this SBUS protocol so challenging for everyone. Talk about "why make things simple if we can make things extermely difficult..."
//To get this to work you'll need to have SBUS conneted receiver that is connected via an Arduiono or  FTDI USB thingy to your PC
//As the SBUS is an inverted signal (yes - to make life even more fun), you'll need to invert the signal using a simple transitor+2 restistors or if you have an FTDI there is a program to invert the signals automatically
//Detail of how to do this are on our website


// References
//https://developer.mbed.org/users/Digixx/notebook/futaba-s-bus-controlled-by-mbed/
//http://www.clubamcl.fr/techniques/la-technologie-futaba-s-bus/
//Thanks goes to https://www.ordinoscope.net/index.php/Electronique/Protocoles/SBUS for the arduino code which I converted to processing


import processing.serial.*;

Serial myPort;  // The serial port
float x, y;

String    myString = null;
int []    buffer = new int [25];
int []    channels = new int [18];
int       errors = 0;
boolean   failsafe = false;
int       idx, inByte, lost, packetErrors;
long      last_refresh = 0;
float     ymag = 0;
float     newYmag = 0;
float     xmag = 0;
float     newXmag = 0; 

void setup() 
{
    size(1500, 600, FX2D); //give good dashboard resolutions
    // size(1500, 600, P3D); //used for drawing cubes
    //fullScreen(); //This sets it to full screen, but comment out the size commmand above
    pixelDensity(1);
    
    x = width * 0.3;
    y = height * 0.5;
    
    // Variable for drawing the cube
   
    
    // List all the available serial ports
    printArray(Serial.list());
    // Open the port you are using at the rate you want:
    myPort = new Serial(this, Serial.list()[0], 100000,'E',8,2);
    myString = myPort.readStringUntil(15); //clean the first buffer
    println(myPort); //Debug to show the port opened
}

void draw() 
{
  
 //Check for incoming Serial Port Data
 if (myPort.available() == 0){
   
   //If no incoming data then count lost packages
    packetErrors++; 
    text ("No Signal", 140,20);
 }
 
 //When data is comming in then check for a start byte No.1=B11110000 and stop byte No.25=B00000000 
 while (myPort.available() > 0) {
     inByte = myPort.read();              //Read the Byte that just came in
    
    //if it's a new packet and the start byte is not  B00001111 (DEC15) then it's an error. 
    //Note that the SBUS byte data is MSB,  which causes some fun later
      if (idx == 0 && inByte != 0x0F) // error - wait for the start byte 
      {          
     text("Package Error", 100,100);
      
      } 
      // if it's a new packet and the start byte is  B00001111 (DEC15) then start reading the next 25 bytes.   
      else {
      buffer[idx++] = inByte;  // fill the buffer with 25 Bytes
    }
   
   // if the buffer of 25 Bytes is reached then start to decode   
      if (idx == 25) 
      {  
          idx = 0;  //reset the buffer count for the next cycle
          if (buffer[24] != 0x00) 
              {  //Check that the packet size is 25 bytes long with stop byte b00000000 as the last byte
              errors++;                //Count the number of errors
              println(errors);         //Print to the error totals to the dashboard
              } 
      else 
      { //Start decoding the bits and bytes
        
        //Buffer[0] contains the start byte value of 15,  so this is ignored
        //The Channels are 11 bits in length, so the bytes need to be split-up 
        //To make this conversion more 'interesting' as the bytes arrive as MSB i.e. the highest byte arrives first and the channels are 
        //assembled as little endian, which means the 1st 3 bits of the second byte need to comes before the 1st byte. 
        
        //--------------Channel 1 -------------------
        // The 1st channel = 1st byte + 3 bits from the 2nd byte
        // This channel packet of 11 bits is  then read backwards. 
        // As the inByte variable is already converted to integers we can move bits along as follows:
        // byte 1 = 00000000 00000011  (say the value is 3)
        // byte 2 = ‭01100100‬  (say the value of the 2nd byte is 100) 
        // but we are only interested in the last 3 bits which need to be moved infront of the 1st byte,...
        // byte 2 = ‭01100100 00000000 - ...So shift this byte along left by 8 and it looks like this 
        // byte 2 = | (or) the two bytes together and you get this
        // byte 1 =    00000000 00000011
        // byte 2 =    ‭01100100 00000000
        // Channel 1 = 01100100 00000011 <- the intermediate result
        // But we were only  interested in the 1st 3 bits of byte 2 so we need strip the 1st 5 bits by and-ing with 2047 (11 bits)
        // & (and) the two together and you get this....
        // Channel1 = 01100100 00000011 
        // 2047     = 00000111 11111111
        // Channel1 = 00000100 00000011 <- the final result
        //The bytes are litte Endian which means that to read the full
        
        channels[0]  = ((buffer[1]|buffer[2]<<8) & 0x07FF); //The first Channel
        
        //--------------Channel 2 -------------------
        // 2nd Channel = last 5 bit of byte2 and 8 bits of byte 3. Here we need to play around some more.
        // Remove the 1st 3 bits of byte2 by pushing them off to the right
        // byte 2   = 00000000 ‭01100100
        // byte 2   = 00000000 ‭00001100 moved 3 to the right
        // byte 3   = 00000000 ‭01010100 lets say that byte 3 is this
        // byte 3   = 00001010 10000000 moved 5 to the left to get the 5 bytes we need in place (remember this is MSB so bits in byte 3 comes before bits in byte 2)
        // | (or) byte 2 and 3 them together to get the 11 bits in place for channels2
        // byte 2   = 00000000 ‭00001100 
        // byte 3   = 00001010 10000000 
        // Channel2 = 00001010 10001100 < - result of| (or-ing) them together 
        // again we were only  interested in 11 bits so strip the package by and-ing with 2047 (11 bits)
        // & (and) the two together and you get this....
        // Channel2 = 00001010 10001100 < - interim result of| (or-ing) them together 
        // 2047     = 00000111 11111111 
        // Channel2 = 00000010 10001100 < - result of &  (and-ing) them together 
        
        channels[1]  = ((buffer[2]>>3|buffer[3]<<5)  & 0x07FF);
        
        //--------------Channel 3 -------------------
        // 3rd Channel = last 2 bit of byte3 and 8 bits of byte 4 and some bits from byte 5. 
        // Here we have even more to play around with. Someone with a sense of humour surely designed this. 
        // Talk about "why make things simple if we can make it very difficult..."
        // Remove the 1st 6 bits of byte3 by pushing them off to the right
        // byte 2   = 00000000 ‭00001100 
        // byte 3   = 00000000 ‭00000001 moved 6 to the right
        // byte 4   = 00000000 10101010 lets say that byte 4 is this
        // byte 4   = 00000010 10101000 moved 2 to the left to get the  bytes we need in place
        // | (or) byte 3 and 4 together to get the 11 bits in place for channels3
        // byte 3   = 00000000 ‭00000001
        // byte 4   = 00000010 10101000
        // Channel3 = 00000010 10101001 < - result of| (or-ing) them together 
        // byte 5   = 00000000 10110101 lets say that byte 5 is this
        // byte 5   = 11010100 00000000 moved 10 to the left to get the  bytes we need in place
        // Channel3 = 00000010 10101001 < - result of prrevious| (or-ing) them together 
        // Channel3 = 11010110 10101001 <- result of or-ing shift byte 5 and previous or-ing
        // | (or) byte 5  together with the current channel 3  to get the 11 bits in place for channels3
        // again we were only  interested in 11 bits so strip the package by and-ing with 2047 (11 bits)
        // & (and) the two together and you get this....
        // Channel3 = 11010110 10101001 <- result of or-ing shift byte 5 and previous or-ing
        // 2047     = 00000111 11111111 
        // Channel3 = 00000110 10101001 < - result of &  (and-ing) them together 
        // ...and so on
        channels[2]  = ((buffer[3]>>6 |buffer[4]<<2 |buffer[5]<<10)  & 0x07FF);
        channels[3]  = ((buffer[5]>>1 |buffer[6]<<7) & 0x07FF);
        channels[4]  = ((buffer[6]>>4 |buffer[7]<<4) & 0x07FF);
        channels[5]  = ((buffer[7]>>7 |buffer[8]<<1 |buffer[9]<<9)   & 0x07FF);
        channels[6]  = ((buffer[9]>>2 |buffer[10]<<6) & 0x07FF);
        channels[7]  = ((buffer[10]>>5|buffer[11]<<3) & 0x07FF);
        channels[8]  = ((buffer[12]   |buffer[13]<<8) & 0x07FF);
        channels[9]  = ((buffer[13]>>3|buffer[14]<<5)  & 0x07FF);
        channels[10] = ((buffer[14]>>6|buffer[15]<<2|buffer[16]<<10) & 0x07FF);
        channels[11] = ((buffer[16]>>1|buffer[17]<<7) & 0x07FF);
        channels[12] = ((buffer[17]>>4|buffer[18]<<4) & 0x07FF);
        channels[13] = ((buffer[18]>>7|buffer[19]<<1|buffer[20]<<9)  & 0x07FF);
        channels[14] = ((buffer[20]>>2|buffer[21]<<6) & 0x07FF);
        channels[15] = ((buffer[21]>>5|buffer[22]<<3) & 0x07FF);
        channels[16] = ((buffer[23]));
        //channels[16] = ((buffer[23])      & 0x0001) ? 2047 : 0;
        //channels[17] = ((buffer[23] >> 1) & 0x0001) ? 2047 : 0;
        //failsafe = ((buffer[23] >> 3) & 0x0001) ? 1 : 0;
        //if ((buffer[23] >> 2) & 0x0001) lost++;  
      }   
      } //For loop
      
 //pushMatrix();
      int pos1=0,channelText = 0;
      //Set the background colour of the bargraphs
      background(199);
      
 //Cycle through all channels and draw a bar chart for each channel value
      for(int c=0;c<16;c++){
        
       //Set the colour of the bar chart graphics
          noStroke(); //remove the graphic boarder lines
          fill(17,37,204); //set the colour of bar chart
       
       //Map Channel bar graph
          float z= float(channels[c]); //convert to a float
          float x1 = map(z,160,2000,0,width*0.95);
          int yoffSet = 50;
          pos1 = pos1 + 20; //y postion of bar on the canvas
          channelText = channelText + 1;
          rect(100, pos1+yoffSet , x1, 15);
          fill(0);
          text("Channel" + channelText + " = ", 5,pos1+10+yoffSet);
          text(channels[c],70,pos1+10 + yoffSet);
      
      //Draw the dashboard title and status messages
          textSize(26); 
          text("Open TX SBUS - Status Dashboard", width/2-150, 30); //Place the text in the centre of the dashboard
          textSize(10); //Reset text size
    
      //If the bits in byte23  are set, then there is an error. Display a warning 
          if (buffer[23] >= 12) {
              fill(226,72,47);
              ellipse(50,40,20,20); //Draw a red warning led
              fill(0); //colour the text
              textSize(12); //Reset text size
              text("Signal Lost",30,20);
              textSize(11); //Reset text size
            }
           else
            {
              fill(22,205,65);
              ellipse(50,40,20,20); //Draw a green warning led
              fill(0); //colour the text
              textSize(12); //Reset text size
              text("Signal OK",30,20);
             textSize(11); //Reset text size
            }
            
        //Place the error counts message
           textSize(12); //Reset text size
           text("Errors", 120,20);
           text("bytes23= ", 100,40);
           text(buffer[23],150,40);
           textSize(11); //Reset text size
           text("Count= ", 100,55);
           text(errors, 150,55);
            
           //Place the lost package message
           textSize(12); //Reset text size
           text("Lost Packages", 170,20);
           textSize(11); //Reset text size
           text(packetErrors, 190,40);         
      
 
  } //if  
 } //While
   
 } 
 