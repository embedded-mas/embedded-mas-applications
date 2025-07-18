#include<Embedded_Protocol_2.h>
#include<ArduinoJson.h>
#include<NewPing.h>
#include<AFMotor.h>

Communication communication;

//DEFININDO VARIÁVEIS DO SENSOR
#define TRIGGER_PIN_1 A1
#define ECHO_PIN_1 A0
#define TRIGGER_PIN_2 A3
#define ECHO_PIN_2 A5
#define MAX_DISTANCE 200

int leitura = 1;
int sensor_state = 5;
float dist_sensor_1, //left distance sensor
    dist_sensor_2; //right distance sensor


NewPing sonar_1(TRIGGER_PIN_1, ECHO_PIN_1, MAX_DISTANCE);
NewPing sonar_2(TRIGGER_PIN_2, ECHO_PIN_2, MAX_DISTANCE);

//DEFININDO VARIÁVEIS MOTORES
AF_DCMotor motorFL(1);
AF_DCMotor motorFR(4);
AF_DCMotor motorBL(2);
AF_DCMotor motorBR(3);


void setup() 
{


  randomSeed(analogRead(0));

  //VELOCIDADE DOS MOTORES -> AJUSTÁVEL CASO NÃO ESTEJAM SINCRONIZADOS (255 = Vmáx)
  motorFR.setSpeed(255);
  motorBR.setSpeed(255);
  motorFL.setSpeed(255);
  motorBL.setSpeed(255);

  halt(); //OS MOTORES INICIAM PARADOS

  Serial.begin(9600);

  /* Build perception that the lihgt is on and send it to the upper layers*/ 
  communication.startBelief("init");
  communication.beliefAdd(1);
  communication.endBelief();
  communication.sendMessage();
  
  delay(10000); //wait 10 seconds (to set up the multi-agent system)
}

void loop() 
{
  readSensors();

  //distance_correction();


  while(Serial.available() > 0){ //check whether there is some information from the serial (possibly from the agent)
    String s = Serial.readString();
  
    if(s.equals("infront")){ //if the agent sends "light_on", then switch the light on
      halt();
      moveForward();         
    }

    if(s.equals("toleft")){ //if the agent sends "light_on", then switch the light on
      
      halt();
      moveBackward();
      delay(500);
      halt();

      halt();
      moveLeft();
      delay(500);
      halt();     
    }

    if(s.equals("toright")){ //if the agent sends "light_on", then switch the light on
      
      halt();
      moveBackward();
      delay(500);
      halt();

      halt();
      moveRight();
      delay(500);
      halt();     
    }

    if(s.equals("toback")){ //if the agent sends "light_on", then switch the light on
      
      moveBackward();
      delay(1000);
      halt();
      moveRight();
      delay(2000);
      halt();     
    }
    
    leitura = 1;
  }

  
  
  if(leitura == 1){
     generatePercepts();
  }
  
}


/*
 * TODO: Implementar leitura dos sensores
 */
void readSensors(){
   long d1, d2;       
   d1 = random(100); Serial.println(d1);
   d2 = random(100); Serial.println(d2);

   dist_sensor_1 = d1/100.0; Serial.println(dist_sensor_1);
   dist_sensor_2 = d2/100.0; Serial.println(dist_sensor_2);

   delay(5000); //espera 5 secs para rodar experimentos sem o carrinho
}



void generatePercepts(){
  
   communication.startBelief("dist_left");
   communication.beliefAdd(dist_sensor_1);
   communication.endBelief();

   communication.startBelief("dist_right");
   communication.beliefAdd(dist_sensor_2);
   communication.endBelief();
   communication.sendMessage();

  
//    //*****SE NÃO ENCONTRAR NADA A 20 CM DOS SENSORES, ENTÃO SEGUE*****
//    if(dist_sensor_1 >= 20 && dist_sensor_2 >= 20 && sensor_state != 1){
//      sensor_state = 1;
//      leitura = 0;
//      //pode seguir em frente
//      communication.startBelief("conditions");
//      communication.beliefAdd(3);
//      communication.endBelief();
//      communication.sendMessage();
//    }
//    
//    //*****SE ENCONTRAR ALGO PŔOXIMO, ENTÃO PARA E VERIFICA*****
//    else if(dist_sensor_1 < 20 && sensor_state != 0 || dist_sensor_2 < 20 && sensor_state != 0){
//      sensor_state = 0;
//      leitura = 0;
//
//      int dist_difference = dist_sensor_1 - dist_sensor_2;
//
//      if(dist_difference > 5){
//        //move-se para um lado
//        communication.startBelief("conditions");
//        communication.beliefAdd(2);
//        communication.endBelief();
//        communication.sendMessage();
//      }
//      else if(dist_difference < -5){
//        //move-se para o outro lado
//        communication.startBelief("conditions");
//        communication.beliefAdd(1);
//        communication.endBelief();
//        communication.sendMessage();
//      }
//      else{
//        //obstáculo nos dois sensores com msm distancia
//        communication.startBelief("conditions");
//        communication.beliefAdd(0);
//        communication.endBelief();
//        communication.sendMessage();
//      }
//    }
}


void motorFL_Forward(){
   motorFL.run(FORWARD);
}

void motorFL_Backward(){
   motorFL.run(BACKWARD);
}

void motorFL_Release(){
   motorFL.run(RELEASE);
}

void motorFR_Forward(){
   motorFR.run(FORWARD);
}

void motorFR_Backward(){
   motorFR.run(BACKWARD);
}

void motorFR_Release(){
   motorFR.run(RELEASE);
}


void motorBL_Forward(){
   motorBL.run(FORWARD);
}

void motorBL_Backward(){
   motorFL.run(BACKWARD);
}

void motorBL_Release(){
   motorBL.run(RELEASE);
}


void motorBR_Forward(){
   motorBR.run(FORWARD);
}

void motorBR_Backward(){
   motorBR.run(BACKWARD);
}


void motorBR_Release(){
   motorBR.run(RELEASE);
}


void moveForward(){

  motorBL_Forward();
  motorFL_Forward();
  motorBR_Forward();
  motorFR_Forward();

}

void moveBackward(){

  motorBL_Backward();
  motorFL_Backward();
  motorBR_Backward();
  motorFR_Backward();

}

void moveRight(){

  motorBL_Release();
  motorFL_Release();
  motorBR_Forward();
  motorFR_Forward();

}

void moveLeft(){

  motorBR_Release();
  motorFR_Release;
  motorBL_Forward();
  motorFL_Forward();

}

void halt(){

  motorBR_Release();
  motorFR_Release();
  motorBL_Release();
  motorFL_Release();

}

void distance_correction(){

  if(dist_sensor_1 == 0) dist_sensor_1 = 1000;
  if(dist_sensor_2 == 0) dist_sensor_2 = 1000;

}
