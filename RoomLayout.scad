/* OpensScad script for creating a 3D room layout 
 * 
 * Assumptions: one corner of the building is at 0,0
 * 
 * Afan Ottenheimer
 */

wall_width=2;
//thickness of 3d printed floor. 
floor_thickness=0.25;
//height of 3d printed walls, should be > floor_thickness. 
wall_height=1;

round_edges=false;

/* module doorway 
 *
 * assumes all walls are the same width 
 * @param dir string    ew means a doorway aligned east-west
 * @param width float   width of the door
 */
module doorway(center=[0,1], dir="ew", width=2) {
    //make door depth wider than wall width to cleanly substract
    door_depth = wall_width + wall_width * 0.8;
    //openscad variables inside if only defined inside if 
    if ( dir == "ew" ) {
        doorway_poly = [
            [center[0]-width/2,center[1]-door_depth/2-.1],
            [center[0]+width/2,center[1]-door_depth/2-.1],
            [center[0]+width/2,center[1]+door_depth/2-.1],
            [center[0]-width/2,center[1]+door_depth/2-.1]];
        translate([0,0,floor_thickness])
            linear_extrude(wall_height*2)
                polygon(doorway_poly);
    } else {
        doorway_poly = [
            [center[0]-door_depth/2-.1,center[1]-width/2],
            [center[0]+door_depth/2-.1,center[1]-width/2],
            [center[0]+door_depth/2-.1,center[1]+width/2],
            [center[0]-door_depth/2-.1,center[1]+width/2]];
        translate([0,0,floor_thickness])
            linear_extrude(wall_height*2)
                polygon(doorway_poly);
    };
    
};

/* module room 
 * 
 * Takes a polynomial and creates a shape suitable for removing from entire_building. 
 * @param  room_poly    array    polygon array of points
 */
module room(room_poly) {
    translate([0,0,floor_thickness])
        linear_extrude(wall_height*2)
            polygon(room_poly);    
}

/* module room_text
 * puts text in room centered in y axis and starting at x_min + wall_width
 * @param room_poly array   polygon array of the room
 * @param room_text string  the string to write
 */
module room_text(room_poly, room_text="room") {
    x_min = room_poly[0][0];
    y_min = room_poly[0][1];
    y_max = room_poly[2][1];
    
    echo(x_min+wall_width);
    echo((y_max+y_min)/2);
    translate([x_min+wall_width, ((y_max+y_min)/2), floor_thickness+.1])  
        linear_extrude(wall_height/2)
            text(room_text, size = 1);
}

$fn = 32;


module building_outline(poly) {
    
    if ( round_edges == true) {
        y_max=poly[2][1];
        x_max=poly[1][0];

        union(){
        //x base
        rotate([90,0,90])
            rotate_extrude(angle=180)
                square([1,x_max]);
        //x top
        translate([0,y_max,0])
            rotate([90,0,90])
                rotate_extrude(angle=180)
                    square([1,x_max]);
        
        //building walls
        linear_extrude(wall_height)
            polygon(poly);
        }
    } else {
        linear_extrude(wall_height)
            polygon(poly);
    };
}

//Define polygon corners of rooms
entire_building=[[0,0],[40,0],[40,20],[0,20]];
front_room=[[2,2],[18,2],[18,18],[2,18]];
back_room=[[20,2],[38,2],[38,18],[20,18]];
//Define centers of doors (assumed rectangular)
front_door = [1, 6];
mid_door = [19, 6];
side_door = [8,1];

//Union of rooms and text
union(){ 
    //Subtract Rooms from Total area
    difference() {
        building_outline(entire_building);
        room(front_room);
        room(back_room);
        doorway(front_door,"ns");
        doorway(mid_door,"ns");
        doorway(side_door,"ew");
    }
    room_text(front_room, "Welcome");
    room_text(back_room, "Secret Area");
}