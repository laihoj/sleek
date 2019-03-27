include <components/BAT_HLD.scad>;
detail = 120;

pcb_x = 13;
pcb_y = 18;
pcb_z = 0.6;
finger_circumference = 52; // circumference of 60mm = 19.1mm diameter = jaakko middle finger
ring_height = 8;

rotate([90, 0, 0])
ring_actually(pcb_x, pcb_y, pcb_z, finger_circumference, ring_height);

//PCBs(pcb_x, pcb_y, pcb_z, finger_circumference);

//if not insisting on a particular thickness of the ring, leave last parameter out
module ring_actually(x, y, z, c, h, thickness_insisted) {
    d = c / 3.14;
    r = d / 2;
    alpha = 2 * atan(d / x);
    effective_center = max(x, y) + z;
    ring_thickness = sqrt(1/4 * x * x + r * r) - r + z * sin(alpha);
    
    difference() {
        rotate([270, 0, 0])
        cylinder(h=h, d=d + ring_thickness * 2, $fn=detail);
        rotate([270, 0, 0])
        translate([0,0, -1])
        cylinder(h=h + 2, d=d, $fn=detail);
    
        translate([-0.2, 2, -0.2]) {
            translate([- x /2 - 2, 0, - d / 2 - z - 10])
            cube([x + 4, y, z + 10]);
            translate([- x /2, 0, - d / 2])
            rotate([0, 360 - alpha, 0])
            cube([x + 4, y, z + 10]);
        }
    }

}
/*
difference() {
    rotate([270, 0, 0])
    cylinder(h=h, d=d + ring_thickness * 2, $fn=detail);
    rotate([270, 0, 0])
    translate([0,0, -1])
    cylinder(h=h + 2, d=d, $fn=detail);
    
    translate([-0.1, 2, -0.1]) {
        translate([- x /2 - 2, 0, - d / 2 - z - 10])
        cube([x + 4, y, z + 10]);
        translate([- x /2, 0, - d / 2])
        rotate([0, 360 - alpha, 0])
        cube([x + 4, y, z + 10]);
    }
}
*/

module PCBs(x, y, z, c) {
    d = c / 3.14;
    alpha = 2 * atan(d / x);
    translate([-0.1, 2, -0.1]) {
        translate([- x /2, 0, - d / 2 - z])
        cube([x, y, z]);
        translate([- x /2, 0, - d / 2])
        rotate([0, 360 - alpha, 0])
        cube([x, y, z]);
    }
}
