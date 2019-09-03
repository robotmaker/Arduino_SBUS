# Arduino_SBUS
Read the WIKI to understand a bit more about how all this works. 

As a summary, this sketch enables a Frysky receiver SBUS connection to control pins on an Arduino, i.e. to expand your RC receiver and give you full 16 channels to activate extra cool devices on your radio controlled model, such as Lights, PPM servos, sensors, parachute,etc....the skys the limit :-)

<br>
To get the sketch working you'll first need to convert the inverted SBUS signal to an non-inveted signal as the arduino doesn't (at the time of writing this code) have the ability to invert it via code. 
<br>
For testing purposes you can just use a FTDI converter. However, you'll first need to configured the FTDI to invert the invertd signal back to a non-invered signal (confused? don't worry! just hang on here for a while). For a permanent solution, there are some dedicated "inverter chips" that do that for you or just use a couple of  transistors and resistors, or you can do a simple hack on your receiver to tap directly into the non-inverted SBUS signal that's already on the reciever itself (duh- why don't the manufacturers just prodvide this as an output option?). See the video and webpages below, which explain all these methods to invert the SBUS signal. 
<Br>
https://www.youtube.com/watch?v=UAR65jER6WY
 Also see the webpage: 
 http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
  

<br>
As explained above, to get this Processing sketch to work, you'll need to invert the SBUS inverted signal back to a non-inverted signal. 
<li>
Using a simple transistor+2 resistors to invert the signal http://blog.oscarliang.net/sbus-smartport-telemetry-naze32/..or...
 <li>
If you have an FTDI USB to TLL serial converter there is a program  (called FT_Prog http://www.ftdichip.com/Support/Utilities/FT_Prog_v3.0.60.276%20Installer.zip) on the ftdiChip.com webpage which allows you to configure signal inversions automatically. See this website for examples of how to connect up and make a cable http://clipvideo.ga/video/_-EouL2nNgE/how-to-make-an-frsky-programming-cable.html....or...
<li>
The easiest method is if you have an X4R you can do a very simple "hack" of the receiver's PCB to obtain a non-inverted data directly; this avoids having to add additional hardware to invert the signal. There is just one pin on the X4R where I simple solder a pin header connector to and... dahdah.. I have an instant non-inverted signal and it works like a dream!  All is explained in the website below. 
 http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
</li>
<br>
For this demo, the corresponding channels mapped below need to be also configured on the FrSky Taranis tranmitter accordingly.
Any of the Channels can of course be used trigger any of the pins on the Arduino. But this is just a Proof of Concept
<br>
Channels used in the demo are 5,6,7. Mapped these to the sliders on the transmitter to change RGB LED values
<li>
Channel 1 set to trigger the Internal Arduino LED on pin 13 once the threshold exceeds 1500
<li>
Channel 10 needs to be mapped to one of the switches on the Taranis which triggers a buzzer on pin 10 of the Arduino 
<li>
 Channel 1 also triggers a servo connected to pin 8 on the Arduino. So moving the throttle will also move the servo according
 </li>
 <br>
 Have fun :-)
 <br>
 Colin Bacon
