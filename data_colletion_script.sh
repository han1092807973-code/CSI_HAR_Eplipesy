#!/bin/bash
sleep 10s



sudo -v

#sudo modprobe -r iwlwifi mac80211
#sudo modprobe iwlwifi connector_log=0x1

for i in {1..10}
do
	echo ">>> Run $i started at $(date)"
	timeout -s KILL 20s sudo ~/linux-80211n-csitool-supplementary/netlink/log_to_file nothing_10_20/csi_nothing_$i.dat
	echo ">>> Run $i finished at $(date)"
	sleep 5s
done
