include <components/BC832.scad>
include <components/K3-2235S-K1.scad>
include <components/microUSB.scad>
include <components/mpu9250.scad>
include <components/3_3V_Regulator.scad>
include <components/TP4056.scad>
include <components/female_header.scad>
include <components/SMD_Components.scad>
//include <components/ADP150.scad>
//include <components/DST1610A.scad>

detail = 30; // decrease to speed up rendering

PCB_x = 14.8;
PCB_y = 29.5;
PCB_z = 0.6;

//mpu9250();
//BC832();
//switch();

//microUSB();
//shelf();

difference() {
    union() {
        PCB();
        translate([0,0,PCB_z]) {
            translate([PCB_x / 2 - microUSB_x / 2, 0, 0])
            microUSB();
            translate([PCB_x / 2 - TP4056_x / 2, 8, 0])
            TP4056();
            translate([PCB_x - BC832_x, PCB_y - BC832_y - 3, 0])
            BC832();
            translate([10, 13, 0])
            mpu9250();
        }
    }
    female_header_2();
    translate([PCB_x - hole_spacing * 4, PCB_y, 0])
    rotate([0, 0, 270])
    female_header_4();
}



module PCB(centering) {
    cube([PCB_x, PCB_y, PCB_z], centering);
}

module header() {
    cylinder(h = 100, r = 0.45, center = true, $fn=100);
}