
//export TURTLEBOT3_MODEL=burger && roslaunch turtlebot3_gazebo turtlebot3_world.launch

obstacle_front(X) :- distance_reading(ranges(L)) &
                    .length(L,S) & 
                    .nth(0,L,X).    


obstacle_right(X) :- distance_reading(ranges(L)) &
                    .length(L,S) & 
                    .nth(40,L,X).    


obstacle_left(X) :- distance_reading(ranges(L)) &
                    .length(L,S) & 
                    .nth(300,L,X).    


!walk.

+!walk : obstacle_front(F) & F < 1 
   <- .print("Obstacle front") ;
      //.move_robot([-0.1,0,0],[0,0,0.0]);
      .back;
      .wait(50);
      //.move_robot([0,0,0],[0,0,-0.2]); //turn right
      .right;
      .wait(100);
      !walk.   

+!walk : obstacle_left(L) & L < 0.2 &
         (not obstacle_right(_) | obstacle_right(R) & R > L)
   <- .print("Obstacle left") ;
      //.move_robot([0,0,0],[0,0,-0.2]);
      .right;
      .wait(100);
      !walk.

+!walk : obstacle_right(R) & R < 0.2 &
         (not obstacle_left(_) | obstacle_left(L) & L > R)
   <- .print("Obstacle right") ;
      //.move_robot([0,0,0],[0,0,0.2]);
      .left;
      .wait(100);
      !walk.


   

+!walk 
   <- .print("no obstacle") ;
      //.move_robot([0.2,0,0],[0,0,0.0]);
      .front;
      .wait(100);
      !walk.      


/*      
+!walk : obstacle_front(X) & X<1
   <- .print("walking obst...", X); 
      .move_robot([-0.2,0,0],[0,0,0]);
      .wait(obstacle_front(K)&K>1.2);
      //!turn;
      !walk.
      .
      
                  
      
+!walk : obstacle_front(X) 
   <- .move_robot([0.2,0,0],[0,0,0]);
      .print("walking nobst...", X);
      .wait(500);
      !walk.      

+!walk : not obstacle_front(X)
   <- .wait(obstacle_front(_));
      !walk. 
      
*/    
/*//case 0: sem obstáculose
+!turn : obstacle_front(F) & F >= 1 &      
         obstacle_right(R) & R >= 1 &    
         obstacle_left(L)  & L >= 1 
   <- .print("No obstacles").
*/
      
//case 1: obstaculo à frente, direita e à esquerda - vai para trás
+!turn : obstacle_front(F) & F < 1 &  
         obstacle_right(R) & R < 1 &     
         obstacle_left(L)  & L < 1   
   <- .print("Obstacle left and right.", R, ", ", L);
      .move_robot([-0.2,0,0],[0,0,0]);
      .wait(100);
      !turn.    
      
//case 2: obstaculo à frente e à  direita - vai para a esquerda
+!turn : obstacle_front(F) & F < 1 &  
         obstacle_right(R) & R < 1              
   <- .print("Obstacle right.", R);
      .move_robot([0,0,0],[0,0,0.2]);
      .wait(100);
      !turn. 

//case 3: obstáculo a frente, sem obstáculo à direita - a direita
+!turn : obstacle_front(F) & F < 1 
 <- .print("No obstacle right");
   .move_robot([0,0,0],[0,0,-0.2]);
   .wait(100);
   !turn. 

//case 4: sem obstáculos - atingiu o objetivo turn
+!turn.

//-------------------------------------------------------------    

{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moise/asl/org-obedient.asl") }
