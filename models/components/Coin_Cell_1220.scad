//1220 Coin Cell Battery
//http://www.farnell.com/datasheets/1496882.pdf

detail = 20;
Coin_Cell_1220_diameter = 12.5;
Coin_Cell_1220_radius = Coin_Cell_1220_diameter / 2;
Coin_Cell_1220_height = 2;

//Coin_Cell_1220();

module Coin_Cell_1220(x, y, z) {
    translate([x, y, z])
    cylinder(h=Coin_Cell_1220_height, r=Coin_Cell_1220_radius, $fn=detail);
}