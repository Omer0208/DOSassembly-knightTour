#include <Arduino.h>
#include <SPI.h>
#define cd 3
#define decodeMode 9
#define intensity 10
#define scan 11
#define shutdown 12
#define displayTest 16

void data(uint8_t add, uint8_t val)
{
  SPI.transfer(add);
  SPI.transfer(val);
}
void setup()
{
pinMode(cd,OUTPUT);
SPI.setBitOrder(MSBFIRST);
SPI.begin();

data(displayTest,0x01);
delay(1000);
data(displayTest,0x00);

data(decodeMode,0x00);
data(intensity,0x00);
data(scan,0x0f);
data(shutdown,0x01);

data(2, B10101010);
}
  
void loop()
{
 
}

