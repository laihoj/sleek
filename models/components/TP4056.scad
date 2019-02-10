//https://datasheet.lcsc.com/szlcsc/Nanjing-Extension-Microelectronics-TP4056_C16581.pdf

TP4056_x = 3.9;
TP4056_y = 4.9;
TP4056_z = 1.55;

TP4056_pin_x = 6;
TP4056_pin_y = 0.4;
TP4056_pin_z = 0.2;
TP4056_pin_spacing = 1.27;
TP4056_pin_offset = 0.4;

//TP4056(1,2);




module TP4056(x, y, z, centering) {
    translate([x, y, z]) {
        if(centering) {
            total_x = TP4056_x;
            total_y = TP4056_y;
            total_z = TP4056_z;
            translate([ -total_x / 2, -total_y / 2, -total_z / 2])
            TP4056_component();
        } else {
            TP4056_component();
        }
    }
}


module TP4056_component() {
    union() {
        //pins
        translate([0, 0 * TP4056_pin_spacing + TP4056_pin_offset, 0])
        cube([TP4056_pin_x, TP4056_pin_y, TP4056_pin_z]);
        translate([0, 1 * TP4056_pin_spacing + TP4056_pin_offset, 0])
        cube([TP4056_pin_x, TP4056_pin_y, TP4056_pin_z]);
        translate([0, 2 * TP4056_pin_spacing + TP4056_pin_offset, 0])
        cube([TP4056_pin_x, TP4056_pin_y, TP4056_pin_z]);
        translate([0, 3 * TP4056_pin_spacing + TP4056_pin_offset, 0])
        cube([TP4056_pin_x, TP4056_pin_y, TP4056_pin_z]);
        //base
        translate([(TP4056_pin_x - TP4056_x) / 2, 0, 0])
        cube([TP4056_x, TP4056_y, TP4056_z]);
    }
}