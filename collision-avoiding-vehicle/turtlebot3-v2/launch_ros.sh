#!/bin/bash
set -e

# 1) Para containers antigos
(docker ps -q --filter "name=novnc" | grep -q . && docker stop novnc || true)
(docker ps -q --filter "name=embedded-mas-example" | grep -q . && docker stop embedded-mas-example || true)

# 2) Garante rede 'ros' e volume para o socket X11
(docker network inspect ros >/dev/null 2>&1 || docker network create ros)
(docker volume inspect x11socket >/dev/null 2>&1 || docker volume create x11socket)

# 3) Inicia o noVNC
sudo docker run -d --rm \
    --net=ros \
    --env="DISPLAY_WIDTH=3000" \
    --env="DISPLAY_HEIGHT=1800" \
    --env="RUN_XTERM=no" \
    --name=novnc \
    -p=8080:8080 \
    theasp/novnc:latest

# 4) Inicia o container
sudo docker run -d --rm \
    --net=ros \
    --env="DISPLAY=novnc:0.0" \
    --env="ROS_MASTER_URI=http://localhost:11311" \
    --name=embedded-mas-example \
    -p 9090:9090 \
    maiquelb/embedded-mas-ros:latest

# 5) Aguarda o ROS master do container ficar disponível
until sudo docker exec embedded-mas-example \
    /bin/bash -c "source /opt/ros/noetic/setup.bash && rosnode list" \
    >/dev/null 2>&1
do
    sleep 1
done

# 6) Inicia o Gazebo/TurtleBot3
sudo docker exec -d embedded-mas-example \
    /bin/bash -c "source /opt/ros/noetic/setup.bash && \
    export TURTLEBOT3_MODEL=burger && \
    roslaunch turtlebot3_gazebo turtlebot3_world.launch"

# 7) Aguarda o TurtleBot3/Gazebo inicializar
sleep 5

# 8) Inicia o serviço /move_robot
sudo docker exec -d embedded-mas-example \
    /bin/bash -c "source /opt/ros/noetic/setup.bash && \
    source /catkin_wsp/devel/setup.bash && \
    rosrun embedded_mas_examples move_robot.py"

echo -e "\e[1;33m**** Docker container is ready. Open http://localhost:8080/vnc.html ****\e[0m"
