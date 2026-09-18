  
!move. //the agent has the goal to move

+!move //plan to satisfy the goal move
   <- .print("Moving front...");
      .front.  //move front
      
//when a for is detected, do something      
+fork_detected("true")
   <- .print("Fork detected. Path decision required");
      .left. //turn left
   
   
//when a line is detected after being lost, resume moving
+line_detected("true")
   <- .print("Line detected.");
      !move. //keep moving
      
      
/*   

   Use the internal actions .front, .left, .right to move in the desired direction.

*/
      
