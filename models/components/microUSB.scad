//https://datasheet.lcsc.com/szlcsc/Jing-Extension-of-the-Electronic-Co-LCSC-MICRO-USB-5S-B-Type-horns-High-temperature_C10418.pdf
microUSB_x = 8;
microUSB_y = 5.74;
microUSB_z = 3;


//microUSB();

module microUSB(x, y, z, centering) {
    translate([x, y, z])
    cube([microUSB_x, microUSB_y, microUSB_z], centering);
}
