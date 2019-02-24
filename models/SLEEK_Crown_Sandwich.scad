include <SLEEK_BT_Module.scad>;
include <SLEEK_Power_Module.scad>;
include <components/ADAFRUIT_LIPO_BATTERIES.scad>;

SLEEK_Crown_Sandwich_x = battery_100mAh_toy_copter_x;
SLEEK_Crown_Sandwich_y = SLEEK_BT_Module_y;
SLEEK_Crown_Sandwich_z = SLEEK_BT_Module_z + BC832_z + battery_100mAh_toy_copter_z + switch_base_z + switch_toggle_z + switch_pin_z;

//SLEEK_Crown_Sandwich(1, 1, 1, true);



module SLEEK_Crown_Sandwich(x, y, z, centering) {
//    translate([-SLEEK_Crown_Sandwich_x / 2, -SLEEK_Crown_Sandwich_y / 2, - SLEEK_Crown_Sandwich_z / 2])
    translate([0,0, SLEEK_BT_Module_z + BC832_z])
    translate([x, y, z]){
    rotate([180,0,0])SLEEK_BT_Module(0, -SLEEK_BT_Module_y);
    battery_100mAh_toy_copter();
    SLEEK_Power_Module(0,0,battery_100mAh_toy_copter_z );   
    }
}