#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>
#include <dht11.h>
#include <ThreeWire.h>
#include <RtcDS1302.h>
#include <LiquidCrystal_I2C.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"

LiquidCrystal_I2C lcd(0x27, 16, 2);


const int ldrPin = 34;
const int dhtPin = 13;
const int moiPin = 35;
const int relayPin = 27;

const int clkPin = 15;
const int datPin = 2;
const int rstPin = 4;

const int butPin = 14;
bool wState = true;

ThreeWire myWire(datPin, clkPin, rstPin);
RtcDS1302<ThreeWire> Rtc(myWire);

const char* firebaseHost = "";
const char* firebaseAuth = "";


const char* ssid;
const char* passwd;

const char* userId;
const char* plantId;

String _ssid;
String _passwd;

String _userId;
String _plantId;


dht11 DHT11;
unsigned long int onTimeFirebase = 0;
float lightMin = 0;
float lightMax = 0;
float moistMin = 0;

byte grau[] =
{
  B01100,
  B10010,
  B10010,
  B01100,
  B00000,
  B00000,
  B00000,
  B00000
};

byte customTemp[] = {
  B00100,
  B01010,
  B01010,
  B01110,
  B01110,
  B11111,
  B11111,
  B01110
};

byte customTimer[] = {
  B00000,
  B01110,
  B10101,
  B10111,
  B10001,
  B01110,
  B00000,
  B00000
};

byte customWater[] = {
  B00100,
  B00100,
  B01010,
  B01010,
  B10001,
  B10001,
  B10001,
  B01110
};

byte customSun[] = {
  B00000,
  B00000,
  B10101,
  B01110,
  B11011,
  B01110,
  B10101,
  B00000
};

bool mount = false;

void setup() {
  Serial.begin(9600);
  lcd.begin();
  lcd.createChar(0, customTemp);
  lcd.createChar(1, customTimer);
  lcd.createChar(2, customWater);
  lcd.createChar(3, customSun);
  lcd.createChar(4, grau);
  lcd.clear();
  pinMode(relayPin, OUTPUT);
  pinMode(butPin, INPUT_PULLUP);
  stateEsp();
  initSDCard();
  readFile(SD, "/conf.txt");

  ssid = _ssid.c_str();
  passwd = _passwd.c_str();
  userId = _userId.c_str();
  plantId = _plantId.c_str();

  delay(300);
  initConnection();

  Firebase.begin(firebaseHost, firebaseAuth);

  rtcBegin();
  turnOnDevice();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Carregando!");
  lightMin = Firebase.getFloat(varPath("lightingMin"));
  lightMax = Firebase.getFloat(varPath("lightingMax"));
  moistMin = Firebase.getFloat(varPath("moistureMin"));
  onTimeFirebase = Firebase.getInt(varPath("timer"));
}

unsigned long int onTime = 0;
unsigned long int timerOne = 0;
unsigned long int timerReley = 0;
unsigned long int sendTime = 0;

float moist = 0;
float light = 0;
float temp = 0;

long int t1;
long int t2;


void loop() {
  if (Firebase.getBool(varPath("situation")) == false) {
    restart();
  }
  if (millis() - timerOne >= 2000) {
    setTemp();
    setLight();
    setMoisture();
    Serial.println("Data: " + dateTime(Rtc.GetDateTime()));
    timerOne = millis();
  }

  if (millis() - sendTime >= 900000) {
    sendInfo(dateTime(Rtc.GetDateTime()));
    sendTime = millis();
  }
  
  operatingTime();
  DashboardScreen(temp, moist, light, onTime + onTimeFirebase);
  
  if (millis() - timerReley >= 150000) {
    if (moist < moistMin) {
      digitalWrite(relayPin, HIGH);
      delay(800);
      digitalWrite(relayPin, LOW);
    }else{
      digitalWrite(relayPin, LOW);  
    }
    timerReley = millis();
  }
}


void rtcBegin() {
  Rtc.Begin();
  RtcDateTime compiled = RtcDateTime(__DATE__, __TIME__);
  if (Rtc.GetIsWriteProtected()) {
    Rtc.SetIsWriteProtected(false);
  }

  if (!Rtc.GetIsRunning()) {
    Rtc.SetIsRunning(true);
  }

  RtcDateTime now = Rtc.GetDateTime();
  if (now < compiled) {
    Rtc.SetDateTime(compiled);
  }
}

String varPath(String var) {
  String path = "/" + (String)userId + "/plants/" + (String)plantId + "/" + var;
  return path;
}

void setTemp() {
  DHT11.read(dhtPin);
  temp = (float)DHT11.temperature;
  Firebase.setFloat(varPath("temperature"), temp);
}

void setMoisture() {
  moist = map(analogRead(moiPin), 4095, 1550, 0, 100);
  //Serial.println(analogRead(moiPin));
  if (moist > 100.0) {
    Firebase.setFloat(varPath("moisture"), 100.0);
    moist = 100.0;
  }
  else {
    Firebase.setFloat(varPath("moisture"), moist);
  }
}

void setLight() {
  light = map(analogRead(ldrPin), 4095, 0, 0, 100);
  Firebase.setFloat(varPath("lighting"), light);
}

void turnOnDevice() {
  String title = Firebase.getString(varPath("title"));
  if (Firebase.getBool(varPath("situation")) == false) {
    Firebase.setBool(varPath("situation"), true);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Cultura");
    lcd.setCursor(0, 1);
    lcd.print("Ativada!");
    delay(1000);
  }
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Cultura:");
  lcd.setCursor(0, 1);
  lcd.print(title);
  delay(1000);
}

void operatingTime() {
  if ((light >= lightMin)) {
    t1 = abs(millis() - t2);
    onTime = (onTime + t1) / 1000 ;
  } else {
    t2 = abs(millis() - t1);
  }
  if (Firebase.getString(varPath("timeReset")) != dateReset(Rtc.GetDateTime())) {
    onTime = 0;
    onTimeFirebase = 0;
  }
  Firebase.setInt(varPath("timer"), (onTime + onTimeFirebase));
  Firebase.setString(varPath("timeReset"), dateReset(Rtc.GetDateTime()));
}

String dateTime(const RtcDateTime& dt) {
  char datestring[20];
  snprintf_P(datestring, (sizeof(datestring) / sizeof(datestring[0])),
             PSTR("%02u-%02u-%04u %02u:%02u:%02u"),
             dt.Day(),
             dt.Month(),
             dt.Year(),
             dt.Hour(),
             dt.Minute(),
             dt.Second());
  return (String)datestring;
}

void initSDCard() {
  if (!SD.begin()) {
    Serial.println("Card Mount Failed");
    return;
  }
  uint8_t cardType = SD.cardType();

  if (cardType == CARD_NONE) {
    Serial.println("No SD card attached");
    return;
  }

  Serial.print("SD Card Type: ");
  if (cardType == CARD_MMC) {
    Serial.println("MMC");
  } else if (cardType == CARD_SD) {
    Serial.println("SDSC");
  } else if (cardType == CARD_SDHC) {
    Serial.println("SDHC");
  } else {
    Serial.println("UNKNOWN");
  }
  uint64_t cardSize = SD.cardSize() / (1024 * 1024);
  Serial.printf("SD Card Size: %lluMB\n", cardSize);
}
void initConnection() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Cactus");
  delay(300);
  WiFi.begin(ssid, passwd);

  lcd.setCursor(0, 1);
  while (WiFi.status() != WL_CONNECTED)
  {
    lcd.print(".");
    delay(300);
  }
  Serial.println();
}

void readFile(fs::FS &fs, const char * path) {
  String cLine = "";
  char ch;
  int index = 0;

  File file = fs.open(path);
  if (!file) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Error!");
    delay(2000);
    restart();
  }

  Serial.println("Read from file: ");
  while (file.available()) {
    ch = file.read();
    if (ch == '\n' && index == 0) {
      _userId = cLine;
      index += 1;
      cLine = "";
    } else if (ch == '\n' && index == 1) {
      _plantId = cLine;
      index += 1;
      cLine = "";
    } else if (ch == '\n' && index == 2) {
      _ssid = cLine;
      index += 1;
      cLine = "";
    } else if (ch == '\n' && index == 3) {
      _passwd = cLine;
      index += 1;
      cLine = "";
    } else {
      cLine += ch;
    }
  }
  file.close();
}

void stateEsp() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Aperte o botao");
  lcd.setCursor(0, 1);
  lcd.print("pra iniciar!");
  while (wState) {
    if (digitalRead(butPin) == LOW) {
      lcd.clear();
      wState = false;
    }
  }
}

void DashboardScreen(float temp, float hum, float light, int timer) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.write(0);
  lcd.setCursor(1, 0);
  lcd.print(": " + (String)(int)round(temp));
  lcd.setCursor(5, 0);
  lcd.write(4);
  lcd.setCursor(0, 1);
  lcd.write(2);
  lcd.setCursor(1, 1);
  lcd.print(": " + (String)(int)round(hum) + "%");
  lcd.setCursor(8, 0);
  lcd.write(3);
  lcd.setCursor(9, 0);
  lcd.print(": " + (String)(int)round(light) + "%");
  lcd.setCursor(8, 1);
  lcd.write(1);
  lcd.setCursor(9, 1);
  lcd.print(": " + (String) convertTime(timer));
}


void restart() {
  int i = 5;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Reiniciando...");
  while (i >= 0) {
    lcd.setCursor(0, 1);
    lcd.print(i);
    delay(1000);
    i -= 1;
  }
  ESP.restart();
}

String convertTime(int timestamp) {
  int horas = timestamp / 3600;
  int minutos = (timestamp - (horas * 3600)) / 60.0;

  char datestring[20];
  snprintf_P(datestring, (sizeof(datestring) / sizeof(datestring[0])),
             PSTR("%02u:%02u"),
             horas,
             minutos);
  return (String)datestring;
}

String dateReset(const RtcDateTime& dt) {
  char datestring[20];
  snprintf_P(datestring, (sizeof(datestring) / sizeof(datestring[0])),
             PSTR("%02u-%02u-%04u"),
             dt.Day(),
             dt.Month(),
             dt.Year());
  return (String)datestring;
}

void sendInfo(String date){
  
   Firebase.setString(varPath("register/"+ date + "/1"), (date));
   Firebase.setFloat(varPath("register/"+ date + "/2"), (moist));
   Firebase.setFloat(varPath("register/"+ date + "/3"), (temp));
   Firebase.setFloat(varPath("register/"+ date + "/4"), (light));
   Firebase.setInt(varPath("register/"+ date + "/5"), (onTime + onTimeFirebase));
}
