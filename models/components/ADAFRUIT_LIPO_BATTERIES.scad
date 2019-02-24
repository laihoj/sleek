battery_100mAh_toy_copter_x = 20;
battery_100mAh_toy_copter_y = 15;
battery_100mAh_toy_copter_z = 7.5;

battery_100mAh_x = 11.5;
battery_100mAh_y = 31;
battery_100mAh_z = 3.8;

battery_150mAh_x = 19.75;
battery_150mAh_y = 26.02;
battery_150mAh_z = 3.8;

//battery_150mAh(0,0,0);
//battery_100mAh_toy_copter();



module battery_150mAh(x, y, z, centering) {
    if(centering) {
        translate([-battery_150mAh_x / 2, -battery_150mAh_y / 2, -battery_150mAh_z / 2])
        translate([x, y, z])
        battery_150mAh_component();
    } else {
        translate([x, y, z])
        battery_150mAh_component();
    }
}

module battery_150mAh_component() {
    cube([battery_150mAh_x, battery_150mAh_y, battery_150mAh_z]);
    translate([battery_150mAh_x / 2 - 1, -1, battery_150mAh_z / 2])
        cube([1,1,1]);
    translate([battery_150mAh_x / 2 + 1, -1, battery_150mAh_z / 2])
        cube([1,1,1]);
}


module battery_100mAh(x, y, z, centering) {
    if(centering) {
        translate([-battery_100mAh_x / 2, -battery_100mAh_y / 2, -battery_100mAh_z / 2])
        translate([x, y, z])
        battery_100mAh_component();
    } else {
        translate([x, y, z])
        battery_100mAh_component();
    }
}

module battery_100mAh_component() {
    cube([battery_100mAh_x, battery_100mAh_y, battery_100mAh_z]);
    translate([battery_100mAh_x / 2 - 1, -1, battery_100mAh_z / 2])
        cube([1,1,1]);
    translate([battery_100mAh_x / 2 + 1, -1, battery_100mAh_z / 2])
        cube([1,1,1]);
}

module battery_100mAh_toy_copter(x, y, z, centering) {
    if(centering) {
        translate([-battery_100mAh_toy_copter_x / 2, -battery_100mAh_toy_copter_y / 2, -battery_100mAh_toy_copter_z / 2])
        translate([x, y, z])
        battery_100mAh_toy_copter_component();
    } else {
        translate([x, y, z])
        battery_100mAh_toy_copter_component();
    }
}

module battery_100mAh_toy_copter_component() {
    cube([battery_100mAh_toy_copter_x, battery_100mAh_toy_copter_y, battery_100mAh_toy_copter_z]);
    translate([battery_100mAh_toy_copter_x / 2 - 1, -1, battery_100mAh_toy_copter_z / 2])
        cube([1,1,1]);
    translate([battery_100mAh_toy_copter_x / 2 + 1, -1, battery_100mAh_toy_copter_z / 2])
        cube([1,1,1]);
}