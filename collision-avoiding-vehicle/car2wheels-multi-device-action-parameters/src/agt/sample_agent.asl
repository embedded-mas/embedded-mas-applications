// +dist_left(L) 
//    <- .print("Distance LEFT: ", L).

// +dist_right(L) 
//    <- .print("Distance RIGHT: ", L).   



 !walk.

+!walk : obstacle_front(F) & F < 1 
   <- .print("Obstacle front") ;
      .back(1000);
      // .wait(1000);      //tive que ajustar o tempo para 1000 para dar tempo de o arduino processar
      .right(1000);
      //  .wait(1000);
      .print("Indo para trás");
      !walk.   

+!walk : obstacle_left(L) & L < 0.2 &
         (not obstacle_right(_) | obstacle_right(R) & R > L)
   <- .print("Obstacle left. Virando a direita ", L, ",", R) ;      
      .right(10000);
      //.print("Virando a direita");
      // .wait(100);
      !walk.

+!walk : obstacle_right(R) & R < 0.2 &
         (not obstacle_left(_) | obstacle_left(L) & L > R)
   <- .print("Obstacle right. Virando a esquerda", L, ",", R) ;
      .left(1000);
      //.print("Virando a esquerda");
      // .wait(100);
      !walk.


   

+!walk 
   <- .print("No obstacle. Moving forward");      
      // .front;
      .front(1000);
      //.print("Indo em frente");
      // .wait(1000);
      !walk;
      .
         