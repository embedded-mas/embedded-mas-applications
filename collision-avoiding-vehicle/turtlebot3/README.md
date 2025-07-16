# 1. Application overview
This application example illustrates an agent (see the agent code [here](src/agt/ros_agent.asl)) whose body is a simulated [Turtlebot3](https://emanual.robotis.com/docs/en/platform/turtlebot3/overview/). The perceptions of the agent (and its corresponding beliefs) come from the robot's sensors. The actions of the agent are actually realized through the robot's actuators. The connection between the agent code and its body is specified in the yaml file [here](src/agt/robot1.yaml).

# 2. Application Scenario
The application contains an agent embodied in a simulated [Turtlebot3](https://emanual.robotis.com/docs/en/platform/turtlebot3/overview/). The robot acts in a walled environment with additional obstacles. In this example, it has the goal to move around the environment avoiding collisions. When detecting an obstacle, it turns right if possible; otherwise, it turns left.

## 2.1 Agent's perceptions

Distances from obstacles are measured by a LIDAR sensor and recorded in the topic *scan(header, angle_min, angle_max, angle_increment, time_increment, range_min, range_max, ranges(D), intensities)* s.t. (i) *ranges(D)* defines a list $D$ of 360 positions, corresponding to the distance of obstacles in the angles $0^\circ$ to $360^\circ$; and (ii) the remainder parameters are not relevant. This value of the topic *scan* is translated to the belief `distance(ranges(L))`, where `L` is the list of 360 positions. The mapping between the topic and the corresponding belief is specified in the key `perceptionTopics` of the  [yaml configuraton file](src/agt/robot1.yaml). To simplify the agent specification, the agent has three inference rules to conclude the following facts:  
- `obstacle_front(X)`, when there is some obstacle ahead at distance `X`, which is the case when the first distance recorded in the list `D` of the belief distance(ranges(D))  *scan* is `X`.
- `obstacle_left(X)`, when there is some obstacle at left at distance `X`, which is the case when the $40^{th}$ distance recorded in the list `D` of the belief distance(ranges(D))  *scan* is `X`.
- `obstacle_right(X)`, when there is some obstacle at right at distance `D`, which is the case when the $300^{th}$ distance recorded in the list `D` of the belief distance(ranges(D))  *scan* is `X`.

The inference rules that specify these facts are specified in the key `perceptionRules` of the  [yaml configuraton file](src/agt/robot1.yaml). 

## 2.1 Agent's actions
The agent has the action *move\_robot(L,A)* in its repertory, used to move with linear velocity *L* and angular velocity *A*. These velocities are decomposed in three values, corresponding to the axis $x$, $y$, and $z$. When the robot executes this action, the parameters *A* and *L* are published in the topic *cmd\_vel*, which causes the robot moving accordingly. The mapping between the action and the corresponding topic is specified in the key `topicWritingActions` of the  [yaml configuraton file](src/agt/robot1.yaml).



# 3. Requirements
- Java JRE >= 17

Additional requirements depend on the method chosen set the simulation up (cf. sections 4.1.1 and 4.1.2 below).

# 4. Running the example
Running the example requires two main steps:  
1. Launch the ROS infrastructure (cf. Section 4.1 below)
2. Launch the JaCaMo application (cf. Section 4.2 below)


### 4.1. Ros node setup:

It is possible to choose between a container-based setup (recommended - only Docker is required) and a local setup (ROS core and related tools are required).

#### 4.1.1 Container-based setup: 
Requirements: [Docker](https://www.docker.com/)

Use the following command to launch the ROS infrastructure:

In a shell, type ```./launch_ros.sh``` to launch the ROS infrastructure. (preceed with ```sudo``` if needed).


Then, go to [http://localhost:8080/vnc.html](http://localhost:8080/vnc.html) to inspect the simulator.

#### 4.1.2 Local setup: 
Requirements
1. [ROS Noetic](http://wiki.ros.org/noetic)
2. [Rosbridge](http://wiki.ros.org/rosbridge_suite/Tutorials/RunningRosbridge)
3. [Turtlebot3 simulator](https://emanual.robotis.com/docs/en/platform/turtlebot3/simulation/)

To run the ROS node in your computer, type the following commands in a shell:

- ``` roscore ``` (to start the roscore)
- ``` roslaunch rosbridge_server rosbridge_websocket.launch``` (to launch the bridge between ROS and Java)
- ``` export TURTLEBOT3_MODEL=burger && roslaunch turtlebot3_gazebo turtlebot3_world.launch``` (to launch the simulator)



### 4.2. Launch the JaCaMo application:

#### Linux:
```
./gradlew run
```
#### Windows:
```
gradlew run 
```

## Some notes on the ROS-Jason integration
This integration is part of a broader integration framework available [here](https://github.com/embedded-mas/embedded-mas)

Agents are configured in the jcm file (in this example, [jason-ros.jcm](jason-ros.jcm)). This example has what we call a <em>cyber-physical agent</em>, which is a software agent that includes physical elements. It may get perceptions from sensors while its actions' repertory may include those enabled by physical actuators. Cyber-physical agents are implemented by the class [`CyberPhysicalAgent`](https://github.com/embedded-mas/embedded-mas/blob/master/src/main/java/embedded/mas/bridges/jacamo/CyberPhysicalAgent.java), that extends [Jason Agents](https://github.com/jason-lang/jason/blob/master/src/main/java/jason/asSemantics/Agent.java). The physical portion of cyber-physical agents is set up in a yaml file with the same name and placed in the same folder as the asl file where the agent is specified. In this example, this file is placed [here](src/agt/robot1.yaml).


A cyber-physical agent can be composed of one to many <em>devices</em>, which are defined in the yaml configuration file. A <em>device</em> is any external element which sensors and actuators are connected to. A device may be either physical (e.g. an Arduino board), or virtual (e.g. a ROS core). Each device has a unique identifier, which is set in the ```device_id``` key of the yaml file. In this example, the agent is composed of a single device, that is a ROS core identified as <em>sample_roscore</em>. An agent can connect with multiple ROS core, if necessary (it is not the case in this example). Besides, an agent can connect with non-ros devices (not shown in this example). Any device is implemented by a Java class that provides interfaces between the parception/action systems of the agent and the real device, according to the [IDevice interface](https://github.com/embedded-mas/embedded-mas/blob/master/src/main/java/embedded/mas/bridges/jacamo/IDevice.java). In this example, it is implemented by the class [RosMaster](https://github.com/embedded-mas/embedded-mas/blob/master/src/main/java/embedded/mas/bridges/ros/RosMaster.java). The device implementing class is defined in the ```className``` key of the configuration file. In addition, a <em>device</em> has three essential configuration items: <em>microcontrollers</em>, <em>perception sources</em>, and <em>enabled actions</em>. These items are explained below.

### Microcontrolers configuration
A device has a <em>microcontroller</em>, which is a Java interface that enables reading from and writing in the physical/virtual device. This interface is set up under the ```microcontroller``` key in the yaml file. Any microcontroller has an identifier, defined in the key ```id```. Any microcontroller implementation must implement the [IExternalInterface](https://github.com/embedded-mas/embedded-mas/blob/master/src/main/java/embedded/mas/bridges/jacamo/IExternalInterface.java). In this example, it is implemented by the class [DefaultRos4EmbeddedMas](https://github.com/embedded-mas/embedded-mas/blob/master/src/main/java/embedded/mas/bridges/ros/DefaultRos4EmbeddedMas.java). The device implementing class is defined in the ```microcontroller/className``` key of the configuration file. In addition, different microcontrollers may have some parameters that are depending on their nature. For example, serial devices like Arduino require configuring serial ports and baud rates. In this example, the microcontroller is a ROS-Java interface. It has a ROS specific parameter, whose key is ```connectionString```. It sets the connection string to the ROS core (e.g. ws://localhost:9090).

### Perception configuration
The sensors connected to a <em>device</em> may be source of perceptions of the agent. If the device is a ROS core, then these sensors are abstracted through topics. The list of topics that produce perceptions is configured in the ```perceptionTopics``` item in the yaml file. Each topic requires to define its name and its type, through the keys ```topicName``` and ```topicType```, respectively. These perceptions produce beliefs in the agent's mind. By default, the belief name has the same identifier (or <em>functor</em>) as the topic identifier. <!--For instance, in this example, the topic ```value1``` produces the belief ```value1(I)```, where ```I``` is an integer number. It is also possible to customize the belief using the optional key ```beliefName```, whose value is the intended belief name. For instance, in this example, the topic ```current_time``` produces the belief ```current_hour(S)```, where ```S``` is a string.-->

   
### Action configuration   
The actions enabled by the actuators connected to a <em>device</em> may be included in the agent's action repertory. If the device is a ROS core, then these actions may be realized both through topic writings and service requests, configured in the keys ```topicWritingActions``` and ```serviceRequestActions``` of the yaml file, respectively. In this example, the agent performs only topic writing actions, that require the following configurations:

   - ```actionName```: the name of the action performed by the agent;

   - ```topicName```: the name of the topic affected by the action;

   - ```topicType```: the type of the topic.

<!--
Notice that the action and topic names may differ. For instance, in this example, the action <em>update_value1</em> is realized through a writing in the topic <em>/value1</em>. The agent action and the physical/virtual actuation are thus decoupled.


```
(docker ps -q --filter "name=novnc" | grep -q . && docker stop novnc || true) &&\
(docker ps -q --filter "name=noetic" | grep -q . && docker stop noetic || true) &&\
sudo docker run -d --rm --net=ros --env="DISPLAY_WIDTH=3000" --env="DISPLAY_HEIGHT=1800" --env="RUN_XTERM=no" --name=novnc -p=8080:8080 theasp/novnc:latest &&\
sudo docker run -it -p11311:11311 -p9090:9090 --rm --net=ros --env="DISPLAY=novnc:0.0" --name noetic maiquelb/embedded-mas-ros:latest \
/bin/bash -c "source /opt/ros/noetic/setup.bash && \
(export TURTLEBOT3_MODEL=burger && roslaunch turtlebot3_gazebo turtlebot3_world.launch > /dev/null 2>&1 &) && \
(sleep 5 && roslaunch rosbridge_server rosbridge_websocket.launch > /dev/null 2>&1 &) && \
sleep 5 && \
echo -e '\e[1;33m**** Docker container is ready. Start the JaCaMo application ****\e[0m' && \
tail -f /dev/null"
```
-->