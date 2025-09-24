
# System overview
The robot follows a path represented by a ground line, which may have decision points (e.g. forks). Upon reaching a decision point, the robot is decides what to do (turn left, turn right, moving forward).


<img src="images/path.png" alt="Diagrama do robô" width="500"/>

Small signals at right of the line mark a decision point ahead. Notice that decision point detected and line following control is implemented in the firmware, without requiring any decision from the robot. 


## Agent description
The agent can move around the map by performing the following internal actions

While running, the agent may have the following perceptions:
- `path_lost`, when there is not line to follow and a decision is required (e.g. turn left or right);
- `path_detected` when a line is detected.


## Firmware description
The system implements a **line-following robot with decision-point detection and agent deliberation support**.  
Its control logic is executed on an Arduino platform, integrating motor control, optical line sensors, and a communication layer for coordination with an external agent.

The firmware expects some of the following commands (so-called *actuations*) from the agent reasoning system:
- `move_front` → to move forward
- `move_left` → to turn left
- `move_right` → to turn right.

These behaviours are explained below:
- *moving forward*: the vehicle keeps in continuous forward motion with line-following correction. After detecting a decision mark, the vehicle continues forward until loosing line detection, when it stops. The firmware sends the perception `path_decision_required` to the agent. 
- *turning left*: the vehicle turns left until the line is detected. The firmware sends the perception `line_detected` to the agent.
- *turning right*: the vehicle turns right until the line is detected. The firmware sends the perception `line_detected` to the agent. 

## Behaviors

### `front()`
- Sends belief `front(in)` through the communication module.  
- Implements continuous forward motion with **line-following correction**:
  - Both sensors detect line → advance (`move_front()`).  
  - Only right sensor detects line → correct left (`move_right()`).  
  - Only left sensor detects line → correct right (`move_left()`).  
- When the marker sensor (`lumi_mark`) is activated:
  - The robot continues forward until both sensors lose line detection.  
  - The robot halts and exits the loop, signaling that it has reached a decision point.  
- Sends belief `comm(ahead)` after halting.  

### `d_left()`
- Sends belief `insp(t2)`.  
- Executes a left turn until the left sensor detects line again.  
- Stops and sends belief `comm(ahead)`.  

### `d_right()`
- Sends belief `insp(t3)`.  
- Executes a right turn until the right sensor detects line again.  
- Stops and sends belief `comm(ahead)`.  

---

## Motion Primitives
- `move_front()`: both motors forward.  
- `move_back()`: both motors backward.  
- `move_left()`: right motor forward, left motor halted.  
- `move_right()`: left motor forward, right motor halted.  
- `halt()`: all motors stopped.  

---

## Communication and Integration
The robot uses the `Communication` object to exchange **beliefs** representing its state and actions with an external system.  
This suggests integration with a **BDI-style agent framework**, where high-level decision-making (e.g., route selection at intersections) is delegated to an external deliberative agent, while the Arduino executes low-level reactive control.  

---

## Behavioral Summary
- The robot follows a ground line using two optical sensors with simple correction logic.  
- It detects decision points using a dedicated marker sensor.  
- Upon reaching a decision point, it halts and notifies the external system.  
- Directional commands from the external system (`move_left`, `move_right`, `move_front`) enable the robot to re-align with the line and continue.  

### Hybrid Control Architecture
- **Reactive layer:** Arduino-based motor and sensor control.  
- **Deliberative layer:** external reasoning agent informed by beliefs communicated from the robot.  
