#!/bin/bash

roscore &

sleep 2

rosparam load /home/armando/catkin_ws/src/mav_control_rw/mav_linear_mpc/resources/msf_parameters_sim.yaml /firefly/pose_sensor/

for i in {1}; do
	for j in {7}; do
	for k in {4}; do
		#rosbag play /home/armando/catkin_ws/src/bags/rovio/sinRand/bag_"$i"_"$j".bag &
		rosrun msf_updates pose_sensor msf_updates/transform_input:=rovio/transform msf_core/imu_state_input:=imu __ns:=firefly __name:=pose_sensor &
		sleep 1

		rosbag play /home/armando/catkin_ws/src/bags/rovio/CompConRep/bag_"$i"_"$j"_"$k".bag &

		rosservice call /firefly/pose_sensor/pose_sensor/initialize_msf_scale "scale: 1.0"
		
		rosbag record /firefly/imu /firefly/msf_core/odometry /firefly/msf_core/pose /firefly/ground_truth/transform -O /home/armando/catkin_ws/src/bags/rovio/CompConRepMsf/bag_"$i"_"$j"_"$k" --duration 17 

		rosnode kill /firefly/pose_sensor
		sleep 4
	done
	done
done
