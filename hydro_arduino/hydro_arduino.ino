#include <DHT.h>

#include <OneWire.h> //Se importan las librerías
#include <DallasTemperature.h>


#define TEMPERATURE 2
#define DHTPIN      5
#define RELAY_1     7
#define RELAY_2     8
#define RELAY_3     11
#define RELAY_4     13
#define SOIL_PIN1   A0
#define SOIL_PIN2   A1
#define SOIL_PIN3   A2
#define PHOTO_PIN   A3

#define DHTTYPE     DHT22

OneWire ourWire(TEMPERATURE);         //Se establece el pin declarado como bus para la comunicación OneWire
DallasTemperature sensors(&ourWire);  //Se instancia la librería DallasTemperature
DHT dht(DHTPIN, DHTTYPE);

String command = "";                  // a string to hold incoming data
boolean commandAvailable = false;     // whether the string is complete

void setup() {
  analogReference(DEFAULT);
  pinMode(SOIL_PIN1,   INPUT);
  pinMode(SOIL_PIN2,   INPUT);
  pinMode(SOIL_PIN3,   INPUT);
  pinMode(PHOTO_PIN,   INPUT);
  pinMode(RELAY_1,    OUTPUT);
  pinMode(RELAY_2,    OUTPUT);
  pinMode(RELAY_3,    OUTPUT);
  pinMode(RELAY_4,    OUTPUT);

  command.reserve(15);

  sensors.begin();            //Se inician los sensores de temperatura
  dht.begin();                //Se inicia sensor de temperatura y humedad

  digitalWrite(RELAY_1, HIGH);  // Desconecto relay 1
  digitalWrite(RELAY_2, HIGH);  // Desconecto relay 2
  digitalWrite(RELAY_3, HIGH);  // Desconecto relay 3
  digitalWrite(RELAY_4, HIGH);  // Desconecto relay 4

  Serial.begin(9600);
  delay(2000);
}

void loop() {
  if (commandAvailable) {
    command.toUpperCase();
    if (command.equals("LIST")) {
      status_ok(command, "TEMP_FLUID;SENSOR|SOIL_MOISTURE_1;SENSOR|SOIL_MOISTURE_2;SENSOR|SOIL_MOISTURE_3;SENSOR|PHOTO;SENSOR|HUMIDITY;SENSOR|TEMP_ENV;SENSOR|RELAY_1;SWITCH|RELAY_2;SWITCH|RELAY_3;SWITCH|RELAY_4;SWITCH");
      return;
    }
    if (command.equals("TEMP_FLUID")) {
      sensors.requestTemperatures();            //Prepara el sensor para la lectura
      float value = sensors.getTempCByIndex(0); //Se lee e imprime la temperatura en grados Celsius
      if (value == -127) {
        status_err(command, "READ_ERROR");
      } else {
        status_ok(command, value);
      }
      return;
    }
    if (command.equals("SYNC")) {
      status_ok("SYNC");
      return;
    }
    if (command.equals("SOIL_MOISTURE_1")) {
      int s = analogRead(SOIL_PIN1);
      status_ok(command, s);
      return;
    }
    if (command.equals("SOIL_MOISTURE_2")) {
      int s = analogRead(SOIL_PIN2);
      status_ok(command, s);
      return;
    }
    if (command.equals("SOIL_MOISTURE_3")) {
      int s = analogRead(SOIL_PIN3);
      status_ok(command, s);
      return;
    }
    if (command.equals("PHOTO")) {
      int s = analogRead(PHOTO_PIN );
      status_ok(command, s);
      return;
    }
    if (command.equals("HUMIDITY")) {
      float h = dht.readHumidity();
      if (isnan(h)) {
        status_err(command, "READ_ERROR");
      } else {
        status_ok(command, h);
      }
      return;
    }
    if (command.equals("TEMP_ENV")) {
      float t = dht.readTemperature();
      if (isnan(t)) {
        status_err(command, "READ_ERROR");
      } else {
         status_ok(command, t);
      }
      return;
    }
    if (command.equals("RELAY_1_ON")) {
      digitalWrite(RELAY_1,LOW);           // Turns ON Relays 1
      status_ok(command, "ON");
      return;
    }
    if (command.equals("RELAY_1_OFF")) {
      digitalWrite(RELAY_1,HIGH);           // Turns ON Relays 1
      status_ok(command, "OFF");
      return;
    }
    if (command.equals("RELAY_2_ON")) {
      digitalWrite(RELAY_2,LOW);           // Turns ON Relays 2
      status_ok(command, "ON");
      return;
    }
    if (command.equals("RELAY_2_OFF")) {
      digitalWrite(RELAY_2,HIGH);           // Turns ON Relays 2
      status_ok(command, "OFF");
      return;
    }
    if (command.equals("RELAY_3_ON")) {
      digitalWrite(RELAY_3,LOW);           // Turns ON Relays 3
      status_ok(command, "ON");
      return;
    }
    if (command.equals("RELAY_3_OFF")) {
      digitalWrite(RELAY_3,HIGH);           // Turns ON Relays 3
      status_ok(command, "OFF");
      return;
    }
    if (command.equals("RELAY_4_ON")) {
      digitalWrite(RELAY_4,LOW);           // Turns ON Relays 4
      status_ok(command, "ON");
      return;
    }
    if (command.equals("RELAY_4_OFF")) {
      digitalWrite(RELAY_4,HIGH);           // Turns ON Relays 4
      status_ok(command, "OFF");
      return;
    }
    status_err(command, "COMMAND_NOT_EXISTS");
    return;
  }
}

void status_ok(String cmd, float value) {
  Serial.print("OK ");
  Serial.println(value);
  command = "";
  commandAvailable = false;
}

void status_ok(String cmd, int value) {
  Serial.print("OK ");
  Serial.println(value);
  command = "";
  commandAvailable = false;
}

void status_ok(String cmd, String value) {
  Serial.print("OK ");
  Serial.println(value);
  command = "";
  commandAvailable = false;
}

void status_ok(String cmd) {
  Serial.println("OK");
  command = "";
  commandAvailable = false;
}

void status_err(String cmd) {
  Serial.println("ERROR");
  command = "";
  commandAvailable = false;
}

void status_err(String cmd, String msg) {
  Serial.print("ERROR ");
  Serial.print(cmd);
  Serial.print("_");
  Serial.println(msg);
  command = "";
  commandAvailable = false;
}

void serialEvent() {
  if (Serial.available()) {
    command = Serial.readString();
    command.remove(command.length() - 1);
    commandAvailable = true;
    delay(1000);
  }
}
