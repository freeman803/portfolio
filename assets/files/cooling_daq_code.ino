// Include the libraries we need
#include <OneWire.h>
#include <DallasTemperature.h>
#include "thermistor.h"
#include "HardwareSerial.h"
const byte inputA = 5;
const byte inputB = 2;
const byte PWM = 7;
bool signalA_changed = false;
bool signalB_changed = false;
unsigned long startTime;
unsigned long elapsedTime;
unsigned int changeCountA;
unsigned int changeCountB;
#define ntc_pin A2      // Pin, to which the voltage divider is connected
#define nominal_resistance 50000       //Nominal resistance at 25â°C
#define vd_power_pin 9
#define nominal_temeprature 25   // temperature for nominal resistance (almost always 25â° C)
#define samplingrate 5    // Number of samples
#define beta 3950  // The beta coefficient or the B value of the thermistor
#define Rref 10000   //Value of  resistor used for the voltage divider
int samples = 0;   //array to store the samples
#define vd_power_pinout 7     // digital 7
#define powerpin 4 
#define ntc_pinout A4         // Pin, to which the voltage divider is connected

THERMISTOR thermistor(ntc_pin,        // Analog pin
                      50000,          // Nominal resistance at 25 ÂºC
                      3950,           // thermistor's beta coefficient
                      27400);         // Value of the series resistor
uint16_t temp;

THERMISTOR thermistor2(ntc_pinout,        // Analog pin
                      50000,          // Nominal resistance at 25 ÂºC
                      3950,           // thermistor's beta coefficient
                      27100);         // Value of the series resistor
uint16_t temp2;


// Data wire is plugged into port 2 on the Arduino
#define ONE_WIRE_BUS 3
#define TEMPERATURE_PRECISION 12

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);
DeviceAddress first = { 0x28, 0xFF, 0xA1, 0x4b, 0xB2, 0x15, 0x01, 0x7C };
DeviceAddress second   = { 0x28, 0xFF, 0xA3, 0x77, 0xB2, 0x15, 0x03, 0x19 };
DeviceAddress third   = { 0x28, 0xFF, 0x93, 0x6F, 0xB2, 0x15, 0x03, 0xB9 };


int pwm_pin = 10; // pin for pwm
void setup() {
sensors.begin();
pinMode(5,INPUT);
pinMode(2,INPUT);
//attachInterrupt(digitalPinToInterrupt(inputA),signalA,CHANGE);
attachInterrupt(digitalPinToInterrupt(5),signalB_ISR,RISING);
attachInterrupt(digitalPinToInterrupt(2),signalA_ISR,RISING);
  // put your setup code here, to run once:
 Serial.begin(115200);


// For time
startTime = millis();
elapsedTime = 0;
changeCountA = 0;
changeCountB= 0 ;
// attachInterrupt(sensorInterrupt,pulseCounter,CHANGE);
 //attachInterrupt(sensorInterrupt2,pulseCounter2, CHANGE);
// set the resolution to 9 bit per device
  sensors.setResolution(first, TEMPERATURE_PRECISION);
  sensors.setResolution(second, TEMPERATURE_PRECISION);
  sensors.setResolution(third, TEMPERATURE_PRECISION);
pinMode(pwm_pin, OUTPUT); // Set the PWM pin as output


}
unsigned long sig_last, sig_now;
float flow_lpm;
unsigned long last_comm = 0;
float flow_lpm2;
unsigned long sig_last2, sig_now2;
// FOR PWM PUMP





void loop() {
int duty_cycle =75;
Pwm(duty_cycle, 150); //e.g. (127/255)50% duty with 150 Hz
if ( (millis() - last_comm) >999){ 
last_comm = millis();
sensors.requestTemperatures();
float tempCfirst = sensors.getTempC(first);
float tempCsecond = sensors.getTempC(second);
float tempCthird = sensors.getTempC(third);
Serial.print("millis; ");
Serial.print(millis());
Serial.print(" ; ");
Serial.print("first T amb; ");
Serial.print(tempCfirst);
Serial.print("  ;   ");
Serial.print("second T past fan rad; ");
Serial.print(tempCsecond);
Serial.print("  ;   ");
Serial.print("third farther than second; ");
Serial.print(tempCthird);
Serial.print("  ; ");
Serial.print(" ; duty cycle ; ");
Serial.print(duty_cycle);
Serial.print(" ; ");
TempReading();
unsigned int flow = sig_now - sig_last;
  flow_lpm = flow;
unsigned int flow2 = sig_now2-sig_last2;
  flow_lpm2 = flow2;
 Serial.print("     ;micros flow1 ;    ");
 Serial.print(flow_lpm);
 Serial.print("  ; ");
Serial.print("     ;micros flow2 ;    ");
 Serial.println(flow_lpm2);



 }}
void TempReading(){
temp = thermistor.read();   // Read temperature

  Serial.print("Temp ÂºC A:;    ");
  float tempf = temp;
  tempf = tempf/10;
  Serial.print(tempf);
temp2 = thermistor2.read();   // Read temperature

  Serial.print("    ;Temp ÂºC B: ;     ");
  float tempf2;
  tempf2 = temp2;
  tempf2 = tempf2/10;
  Serial.print(tempf2);
}
void signalB_ISR() {
sig_last = sig_now;
sig_now = micros();

}
void signalA_ISR(){
sig_last2 = sig_now2;
sig_now2 = micros();

}
void Pwm(unsigned char duty, float freq) {
  TCCR1A = 0x21;
  TCCR1B = 0x14;
  OCR1A = 0x7A12 / freq;
  OCR1B = OCR1A * (duty / 255.0);
}

