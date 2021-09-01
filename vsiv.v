module main

import os
import gg
import gx

struct App {
mut:
  gg    &gg.Context
  img   gg.Image
  size  gg.Size
  px    f32
  py    f32
  msx   int
  msy   int
  scale f32
}

fn main() {
  mut app := &App{
    gg:0
  }

  app.gg = gg.new_context(
    bg_color: gx.white
    width: 512
    height: 512
    create_window: true
    resizable: true
    window_title: "vsiv"
    init_fn: init
    frame_fn: frame
    user_data: app
  )
  app.gg.run()
}

fn init(mut app &App) {
  if os.args[1] == "" {
    app.gg.quit()
  }
  app.scale = 1.0
  app.img = app.gg.create_image(os.args[1])
  app.gg.resize(app.img.width, app.img.height)
  app.gg.refresh_ui()
}

fn frame(mut app &App) {
  app.gg.begin()
  draw(mut app)
  update(mut app)
  app.gg.end()
}

fn draw(mut app &App) {
  app.size = gg.window_size()
  
  // draw image
  app.gg.draw_image(app.px + (app.size.width/2 - (app.img.width/2) * app.scale),
                    app.py + (app.size.height/2 - (app.img.height/2) * app.scale),
                    app.img.width * app.scale,
                    app.img.height * app.scale,
                    app.img)
  
  // draw image frame
  app.gg.draw_empty_rect(app.px + (app.size.width/2 - (app.img.width/2) * app.scale),
                         app.py + (app.size.height/2 - (app.img.height/2) * app.scale),
                         app.img.width * app.scale,
                         app.img.height * app.scale,
                         gx.black)
  
  // draw image info
  app.gg.draw_rect(0, app.size.height-25, app.size.width, app.size.height, gx.white)
  app.gg.draw_text(5, app.size.height-20, "path: ${app.img.path}  |  size: ${app.img.width}x${app.img.height}  |  file type: ${app.img.ext}")
}

fn update(mut app &App) {
  // app exit
  if app.gg.pressed_keys[256] == true {
    app.gg.quit()
  }

  // mouse look x
  if app.gg.mouse_buttons == gg.MouseButtons.left {
    app.px -= (app.gg.mouse_pos_x - app.msx)/20
    app.py -= (app.gg.mouse_pos_y - app.msy)/20
  }else {
    app.msx = app.gg.mouse_pos_x
    app.msy = app.gg.mouse_pos_x
  }
  // mouse bounderies
  // x
  if app.px < (-app.img.width/2) * app.scale{
    app.px = (-app.img.width/2) * app.scale
  }
  if app.px > (app.img.width/2) * app.scale {
    app.px = (app.img.width/2) * app.scale
  }
  // y
  if app.py < (-app.img.height/2) * app.scale {
    app.py = (-app.img.height/2) * app.scale
  }
  if app.py > (app.img.height/2) * app.scale {
    app.py = (app.img.height/2) * app.scale
  }

  // scale with scroll
  if app.gg.scroll_y != 0 {
    app.scale += (f32(app.gg.scroll_y)/20) * app.scale
    app.gg.scroll_y = 0
  }
  
  // scale borders
  if app.scale < 0.1 {
    app.scale = 0.1
  }
  if app.scale > 10.0 {
    app.scale = 10.0
  }

  // scale with buttons "[ ]"
  if app.gg.pressed_keys[93] == true {
    app.scale += 0.05 * app.scale
  }
  if app.gg.pressed_keys[91] == true {
    app.scale -= 0.05 * app.scale
  }
}
