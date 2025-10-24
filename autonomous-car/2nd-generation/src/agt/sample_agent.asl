
//Plan for handling fork detection. The agent must decide to turn either left or right.
+fork_detected
   <- .print("Fork detected. Path decision required").	
   
   
//Plan for handling line detection. The agent can move forward.
+line_detected
   <- .print("Line detected").	   
   
/*   

   Use the internal actions .front, .left, right to move in the desired direction.

*/
