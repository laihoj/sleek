

/*
 Controlling a servo position using a potentiometer (variable resistor)
 by Michal Rinott <http://people.interaction-ivrea.it/m.rinott>

 modified on 8 Nov 2013
 by Scott Fitzgerald
 http://www.arduino.cc/en/Tutorial/Knob

 
  Example Bluetooth Serial Passthrough Sketch
 by: Jim Lindblom
 SparkFun Electronics
 date: February 26, 2013
 license: Public domain

 This example sketch converts an RN-42 bluetooth module to
 communicate at 9600 bps (from 115200), and passes any serial
 data between Serial Monitor and bluetooth module.
 */

#include "mpu9250.c"
#include <Wire.h> //I2C library



/************************************************************
 * Arduino hardware readings
*************************************************************/
//Direct readings from IMU MPU9250
signed int roll = 0;
signed int pitch = 0;
signed int yaw = 0;
//smoothing values by averaging
int averageArrayIndex = 0;
int averageArrayIndexSize = 10;
signed int rollArr[] = {0,0,0,0,0,0,0,0,0,0};
signed int pitchArr[] = {0,0,0,0,0,0,0,0,0,0};
signed int rollAverage = 0;
signed int pitchAverage = 0;





/************************************************************
 * MPU9250 data storage
*************************************************************/
byte accelData[6];
byte tempData[2];
byte gyroData[6];
byte magnetoData[6];



/*----------------------------------------------------------
 * Setup
------------------------------------------------------------*/

void setup(){

  
  /*********
   * LED to tell powered
  ***********/
  pinMode(13,OUTPUT);
  digitalWrite(13, HIGH);

  /*********
   * Begin communication streams
  ***********/
  Wire.begin(); // Begin I2C for mpu9250
  Serial.begin(57600);  // Begin the serial monitor at 9600bps
  delay(100);
  Serial.println("Started");

  /*********
   * MPU setup
  ***********/
  //INIT MPU
  // wake up device
  // Clear sleep mode bit (6), enable all sensors
  writeByte(MPU9250_ADDRESS, PWR_MGMT_1, 0x00);
  delay(100); // Wait for all registers to reset
  writeByte(MPU9250_ADDRESS, INT_ENABLE, 0x01);
  // Configure Interrupts and Bypass Enable
  // Set interrupt pin active high, push-pull, hold interrupt pin level HIGH
  // until interrupt cleared, clear on read of INT_STATUS, and enable
  // I2C_BYPASS_EN so additional chips can join the I2C bus and all can be
  // controlled by the Arduino as master.
  writeByte(MPU9250_ADDRESS, INT_PIN_CFG, 0x22);
  // Enable data ready (bit 0) interrupt
  writeByte(MPU9250_ADDRESS, INT_ENABLE, 0x01);
  delay(100);
} 




/*----------------------------------------------------------
 * Loop
------------------------------------------------------------*/

void loop() {
  /*********
   * Read MPU9250
  ***********/

  /*READ ACCELEROMETER*/
  Wire.beginTransmission(SENSOR_I2CADD); //Begin transmission to slave address
  Wire.write(ACCEL_XOUT_H); //Register address within the sensor where the data is to be read from
  Wire.endTransmission();
  Wire.requestFrom(SENSOR_I2CADD, 6); //Get 6 bytes from the register address 
  int i = 0;
  while(Wire.available()) //If the buffer has data
  {
    accelData[i] = Wire.read(); //Save the data to a variable
    i++;
  }
  int accelX = accelData[1] | (int)accelData[0] << 8;
  int accelY = accelData[3] | (int)accelData[2] << 8;
  int accelZ = accelData[5] | (int)accelData[4] << 8;


  /*READ TEMPERATURE*/
  Wire.beginTransmission(SENSOR_I2CADD); //Begin transmission to slave address
  Wire.write(TEMP_OUT_H); //Register address within the sensor where the data is to be read from
  Wire.endTransmission();
  Wire.requestFrom(SENSOR_I2CADD, 2); //Get 2 bytes from the register address 
  i = 0;
  while(Wire.available()) //If the buffer has data
  {
    tempData[i] = Wire.read(); //Save the data to a variable
    i++;
  }
  int temp = tempData[1] | (int)tempData[0] << 8;

  /*READ GYRO*/
  Wire.beginTransmission(MPU9250_ADDRESS); //Begin transmission to slave address
  Wire.write(GYRO_XOUT_H); //Register address within the sensor where the data is to be read from
  Wire.endTransmission();
  Wire.requestFrom(SENSOR_I2CADD, 6); //Get 6 bytes from the register address 
  i = 0;
  while(Wire.available()) //If the buffer has data
  {
    gyroData[i] = Wire.read(); //Save the data to a variable
    i++;
  }
  int gyroX = gyroData[1] | (int)gyroData[0] << 8;
  int gyroY = gyroData[3] | (int)gyroData[2] << 8;
  int gyroZ = gyroData[5] | (int)gyroData[4] << 8;
  
  /*READ MAGNETOMETRI*/
  //turning magnetometer off and on is a workaround that makes output value update
  writeByte(AK8963_ADDRESS, AK8963_CNTL, 0x00); // Power down magnetometer
  delay(10);
  writeByte(AK8963_ADDRESS, AK8963_CNTL, 0x16);
  delay(10);
  Wire.beginTransmission(AK8963_ADDRESS);
  Wire.write(AK8963_XOUT_L);
  Wire.endTransmission();
  
  byte rawData[6];
  i = 0;
  // Read bytes from slave register address
  Wire.requestFrom(AK8963_ADDRESS, 6);
  while (Wire.available())
  {
    // Put read results in the Rx buffer
    rawData[i++] = Wire.read();
  }

  int magnetoX = ((int16_t)rawData[1] << 8) | rawData[0];
  int magnetoY = ((int16_t)rawData[3] << 8) | rawData[2];
  int magnetoZ = ((int16_t)rawData[5] << 8) | rawData[4];




  
  /*********
   * Store data to values
  ***********/

  /****
   * mapping
  ******/

  //accelerometer stuff
  float x = accelX * 16.0f / 32768.0f;
  float y = accelY * 16.0f / 32768.0f;
  float z = accelZ * 16.0f / 32768.0f;
  

  //magnetometer stuff
  float magx = magnetoX * 10.0f * 4912.0f / 32760.0f;
  float magy = magnetoY * 10.0f * 4912.0f / 32760.0f;
  

  /****
   * store to variables
  ******/
//  roll =  floor(degrees(atan2(-x, sqrt(y * y + z * z))));
//  pitch = floor(degrees(atan2(y,z)));
//  //atan2 needs correction for correct quadrant
//  if(x > 0 && y > 0) ;
//  if(x > 0 && y < 0) pitch += 180;
//  if(x < 0 && y > 0) ;
//  if(x < 0 && y < 0) pitch -= 180;
roll = 180 * atan (x/sqrt(y*y + z*z))/PI;
pitch = 180 * atan (y/sqrt(x*x + z*z))/PI;

  yaw =   floor(degrees(atan2(magy,magx))); //too lazy to think about this, yaw not necessary


  /****
   * Actuate
  ******/
  //String res = "Roll:\t" + (String)roll + "\tPitch:\t" + (String)pitch + "\tYaw\t: " + (String)yaw;
//  Serial.println(res);
//  delay(15);
  delay(10);

  /****
   * Read serial input
  ******/
  String response = ""; //set up empty string to be built
  if (Serial.available() > 0) {
    // read the incoming byte:
    int incomingByte = 0;   // for incoming serial data
    incomingByte = Serial.read();

    //shitty nested ifs is good enough.
    if(incomingByte == 33) //'!' is starting symbol
    {
      while (Serial.available() > 0) {
        incomingByte = Serial.read();
        switch(incomingByte) {
          case 'r': response += (String) map(roll,-90,90,0,9);  //mapping experimental
          break;
          case 'p': response += (String) map(pitch,-90,90,0,9); //mapping experimental
          break;
          case 'y': response += (String) map(yaw,-140,140,0,9); //mapping experimental
          break;
          case '$': Serial.print('!' + response + '$');
          continue;
          default: break;
        }
      }
    }
  }

  /*
  ASCII cheat sheet
  '!' == 33
  '$' == 36 <- Dollar sign
  '0' == 48
  '1' == 49
  '2' == 50
  '3' == 51
  '4' == 52
  '5' == 53
  '6' == 54
  '7' == 55
  '8' == 56
  '9' == 57
  
  */
}











/************************************************************
 * Useful functions
*************************************************************/

/*********
 * Data to variables functions
***********/


signed int average(signed int a[]) {
  signed int sum = 0;
  for(int i = 0; i < averageArrayIndexSize;  a) {
    sum += a;
  }
  return sum / averageArrayIndexSize;
}

/*********
 * MPU9250 necessities
***********/

uint8_t writeByteWire(uint8_t deviceAddress, uint8_t registerAddress, uint8_t data) {
  Wire.beginTransmission(deviceAddress);  // Initialize the Tx buffer
  Wire.write(registerAddress);      // Put slave register address in Tx buffer
  Wire.write(data);                 // Put data in Tx buffer
  Wire.endTransmission();           // Send the Tx buffer
  // TODO: Fix this to return something meaningful
  return NULL;
}

uint8_t writeByte(uint8_t deviceAddress, uint8_t registerAddress, uint8_t data) {
    return writeByteWire(deviceAddress,registerAddress, data);
}

uint8_t readByte(uint8_t deviceAddress, uint8_t registerAddress) {
    return readByteWire(deviceAddress, registerAddress);
}

// Read a byte from the given register address from device using I2C
uint8_t readByteWire(uint8_t deviceAddress, uint8_t registerAddress) {
  uint8_t data; // `data` will store the register data

  // Initialize the Tx buffer
  Wire.beginTransmission(deviceAddress);
  // Put slave register address in Tx buffer
  Wire.write(registerAddress);
  // Send the Tx buffer, but send a restart to keep connection alive
  Wire.endTransmission(false);
  // Read one byte from slave register address
  Wire.requestFrom(deviceAddress, (uint8_t) 1);
  // Fill Rx buffer with result
  data = Wire.read();
  // Return data read from slave register
  return data;
}

// Read 1 or more bytes from given register and device using I2C
uint8_t readBytesWire(uint8_t deviceAddress, uint8_t registerAddress, uint8_t count, uint8_t * dest) {
  // Initialize the Tx buffer
  Wire.beginTransmission(deviceAddress);
  // Put slave register address in Tx buffer
  Wire.write(registerAddress);
  // Send the Tx buffer, but send a restart to keep connection alive
  Wire.endTransmission(false);
  uint8_t i = 0;
  // Read bytes from slave register address
  Wire.requestFrom(deviceAddress, count);
  while (Wire.available()) {
    // Put read results in the Rx buffer
    dest[i++] = Wire.read();
  }
  return i; // Return number of bytes written
}

uint8_t readBytes(uint8_t deviceAddress, uint8_t registerAddress, uint8_t count, uint8_t * dest) {
    return readBytesWire(deviceAddress, registerAddress, count, dest);
 }

 
/*----------------------------------------------------------
 * END
------------------------------------------------------------*/
