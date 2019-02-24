//include <SLEEK_Crown_Sandwich.scad>;
ROUNDING = true;
detail = 120; // decrease to speed up rendering

/*

chip_x = 22;
chip_y = 33;
chip_z = 2;
top_plate_front_curvature = 1;
top_plate_back_curvature = 0;
ring_front_curvature = 15;
ring_back_curvature = 0;
ring_width = 6;
ring_height = chip_x;
ring_position = 8;
ring_curvature = chip_x / 2;
finger_diameter = 18;
*/
//rotate([270,0,270])
//translate([20 - 55, -chip_y/2, 45 - 10])

//translate([10,0,0])
//ringster(20,18,2,1,0,15,0,6,22,8,11,18);
/*
ringster(
    20, //chip_x
    22, //chip_y
    2,  //chip_z
    2,  //top_plate_front_curvature
    0,  //top_plate_back_curvature
    13, //ring_front_curvature
    13, //ring_back_curvature
    -8, //ring_width
    22, //ring_height
    12, //ring_position
    11, //ring_curvature
    18  //finger_diameter
);
*/
chip_x = 20;
chip_y = 10;
chip_z = 3;
ring_height = 20;
ring_width = 3;
ring_curvature = 10;
ring_position = 0;
ring_front_curvature = 0;
ring_back_curvature = 0;
finger_diameter = 18;
top_plate_front_curvature = 0;
top_plate_back_curvature = 0;
bottom_separation = 4;


//ring_cutout(chip_x, chip_y, chip_z, ring_position, ring_height, ring_width,         ring_front_curvature, ring_back_curvature);

ringster(chip_x, chip_y, chip_z, top_plate_front_curvature, top_plate_back_curvature, ring_front_curvature, ring_back_curvature, ring_width, ring_height, ring_position, ring_curvature, finger_diameter, bottom_separation);



//        ring_element(chip_x, chip_y, chip_z, ring_height, ring_curvature);


//ring(chip_x, chip_y, chip_z, ring_height, ring_width, ring_curvature, ring_position, ring_front_curvature, ring_back_curvature, finger_diameter) ;

//ring(20, 18, -5, 20, 7, 10, 3.5, 5, 5, 18);
//ring_element(20, 22, 2, 22, 11);
//ring_cutout(16, 25, 0, 12, 20, 3, 13, 8);

//ring_cutout(chip_x, chip_y, chip_z, ring_position, ring_height, ring_width,  ring_front_curvature, ring_back_curvature)
//module ring(chip_x, chip_y, chip_z, ring_height, ring_width, ring_curvature, ring_position, ring_front_curvature, ring_back_curvature, finger_diameter) 




module ringster(chip_x, chip_y, chip_z, top_plate_front_curvature, top_plate_back_curvature, ring_front_curvature, ring_back_curvature, ring_width, ring_height, ring_position, ring_curvature, finger_diameter, bottom_separation)
{
    difference() {
        translate([0, 0, - chip_z / 2]) //place on floor
            union()
            {
                top_plate(chip_x, chip_y, chip_z, top_plate_back_curvature, top_plate_front_curvature);
                ring(chip_x, chip_y, chip_z, ring_height, ring_width, ring_curvature, ring_position, ring_front_curvature, ring_back_curvature, finger_diameter);
            }
            bottom_separator(chip_z, ring_height, ring_width, bottom_separation);
    }
}

module bottom_separator(chip_z, ring_height, ring_width, bottom_separation) {
    translate([0,0, - chip_z -  ring_height])
        cube([bottom_separation,ring_width + 1,ring_height], true);
}

module ring(chip_x, chip_y, chip_z, ring_height, ring_width, ring_curvature, ring_position, ring_front_curvature, ring_back_curvature, finger_diameter) 
{
    difference()
    {
        ring_element(chip_x, chip_y, chip_z, ring_height, ring_curvature);
        ring_cutout(chip_x, chip_y, chip_z, ring_position, ring_height, ring_width,         ring_front_curvature, ring_back_curvature);
        ring_hole_cutout(chip_y, chip_z, ring_height, finger_diameter);
    }
}

//thin disk just inside the ring hole
module ring_incision(chip_x, chip_z, ring_position, ring_width, finger_diameter)
{
    rotate([90,0,0])
    translate([0, - chip_x / 2 - chip_z / 2, ring_position - ring_width / 2 - 18])
    difference()
    {
        cylinder(1, finger_diameter / 2 + 0.5, finger_diameter / 2 + 0.5, false, $fn=detail);
    }
}

//long cylinder piercing the base block
module ring_hole_cutout(chip_y, chip_z, ring_height, finger_diameter)
{
    rotate([90,0,0])
    translate([
        0, 
        - chip_z / 2 - ring_height / 2,  
        - chip_y / 2 - 1
    ])
    cylinder(chip_y + 2, finger_diameter / 2, finger_diameter / 2, false, $fn=detail);
}

//base block chunk to be carved
module ring_element(chip_x, chip_y, chip_z, ring_height, ring_curvature)
{
    translate([0, 0, - chip_z / 2 - ring_height / 2])
    rotate([0,0,90])
    both_sided_spade(chip_y, chip_x, ring_height, ring_curvature); //why use spade? Just cube would work
}

//cut out the space in front of and behind what will become the ring
module ring_cutout(chip_x, chip_y, chip_z, ring_position, ring_height, ring_width,  ring_front_curvature, ring_back_curvature)
{
    //front
    translate([0,-chip_y,0])
    union() {
    rotate([0,180,0])
    translate([
        0,
        -chip_y -ring_position , // - 5 for a bit of extra margin
        ring_height / 2 + chip_z / 2
        ])
    both_sided_spade(
        chip_x + 1, 
        chip_y + 10, // translated - 5, so y is * -2
        ring_height + 1,
        ring_front_curvature
    );
    
    //back
    rotate([0,180,0])
    translate([
        0,
        -chip_y / 2 -ring_position + chip_y + ring_width + 5, // + 5 for extra margin in case ring shifted too much
        ring_height / 2 + chip_z / 2
        ])
    both_sided_spade(
        chip_x + 1, 
        chip_y + 10, // translated + 5, so y is * 2
        ring_height + 1, 
        ring_back_curvature
        );
    }
}

//Mount the microcontroller atop this
module top_plate(chip_x, chip_y, chip_z, top_plate_back_curvature, top_plate_front_curvature)
{
    intersection()
    {
        spade(chip_x, chip_y, chip_z, top_plate_back_curvature);
        rotate([0,0,180])
        spade(chip_x, chip_y, chip_z, top_plate_front_curvature);
    }
}


//A thing that is shaped like U
module both_sided_spade(x, y, z, rounding)
{
    intersection()
    {
        spade(x, y, z, rounding);
        rotate([0,0,180])
        spade(x, y, z, rounding);
    }
}

//make sure rounding is smaller than all x, y, z, or unexpected things may happen
//rounding appears along edge at +y, -z
module spade(x, y, z, rounding)
{
    translate([-x/2, -y/2, -z/2])
    {
        union()
        {
            cube([x, y - min(rounding, z), min(rounding, z)], false);
            translate([0, 0, min(rounding, z)])
            cube([x, y, z - min(rounding, z)], false);
            
            union()
            {
                intersection()
                {
                    cube([x, y, z], false);
                    translate([x / 2, y - rounding, min(rounding, z)])
                    rotate([0,90,0])
                    cylinder(x, rounding, rounding, true, $fn=detail);

                }
                if(!ROUNDING) {
                    translate([x, y - rounding, min(rounding, z)])
                    rotate([0,90,90])
                    cube([z - rounding, x, rounding]);
                }
                translate([0, y - min(rounding, z), min(rounding, z)])
                cube([x, min(rounding, z), z - min(rounding, z)], false);
            }
        }
    }
}