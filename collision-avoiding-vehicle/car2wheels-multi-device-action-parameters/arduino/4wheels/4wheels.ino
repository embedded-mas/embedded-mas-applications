#include <Embedded_Protocol_2.h>
#include <ArduinoJson.h>

Communication communication;

const int MAX_ACTUATIONS = 10;
const String END_OF_SEND_MESSAGE = "__eom__";

// cada "motor" agora é um LED em um pino digital
const int MOTOR_LEFT  = 2;
const int MOTOR_RIGHT = 3;

// estados dos LEDs
bool motor_left_on  = false;
bool motor_right_on = false;

// buffer de entrada serial
String inputBuffer = "";

int count_percept = 0;

void halt() {
  digitalWrite(MOTOR_LEFT,  LOW);
  digitalWrite(MOTOR_RIGHT, LOW);
}

int splitString(String input, char delimiter, String parts[]) {
  int count = 0;
  int startIndex = 0;
  int endIndex = input.indexOf(delimiter);

  while (endIndex != -1 && count < MAX_ACTUATIONS) {
    parts[count++] = input.substring(startIndex, endIndex);
    startIndex = endIndex + 1;
    endIndex = input.indexOf(delimiter, startIndex);
  }
  if (startIndex < input.length() && count < MAX_ACTUATIONS) {
    parts[count++] = input.substring(startIndex);
  }
  return count;
}

void act(String s) {
  s.trim();
  if (s.length() == 0) return;

  Serial.print("Processando: "); Serial.println(s);

  String acts[MAX_ACTUATIONS];
  int qtd = splitString(s, ';', acts);
  
  for (int i = 0; i < qtd; i++) {
    acts[i].trim();
    Serial.println("Recebido 2: " + acts[i]);
    if (acts[i].length() == 0) continue;

    if (acts[i].equals("motor_left.forward")) {
      motor_left_on = true;
    }
    else if (acts[i].equals("motor_left.turn_off") || acts[i].equals("motor_left.backward")) {
      motor_left_on = false;
    }
    else if (acts[i].equals("motor_right.forward")) {
      motor_right_on = true;
    }
    else if (acts[i].equals("motor_right.turn_off") || acts[i].equals("motor_right.backward")) {
      motor_right_on = false;
    }   
    else {
      Serial.println("Comando desconhecido: " + acts[i]);
    }
  }
}

void make_percepts() {
  if (count_percept == 0) {
    float dist_sensor_left = random(10) / 10.0;
    float dist_sensor_right = random(10) / 10.0;
    communication.startBelief("dist_left");
    communication.beliefAdd(dist_sensor_left);
    communication.endBelief();
    communication.startBelief("dist_right");
    communication.beliefAdd(dist_sensor_right);
    communication.endBelief();
    communication.sendMessage();
  }
  if (++count_percept >= 5) count_percept = 0;
}

void setup() {
  pinMode(MOTOR_LEFT, OUTPUT);
  pinMode(MOTOR_RIGHT, OUTPUT);
  
  Serial.begin(9600);
  Serial.println("Iniciando...");

  halt();
}

void loop() {
  // ler serial
  while (Serial.available() > 0) {
    char c = (char)Serial.read();
    inputBuffer += c;
  }

  // procurar pacotes completos
  int idx = inputBuffer.indexOf(END_OF_SEND_MESSAGE);
  while (idx != -1) {
    String packet = inputBuffer.substring(0, idx);
    packet.trim();
    if (packet.length() > 0) act(packet);

    inputBuffer = inputBuffer.substring(idx + END_OF_SEND_MESSAGE.length());
    idx = inputBuffer.indexOf(END_OF_SEND_MESSAGE);
  }

  // aplicar os estados dos LEDs
  digitalWrite(MOTOR_LEFT,  motor_left_on  ? HIGH : LOW);
  digitalWrite(MOTOR_RIGHT, motor_right_on ? HIGH : LOW);
  
  // percepções simuladas
  make_percepts();

  delay(50);
}
