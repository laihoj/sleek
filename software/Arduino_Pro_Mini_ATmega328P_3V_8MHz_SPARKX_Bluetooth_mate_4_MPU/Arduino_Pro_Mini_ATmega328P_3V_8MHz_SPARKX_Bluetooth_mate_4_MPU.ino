

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
#include <inttypes.h>

#include "mpu9250.h"
#include <Wire.h> //I2C library


#define DEBUG 0




/************************************************************
 * MPU9250 data storage
*************************************************************/
//Direct readings from IMU MPU9250
byte accelData[6];
byte tempData[2];
byte gyroData[6];
byte magnetoData[6];

//Raw readings
int16_t accelX,accelY,accelZ;
int16_t gyroX,gyroY,gyroZ;
int16_t magnetoX,magnetoY,magnetoZ;

//Resolution-adjusted
int16_t ax, ay, az; //unit: m/s^2
int16_t gx, gy, gz; //unit: ???
int16_t mx, my, mz; //unit: ???


//Converted readings
int16_t roll = 0;
int16_t pitch = 0;
int16_t yaw = 0;

//double timestamp;

//Output
String response;

/************************************************************
 * Service parameters
 * 
 * outputRangeMin => in outputMode = 1 r,p,y are adjusted to this mapping
 * outputRangeMax => in outputMode = 1 r,p,y are adjusted to this mapping
 * outputMode = 0   => position needs to be requested.
 * outputMode = 1   => constant output of roll,pitch,yaw
 * outputMode = 2(5) => constant output of acceleration (in raw form)
 * outputMode = 3(6) => constant output of gyroscope (in raw form)
 * outputMode = 4(7) => constant output of magnetometer  (in raw form)
 * userDelay => in outputMode = 0 remember to put delay to 0. otherwise choose self
*************************************************************/

int outputRangeMin = 0; //mapping
int outputRangeMax = 9;
int outputMode = 0;
int userDelay = 35; //delay in ms//currently makes sampling rate approx 20Hz

/************************************************************
 * Flags
*************************************************************/
char sleeping = 1; //not in use?

char * cx = (char*)malloc(sizeof(char)*2);
char * cy = (char*)malloc(sizeof(char)*2);
char * cz = (char*)malloc(sizeof(char)*2);
char * ca = (char*)malloc(sizeof(char)*2);
char * cg = (char*)malloc(sizeof(char)*2);
char * cm = (char*)malloc(sizeof(char)*2);


char caxarray[5];
char cayarray[5];
char cazarray[5];
char cgxarray[6];
char cgyarray[6];
char cgzarray[6];

char *cax = &caxarray[0];
char *cay = &cayarray[0];
char *caz = &cazarray[0];
char *cgx = &cgxarray[0];
char *cgy = &cgyarray[0];
char *cgz = &cgzarray[0];
  
/*----------------------------------------------------------
 * Structures
------------------------------------------------------------*/

struct Main_memory {
  byte arraylength = 7;
  byte next = 0;
  byte datalength = 70;
  char dataJSON[7][70];
};

Main_memory main_memory;
  
/*----------------------------------------------------------
 * Setup
------------------------------------------------------------*/

void setup() {
  strcpy(cx, "x\0");
  strcpy(cy, "y\0");
  strcpy(cz, "z\0");
  strcpy(ca, "a\0");
  strcpy(cg, "g\0");
  strcpy(cm, "m\0");
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

  /*********
   * MPU setup
  ***********/
  //INIT MPU
  
  wake();
  writeByte(MPU9250_ADDRESS, INT_ENABLE, 0x01); //TODO: interrupts
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
  
  readAcceleration();
  
  uint32_t timestamp = millis();

  //generate sample
  char* accelerationData = convertAccelerationToJSON(timestamp);

  //publish sample
  char buffer[200];
  sprintf(buffer, "%s\n", accelerationData);    
  Serial.print(buffer);

  uint16_t err = 0;
  err = copyDataToMemory(accelerationData);
  if (DEBUG) {
    if (err == -1) {
      Serial.println("storing to memory failed");
    }
    if (err >= 0) {
      Serial.println("Data stored at "+(String) err+". Next data goes to " + main_memory.next);
    }
  }

  free(accelerationData);


  readGyroscope();
  timestamp = millis();

  char* gyroData = convertGyroscopeToJSON(timestamp);
  
  //publish sample
  buffer[200];
  sprintf(buffer, "%s\n", gyroData);    
  Serial.print(buffer);
  
  err = copyDataToMemory(gyroData);
  if (DEBUG) {
    if (err == -1) {
      Serial.println("storing to memory failed");
    }
    if (err >= 0) {
      Serial.println("Data stored at "+(String) err+". Next data goes to " + main_memory.next);
    }
  }
  
  free(gyroData);


  readMagnetometer();
  
  readTemp();
  /****
   * Output prepared
  ******/

  roll = 180 * atan (ax/sqrt(ay*ay + az*az))/PI;
  pitch = 180 * atan (ay/sqrt(ax*ax + az*az))/PI;
  yaw =   floor(degrees(atan2(my,mx))); //too lazy to think about this, yaw not necessary


  

  /****
   * Write output based on user-defined output mode
  ******/

  //modes 2-4 are processed output, modes 5-7 are raw output. See above for more detail
  switch(outputMode)
  {
    case 0: break; //request based output
    case 1: Serial.print("!" + (String) getRoll() + (String) getPitch() + (String) getYaw() + '$');
      break;
    case 2: Serial.print("!," + (String) getAccel('x') + ',' + (String) getAccel('y') + ',' + (String) getAccel('z') + ",$"); 
      break;
    case 3: Serial.print("!," + (String) getGyro('x') + ',' + (String) getGyro('y') + ',' + (String) getGyro('z') + ",$"); 
      break;
    case 4: Serial.print("!," + (String) getMag('x') + ',' + (String) getMag('y') + ',' + (String) getMag('z') + ",$"); 
      break;
    case 5: Serial.print("!," + (String) getAccel('X') + ',' + (String) getAccel('Y') + ',' + (String) getAccel('Z') + ",$"); 
      break;
    case 6: Serial.print("!," + (String) getGyro('X') + ',' + (String) getGyro('Y') + ',' + (String) getGyro('Z') + ",$"); 
      break;
    case 7: Serial.print("!," + (String) getMag('X') + ',' + (String) getMag('Y') + ',' + (String) getMag('Z') + ",$"); 
      break;
  }

  
  /****
   * Read serial input
  ******/
  
  response = ""; //set output to empty string
  if (Serial.available() > 0) {
    boolean validInput = true;
    boolean terminalReached = false;
    char incomingByte = 0;
    incomingByte = Serial.read(); // read the incoming byte:

    //shitty nested branching is good enough.
    //using 'continue' instead of 'break' if terminal symbol reached
    if(incomingByte == 33) //'!' is starting symbol
    {
      
      while (Serial.available() > 0  && validInput && !terminalReached) {
        incomingByte = Serial.read();
        switch(incomingByte) {
          case 'r': response += (String) getRoll();
            break;
          case 'p': response += (String) getPitch();
            break;
          case 'y': response += (String) getYaw();
            break;
          case 'a': response += (String) getAccel('x') + ',';
                    response += (String) getAccel('y') + ',';
                    response += (String) getAccel('z') + ',';
            break;
          case 'g': response += (String) getGyro('x') + ',';
                    response += (String) getGyro('y') + ',';
                    response += (String) getGyro('z') + ',';
            break;
          case 'm': response += (String) getMag('x') + ',';
                    response += (String) getMag('y') + ',';
                    response += (String) getMag('z') + ',';
            break;
          case 'A': response += (String) getAccel('X') + ',';
                    response += (String) getAccel('Y') + ',';
                    response += (String) getAccel('Z') + ',';
            break;
          case 'G': response += (String) getGyro('X') + ',';
                    response += (String) getGyro('Y') + ',';
                    response += (String) getGyro('Z') + ',';
            break;
          case 'M': response += (String) getMag('M') + ',';
                    response += (String) getMag('Y') + ',';
                    response += (String) getMag('Z') + ',';
            break;
          case 'b': response += broadcastNewStuffInMemory();
            break;
          case '$': terminalReached = true;
            continue;
          default: 
            validInput = false;
          continue;
        }
      }
      if(validInput && terminalReached) {
        Serial.print('!' + response + '$');
        response = "";
      }
      Serial.flush();
    } 
    else if(incomingByte == 63) //'?' is starting symbol
    {
      while (Serial.available() > 0) {
        incomingByte = Serial.read();
        switch(incomingByte) {
          case 's': 
            sleep(); 
            response = "sleeping:1";
            break;
          case 'w': 
            wake(); 
            response = "sleeping:0";
            break;
          case 'o': 
            response = "ok";
            break;
          case 'm': outputRangeMax = Serial.parseInt();
            response = "outputRangeMax:" + (String)outputRangeMax;
            break;
          case 'n': outputRangeMin = Serial.parseInt();
            response = "outputRangeMin:" + (String)outputRangeMin;
            break;
          case 'd': userDelay = Serial.parseInt();
            response = "userDelay:" + (String)userDelay;
            break;
          case 'p': outputMode = Serial.parseInt();
            response = "outputMode:" + (String)outputMode;
            break;
          default: 
            validInput = false;
            continue;
          case '$': terminalReached = true;
            continue;
        }
      }

      if(validInput && terminalReached) {
        Serial.print('#' + response + '$');
        response = "";
      }
      Serial.flush();
    }
  }
  
  /****
   * Actuate
  ******/
  delay(userDelay);
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
  '?' == 63
  
  */




/*********
 * API
***********/


  char * 
  broadcastNewStuffInMemory() 
  {
    uint16_t i;
    for (i = 0; i < main_memory.arraylength - 1; i++) {
      Serial.println(main_memory.dataJSON[i]);
    }
  }


char 
  copyDataToMemory(char* dataa) 
  {
    uint16_t i;
    uint16_t current = main_memory.next;
//    for(i = 0; i < main_memory.datalength; i++)
//    {
//      main_memory.dataJSON[current][i] = '0';
//    }
    i = 0;
    while(*dataa) {
      main_memory.dataJSON[current][i] = *dataa;
      dataa++;
      i++;
    }
    main_memory.dataJSON[current][i] = '\0';
    main_memory.next = (current + 1) % main_memory.arraylength;
    return current; //now its actually previous rather than current
    }

 void readAcceleration() {
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
  accelX = (int16_t)accelData[0] << 8 | accelData[1];
  accelY = (int16_t)accelData[2] << 8 | accelData[3];
  accelZ = (int16_t)accelData[4] << 8 | accelData[5];

  ax = accelX / 17; //nice approx for this resolution //scale goes from 0 to 981
  ay = accelY / 17;
  az = accelZ / 17;
  
 }

  void readGyroscope() {
    /*********
   * READ GYRO
  ***********/
  Wire.beginTransmission(MPU9250_ADDRESS); //Begin transmission to slave address
  Wire.write(GYRO_XOUT_H); //Register address within the sensor where the data is to be read from
  Wire.endTransmission();
  Wire.requestFrom(SENSOR_I2CADD, 6); //Get 6 bytes from the register address 
  int i = 0;
  while(Wire.available()) //If the buffer has data
  {
    gyroData[i] = Wire.read(); //Save the data to a variable
    i++;
  }
  gyroX = (int16_t)gyroData[0] << 8| gyroData[1];
  gyroY = (int16_t)gyroData[2] << 8| gyroData[3];
  gyroZ = (int16_t)gyroData[4] << 8| gyroData[5];

  gx = gyroX / 16; //nice approx
  gy = gyroY / 16;
  gz = gyroZ / 16;
    }
    
  void readMagnetometer() {
    

  /*********
   * READ MAGNETOMETER
  ***********/
  //turning magnetometer off and on is a workaround that makes output value update
  writeByte(AK8963_ADDRESS, AK8963_CNTL, 0x00); // Power down magnetometer
  delay(10);
  writeByte(AK8963_ADDRESS, AK8963_CNTL, 0x16);
  delay(10);
  Wire.beginTransmission(AK8963_ADDRESS);
  Wire.write(AK8963_XOUT_L);
  Wire.endTransmission();
  
  byte rawData[6];
  int i = 0;
  // Read bytes from slave register address
  Wire.requestFrom(AK8963_ADDRESS, 6);
  while (Wire.available())
  {
    // Put read results in the Rx buffer
    rawData[i++] = Wire.read();
  }

  magnetoX = ((int16_t)rawData[1] << 8) | rawData[0];
  magnetoY = ((int16_t)rawData[3] << 8) | rawData[2];
  magnetoZ = ((int16_t)rawData[5] << 8) | rawData[4];

  mx = magnetoX * 3 / 2; //nice approx
  my = magnetoY * 10.0f * 4912.0f / 32760.0f;
  mz = magnetoZ * 10.0f * 4912.0f / 32760.0f;

    }
  void readTemp() {
      /*********
   * READ TEMPERATURE
  ***********/
  Wire.beginTransmission(SENSOR_I2CADD); //Begin transmission to slave address
  Wire.write(TEMP_OUT_H); //Register address within the sensor where the data is to be read from
  Wire.endTransmission();
  Wire.requestFrom(SENSOR_I2CADD, 2); //Get 2 bytes from the register address 
  int i = 0;
  while(Wire.available()) //If the buffer has data
  {
    tempData[i] = Wire.read(); //Save the data to a variable
    i++;
  }
  int temp = tempData[1] | (int)tempData[0] << 8;
    }


    

/*********
 * Shittest JSON library for arduino you will ever find
***********/


  char*
  cnewJSONObject()
  {
    char *src = (char*)malloc(50*sizeof(char)); //hard-coded value is pulled from sleeve. maybe 3 is right number?
    strcpy(src, "{}\0");
    return src;
  }


  char* 
  caddKeyValuePair(char* jsonObject, 
                   char* pairname, 
                   char* pairvalue)
  {
    uint16_t newsize = strlen(jsonObject) + strlen(pairname) + strlen(pairvalue) + 6 + 1;
    jsonObject = (char*) realloc(jsonObject, newsize);
    char* pcopy = jsonObject;
    while(*jsonObject) {
      jsonObject ++;
    }
    jsonObject --;
    *jsonObject= '\0';
    jsonObject = pcopy;
    if (strlen(jsonObject) > 2) {  //if not the first entry, place comma
      strcat(jsonObject, ",");
    }
    strcat(jsonObject, "\"");
    strcat(jsonObject, pairname);
    strcat(jsonObject, "\":\"");
    strcat(jsonObject, pairvalue);
    strcat(jsonObject, "\"}\0");
    return jsonObject;
  }

  char* 
  caddKeyObjectPair(char* jsonObject, 
                   char* pairname, 
                   char* pairobject)
  {
    uint16_t oldsize = strlen(jsonObject);
    uint16_t namesize = strlen(pairname);
    uint16_t objectsize = strlen(pairobject);
    uint16_t newsize = oldsize + namesize + objectsize + 4 + 1;
    jsonObject = (char*) realloc(jsonObject, newsize);
    char* pcopy = jsonObject;
    while(*jsonObject) {
      jsonObject ++;
    }
    jsonObject --;
    *jsonObject= '\0';
    jsonObject = pcopy;
    if (strlen(jsonObject) > 2) {  //if not the first entry, place comma
      strcat(jsonObject, ",");
    }
    strcat(jsonObject, "\"");
    strcat(jsonObject, pairname);
    strcat(jsonObject, "\":");
    strcat(jsonObject, pairobject);
    strcat(jsonObject, "}\0");
    return jsonObject;
  }


char*
convertAccelerationToJSON(uint32_t timestamp)
{
  char* DatapointJSON = cnewJSONObject();
  char* timestring = (char*)malloc(10*sizeof(char));
  strcpy(timestring, "timestamp");
  char ctimestamparray[20];
  sprintf(ctimestamparray,"%lu",timestamp);
  char *ctimestamp = &ctimestamparray[0];
  DatapointJSON = caddKeyValuePair(DatapointJSON, timestring, ctimestamp);

  sprintf(caxarray ,"%" PRId16, ax);
  sprintf(cayarray ,"%" PRId16, ay);
  sprintf(cazarray ,"%" PRId16, az);
  
  char* AccelJSON = cnewJSONObject();
  AccelJSON = caddKeyValuePair(AccelJSON, cx, cax);
  AccelJSON = caddKeyValuePair(AccelJSON, cy, cay);
  AccelJSON = caddKeyValuePair(AccelJSON, cz, caz);
  DatapointJSON = caddKeyObjectPair(DatapointJSON, ca, AccelJSON);
  

  sprintf(cgxarray ,"%" PRId16, gx);
  sprintf(cgyarray ,"%" PRId16, gy);
  sprintf(cgzarray ,"%" PRId16, gz);

  free(AccelJSON);
  free(timestring);
  
  return DatapointJSON;
  
  }

  char*
convertGyroscopeToJSON(uint32_t timestamp)
{
  char* DatapointJSON = cnewJSONObject();
  char* timestring = (char*)malloc(10*sizeof(char));
  strcpy(timestring, "timestamp");
  char ctimestamparray[20];
  sprintf(ctimestamparray,"%lu",timestamp);
  char *ctimestamp = &ctimestamparray[0];
  DatapointJSON = caddKeyValuePair(DatapointJSON, timestring, ctimestamp);

  sprintf(cgxarray ,"%" PRId16, gx);
  sprintf(cgyarray ,"%" PRId16, gy);
  sprintf(cgzarray ,"%" PRId16, gz);
  
  char* GyroJSON = cnewJSONObject();
  GyroJSON = caddKeyValuePair(GyroJSON, cx, cgx);
  GyroJSON = caddKeyValuePair(GyroJSON, cy, cgy);
  GyroJSON = caddKeyValuePair(GyroJSON, cz, cgz);
  DatapointJSON = caddKeyObjectPair(DatapointJSON, cg, GyroJSON);

  free(GyroJSON);
  free(timestring);
  
  return DatapointJSON;
  
  }



/************************************************************
 * Utilities
*************************************************************/



int getRoll()
{
  return map(roll,-90,90,outputRangeMin,outputRangeMax);   //calibration experimental
}

int getPitch()
{
  return map(pitch,-90,90,outputRangeMin,outputRangeMax);    //calibration experimental
}

int getYaw()
{
  return map(yaw,-140,140,outputRangeMin,outputRangeMax);   //calibration experimental
}

int getMag(char axis)
{
    switch(axis) {
      case 'x': return mx; break;
      case 'y': return my; break;
      case 'z': return mz; break;
      case 'X': return magnetoX; break;
      case 'Y': return magnetoY; break;
      case 'Z': return magnetoZ; break;
    }
}

int getAccel(char axis)
{
  switch(axis) {
    case 'x': return ax; break;
    case 'y': return ay; break;
    case 'z': return az; break;
    case 'X': return accelX; break;
    case 'Y': return accelY; break;
    case 'Z': return accelZ; break;
  }
}

int getGyro(char axis)
{
  switch(axis) {
    case 'x': return gx; break;
    case 'y': return gy; break;
    case 'z': return gz; break;
    case 'X': return gyroX; break;
    case 'Y': return gyroY; break;
    case 'Z': return gyroZ; break;
  }
}

void wake() 
{
  // Clear sleep mode bit (6), enable all sensors
  writeByte(MPU9250_ADDRESS, PWR_MGMT_1, 0x00);
  delay(10); // Wait for all registers to reset
  sleeping = 0;
}

void sleep()
{
  writeByte(MPU9250_ADDRESS, PWR_MGMT_1, 0x40);
  delay(10); // Wait for all registers to reset 
  sleeping = 1;
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
