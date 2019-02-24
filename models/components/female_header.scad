hole_diameter = 0.88;
hole_spacing = 2.5;
//female_header_4(1,1,1);


module female_header_1(x, y, z, centering) {
    translate([x, y, z]) {
        translate([1.27,1.27,0])
        cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
    }
}


module female_header_2(x, y, z, centering) {
    translate([x, y, z]) {
        translate([1.27,1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 1 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
    }
}


module female_header_3(x, y, z, centering) {
    translate([x, y, z]) {
        translate([1.27,1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 1 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 2 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
    }
}


module female_header_4(x, y, z, centering) {
    translate([x, y, z]) {
        translate([1.27,1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 1 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 2 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 3 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
    }
}

module female_header_7(x, y, z, centering) {
    translate([x, y, z]) {
        translate([1.27,1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 1 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 2 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 3 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 4 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 5 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
        translate([1.27, 6 * hole_spacing + 1.27,0])
            cylinder(h = 10, r = hole_diameter / 2, center = true, $fn=10);
    }
}