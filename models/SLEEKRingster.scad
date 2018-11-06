detail = 30; // decrease to speed up rendering

//parameters to make nice side-aligned ringster
//chip_x = 22;
//chip_y = 33;
//chip_z = 2;
//top_plate_front_curvature = 1;
//top_plate_back_curvature = 0;
//ring_front_curvature = 15;
//ring_back_curvature = 0;
//ring_width = 6;
//ring_height = chip_x;
//ring_position = 8; //chip_x = 22, width = 6: min = 8, max = 33
//ring_curvature = chip_x / 2;
//finger_diameter = 20;

chip_x = 22;
chip_y = 33;
chip_z = 2;
top_plate_front_curvature = 1;
top_plate_back_curvature = 0;
ring_front_curvature = 15;
ring_back_curvature = 0;
ring_width = 6;
ring_height = chip_x;
ring_position = 8; //chip_x = 22, width = 6: min = 8, max = 33
ring_curvature = chip_x / 2;
finger_diameter = 20;


ringster();


module ringster()
{
    
    rotate([180, 0, 0]) //rotate upside down for printing
    translate([0, 0, - chip_z / 2]) //place on floor
    union()
    {
        top_plate();
        ring();
    }
}


module ring()
{
    difference()
    {
        ring_element();     //base block
        ring_cutout();      //minus the ring base
        ring_hole_cutout(); //minus the finger hole
        ring_incision();    //minus dent in ring
    }
}

//thin disk just inside the ring hole
module ring_incision()
{
    rotate([90,0,0])
    translate([0, - chip_x / 2 - chip_z / 2, ring_position - ring_width / 2 - 18])
    difference()
    {
        cylinder(1, finger_diameter / 2 + 0.5, finger_diameter / 2 + 0.5, false, $fn=detail);
    }
}

//long cylinder piercing the base block
module ring_hole_cutout()
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
module ring_element()
{
    translate([0, 0, - chip_z / 2 - ring_height / 2])
    rotate([0,0,90])
    both_sided_spade(chip_y, chip_x, ring_height, ring_curvature); //why use spade? Just cube would work
}

//cut out the space in front of and behind what will become the ring
module ring_cutout()
{
    //front
    rotate([0,180,0])
    translate([
        0,
        -ring_position - 5, // - 5 for a bit of extra margin
        chip_z / 2 + chip_x / 2
        ])
    both_sided_spade(
        ring_height + 1, 
        chip_y + 10, // translated - 5, so y is * -2
        ring_height + 1,
        ring_front_curvature
    );
    
    //back
    rotate([0,180,0])
    translate([
        0,
        -ring_position + 35 + ring_width + 5, // + 5 for extra margin in case ring shifted too much
        chip_z / 2 + chip_x / 2
        ])
    both_sided_spade(
        ring_height + 1, 
        chip_y + 10, // translated + 5, so y is * 2
        ring_height + 1, 
        ring_back_curvature
        );
}

//Mount the microcontroller atop this
module top_plate()
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
                translate([0, y - min(rounding, z), min(rounding, z)])
                cube([x, min(rounding, z), z - min(rounding, z)], false);
            }
        }
    }
}