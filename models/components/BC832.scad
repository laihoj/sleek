//https://www.mouser.com/datasheet/2/915/BlueNor_BC832_datasheets-1360471.pdf
BC832_x = 7.8;
BC832_y = 8.8;
BC832_z = 1.5;

//BC832(0,0,0);

module BC832(x, y, z, centering) {
    translate([x, y, z])
    cube([BC832_x,BC832_y,BC832_z], centering);
}
