# IntroToArduino
Repository for slides and sample code for my Introduction to Arduino presentation at SLC CocoaHeads on February 3, 2015.

Included are two examples for Arduno (these are for the Arduino Esplora board):
- LightTheremin - A very simple "theremin" that uses light sensor input to vary an audio tone played through the speaker.
- ThreeDController - This example responds to serial requests for accelerometer, light sensor, and slider data. Demonstrates serial communication.

There is also a Mac app example called Esplora Accelerometer Demo. This app shows a representation of the Esplora board on screen. It can connect to an Esplora board running the ThreeDController example over the serial/USB connection. The onscreen board's orientation varies depending on the physical board's orientation. The Arduino's light sensor values are used to vary the light level on screen, while the slider on the board controls the color of the onscreen board.

![Esplora Accelerometer Demo app screenshot](screenshot.png?raw=true)