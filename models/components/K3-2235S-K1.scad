//https://datasheet.lcsc.com/szlcsc/Korean-Hroparts-Elec-K3-2235S-K1_C145845.pdf

switch_base_x = 3.5;
switch_base_y = 9.1;
switch_base_z = 3.5;

switch_toggle_x = 1.5;
switch_toggle_y = 1.5;
switch_toggle_z = 2;
switch_toggle_travel = 2;

switch_pin_x = 6.9;
switch_pin_y = 0.6;
switch_pin_z = 0.3;
switch_pin_spacing = 2.5;
switch_pin_offset = (switch_base_y - 3 * switch_pin_y) / 4;

//switch();


module switch(x, y, z, centering) {
    translate([x, y, z]) {
        if(centering) {
            total_x = switch_pin_x;
            total_y = switch_base_y;
            total_z = switch_base_z + switch_toggle_z + switch_pin_z;
            translate([ -total_x / 2, -total_y / 2, -total_z / 2])
            switch_component();
        } else {
            switch_component();
        }
    }
}



module switch_component() {
    union() {
        //base
        translate([switch_pin_x / 2 - switch_base_x / 2, 0, switch_pin_z])
        cube([switch_base_x, switch_base_y, switch_base_z]);
        //pins
        translate([0, 0 * switch_pin_spacing + switch_pin_offset, 0])
        cube([switch_pin_x, switch_pin_y, switch_pin_z]);
        translate([0, 1 * switch_pin_spacing + switch_pin_offset, 0])
        cube([switch_pin_x, switch_pin_y, switch_pin_z]);
        translate([0, 2 * switch_pin_spacing + switch_pin_offset, 0])
        cube([switch_pin_x, switch_pin_y, switch_pin_z]);
        //toggle
        translate([(switch_pin_x - switch_toggle_x) / 2, (switch_base_y - (switch_toggle_y + switch_toggle_travel)) / 2, switch_pin_z + switch_base_z])
        cube([switch_toggle_x, switch_toggle_y + switch_toggle_travel, switch_toggle_z]);
    }
}