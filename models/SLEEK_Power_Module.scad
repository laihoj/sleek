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
include <components/MCP73831.scad>

SLEEK_Module_PCB_x = 18.0;
SLEEK_Module_PCB_y = 15.5;
SLEEK_Module_PCB_z = 0.6;

difference() {
    union() {
        PCB();
        translate([0,0,SLEEK_Module_PCB_z]) {
            microUSB(18 - microUSB_x,0,0);
            rotate([0,0,270])
                switch(-switch_base_x * 2,0,0);
            rotate([0,0,270])
            3_3V_Regulator(-12,5,0);
            MCP73831(9,10,0);
        }
    }
    rotate([0,0,270])
    female_header_3(-SLEEK_Module_PCB_y, 0, 0);
    rotate([0,0,180])
    female_header_2(-SLEEK_Module_PCB_x, -11, 0);
}




module PCB() {
    cube([SLEEK_Module_PCB_x, SLEEK_Module_PCB_y, SLEEK_Module_PCB_z]);
}