
//export TURTLEBOT3_MODEL=burger &&\
//roslaunch turtlebot3_gazebo turtlebot3_world.launch

max_actuations(10000). //set a value X>0 to finish the application after X actuations
actuations(0).

// Compute the robot yaw from the orientation quaternion in the odometry belief.
// The yaw is the angle around the Z axis, expressed in radians.
robot_angle(Yaw) :-
    odometry(
        pose(
            pose(
                position(x(_),y(_)),
                orientation(
                    x(OX),
                    y(OY),
                    z(OZ),
                    w(OW)
                )
            )
        )
    ) &
    A = 2*(OW*OZ + OX*OY) &
    B = 1 - 2*(OY*OY + OZ*OZ) &
    atan2_approx(A,B,Yaw).


// Compute atan(z) using a polynomial approximation.
// The argument must satisfy -1 <= z <= 1.
atan_poly(Z,P) :-
    Z2 = Z*Z &
    Z3 = Z2*Z &
    Z5 = Z3*Z2 &
    Z7 = Z5*Z2 &
    Z9 = Z7*Z2 &
    Z11 = Z9*Z2 &
    P = Z - Z3/3 + Z5/5 - Z7/7 + Z9/9 - Z11/11.


// Compute atan2(A,B) when |A| <= |B| and B is positive.
// In this case, atan2(A,B) = atan(A/B).
atan2_approx(A,B,Yaw) :-
    A*A <= B*B &
    B > 0 &
    Z = A/B &
    atan_poly(Z,Yaw).


// Compute atan2(A,B) when |A| <= |B|, B is negative,
// and A is non-negative.
// The result is corrected to the second quadrant.
atan2_approx(A,B,Yaw) :-
    A*A <= B*B &
    B < 0 &
    A >= 0 &
    Z = A/B &
    atan_poly(Z,P) &
    Yaw = 3.141592653589793 + P.


// Compute atan2(A,B) when |A| <= |B| and both A and B are negative.
// The result is corrected to the third quadrant.
atan2_approx(A,B,Yaw) :-
    A*A <= B*B &
    B < 0 &
    A < 0 &
    Z = A/B &
    atan_poly(Z,P) &
    Yaw = -3.141592653589793 + P.


// Compute atan2(A,B) when |A| > |B| and A is positive.
// The argument is inverted to keep it within [-1,1].
atan2_approx(A,B,Yaw) :-
    A*A > B*B &
    A > 0 &
    Z = B/A &
    atan_poly(Z,P) &
    Yaw = 1.5707963267948966 - P.


// Compute atan2(A,B) when |A| > |B| and A is negative.
// The argument is inverted and the result is corrected to the
// corresponding lower half-plane.
atan2_approx(A,B,Yaw) :-
    A*A > B*B &
    A < 0 &
    Z = B/A &
    atan_poly(Z,P) &
    Yaw = -1.5707963267948966 - P.

    

!go_to(5,8).

+!go_to(X,Y) : position(MyX,MyY)
   <- .print("I am at (", MyX, ",", MyY, ") and I want to go to (", X, ",", Y, ").");
      !align(X,Y);
      .move_robot([0.2,0,0],[0,0,0]);
      .wait(100);
      !go_to(X,Y);
      .



+!go_to(X,Y)   
   <- .print("Waiting to start moving to (", X, ",", Y, ").");
      .wait(100);
      !go_to(X,Y).


+!align(X,Y) : position(MyX,MyY) & robot_angle(MyA) &  
               .angle(MyX, MyY, X, Y,A) & ((A-MyA)<(-0.1)|(A-MyA)>0.1) &
   <- .print("Angle: ", A, "   My angle: ", MyA);
      .move_robot([0,0,0],[0,0,0.2]); //turn right
      .wait(500);
      !align(X,Y);
      .

+!align(X,Y) 
   <- .print("I am aligned.");
       .move_robot([0,0,0],[0,0,0]);
      .

/** Calcular o angulo entre (X1,Y1) e (X2,Y2) em relacao a horizontal usando aproximação polinomial */



// !walk.

// // +!walk : odom(X,Y) & x > -10
// // +!walk : odometry(pose(pose(position(x(X),y(Y)))))
// +!walk : position(X,Y) & X > -10
//    <- .print("I should go left");
//       //  .move_robot([0,0,0],[0,0,0.2]); //turn right
//       .wait(100);
//       !walk.
      
// +!walk 
//    <- .print("waiting");
//       .wait(100);
//       !walk.



// +!walk : obstacle_front(F) & F < 1 
//    <- .print("Obstacle front") ;
//       .move_robot([-0.1,0,0],[0,0,0.0]);
//       ?actuations(A);
//       -+actuations(A+1);
//       .wait(100);
//       .move_robot([0,0,0],[0,0,-0.2]); //turn right
//       ?actuations(A2);
//       -+actuations(A2+1);
//       .wait(75);
//       !walk.   

// +!walk : obstacle_left(L) & L < 0.2 &
//          (not obstacle_right(_) | obstacle_right(R) & R > L)
//    <- .print("Obstacle left") ;
//       .move_robot([0,0,0],[0,0,-0.2]);
//       ?actuations(A);
//       -+actuations(A+1);
//       .wait(100);
//       !walk.

// +!walk : obstacle_right(R) & R < 0.2 &
//          (not obstacle_left(_) | obstacle_left(L) & L > R)
//    <- .print("Obstacle right") ;
//       .move_robot([0,0,0],[0,0,0.2]);
//       ?actuations(A);
//       -+actuations(A+1);
//       .wait(100);
//       !walk.


   

// +!walk 
//    <- .print("no obstacle") ;
//       .move_robot([0.2,0,0],[0,0,0.0]);
//       ?actuations(A);
//       -+actuations(A+1);
//       .wait(100);
//       !walk.      


// /*      
// +!walk : obstacle_front(X) & X<1
//    <- .print("walking obst...", X); 
//       .move_robot([-0.2,0,0],[0,0,0]);
//       .wait(obstacle_front(K)&K>1.2);
//       //!turn;
//       !walk.
//       .
      
                  
      
// +!walk : obstacle_front(X) 
//    <- .move_robot([0.2,0,0],[0,0,0]);
//       .print("walking nobst...", X);
//       .wait(500);
//       !walk.      

// +!walk : not obstacle_front(X)
//    <- .wait(obstacle_front(_));
//       !walk. 
      
// */    
// /*//case 0: sem obstáculose
// +!turn : obstacle_front(F) & F >= 1 &      
//          obstacle_right(R) & R >= 1 &    
//          obstacle_left(L)  & L >= 1 
//    <- .print("No obstacles").
// */
      
// //case 1: obstaculo à frente, direita e à esquerda - vai para trás
// +!turn : obstacle_front(F) & F < 1 &  
//          obstacle_right(R) & R < 1 &     
//          obstacle_left(L)  & L < 1   
//    <- .print("Obstacle left and right.", R, ", ", L);
//       .move_robot([-0.2,0,0],[0,0,0]);
//       .wait(100);
//       !turn.    
      
// //case 2: obstaculo à frente e à  direita - vai para a esquerda
// +!turn : obstacle_front(F) & F < 1 &  
//          obstacle_right(R) & R < 1              
//    <- .print("Obstacle right.", R);
//       .move_robot([0,0,0],[0,0,0.2]);
//       .wait(100);
//       !turn. 

// //case 3: obstáculo a frente, sem obstáculo à direita - a direita
// +!turn : obstacle_front(F) & F < 1 
//  <- .print("No obstacle right");
//    .move_robot([0,0,0],[0,0,-0.2]);
//    .wait(100);
//    !turn. 

// //case 4: sem obstáculos - atingiu o objetivo turn
// +!turn.

// //-------------------------------------------------------------    

// +actuations(A) : max_actuations(M) & M>-1 & A>M 
//    <- .move_robot([0,0,0],[0,0,0.0]);
//       .print("Finishing system after ", A, " actuations."); 
//       .stopMAS.

// { include("$jacamo/templates/common-cartago.asl") }
// { include("$jacamo/templates/common-moise.asl") }

// // uncomment the include below to have an agent compliant with its organisation
// //{ include("$moise/asl/org-obedient.asl") }
