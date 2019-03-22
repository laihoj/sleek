//BAT-HLD-012-SMT-OTL
//https://www.mouser.se/datasheet/2/238/BAT-HLD-012-SMT%20Diagram-1175215.pdf
BAT_HLD_x = 13.5;
BAT_HLD_y = 9.5;
BAT_HLD_z = 3.6;


//BAT_HLD();

module BAT_HLD(x, y, z, centering) {
    translate([x, y, z])
    cube([BAT_HLD_x, BAT_HLD_y, BAT_HLD_z], centering);
}
