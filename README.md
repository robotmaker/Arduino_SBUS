# Arduino_SBUS
Enables a Frysky receiver SBUS connection to control an Arduino - e.g. Lights, PPM servos, sensors

<br>
To get the sketch working you'll first need to convert the inverted SBUS signal to an non-inveted signal such as using a FTDI converter and configured that to invert the signals which will actually invert them back to a non-inverted signal. You can also do that with an inverter or transistors, see the video and webpages below. 
<Br>
https://www.youtube.com/watch?v=UAR65jER6WY
 Also see the webpage: 
  http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation
  http://www.robotmaker.eu/ROBOTmaker/quadcopter-3d-proximity-sensing/sbus-graphical-representation

<br>
To get this Processing sketch to work, you'll need invert the SBUS inverted signal back to a non-inverted signal. 
<li>
Using a simple transistor+2 resistors to invert the signal ..or...
If you have an FTDI USB to TLL serial converter there is a program  (called FT_Prog) on the ftdiChip.com webpage which allows you to configure signal inversions automatically. See this website for examples of how to connect up and make a cable....or...
If you have an X4R you can hack the receiver to obtain non-inverted data directly; without the need to invert the signal by fixing a connector to available position show here (I soldered  directly to inverter pin as I wanted to add a connector later). 
</li>
<br>
The receiver type shouldn't make any difference; -  as it's still the SBUS standard.   
