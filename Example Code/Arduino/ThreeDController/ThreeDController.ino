#include <Esplora.h>
#include "Packetizer.h"

Packetizer slicer;

void setup()
{
  Serial.begin(57600);        // initialize serial communications with your computer
  configurePacketizer();
  Serial.println("Initialization complete.");
}

void configurePacketizer()
{
  slicer.init(128);
  slicer.setStartCondition("?");
  slicer.setEndCondition(";");
  slicer.onPacket(serialPacketWasReceived);  
}

void loop()
{
  readSerialData();
}

void readSerialData() 
{
  while (Serial.available()) {
    int inputByte = Serial.read();    
    if (inputByte < 0) continue;
    
    slicer.appendData((uint8_t)inputByte);
  }
}

void serialPacketWasReceived(byte* inputData, unsigned int inputSize)
{
  if (!memcmp(inputData, "all", 3)) {
    sendOrientation();
    return;
  } else if (!memcmp(inputData, "light", 5)) {
    sendLightReading();
    return;
  } else if (!memcmp(inputData, "slider", 6)) {
    sendSliderReading();
    return;
  }
}

/* Command handlers */

void sendOrientation() {
  int xAxis = Esplora.readAccelerometer(X_AXIS);    // read the X axis
  int yAxis = Esplora.readAccelerometer(Y_AXIS);    // read the Y axis
  int zAxis = Esplora.readAccelerometer(Z_AXIS);    // read the Z axis
    
  Serial.print("all");
  Serial.print(xAxis);
  Serial.print(":");
  Serial.print(yAxis);
  Serial.print(":");
  Serial.print(zAxis);
  Serial.print(";");
}

void sendLightReading() {
  int light = Esplora.readLightSensor();
  light = constrain(light, 600, 1000);
  light = map(light, 600, 1023, 0, 255);
  Serial.print("light");
  Serial.print(light);
  Serial.print(";");
}

void sendSliderReading() {
  int slider = Esplora.readSlider();
  slider = map(slider, 0, 1023, 0, 255);
  Serial.print("slider");
  Serial.print(slider);
  Serial.print(";");
}


