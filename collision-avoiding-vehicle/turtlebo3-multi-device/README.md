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
