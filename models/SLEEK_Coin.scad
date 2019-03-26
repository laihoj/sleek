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
include <components/BAT_HLD.scad>
include <components/Coin_Cell_1220.scad>

detail = 100;

SLEEK_Coin_PCB_x = 18.1;
SLEEK_Coin_PCB_y = 13.1;
SLEEK_Coin_PCB_z = 0.6;

translate([0,0,6])
difference() {
    SLEEK_Capsule(6, 0);
    translate([1,1,-0.5])   //extra depth added, just in case
    SLEEK_Coin();
    translate([1,5.5,3])   //extra depth added, just in case
    translate([SLEEK_Coin_PCB_x / 2, SLEEK_Coin_PCB_y / 2, - SLEEK_Coin_PCB_z * 2 - Coin_Cell_1220_height])
    cube([Coin_Cell_1220_diameter, Coin_Cell_1220_diameter, 6], true);
    translate([1,-5.5,3])   //extra depth added, just in case
    translate([SLEEK_Coin_PCB_x / 2, SLEEK_Coin_PCB_y / 2, - SLEEK_Coin_PCB_z * 2 - Coin_Cell_1220_height])
    cube([Coin_Cell_1220_radius, Coin_Cell_1220_diameter, 6], true);
}

translate([0,0,3])
rotate([180,0,0])
translate([0,2,0])
SLEEK_Capsule_Top(3,0);




module SLEEK_Capsule(height, rounding) {
    rounded_box(height,rounding);
}

module SLEEK_Capsule_Top(height, rounding) {
    difference() {
    rotate([0,180,0])
    translate([-20,0,0])
    rounded_box(height,rounding);
    translate([1,1,-1])
    cube([SLEEK_Coin_PCB_x, SLEEK_Coin_PCB_y, 3]);  //FILLING
    translate([7.5,1.5,0])
    cube([2, 2, 10]);   //RGB LED
    }
    
}

module rounded_box(z,rounding) {
    translate([-0.5,1.5,-z]) 
    intersection() {
        union() {
            spade(SLEEK_Coin_PCB_x + 0.5,12.5,z,rounding);
            rotate([0,0,180])
            translate([-SLEEK_Coin_PCB_x-3,-12,0])
            spade(SLEEK_Coin_PCB_x + 0.5,12.5,z,rounding);
        }
        union() {
            rotate([0,0,90])
            translate([-2,-14,0])
            spade(13.5,12.5,z,rounding);
            rotate([0,0,270])
            translate([-14,7,0])
            spade(13.5,12.5,z,rounding);
        }
    }
}

module SLEEK_Coin(x, y, z, centering) {
    translate([x, y, z])
    SLEEK_Coin_components();
}

module SLEEK_Coin_components() {
    difference() {
        union() {
            PCB();
            translate([0,0,SLEEK_Coin_PCB_z]) {
                translate([0,0,-0.1])
                BC832(2.5,4,0);
                translate([0,0,-0.1])
                mpu9250(12,7,0);
                translate([6.5,1,0])
                translate([0,0,-0.1])
                cube([1.6,1.6,0.5]);  //RGB LED
                translate([0,0,0.1])
                BAT_HLD(2,1.5,-SLEEK_Coin_PCB_z*2 - BAT_HLD_z);
                translate([0,0,0.1])
                Coin_Cell_1220(SLEEK_Coin_PCB_x / 2, SLEEK_Coin_PCB_y / 2, - SLEEK_Coin_PCB_z * 2 - Coin_Cell_1220_height);
                
            }
        }
        /*
        translate([2.5,5.5,0])
        female_header_3(-hole_spacing, 0, 0);
        translate([18,10.5,0])
        female_header_1(-hole_spacing, 0, 0);
        */
    }
}


module PCB() {
    cube([SLEEK_Coin_PCB_x, SLEEK_Coin_PCB_y, SLEEK_Coin_PCB_z]);
    translate([0,0,-SLEEK_Coin_PCB_z])
    cube([SLEEK_Coin_PCB_x, SLEEK_Coin_PCB_y, SLEEK_Coin_PCB_z]);
}

module spade(x, y, z, rounding) {
    diameter = min(y, z, rounding);
    //translate([- x / 2 - 1, 0, 0]) {
    translate([ 0 , 1, 0]) {
        translate([0,-1,0])
        cube([x + 2, y + 1 - diameter / 2, z]);
        translate([0,0,diameter / 2])
        cube([x + 2, y, z - diameter / 2]);
        translate([0, y - diameter / 2, diameter / 2])rotate([0,90,0])cylinder(x + 2, diameter / 2, diameter / 2, false, $fn=detail);
    }
}