detail = 60;

chip_x = 22;
chip_y = 33;
chip_z = 2;
top_plate_curvature = 2;
ring_front_curvature = 15;
ring_back_curvature = 0;
ring_width = 6;
ring_height = chip_x;
ring_position = 8;
ring_curvature = chip_x / 2;
finger_diameter = 20;


ringster();


module ringster()
{
    
    rotate([180, 0, 0])
    translate([0, 0, - chip_z / 2])
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
        ring_element();
        ring_cutout();
        ring_hole_cutout();
        ring_incision();
    }
}

module ring_incision()
{
    rotate([90,0,0])
    translate([0, - chip_x / 2 - chip_z / 2, ring_position - ring_width / 2 - 18])
    difference()
    {
        cylinder(1, finger_diameter / 2 + 0.5, finger_diameter / 2 + 0.5, false, $fn=detail);
    }
}

module ring_hole_cutout()
{
    rotate([90,0,0])
    translate([0, - chip_z / 2 - ring_height / 2, -chip_x])
    cylinder(chip_y, finger_diameter / 2, finger_diameter / 2, false, $fn=detail);
}

module ring_element()
{
    translate([0, 0, - chip_z / 2 - ring_height / 2])
    rotate([0,0,90])
    both_sided_spade(chip_y, chip_x, ring_height, ring_curvature);
}
//ring_cutout();

module ring_cutout()
{
    //front
    rotate([0,180,0])
    translate([
        0,
        -ring_position,
        chip_z / 2 + chip_x / 2
        ])
    both_sided_spade(ring_height + 1, chip_y, ring_height + 1, ring_front_curvature);
    
    //back
    rotate([0,180,0])
    translate([
        0,
        -ring_position + 35 + ring_width,
        chip_z / 2 + chip_x / 2
        ])
    both_sided_spade(ring_height + 1, chip_y, ring_height + 1, ring_back_curvature);
}


module top_plate()
{
    both_sided_spade(chip_x, chip_y, chip_z, top_plate_curvature);
}


//Spade on both ends
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