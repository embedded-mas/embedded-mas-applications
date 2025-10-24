#include <NewPing.h> //Biblioteca para uso das funções dos sensores ultrassônicos
#include <Embedded_Protocol_2.h>
#include <ArduinoJson.h>

#define TRIGGER_PIN_RIGHT A0 //Sensor ultrassônico direito (vista traseira)
#define ECHO_PIN_RIGHT A1    //Sensor ultrassônico direito (vista traseira)
#define TRIGGER_PIN_LEFT A5  //Sensor ultrassônico esquerdo (vista traseira)
#define ECHO_PIN_LEFT A2     //Sensor ultrassônico esquerdo (vista traseira)
#define MAX_DISTANCE 200 //Máxima distância de leitura dos sensores (dois metros)

// NewPing sonar_right(TRIGGER_PIN_RIGHT, ECHO_PIN_RIGHT, MAX_DISTANCE); //Função da biblioteca NewPing.h a qual se responsabiliza pela conversão das unidades
// NewPing sonar_left(TRIGGER_PIN_LEFT, ECHO_PIN_LEFT, MAX_DISTANCE);    //Função da biblioteca NewPing.h a qual se responsabiliza pela conversão das unidades

int IN[4] = {8, 9, 10, 11}; //Definindo pinos dos motores
// #define PH1 4
// #define PH2 5
// #define PH3 6
// #define PH4 7

int lumi_esq = 0;           //Necesidade de ser uma variável global
int lumi_dir = 0;           //Necesidade de ser uma variável global
int lumi_mark = 0;

Communication com;

int time = 5000;

/* Devido ao fato de terem muitos sensores conectados ao Vcc e o arduíno possuir apenas um pino para isto
defini-se o pino 13 em nível lógico alto, apenas para distribuir as cargas */

void setup() {

  for(int i = 0; i <= 4; i++){
    pinMode(IN[i], OUTPUT);
    digitalWrite(IN[i], LOW);
  }

  pinMode(lumi_esq, INPUT);
  pinMode(lumi_dir, INPUT);
  pinMode(lumi_mark, INPUT);

  Serial.begin(9600);

}

void loop() {

  while(Serial.available() > 0) {
    String s = Serial.readString();
    if(s.equals("move_front")){
      front();

    } else if(s.equals("move_left")){
      d_left();

    } else if(s.equals("move_right")){
      d_right();

    } 
    // else if(s.equals("halt_turn")){

      // com.startBelief("inspec");
      // com.beliefAdd(s);
      // com.endBelief();

      // com.sendMessage();

    //   d_stop();
    // }
    // com.startBelief("inspec");
    // com.beliefAdd(s);
    // com.endBelief();

    // com.sendMessage();
  }

}
  
void front(){

  bool frwd = true;

  com.startBelief("front");
  com.beliefAdd("in");
  com.endBelief();
  com.sendMessage();

  while(frwd == true){

    lumi_esq = digitalRead(3);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)
    lumi_dir = digitalRead(4);           //Variável de medida do sensor de luminosidade direito (vista traseira)

    if(lumi_esq && lumi_dir){ //Caso ambos sensores estejam identificando luminosidade
      move_front();                   //O carrinho se locomove para frente
    }
    else if(!lumi_esq && lumi_dir){ //Caso o sensor da direita identifique luminosidade
      move_right();                        //O carrinho se move para a esquerda, afim de encontrar a linha
    }
    else if(lumi_esq && !lumi_dir){ //Caso o sensor da esquerda identifique luminosidade
      move_left();                       //O carrinho se move para a direita, afim de encontrar a linha
    }   

    lumi_mark = digitalRead(5);          //Variável digital de detecção de marcador (sensor de decisao)0

    if(lumi_mark){
      while(frwd == true){ // o carrinho precisa ir para frente até o ponto de decisão
        move_front();

        lumi_esq = digitalRead(3);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)
        lumi_dir = digitalRead(4);           //Variável de medida do sensor de luminosidade direito (vista traseira)

        if (!lumi_esq && !lumi_dir){
          frwd = false;
        }
      }
      halt();
      break;             //O agente toma uma decisao
    }
  }

  com.startBelief("comm");
  com.beliefAdd("ahead");
  com.endBelief();
  com.sendMessage();

}

void d_left(){

  com.startBelief("insp");
  com.beliefAdd("t2");
  com.endBelief();
  com.sendMessage();

  while(!lumi_esq){
    lumi_esq = digitalRead(3);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)

    digitalWrite(IN[0], HIGH);
    digitalWrite(IN[1], LOW);
    digitalWrite(IN[2], LOW);
    digitalWrite(IN[3], HIGH);

  }

  halt();

  com.startBelief("comm");
  com.beliefAdd("ahead");
  com.endBelief();
  com.sendMessage();

 }

void d_right(){

  com.startBelief("insp");
  com.beliefAdd("t3");
  com.endBelief();
  com.sendMessage();


  while(!lumi_dir){
    lumi_dir = digitalRead(4);         //Variável de medida do sensor de luminosidade direito (vista traseira)

    digitalWrite(IN[0], LOW);
    digitalWrite(IN[1], HIGH);
    digitalWrite(IN[2], HIGH);
    digitalWrite(IN[3], LOW);

  }

  halt();

  com.startBelief("comm");
  com.beliefAdd("ahead");
  com.endBelief();
  com.sendMessage();

 }

//  void d_stop(){
  
//   bool frwd = true, flag = true;

//   while(flag){
//     digitalWrite(IN[0], LOW);
//     digitalWrite(IN[1], HIGH);
//     digitalWrite(IN[2], HIGH);
//     digitalWrite(IN[3], LOW);

//     lumi_esq = digitalRead(9);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)

//     if(!lumi_esq){flag=false;}
//   }

//   halt();

//   com.startBelief("comm");
//   com.beliefAdd("turn");
//   com.endBelief();
//   com.sendMessage();

//  }

//ABAIXO CONSTAM APENAS AS FUNÇÕES DE SENTIDO DE GIRO E COMBINAÇÃO ENTRE OS MOTORES

void move_front(){

  digitalWrite(IN[0], LOW);
  digitalWrite(IN[1], HIGH);
  digitalWrite(IN[2], LOW);
  digitalWrite(IN[3], HIGH);

  // digitalWrite(PH1, HIGH);
  // digitalWrite(PH2, LOW); // move pneu direita para frente
  // digitalWrite(PH2, HIGH);
  // digitalWrite(PH4, LOW);

  // Serial.println("forward");

}

void halt(){
  digitalWrite(IN[0], LOW);
  digitalWrite(IN[1], LOW);
  digitalWrite(IN[2], LOW);
  digitalWrite(IN[3], LOW);
  // Serial.println("halt");
}

void move_back(){
  digitalWrite(IN[0], HIGH);
  digitalWrite(IN[1], LOW);
  digitalWrite(IN[3], HIGH);
  digitalWrite(IN[2], LOW);
}

void move_right(){
  digitalWrite(IN[0], LOW);
  digitalWrite(IN[1], HIGH);
  digitalWrite(IN[2], LOW);
  digitalWrite(IN[3], LOW);
  // Serial.println("right");
}

void move_left(){
  digitalWrite(IN[0], LOW);
  digitalWrite(IN[1], LOW);
  digitalWrite(IN[2], LOW);
  digitalWrite(IN[3], HIGH);
  // Serial.println("left");
}
