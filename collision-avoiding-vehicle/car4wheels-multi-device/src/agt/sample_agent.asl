// obstacle_front(L) :- dist_left(L) & dist_right(R) & L<=0.2 & R <=0.2 & L < R.

// obstacle_front(R) :- dist_left(L) & dist_right(R) & L<=0.2 & R <=0.2 & L >= R.


// obstacle_right(R) :- dist_left(L) & dist_right(R) & L>0.2 & R <=0.2.


// obstacle_left(L) :- dist_left(L) & dist_right(R) & L<=0.2 & R>0.2.


// +dist_left(L) : obstacle_front(X)  & dist_right(R) 
//    <- .print("obstacle front ", X, " left: ", L, " right: ", R).

// +dist_left(L) : obstacle_left(L)  & dist_right(R) 
//    <- .print("obstacle  left: ", L, " right: ", R).   

// +dist_left(L) : obstacle_right(R)  & dist_right(R) 
//    <- .print("obstacle  right: ", L, " right: ", R).      
   
+dist_left(L) 
   <- .print("Distance LEFT: ", L).

+dist_right(L) 
   <- .print("Distance RIGHT: ", L).   



 !walk.

+!walk : obstacle_front(F) & F < 1 
   <- .print("Obstacle front") ;
      .back;
      .wait(1000);      //tive que ajustar o tempo para 1000 para dar tempo de o arduino processar
      .right;
       .wait(1000);
      .print("Indo para trás");
      !walk.   

+!walk : obstacle_left(L) & L < 0.2 &
         (not obstacle_right(_) | obstacle_right(R) & R > L)
   <- .print("Obstacle left. Virando a direita ", L, ",", R) ;      
      .right;
      //.print("Virando a direita");
      .wait(100);
      !walk.

+!walk : obstacle_right(R) & R < 0.2 &
         (not obstacle_left(_) | obstacle_left(L) & L > R)
   <- .print("Obstacle right. Virando a esquerda", L, ",", R) ;
      .left;
      //.print("Virando a esquerda");
      .wait(100);
      !walk.


   

+!walk 
   <- .print("No obstacle. Moving forward");      
      .front;
      //.print("Indo em frente");
      .wait(100);
      !walk;
      .
         