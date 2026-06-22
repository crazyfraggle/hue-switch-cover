// Parameters

/* [Original switch] */
old_button_box_width = 50;
old_button_box_height = 50;
old_button_box_depth = 30;

/* [Box Wall] */
wall_thickness = 3; // [2.6:0.2:4]
top_thickness = wall_thickness;
drop_left_wall = false;
drop_right_wall = false;
door_frame_adjust_left = 0;
door_frame_adjust_right = 0;

/* [Mounting plate] */
mounting_plate_thickness = 3;
grip_height = 4;

/* [Cable holes] */
top_left_cable_hole_diameter = 0;
top_right_cable_hole_diameter = 0;
bottom_left_cable_hole_diameter = 0;
bottom_right_cable_hole_diameter = 0;

/* [Buttons] */
inset_depth = 2;
//hue_buttons_offset_from_center = 0;

/* [Text] */
//text = "Let there be light";

/* [Hidden] */
hue_switch_width = 35.2;
hue_switch_height = 92.3;
hue_switch_thickness = 11.3;
hue_switch_rounding_r = 4;
hue_switch_inset_depth = 0.8;
hue_switch_inset_offset_top = 5.5;
hue_switch_inset_thickness = 1;
hue_switch_inset_width = 25;
hue_switch_magnet_offset_top = 40;
hue_switch_cutout_tolerance = 1;
$fn = 90;

box_dims = [
  max(old_button_box_width, hue_switch_width) + 2 * wall_thickness,
  max(old_button_box_height, hue_switch_height) + 2 * wall_thickness,
  old_button_box_depth + top_thickness - mounting_plate_thickness,
];
inner_box_dims = box_dims - [2, 2, 0] * wall_thickness - [0, 0, top_thickness];

union() {
  difference() {
    outer_box();
    inner_box();
    hue_switch_cutout();
    wall_removal_cutout();
    wire_holes_cutout();
    button_peek_hole();
    translate([0, 0, (box_dims[2] - grip_height) / -2])
      scale([1.01, 1, 1]) // Slight scaling to give some sideways slack
        mounting_grips();
  }
  // Need to add at the end to avoid it being cut out.
  magnet_holder();
}

translate([box_dims[0] + 10, 0, 0]) mounting_plate();

module mounting_plate() {
  wt = wall_thickness;
  dims = [box_dims[0], box_dims[1], mounting_plate_thickness];

  difference() {
    hull() {
      for (xm = [-2:4:2], ym = [-2:4:2])
        translate([(dims[0] - wt) / xm, (dims[1] - wt) / ym, 0])
          cylinder(h=dims[2], d=wt, center=true);
    }
    cube([old_button_box_width, old_button_box_height, dims[2]] + [1, 1, 1], center=true);
    // Wall cutaway
    if (drop_left_wall || door_frame_adjust_left > 0)
      translate([(dims[0] - wt) / -2, 0, 0])
        cube([wt, dims[1], dims[2]], center=true);
    if (drop_right_wall || door_frame_adjust_right > 0)
      translate([(dims[0] - wt) / 2, 0, 0])
        cube([wt, dims[1], dims[2]], center=true);
    // Wire cutaway
    translate([0, 0, box_dims[2] / 2 + mounting_plate_thickness])
      wire_holes_cutout();
    // TODO: Screw mount cutaway
    for (xm = [-1:1], ym = [-2:4:2])
      translate([box_dims[0] / 4 * xm, (box_dims[1] - (box_dims[1] - old_button_box_height) / 2) / ym, 0])
        union() {
          cylinder(h=dims[2], d=4, center=true);
          translate([0, 0, dims[2] / 4]) #cylinder(h=dims[2] / 2, d1=4, d2=8, center=true);
        }
  }
  // Mounting grip
  translate([0, 0, (mounting_plate_thickness + grip_height) / 2])
    mounting_grips();
}

module mounting_grips() {
  translate([0, (box_dims[1] - wall_thickness) / 2, 0]) mirror([0, 1, 0]) mounting_grip();
  translate([0, (box_dims[1] - wall_thickness) / -2, 0]) mounting_grip();
}

module mounting_grip() {
  grip_wall = wall_thickness / 3;
  grip = grip_wall * 2;
  width = 20;
  height = grip_height;

  union() {
    translate([0, (wall_thickness - grip_wall) / 2, 0])
      cube([width, grip_wall, height], center=true);
    translate([0, (wall_thickness - grip) / 2, (height - grip) / 2])
      rotate([0, 90, 0])
        cylinder(d=grip, h=width, center=true, $fn=4);
    translate([0, (wall_thickness - grip_wall) / 2, height / -2])
      rotate([0, 90, 0])
        cylinder(d=wall_thickness, h=width, center=true, $fn=4);
  }
}

module outer_box() {
  wt = wall_thickness;
  tt = top_thickness;

  hull() {
    for (xm = [-2:4:2], ym = [-2:4:2]) {
      translate([(box_dims[0] - wt) / xm, (box_dims[1] - wt) / ym, (box_dims[2] - tt) / -2])
        cylinder(h=wt, d=wt, center=true);
      translate([(box_dims[0] - wt) / xm, (box_dims[1] - wt) / ym, (box_dims[2] - tt) / 2])
        sphere(d=wt);
    }
  }
}

module inner_box() {
  wt = wall_thickness;
  tt = top_thickness;

  hull() {
    for (xm = [-2:4:2], ym = [-2:4:2]) {
      translate(
        [
          (inner_box_dims[0] - wt) / xm,
          (inner_box_dims[1] - wt) / ym,
          (inner_box_dims[2]) / -2 - tt,
        ]
      )
        cylinder(h=wt, d=wt, center=true);
      translate(
        [
          (inner_box_dims[0] - wt) / xm,
          (inner_box_dims[1] - wt) / ym,
          (inner_box_dims[2]) / 2 - tt,
        ]
      )
        sphere(d=wt);
    }
  }
}

module hue_switch_cutout() {
  translate([0, 0, (box_dims[2] + hue_switch_thickness) / 2 - inset_depth])
    hue_switch();
}

module hue_switch() {
  r = hue_switch_rounding_r;
  center_width = hue_switch_width - 2 * r;
  center_height = hue_switch_height - 2 * r;
  center_depth = hue_switch_thickness - 2 * r;

  union() {
    hull() {
      for (x = [-2:4:2], y = [-2:4:2]) {
        translate([(center_width - 0.8) / x, (center_height - 0.8) / y, (center_depth) / -2])
          sphere(r=hue_switch_rounding_r);
        translate([(center_width) / x, (center_height) / y, (center_depth) / 2])
          cylinder(h=hue_switch_rounding_r * 2, r=hue_switch_rounding_r, center=true);
      }
    }
    translate([0, hue_switch_height / 2 - hue_switch_inset_offset_top, -hue_switch_thickness / 2])
      hull() {
        translate([hue_switch_inset_width / -2, 0, 0])
          sphere(d=hue_switch_inset_thickness);
        translate([hue_switch_inset_width / 2, 0, 0])
          sphere(d=hue_switch_inset_thickness);
      }
  }
}

module wire_holes_cutout() {
  translate([0, 0, box_dims[2] / -2 - mounting_plate_thickness]) {
    translate([inner_box_dims[0] / -2, box_dims[1] / 2, 0])
      cable_hole(top_left_cable_hole_diameter);
    translate([inner_box_dims[0] / 2, box_dims[1] / 2, 0])
      cable_hole(top_right_cable_hole_diameter, left=false);
    translate([inner_box_dims[0] / -2, box_dims[1] / -2, 0])
      cable_hole(bottom_left_cable_hole_diameter);
    translate([inner_box_dims[0] / 2, box_dims[1] / -2, 0])
      cable_hole(bottom_right_cable_hole_diameter, left=false);
  }
}

// TODO: Make cable hole be a square that is rounded only on the inner side, instead of a cylinder?
module cable_hole(d, left = true) {
  if (d > 0)
    rotate([90, 0, 0])
      cylinder(h=box_dims[1], r=d, center=true, $fn=45);
}

// This handles both door frame adjustment and side wall removal
module wall_removal_cutout() {
  dfal = drop_left_wall ? box_dims[2] : max(0, door_frame_adjust_left - mounting_plate_thickness);
  dfar = drop_right_wall ? box_dims[2] : max(0, door_frame_adjust_right - mounting_plate_thickness);

  translate([(box_dims[0] - wall_thickness) / -2, 0, (box_dims[2] - dfal) / -2])
    cube([wall_thickness, box_dims[1], dfal], center=true);
  translate([(box_dims[0] - wall_thickness) / 2, 0, (box_dims[2] - dfar) / -2])
    cube([wall_thickness, box_dims[1], dfar], center=true);
}

module button_peek_hole() {
  r = 1;
  center_width = hue_switch_width - 4 * hue_switch_rounding_r - 2 * r;
  center_height = old_button_box_height - 2 * r;
  hull() {
    for (x = [-2:4:2], y = [-2:4:2]) {
      translate([(center_width) / x, (center_height) / y, 0])
        cylinder(h=old_button_box_depth + wall_thickness, r=r, center=true, $fn=45);
    }
  }
}

module magnet_holder() {
  width = old_button_box_width;
  height = 20;
  depth = 0.6;

  translate([0, hue_switch_height / 2 - hue_switch_magnet_offset_top, (box_dims[2]) / 2 - inset_depth - depth / 2])
    cube([width, height, depth], center=true);
}
