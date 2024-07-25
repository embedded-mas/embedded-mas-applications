#include<Embedded_Protocol_2.h>
#include<ArduinoJson.h>
//#include<NewPing.h>
#include<AFMotor.h>

//DEFININDO VARIÁVEIS MOTORES
AF_DCMotor motorFL(1);
AF_DCMotor motorFR(4);
AF_DCMotor motorBL(2);
AF_DCMotor motorBR(3);
int lumi_esq = 0;           //Necesidade de ser uma variável global
int lumi_dir = 0;          //Necesidade de ser uma variável global
int lumi_mark = 0;

int time = 5000; // tempo que o agente espera antes da proxima instrucao

// noDelay BeliefTime(500); //tempo do envio das crenças
Communication com;

/* Devido ao fato de terem muitos sensores conectados ao Vcc e o arduíno possuir apenas um pino para isto
defini-se o pino 13 em nível lógico alto, apenas para distribuir as cargas */

void setup() {

  //VELOCIDADE DOS MOTORES -> AJUSTÁVEL CASO NÃO ESTEJAM SINCRONIZADOS (255 = Vmáx)
  motorFR.setSpeed(255);
  motorBR.setSpeed(255);
  motorFL.setSpeed(255);
  motorBL.setSpeed(255);

  halt(); //OS MOTORES INICIAM PARADOS

  Serial.begin(9600);

  delay(2000);

}

void loop() {

  while (Serial.available() > 0) { // checa presenca de informacao na serial
    String s = Serial.readString();
    if(s.equals("move_front")){
      front(); // caso agente envie 'front', arduino move o robo para frente

    } else if(s.equals("move_left")){
      d_left();   // caso agente envie 'left', arduino move o robo para esquerda

    } else if(s.equals("move_right")){
      d_right();  // caso agente envie 'right', arduino move o robo para direita
      
    }
  }
 }

void front(){

  bool frwd = true;

  // char comm = "wait";
  // com.startBelief("wait");
  // com.beliefAdd(comm);
  // com.endBelief();

  // com.sendMessage();

  while(frwd){

    lumi_esq = digitalRead(A4);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)
    lumi_dir = digitalRead(A2);           //Variável de medida do sensor de luminosidade direito (vista traseira)

    if(lumi_esq && lumi_dir){ //Caso ambos sensores estejam identificando luminosidade
      moveForward();                   //O carrinho se locomove para frente
    }
    else if(!lumi_esq && lumi_dir){ //Caso o sensor da direita identifique luminosidade
      moveRight();                        //O carrinho se move para a esquerda, afim de encontrar a linha
    }
    else if(lumi_esq && !lumi_dir){ //Caso o sensor da esquerda identifique luminosidade
      moveLeft();                       //O carrinho se move para a direita, afim de encontrar a linha
    }

    lumi_mark = digitalRead(9);          //Variável digital de detecção de marcador (sensor de decisao) 

    if(lumi_mark){
      while(frwd){ // o carrinho precisa ir para frente até o ponto de decisão
        moveForward();

        lumi_esq = digitalRead(A4);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)
        lumi_dir = digitalRead(A2);           //Variável de medida do sensor de luminosidade direito (vista traseira)

        if(!lumi_esq && !lumi_dir!){
          frwd = false;
        }
      }
      delay(500);
      halt();              //O agente toma uma decisao
      break;
    }
  }

  com.startBelief("comm");
  com.beliefAdd("ahead");
  com.endBelief();

  com.sendMessage();

 }

 void d_left(){

  com.startBelief("insp");
  com.beliefAdd("decisionL");
  com.endBelief();

  com.sendMessage();

  while(lumi_dir == 0){
    lumi_dir = digitalRead(A4);           //Variável de medida do sensor de luminosidade esquerdo (vista traseira)

    motorBL.run(BACKWARD);
    motorFL.run(BACKWARD);
    // motorBL.run(RELEASE);
    // motorFL.run(RELEASE);
    motorBR.run(FORWARD);
    motorFR.run(FORWARD);

    // Serial.println("Decision Left");
  }

  halt();

  com.startBelief("comm");
  com.beliefAdd("ahead");
  com.endBelief();
  com.sendMessage();

 }

 void d_right(){

  com.startBelief("insp");
  com.beliefAdd("decisionR");
  com.endBelief();
  com.sendMessage();

  while(lumi_esq == 0){
    lumi_esq = digitalRead(A2);         //Variável de medida do sensor de luminosidade direito (vista traseira)

    motorBR.run(BACKWARD);
    motorFR.run(BACKWARD);
    // motorBR.run(RELEASE);
    // motorFR.run(RELEASE);
    motorBL.run(FORWARD);
    motorFL.run(FORWARD);

    // Serial.println("Decision Right");
  }

  halt();

  com.startBelief("comm");
  com.beliefAdd("ahead");
  com.endBelief();
  com.sendMessage();

 }


void moveForward(){

  motorBL.run(FORWARD);
  motorFL.run(FORWARD);
  motorBR.run(FORWARD);
  motorFR.run(FORWARD);

  Serial.println("forward");

}

void moveBackward(){

  motorBL.run(BACKWARD);
  motorFL.run(BACKWARD);
  motorBR.run(BACKWARD);
  motorFR.run(BACKWARD);

  Serial.println("backward");

}

void moveLeft(){

  motorBL.run(RELEASE);
  motorFL.run(RELEASE);
  motorBR.run(FORWARD);
  motorFR.run(FORWARD);

  Serial.println("left");

}

void moveRight(){

  motorBR.run(RELEASE);
  motorFR.run(RELEASE);
  motorBL.run(FORWARD);
  motorFL.run(FORWARD);

  Serial.println("right");

}

void halt(){

  motorBR.run(RELEASE);
  motorFR.run(RELEASE);
  motorBL.run(RELEASE);
  motorFL.run(RELEASE);

}