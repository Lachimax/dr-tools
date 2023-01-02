def colours
  { earth_brown: { r: 225, g: 169, b: 95 } }
end

def setup_render (args)
  args.state.draw = true
  args.state.scale = 1
  args.state.draw_targets = 1
  args.state.debug_entities = 1
  args.state.debug_entities_states = %w[off mouse all]
  args.state.debug_global = true
  args.state.debug_layers = false
  args.state.do_lighting = true

  args.state.solids = []
  args.state.render_layers = []

  args.state.num_layers = 4
  args.state.num_layers.times do
    args.state.render_layers << Array.new
  end

  # If no 'to render' list set up, create an empty one
  args.state.setup_.to_render ||= []

  args.state.setup_.to_render do |e|
    e.create_render_target args
  end

  args.render_target(:targeted).solids << { x: 0, y: 0, w: 100, h: 100, r: 255, g: 0, b: 0, a: 192 }

end

def render (args)
  # This code loops over all render layers, collects the entities in them, and sends their primitives to the output arrays.
  if args.state.draw
    args.state.num_layers.times do |i|

      args.outputs.sprites << args.state.render_layers[i]
                                  .map { |e| e.sprite(args) }
                                  .reject_nil

      # args.outputs.solids << args.state.render_layers[i]
      #                            .map { |e| e.solid(args) }
      #                            .reject_nil
      #
      # args.outputs.borders << args.state.render_layers[i]
      #                             .map { |e| e.border(args) }
      #                             .reject_nil
      #
      # args.outputs.labels << args.state.render_layers[i]
      #                            .map { |e| e.label(args) }
      #                            .reject_nil
      #
      # args.outputs.lines << args.state.render_layers[i]
      #                           .map { |e| e.line(args) }
      #                           .reject_nil

      # Draw entity debug variables onscreen
      if args.state.debug_entities_states[args.state.debug_entities] == "all"
        args.outputs.debug << args.state.render_layers[i]
                                  .map { |e| e.debug(args) }
                                  .reject_nil
      end
    end
  end
end

def lighting (args, r, g, b)
  if args.state.do_lighting
    # Make it grey at night.
    factor = 1.0
    if args.state.sunlight <= 0.0
      factor = args.state.dark_factor
    elsif args.state.sunlight <= 0.26
      factor = args.state.dark_factor + args.state.sunlight / 0.3
    end
    r = (r * factor).round
    g = (g * factor).round
    b = (b * factor).round
  end
  [r, g, b]
end

# Transforms gameworld x-position to screen x-position.
def scale_x (args, x)
  args.state.scale * (x - args.state.camera.x) + args.grid.w / 2
end

# Transforms gameworld y-position to screen x-position.
def scale_y (args, y)
  args.state.scale * (y - args.state.camera.y) + args.grid.h / 2
end

# Scales a size to the zoom level.
def scale_size (args, size)
  size * args.state.scale
end

# Checks if an object at position x, y with width w and height h is onscreen.
def onscreen? (args, x, y, w = 0, h = 0)
  0 < x + w && x < args.grid.w && 0 < y + h && y < args.grid.h
end

# Undoes the scale transformations.
def unscaler (args, x, y, w, h)
  x_cam = args.state.camera.x
  y_cam = args.state.camera.y
  x = x_cam + (x - args.grid.w / 2) / args.state.scale
  y = y_cam + (y - args.grid.h / 2) / args.state.scale
  w = w / args.state.scale
  h = h / args.state.scale
  [x, y, w, h]
end

def play_sound (args, title)
  args.outputs.sounds << "mygame/sounds/sfx/#{title}.wav"
end

def get_sprite (title)
  "mygame/sprites/#{title}.png"
end

def draw_sprite (args, x, y, w, h, path, r = 255, g = 255, b = 255, angle = 0, source_x = 0, source_y = 0, source_w = nil, source_h = nil)
  x = scale_x args, x
  y = scale_y args, y
  w = scale_size args, w
  h = scale_size args, h
  r, g, b = lighting args, r, g, b
  if onscreen? args, x, y, w, h
    sprite = { x: x, y: y, w: w, h: h, path: path, source_x: source_x, source_y: source_y, r: r.to_i, g: g.to_i, b: b.to_i, angle: angle }
    if source_w != nil
      sprite[:source_w] = source_w
    end
    if source_h != nil
      sprite[:source_h] = source_h
    end
    sprite
  else
    nil
  end
end

def draw_solid (args, x, y, w, h, r = 0, g = 0, b = 0, a = 255)
  x = scale_x args, x
  y = scale_y args, y
  w = scale_size args, w
  h = scale_size args, h
  r, g, b = lighting args, r, g, b
  if onscreen? args, x, y, w, h
    { x: x, y: y, w: w, h: h, r: r, g: g, b: b, a: a }
  else
    nil
  end
end

def draw_border (args, x, y, w, h, r = 0, g = 0, b = 0, a = 255)
  x = scale_x args, x
  y = scale_y args, y
  w = scale_size args, w
  h = scale_size args, h
  r, g, b = lighting args, r, g, b
  if onscreen? args, x, y, w, h
    { x: x, y: y, w: w, h: h, r: r, g: g, b: b, a: a }
  else
    nil
  end
end

def draw_line (args, x, y, x2, y2, r = 0, g = 0, b = 0, a = 255)
  x_prime = [x, x2].min
  x2_prime = [x, x2].max
  y_prime = [y, y2].min
  y2_prime = [y, y2].max
  w = x2_prime - x_prime
  h = y2_prime - y_prime
  x_prime_scale = scale_x args, x_prime
  y_prime_scale = scale_y args, y_prime
  w = scale_size args, w
  h = scale_size args, h
  r, g, b = lighting args, r, g, b
  if onscreen? args, x_prime_scale, y_prime_scale, w, h
    x = scale_x args, x
    y = scale_y args, y
    x2 = scale_x args, x2
    y2 = scale_y args, y2
    { x: x, y: y, x2: x2, y2: y2, r: r, g: g, b: b, a: a }
  else
    nil
  end
end

def draw_label (args, x, y, text, size = 1, alignment = 1, r = 0, g = 0, b = 0, a = 255)
  x = scale_x args, x
  y = scale_y args, y
  if onscreen? args, x, y
    { x: x, y: y, text: text, size_enum: size, alignment_enum: alignment, r: r, g: g, b: b, a: a }
  else
    nil
  end
end

def draw_calender (args, x = 1000, y = 680)
  # Put a 0 in front of single-digits.
  year = leading_zeroes args.state.times.current.year.to_i, 4
  month = leading_zeroes args.state.times.current.month.to_i
  day = leading_zeroes args.state.times.current.day.to_i
  # Calendar
  args.outputs.labels << { x: x, y: y, text: "Date: #{year}-#{month}-#{day}", r: 255, g: 0, b: 0 }
end

def draw_clock (args, x = 1000, y = 700)
  # Put a 0 in front of single-digits.
  hour = leading_zeroes args.state.times.current.hour.to_i
  minute = leading_zeroes args.state.times.current.minute.to_i
  second = leading_zeroes args.state.times.current.second.to_i
  # Clock.
  args.outputs.labels << { x: x, y: y, text: "Time: #{hour}:#{minute}:#{second}", r: 255, g: 0, b: 0 }
end

def draw_spawner (args)
  spawning = args.state.spawnable[args.state.spawning]
  args.outputs.sprites << args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 50,
    h: 50,
    path: spawning.sprite_path,
    source_x: 0,
    source_y: 0,
    #source_w: 50,
    #source_h: 50,
    r: 255,
    g: 255,
    b: 255,
    angle: 0 }
  args.outputs.labels << { x: 55, y: 45, text: spawning.name, r: 0, g: 0, b: 0 }
  args.outputs.labels << { x: 55, y: 25, text: args.state.pop[spawning.name].current, r: 0, g: 0, b: 0 }
end

def draw_variable_hud (args, name, value, x, y, r = 255, g = 0, b = 0)
  args.outputs.labels << { x: x, y: y, text: "#{name}: #{value}", r: r, g: g, b: b }
end

def draw_variable_debug (args, name, value, x, y, r = 255, g = 0, b = 0)
  args.outputs.debug << { x: x, y: y, text: "#{name}: #{value}", r: r, g: g, b: b }
end

def draw_debug (args, x = 10, y = 100)
  if args.state.debug_global
    args.outputs.debug << args.gtk.framerate_diagnostics_primitives
    # $gtk.framerate_diagnostics

    mouse_x, mouse_y = unscaler(args, args.inputs.mouse.x, args.inputs.mouse.y, 0, 0)
    x_player, y_player = args.state.player.position?

    debug_vars = {
      :now_playing => args.state.now_playing,
      :tick => args.state.times.current.ticks,
      :mouse_x => mouse_x, # mouse position
      :mouse_y => mouse_y,
      :player_x => x_player,
      :player_y => y_player,
      :sunlight => args.state.sunlight,
      :scale => args.state.scale,
      :num_entities => args.state.entities.size,
      :debug_entities => args.state.debug_entities_states[args.state.debug_entities],
      :do_lighting => args.state.do_lighting,
      :num_sprites => args.outputs.sprites.size,
      :minute => args.state.times.current.minute.to_i,
      :debug_bool => args.state.current.minute.to_i == 0
    }

    debug_vars.each do |key, value|
      draw_variable_hud args, key, value, x, y, 255, 0, 0
      y -= 22
    end
  end
end
