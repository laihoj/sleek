include <components/BC832.scad>
include <components/K3-2235S-K1.scad>
include <components/microUSB.scad>
include <components/mpu9250.scad>
include <components/3_3V_Regulator.scad>
include <components/TP4056.scad>
include <components/female_header.scad>
include <components/SMD_Components.scad>
include <components/ADP150.scad>
include <components/DST1610A.scad>

SLEEK_Module_PCB_x = 18.0;
SLEEK_Module_PCB_y = 15.5;
SLEEK_Module_PCB_z = 0.6;

difference() {
    union() {
        PCB();
        translate([0,0,SLEEK_Module_PCB_z]) {
            BC832(0,3,0);
            mpu9250(9,7,0);
            rotate([0,0,270])
            DST1610A(-15,5,0);
        }
    }
    rotate([0,0,270])
    female_header_7(-hole_spacing, 0, 0);
}





module PCB() {
    cube([SLEEK_Module_PCB_x, SLEEK_Module_PCB_y, SLEEK_Module_PCB_z]);
}