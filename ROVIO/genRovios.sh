#!/bin/bash

roslaunch mav_ground_control_backend rovio.launch &

sleep 2

for i in {1..20}; do
	for j in {21..30}; do
		rosbag play /home/armando/catkin_ws/src/bags/rovio/sinRand/bag_"$i"_"$j".bag &

		rosservice call /firefly/rovio/reset
		
		rosbag record /firefly/imu /firefly/ground_truth/transform /firefly/rovio/transform /firefly/rovio/odometry -O /home/armando/catkin_ws/src/bags/rovio/conRand/bag_"$i"_"$j" --duration 15 

		rosservice call /firefly/rovio/reset
		sleep 3
	done
done

