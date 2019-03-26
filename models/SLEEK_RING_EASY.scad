//SLEEK RING EASY
detail = 120;


//sleek_ring_easy(finger_diameter, ring_thickness, lid_thickness, top_x, top_z)
//sleek_ring_easy(18, 1, 1, 20, 15);
sleek_ring_easy(18, 1, 1, 20, 15);

module triangle(x, y, height) {
    a = max(x, y, height);
    resize([x, y, height])
    difference() {
        cube([a,a,a]);
        rotate([45,0,0])
        translate([-1,0,0])
        cube([a +2, a * a, a]);
    }
}

module triangle_with_finger_cut(effective_x, top_z, finger_diameter) {
    difference() {
        triangle(effective_x, effective_x, top_z);
        translate([effective_x / 2, effective_x / 2, -1])
        cylinder(h=top_z + 2, d=finger_diameter, $fn=detail);
    }
}

module ring(effective_x, top_z, finger_diameter, effective_ring_thickness) {
    translate([effective_x / 2, effective_x / 2, -1])
    cylinder(h=top_z + 2, d=finger_diameter + effective_ring_thickness * 2, $fn=detail);
}

module triangle_ring(effective_x, top_z, finger_diameter, effective_ring_thickness) {
    intersection() {
        triangle_with_finger_cut(effective_x, top_z, finger_diameter);
        ring(effective_x, top_z, finger_diameter, effective_ring_thickness);
    }
}

module triangle_ring_lidless(finger_diameter, effective_ring_thickness, effective_x, top_z) {
    union() {
        triangle_ring(effective_x, top_z, finger_diameter, effective_ring_thickness);
        intersection() {

            triangle_with_finger_cut(            effective_x, top_z, finger_diameter);
            translate([0, effective_x / 2, 0])
            cube([effective_x, effective_x / 2, top_z]);
        }
    }
}

module lid(top_x, top_z, effective_x, lid_thickness) {
    translate([(effective_x - top_x) / 2, effective_x - 0.0, 0])
    cube([top_x, lid_thickness, top_z]); 
}

module sleek_ring_easy(finger_diameter, ring_thickness, lid_thickness, top_x, top_z) {
    effective_ring_thickness = max(ring_thickness, top_x - (finger_diameter + ring_thickness));
    effective_x = max(top_x, finger_diameter + 2 * effective_ring_thickness);
    union() {
        triangle_ring_lidless(finger_diameter, effective_ring_thickness, effective_x, top_z);
        lid(top_x, top_z, effective_x, lid_thickness);
    }
}