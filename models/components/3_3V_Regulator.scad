//https://datasheet.lcsc.com/szlcsc/Texas-Instruments-TI-TPS76933DBVR-PB-FREE_C7101.pdf
reg_x = 1.6;
reg_y = 2.9;
reg_z = 1.45;

reg_pin_x = 2.8;
reg_pin_y = 0.4;
reg_pin_z = 0.1;
reg_pin_spacing = 0.8;
reg_pin_offset = (reg_y - 3 * reg_pin_y) / 4;

//3_3V_Regulator();

module 3_3V_Regulator(x, y, z, centering) {
    translate([x, y, z]) {
        if(centering) {
        total_x = reg_pin_x;
        total_y = reg_y;
        total_z = reg_z + reg_pin_z;
        translate([-total_x/2, -total_y/2, -total_z/2])
        3_3V_Regulator_Component();
        } else {
            3_3V_Regulator_Component();
        }
    }
}

module 3_3V_Regulator_Component() {
    union() {
        //base
        translate([reg_pin_x / 2 - reg_x / 2, 0, reg_pin_z])
        cube([reg_x, reg_y, reg_z]);
        //pins
        translate([0, 0 * reg_pin_spacing + reg_pin_offset, 0])
        cube([reg_pin_x, reg_pin_y, reg_pin_z]);
        translate([0, 1 * reg_pin_spacing + reg_pin_offset, 0])
        cube([reg_pin_x, reg_pin_y, reg_pin_z]);
        translate([0, 2 * reg_pin_spacing + reg_pin_offset, 0])
        cube([reg_pin_x, reg_pin_y, reg_pin_z]);
    }
}