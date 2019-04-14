#!/bin/sh

detail=120
declare -a components=("TESTING" "INNER_SHELL" "OUTER_SHELL" "TOP_COVER" "BOTTOM_COVER" "DIAGNOSTICS")

for MODE in 1 2 3 4 5
do
	component="${components[$MODE]}"
for finger_circumference in 45 48 51 54 57 60 63
#for finger_circumference in 45
do
for segment_angle in 60
do

finger_radius=0
segment_height=0
Cavity_manual=0
ring_height_manual=0
d=0.3
pcb_x=12
pcb_y=12
pcb_z=0.6
DATE=`date +%Y_%m_%d`


file_name="SLEEK_RING_SEGMENT_CIRC_"$finger_circumference"_SEG_"$segment_angle
renders_path="../renders/production/SLEEK_RING_SEGMENT/"$file_name"/"
if [ ! -d "$renders_path" ]; then
mkdir $renders_path
fi

if (($MODE == 5)); then
file_type=".echo"
else
file_type=".stl"
fi

component_name=$component"_"$DATE"_"$file_type


openscad -o $renders_path$component_name -D 'detail='$detail -D 'finger_circumference='$finger_circumference -D 'finger_radius='$finger_radius -D 'segment_height='$segment_height -D 'segment_angle='$segment_angle -D 'Cavity_manual='$Cavity_manual -D 'ring_height_manual='$ring_height_manual -D 'd='$d -D 'pcb_x='$pcb_x -D 'pcb_y='$pcb_y -D 'pcb_z='$pcb_z -D 'MODE='$MODE -D 'COMPONENT='$component ../SLEEK_RING_SEGMENT.scad

if (($MODE == 5)); then
mv $renders_path$component_name $renders_path$component"_"$DATE"_.txt"
fi

done
done
done