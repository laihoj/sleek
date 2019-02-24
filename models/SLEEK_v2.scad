include <SLEEK_Crown_Sandwich.scad>;

detail = 120;

plate_x = 22;
plate_y = 1;
plate_z = 20;
ring_height = 15;
ring_diameter = plate_z + + 2;
ring_position = 0;
finger_diameter = 20;
top_plate_front_curvature = ring_diameter;
top_plate_back_curvature = ring_diameter;
bottom_separation = 2;
crown_height = SLEEK_Crown_Sandwich_y;
crown_thickness = 1;

 for (i =[0:5])translate([(plate_x + 1) * i, 0 ,0])
ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter - i, ring_height - i, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);

/*
ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter, ring_height, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);

translate([(plate_x + 1) * 1, 0 ,0])
ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter - 1, ring_height - 1, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);

translate([(plate_x + 1) * 2, 0 ,0])
ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter - 2, ring_height - 2, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);

translate([(plate_x + 1) * 3, 0 ,0])
ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter - 3, ring_height - 3, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);

translate([(plate_x + 1) * 4, 0 ,0])
ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter - 4, ring_height - 4, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);

*/




//HW();


module crown() {
    difference() {
        translate([0, ring_diameter + plate_y, 0]) {
            //right wall
            translate([-plate_x / 2, 0, 0])
            cube([crown_thickness, crown_height, plate_z]);
            //left wall
            translate([plate_x / 2 - crown_thickness, 0, 0])
            cube([crown_thickness, crown_height, plate_z]);
            //back wall
            translate([-plate_x / 2, 0, 0])
            cube([plate_x, crown_height, crown_thickness]);
            //front wall
            /* commented out for manufacturing related reasons. Can't print a ridge
            difference() {
                //cover
                translate([-plate_x / 2, 0, plate_z - 1])
                cube([plate_x, crown_height, crown_thickness]);
                //exposed USB
                translate([0, crown_height - SLEEK_Power_Module_z, plate_z - 2])
                cube([plate_x, crown_height, crown_thickness + 3]);
            }
            */
            
            //lid
            translate([-plate_x/2, crown_height - crown_thickness, 0])
            cube([plate_x, crown_thickness, plate_z]);
        }
        HW();
    }
}

module HW() {
    translate([-SLEEK_Crown_Sandwich_x / 2, ring_diameter + plate_y, 2])
    translate([0, 0, SLEEK_Crown_Sandwich_z])
    rotate([270, 0, 0])
    SLEEK_Crown_Sandwich();
}

module ringster(plate_x, plate_y, plate_z, ring_diameter, finger_diameter, ring_height, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation) {
    top_plate(plate_x, plate_y, plate_z);
    ringlet(plate_x, plate_z, ring_diameter, finger_diameter, ring_height, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation);
    
    translate([0, ring_diameter + plate_y + 2, crown_height * 2.5 - crown_thickness])
    rotate([270,0,0])
    crown();
}

module ringlet(plate_x, plate_z, ring_diameter, finger_diameter, ring_height, ring_position, top_plate_front_curvature, top_plate_back_curvature, detail, bottom_separation) {
        difference() {
        size = max(plate_x, ring_diameter);
        start_block(plate_x, ring_diameter, plate_z);
        front_curve_cutout(ring_height,ring_position,size,ring_diameter,top_plate_front_curvature);
        back_curve_cutout(ring_height,ring_position,size,ring_diameter,top_plate_back_curvature);
        finger_hole_cutout(ring_diameter, finger_diameter, plate_z, detail);
        bottom_curve_cutout(ring_diameter, plate_z, detail, size);
        bottom_separator(plate_z, ring_diameter, ring_height, bottom_separation);
    }
}

module start_block(plate_x, ring_diameter, plate_z) {
        //block to be 'carved'
    translate([-(plate_x) / 2, 0, 0])
    cube([plate_x, ring_diameter, plate_z]);
}

module top_plate(plate_x, plate_y, plate_z) {
    translate([-plate_x/2,ring_diameter,0])
    cube([plate_x, plate_y, plate_z]);
}

module finger_hole_cutout(ring_diameter, finger_diameter, plate_z, detail) {
        //finger hole cutout
    translate([0, ring_diameter / 2,-1])
    cylinder(plate_z + 2, finger_diameter / 2, finger_diameter / 2, false, $fn=detail);
}

module front_curve_cutout(ring_height,ring_position,size,ring_diameter,top_plate_front_curvature) {
        //ring front curvature cutout
    translate([0,0, ring_height + ring_position])
    spade(size, ring_diameter, 30, top_plate_front_curvature);
}

module back_curve_cutout(ring_height,ring_position,size,ring_diameter,top_plate_back_curvature) {
    //ring back curvature cutout
    translate([0, 0, ring_position])rotate([0,180,0])
    spade(size, ring_diameter, plate_z, top_plate_back_curvature);
}

module bottom_separator(plate_z, ring_diameter, ring_height, bottom_separation) {
    translate([-bottom_separation / 2,-1,ring_position - 1])
        cube([bottom_separation,ring_height,ring_height + 2]);
}

module bottom_curve_cutout(ring_diameter, plate_z, detail, size) {
    //bottom curvature
    translate([0,ring_diameter / 2,-1])
    difference() {
        cylinder(plate_z + 2, size, size, false, $fn=detail);
        translate([0,0,-1])
        cylinder(plate_z + 4, size / 2, size / 2, false, $fn=detail);
        translate([-ring_diameter, 0, -1])
        cube([ring_diameter * 2, ring_diameter, plate_z + 4]);
    }
}

module spade(x, y, z, rounding) {
    diameter = min(y, z, rounding);
    translate([- x / 2 - 1, 0, 0]) {
        translate([0,-1,0])
        cube([x + 2, y + 1 - diameter / 2, z]);
        translate([0,0,diameter / 2])
        cube([x + 2, y, z - diameter / 2]);
        translate([0, y - diameter / 2, diameter / 2])rotate([0,90,0])cylinder(x + 2, diameter / 2, diameter / 2, false, $fn=detail);
    }
}