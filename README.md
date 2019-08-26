# Arduino_SBUS
Enables a Frysky receiver SBUS connection to control an Arduino - e.g. Lights, PPM servos, sensors

<br>
To get the sketch working you'll first need to convert the inverted SBUS signal to an non-inveted signal,  e.g. by using a FTDI converter. You'll need to configured the FTDO to invert the signals which will actually invert them back to a non-inverted signal. You can also do that with an inverter chip or transistors, see the video and webpages below. 
<Br>
https://www.youtube.com/watch?v=UAR65jER6WY
 Also see the webpage: 
  http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
  

<br>
To get this Processing sketch to work, you'll need invert the SBUS inverted signal back to a non-inverted signal. 
<li>
Using a simple transistor+2 resistors to invert the signal http://blog.oscarliang.net/sbus-smartport-telemetry-naze32/..or...
 <li>
If you have an FTDI USB to TLL serial converter there is a program  (called FT_Prog http://www.ftdichip.com/Support/Utilities/FT_Prog_v3.0.60.276%20Installer.zip) on the ftdiChip.com webpage which allows you to configure signal inversions automatically. See this website for examples of how to connect up and make a cable http://clipvideo.ga/video/_-EouL2nNgE/how-to-make-an-frsky-programming-cable.html....or...
<li>
Easiest method is if you have an X4R you can very easily hack the receiver's PCB to obtain non-inverted data directly; without the need to invert the signal by fixing a connector to available position, as shown in the website below. I simply added a pin header connector directly to the inverter pin and it works like a dream! 
 http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
</li>
<br>
The receiver type shouldn't make any difference; -  as it's still the SBUS standard.   
