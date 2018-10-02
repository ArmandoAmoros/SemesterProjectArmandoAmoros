# SemesterProjectArmandoAmoros

The presentation is compressed and split because it was too heavy

In the "trajectories" folder
- create_points.m	create n files with m number of points in each, the points are random generated. This files are used to load as a trajectories in the v4rl_mav_ground_control (the file has a default start and end point in 2m altitude.
- create_init.m		create n random point with random orientation. This points are loaded in v4rl_mav_ground_control and used as random spawns from where to start a initialization trajectory.

In the “worlds”  folder
- we have all the worlds used for experimentation, the single feature ones and the 360 ones.

In the “MSF_get_data” folder
- ret_msgs_rep_msf		Loads bag files with ground-truth information and MSF information, it compares them and labels them (you can check the report in the labeling section) .
- ret_msgs_test_rep_msf	Loads IMU and MSF data and apply the initialization test algorithm, giving as a result the classification as convergence or divergence. This is the actual initialization test algorithm
- genMsf.sh	This script automatically play a number of bags and runs MSF on them storing new bags with MSF output information.

In the “ROVIO” folder
- creator.launch	Plays a ROS bag with VI sensor information (images and IMU) to feed a ROVIO node and saves the ROVIO outputs, ground-truth info and IMU info.
- ret_msgs_rep.m	Loads bag files with ground-truth information and ROVIO information, it compares them and labels them (you can check the report in the labeling section) .
- ret_msgs_test_rep.m	Loads IMU and ROVIO data and apply the initialization test algorithm, giving as a result the classification as convergence or divergence. This is the actual initialization test algorithm
- genRovios.sh	This script automatically play a number of bags and runs ROVIO on them storing new bags with ROVIO output information.

In the “FFT” folder
- Transforms.m	loads IMU acceleration and velocity from two bag files, applies fast Fourier transforms and compares them. Usually one bag diverging and one converging are chosen. Used for the first FFT approach.

In the “bagGen” folder
- genBags.sh	with  v4rl_mav_ground_control already running and rqt open, this script takes the UAV to different spawn positions, then load random trajectories previously generated with the other scripts and records a ROS bag with the info. Then loads another trajectory or goes to another respawn position, and records again, until is finished.
For this script it is needed to generate a file like init.csv, with the info of the spawning points, so the trajectories can be offseted accordingly with the spawn origin and orientation.
- script.sh	This script calls the creator.launch file with arguments from console
-init.csv	Example file of respawn information needed for genBags.sh to offset the trajectories according to the spawn.
