//https://datasheet.lcsc.com/szlcsc/Analog-Devices-ADI-ADP150ACBZ-3-3-R7_C136038.pdf

ADP150_x = 0.76;
ADP150_y = 0.76;
ADP150_z = 0.4;

//ADP150();
module ADP150(x, y, z, centering) {
    translate([x, y, z])
    cube([ADP150_x, ADP150_y, ADP150_z], centering);
}
