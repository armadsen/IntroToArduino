#include <Esplora.h>

void setup() {
}

void loop() 
{
  if (Esplora.readButton(SWITCH_DOWN) == LOW) {
    
    int light = Esplora.readLightSensor();
    light = constrain(light, 600, 1000);
    light = map(light, 500, 1000, 380, 650);
    Esplora.tone(light);
  } else {
    Esplora.noTone();
  }

}
