#include <DHT.h>

#include <OneWire.h> //Se importan las librerías
#include <DallasTemperature.h>


#define TEMPERATURE 2
#define LED         3 
#define DHTPIN      5
#define RELAY_1     7                        
#define RELAY_2     8                        
#define RELAY_3     12                        
#define RELAY_4     13                       
#define SOIL_PIN1   A0
#define SOIL_PIN2   A1
#define SOIL_PIN3   A2
#define PHOTO_PIN   A3

#define DHTTYPE     DHT11

OneWire ourWire(TEMPERATURE);         //Se establece el pin declarado como bus para la comunicación OneWire
DallasTemperature sensors(&ourWire);  //Se instancia la librería DallasTemperature
DHT dht(DHTPIN, DHTTYPE);

String command = "";                  // a string to hold incoming data
boolean commandAvailable = false;     // whether the string is complete

void setup() {
  pinMode(SOIL_PIN1,   INPUT);
  pinMode(SOIL_PIN2,   INPUT);
  pinMode(SOIL_PIN3,   INPUT);
  pinMode(PHOTO_PIN,   INPUT);
  pinMode(RELAY_1,    OUTPUT);
  pinMode(RELAY_2,    OUTPUT);
  pinMode(RELAY_3,    OUTPUT);
  pinMode(RELAY_4,    OUTPUT);
  pinMode(LED,        OUTPUT);

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
    Serial.print(command);
    Serial.print(" ");
    if (command.equals("TEMP_FLUID")) {
      sensors.requestTemperatures(); //Prepara el sensor para la lectura
      Serial.print(sensors.getTempCByIndex(0)); //Se lee e imprime la temperatura en grados Celsius
      status("OK");
      return;
    }
    if (command.equals("SOIL_MOISTURE_1")) {
      int s = analogRead(SOIL_PIN1);
      Serial.print(s);
      status("OK");
      return;
    }
    if (command.equals("SOIL_MOISTURE_2")) {
      int s = analogRead(SOIL_PIN2);
      Serial.print(s);
      status("OK");
      return;
    }
    if (command.equals("SOIL_MOISTURE_3")) {
      int s = analogRead(SOIL_PIN3);
      Serial.print(s);
      status("OK");
      return;
    }
    if (command.equals("PHOTO")) {
      int s = analogRead(PHOTO_PIN );
      Serial.print(s);
      status("OK");
      return;
    }
    if (command.equals("HUMIDITY")) {
      float h = dht.readHumidity();
      if (isnan(h)) {
        status("ERROR");
      } else {
        Serial.print(h);
        status("OK");        
      }
      return;
    }
    if (command.equals("TEMP_ENV")) {
      float t = dht.readTemperature();
      if (isnan(t)) {
        status("ERROR");
      } else {
        Serial.print(t);
        status("OK");
      }
      return;
    }    
    if (command.equals("RELAY_1_ON")) {
      digitalWrite(RELAY_1,LOW);           // Turns ON Relays 1
      status("OK");
      return;
    }
    if (command.equals("RELAY_1_OFF")) {
      digitalWrite(RELAY_1,HIGH);           // Turns ON Relays 1
      status("OK");
      return;
    }
    if (command.equals("RELAY_2_ON")) {
      digitalWrite(RELAY_2,LOW);           // Turns ON Relays 1
      status("OK");
      return;
    }
    if (command.equals("RELAY_2_OFF")) {
      digitalWrite(RELAY_2,HIGH);           // Turns ON Relays 1
      status("OK");
      return;
    }    
    if (command.equals("RELAY_3_ON")) {
      digitalWrite(RELAY_3,LOW);           // Turns ON Relays 1
      status("OK");
      return;
    }
    if (command.equals("RELAY_3_OFF")) {
      digitalWrite(RELAY_3,HIGH);           // Turns ON Relays 1
      status("OK");
      return;
    }    
    if (command.equals("RELAY_4_ON")) {
      digitalWrite(RELAY_4,LOW);           // Turns ON Relays 1
      status("OK");
      return;
    }
    if (command.equals("RELAY_4_OFF")) {
      digitalWrite(RELAY_4,HIGH);           // Turns ON Relays 1
      status("OK");
      return;
    }
    status("COMMAND_NOT_EXISTS ERROR");
    return;
  }  
}

void status(String msg) {
  Serial.print(" ");
  Serial.println(msg);
  command = "";
  commandAvailable = false;
  digitalWrite(LED, LOW);
}

void serialEvent() {
  if (Serial.available()) {
    command = Serial.readString();
    command.remove(command.length() - 1);
    commandAvailable = true;
    digitalWrite(LED, HIGH);
    delay(1000);
  }
}

