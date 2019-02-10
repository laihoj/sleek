//https://datasheet.lcsc.com/szlcsc/Microchip-Tech-MCP73831-2ACI-MC_C150772.pdf

MCP73831_x = 2;
MCP73831_y = 3;
MCP73831_z = 0.9;

module MCP73831(x, y, z, centering) {
    translate([x, y, z])
    cube([MCP73831_x, MCP73831_y, MCP73831_z], centering);
}