include <components/MCP73831.scad>
include <components/SMD_Components.scad>
include <components/ADP150.scad>

SLEEK_Power_Ring_diameter_outer = 22;
SLEEK_Power_Ring_diameter_inner = 18;
detail = 100;
h = 1.6;
translate([SLEEK_Power_Ring_diameter_outer/2, SLEEK_Power_Ring_diameter_outer/2 , 0])
SLEEK_Power_Ring();
MCP73831(9.2, 20.4, h, true);
PCB_Pad_Square(4, 17, h, true);
_0603(1.6, 13.8, h, true);
ADP150(1.4, 8.5, h, true);
PCB_Pad_Square(3, 5, h, true);
_0603(6.3, 2.3, h, true);
PCB_Pad_Square(11, 1, h, true);
PCB_Pad_Square(14.7, 1.6, h, true);
_0603(18.5, 4.2, h, true);
_0402(21, 8.7, h, true);
_0402(21.2, 12.5, h, true);
_0402(20, 16.2, h, true);
_0402(17.8, 18.8, h, true);
_0402(13, 20.5, h, true);


module SLEEK_Power_Ring(x, y, z) {
    translate([x, y, z])
    SLEEK_Power_Ring_component();
}

module SLEEK_Power_Ring_component() {
    difference() {
        cylinder(h, d = SLEEK_Power_Ring_diameter_outer, $fn = detail);
        translate([0,0,-1])
            cylinder(h + 2, d = SLEEK_Power_Ring_diameter_inner, $fn = detail);
    }
}

module PCB_Pad_Round(x, y, z, centering) {
    translate([x, y, z])
        cylinder(h = 0.1, d = 1.6, $fn = detail, centering);
}

module PCB_Pad_Square(x, y, z, centering) {
    translate([x, y, z])
        cube([1.6, 1.6, 0.1], centering);
}