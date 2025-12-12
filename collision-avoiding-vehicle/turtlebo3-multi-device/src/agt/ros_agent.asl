
//export TURTLEBOT3_MODEL=burger && roslaunch turtlebot3_gazebo turtlebot3_world.launch

// obstacle_front(X) :- distance_reading(ranges(L)) &
//                     .length(L,S) & 
//                     .nth(0,L,X).    


// obstacle_right(X) :- distance_reading(ranges(L)) &
//                     .length(L,S) & 
//                     .nth(40,L,X).    


// obstacle_left(X) :- distance_reading(ranges(L)) &
//                     .length(L,S) & 
//                     .nth(300,L,X).    


obstacle(front,D) :- distance_reading(ranges(L)) &
                     .length(L,S) & 
                     .nth(0,L,D).    

obstacle(right,D) :- distance_reading(ranges(L)) &
                    .length(L,S) & 
                    .nth(40,L,D).    

obstacle(left,D) :- distance_reading(ranges(L)) &
                    .length(L,S) & 
                    .nth(300,L,D).                    



!walk.

// +!walk : obstacle_front(F) & F < 1 
//    <- .print("Obstacle front") ;
//       .back;
//       .wait(50);
//       .right;
//       .wait(100);
//       !walk.   

// +!walk : obstacle_left(L) & L < 0.2 &
//          (not obstacle_right(_) | obstacle_right(R) & R > L)
//    <- .print("Obstacle left") ;
//       .right;
//       .wait(100);
//       !walk.

// +!walk : obstacle_right(R) & R < 0.2 &
//          (not obstacle_left(_) | obstacle_left(L) & L > R)
//    <- .print("Obstacle right") ;
//       .left;
//       .wait(100);
//       !walk.


+!walk : obstacle(front,D) & D < 1 
   <- .print("Obstacle front") ;
      .back(75);
      .right(100);
      !walk.   

+!walk : obstacle(left(L)) & L < 0.2 &
         (not obstacle(right,_) | obstacle(right,R) & R > L)
   <- .print("Obstacle left") ;
      .right(100);
      !walk.

+!walk : obstacle(right,R) & R < 0.2 &
         (not obstacle(left,_) | obstacle(left,L) & L > R)
   <- .print("Obstacle right") ;
      .left(100);
      !walk.

   

+!walk 
   <- .print("no obstacle") ;
      .front(1000);
      !walk.      


{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moise/asl/org-obedient.asl") }
