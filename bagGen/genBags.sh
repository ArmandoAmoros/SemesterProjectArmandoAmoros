#!/bin/bash
k=0
while IFS=, read  y1 y2 y3 y4 y5 y6 y7 y8; do
	k=$(($k+1))

	rosservice call /firefly/spawn_marker_req "spawn_loc:
  position:
    x: $y2
    y: $y3
    z: $y4
  orientation:
    x: $y5
    y: $y6
    z: $y7
    w: $y8
name: '$y1'
before: 0
reference_wp: ''"	

	rosservice call /firefly/start_wp "data: true"
	sleep 10
	rosservice call /firefly/delete_marker_req "str: '$y1'
data: 0"

	for i in {21..30}; do
		xr=''
		while IFS=, read  x1 x2 x3 x4 x5 x6 x7 x8; do
			rosservice call /firefly/spawn_marker_req "spawn_loc:
  position:
    x: $(awk "BEGIN {print $y2+$x2; exit}")
    y: $(awk "BEGIN {print $y3+$x3; exit}")
    z: $x4
  orientation:
    x: $x5
    y: $x6
    z: $y7
    w: $y8
name: '$x1'
before: 0
reference_wp: '$xr'"
			xr=$x1
		done < "/home/armando/Desktop/Calibration_Trajectories/traj_$i.csv"
		
		rosbag record /firefly/vi_sensor/left/image_raw /firefly/vi_sensor/imu /firefly/imu /firefly/ground_truth/transform -O /home/armando/catkin_ws/src/bags/rovio/sinRand/bag_"$k"_"$i" --duration 15 &
		sleep 2
		rosservice call /firefly/start_wp "data: true"
		sleep 14


		for j in {6..0}; do
			rosservice call /firefly/delete_marker_req   "str: 'P$j'
data: 0"
		done

	done

done < "/home/armando/Desktop/Calibration_Trajectories/init2.csv"
