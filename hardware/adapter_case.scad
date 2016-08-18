// Serial DMM adapter case
// designed to fit an Arduino nano clone and a DB-9 male plug
//
// Copyright (C) 2016 Theodore C. Yapo

layout = "printing";
//layout = "exploded";


board_width = 18.5;
board_length = 44.5;
board_thickness = 1.85;
usb_lip = 2;
usb_height = 4.25;
usb_width = 8;
usb_length = 9;

module nano_board()
{
  translate([-board_length/2, -board_width/2, 0]){
    color("blue") cube([board_length, board_width, board_thickness]);
  }
  translate([-board_length/2-2.5, -usb_width/2, board_thickness]){
    color([0.85, 0.85, 0.85]) cube([usb_length, usb_width, usb_height]);
  }
}

db9_hole_spacing = 25;
module db9_profile()
{
  corner_r = 3;
  top_w = 19.5;
  bottom_w = 17.5;
  height = 9.5;
  length = 7;
  back_length = 9;
  flange_w = 33.5;
  flange_h = 20;
  flange_r = 1;
  flange_thickness = 1.25;
  fn = 13;
  epsilon = 0.1;

  // pin shroud
  translate([0, 0, -back_clearance]){
    hull(){
      translate([+(-top_w/2 + corner_r), +(-height/2 + corner_r), 0]){
        cylinder($fn = fn, r = corner_r, h = length);
      }
      translate([+(-bottom_w/2 + corner_r), -(-height/2 + corner_r), 0]){
        cylinder($fn = fn, r = corner_r, h = length);
      }
      translate([-(-bottom_w/2 + corner_r), -(-height/2 + corner_r), 0]){
        cylinder($fn = fn, r = corner_r, h = length);
      }
      translate([-(-top_w/2 + corner_r), +(-height/2 + corner_r), 0]){
        cylinder($fn = fn, r = corner_r, h = length);
      }
    }
  }

  // back body
  b_corner_r = 3;
  b_top_w = 22;
  b_bottom_w = 19;
  b_height = 12;
  translate([0, 0, -back_clearance]){
    hull(){
      translate([+(-b_top_w/2 + b_corner_r),
                 +(-b_height/2 + b_corner_r),
                 -back_length-epsilon]){
        cylinder($fn = fn, r = b_corner_r, h = back_length+2*epsilon);
      }
      translate([+(-b_bottom_w/2 + b_corner_r),
                 -(-b_height/2 + b_corner_r),
                 -back_length-epsilon]){
        cylinder($fn = fn, r = b_corner_r, h = back_length+2*epsilon);
      }
      translate([-(-b_bottom_w/2 + b_corner_r),
                 -(-b_height/2 + b_corner_r),
                 -back_length-epsilon]){
        cylinder($fn = fn, r = b_corner_r, h = back_length+2*epsilon);
      }
      translate([-(-b_top_w/2 + b_corner_r),
                 +(-b_height/2 + b_corner_r),
                 -back_length-epsilon]){
        cylinder($fn = fn, r = b_corner_r, h = back_length+2*epsilon);
      }
    }
  }

  // flange
  hull(){
    translate([+(-flange_w/2 + flange_r), +(-flange_h/2 + flange_r), 0]){
      cylinder($fn = fn, r = flange_r, h = flange_thickness);
    }
    translate([+(-flange_w/2 + flange_r), -(-flange_h/2 + flange_r), 0]){
      cylinder($fn = fn, r = flange_r, h = flange_thickness);
    }
    translate([-(-flange_w/2 + flange_r), +(-flange_h/2 + flange_r), 0]){
      cylinder($fn = fn, r = flange_r, h = flange_thickness);
    }
    translate([-(-flange_w/2 + flange_r), -(-flange_h/2 + flange_r), 0]){
      cylinder($fn = fn, r = flange_r, h = flange_thickness);
    }
  }


}

height = 20;
length = 64;
width = 22;
board_lip = 2;
connector_width = 40;
connector_length = 18;
connector_recess = 5;
connector_height = 13;
bulge_length = 10;
bottom_thickness = 3;
nut_dist = 6;
screw_hole_d = 3.25;
screw_hole_x = length/2 - connector_length + 5;
screw_hole_y = (connector_width + width) / 4;

module case_bottom()
{
  difference(){
    union(){
      // body
      translate([-length/2, -width/2, 0]){
        cube([length, width, height/2]);
      }
      // DB9 connector bulge
      translate([length/2 - connector_length, -connector_width/2, 0]){
        cube([connector_length, connector_width, connector_height]);
      }
      // screw clamp bulge
      translate([-length/2, -connector_width/2, 0]){
        cube([bulge_length, connector_width, height/2]);
      }
    }

    // wire channel
    translate([-length/2 + usb_lip,
               -board_width/2 + board_lip,
               height/2]){
      cube([length - board_lip,
            board_width - 2*board_lip,
            height/2]);
    }

    // below-board hollow
    translate([-length/2 + usb_lip,
               -board_width/2 + board_lip,
               bottom_thickness]){
      cube([board_length - board_lip,
            board_width - 2*board_lip,
            height/2]);
    }
    // board recess
    translate([-length/2 + usb_lip,
               -board_width/2,
               height/2 - board_thickness]){
      cube([board_length,
            board_width,
            height/2]);
    }
    // DB9 opening
    translate([length/2-connector_recess, 0, height/2]){
      rotate([0, 90, 0]){
        rotate([0, 0, -90]){
          db9_profile();
        }
      }
    }
    // nut slots
    translate([length/2-nut_dist, -db9_hole_spacing/2, height/2]){
      rotate([0, -90, 0]){
        hull(){
          cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          translate([20, 0, 0]){
            cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          }
        }
      }
    }
    translate([length/2-nut_dist, +db9_hole_spacing/2, height/2]){
      rotate([0, -90, 0]){
        hull(){
          cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          translate([20, 0, 0]){
            cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          }
        }
      }
    }

    // screw holes
    epsilon = 1;
    screw_hole_d = 3.25;
    screw_hole_x1 = length/2 - connector_length + 5;
    screw_hole_y = (connector_width + width) / 4;
    translate([screw_hole_x1, -screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }
    translate([screw_hole_x1, +screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }

    screw_hole_x2 = -length/2 + 5;
    translate([screw_hole_x2, -screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }
    translate([screw_hole_x2, +screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }

    // DB connector screw holes
    translate([length/2 -15,  -db9_hole_spacing/2, height/2]){
      rotate([0, 90, 0]){
        cylinder($fn = 8, d = screw_hole_d, h = height);
      }
    }
    translate([length/2 -15,  +db9_hole_spacing/2, height/2]){
      rotate([0, 90, 0]){
        cylinder($fn = 8, d = screw_hole_d, h = height);
      }
    }

  }
}

module case_top()
{
  epsilon = 1;

  difference(){
    union(){
      // body
      translate([-length/2, -width/2, 0]){
        cube([length, width, height/2]);
      }
      // DB9 connector bulge
      translate([length/2 - connector_length, -connector_width/2, 0]){
        cube([connector_length, connector_width, height-connector_height]);
      }
      // screw clamp bulge
      translate([-length/2, -connector_width/2, 0]){
        cube([bulge_length, connector_width, height/2]);
      }
    }

    // DB9 connector bulge trim
    tol = 0.5;
    translate([length/2 - connector_length - tol,
               -connector_width/2,
               height-connector_height]){
      cube([connector_length+epsilon+tol, connector_width, connector_height]);
    }

    // wire channel
    translate([-length/2 + usb_lip,
               -board_width/2 + board_lip,
               height - connector_height]){
      cube([length - board_lip,
            board_width - 2*board_lip,
            height/2]);
    }


    // below-board hollow
    translate([-length/2 + usb_lip,
               -board_width/2 + board_lip,
               bottom_thickness]){
      cube([board_length - board_lip,
            board_width - 2*board_lip,
            height/2]);
    }

    // DB9 opening
    translate([length/2-connector_recess, 0, height/2]){
      rotate([0, 90, 0]){
        rotate([0, 0, 90]){
          db9_profile();
        }
      }
    }

    // usb slot
    translate([-length/2-5, -usb_width/2, height/2-usb_height]){
      cube([10, usb_width, usb_height+epsilon]);
    }

    // nut slots
    translate([length/2-nut_dist, -db9_hole_spacing/2, height/2]){
      rotate([0, -90, 0]){
        hull(){
          cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          translate([20, 0, 0]){
            cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          }
        }
      }
    }
    translate([length/2-nut_dist, +db9_hole_spacing/2, height/2]){
      rotate([0, -90, 0]){
        hull(){
          cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          translate([20, 0, 0]){
            cylinder($fn = 6, d = 6.25 / cos(30), h = 3); 
          }
        }
      }
    }
    
    // screw holes
    epsilon = 1;
    screw_hole_d = 3.25;
    screw_hole_x1 = length/2 - connector_length + 5;
    screw_hole_y = (connector_width + width) / 4;
    translate([screw_hole_x1, -screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }
    translate([screw_hole_x1, +screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }
    screw_hole_x2 = -length/2 + 5;
    translate([screw_hole_x2, -screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }
    translate([screw_hole_x2, +screw_hole_y, -epsilon]){
      cylinder($fn = 8, d = screw_hole_d, h = height);
    }
  }
}


if (layout == "exploded"){ 
  exploded_dist = 10;
  
  case_bottom();
  translate([0, 0, 4*exploded_dist]){
    mirror([0, 0, 1]){
      case_top();
    }
  }
  translate([-(length - board_length)/2 + usb_lip,
             0,
             height/2 - board_thickness + exploded_dist]){
    nano_board();
  }
  translate([length/2-connector_recess + exploded_dist,
             0,
             height/2 + exploded_dist]){
    rotate([0, 90, 0]){
      rotate([0, 0, -90]){
        color([0.85, 0.85, 0.85]) db9_profile();
      }
    }
  }
}

if (layout == "printing"){
  s = 25;

  translate([0, +s, 0]){
    case_bottom();
  }
  translate([0, -s, 0]){
    rotate([0, 0, 180]){
      case_top();
    }
  }
}
