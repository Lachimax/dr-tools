# Create type with ALL sprite properties AND primitive_marker
class Sprite
  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b,
                :source_x, :source_y, :source_w, :source_h,
                :tile_x, :tile_y, :tile_w, :tile_h,
                :flip_horizontally, :flip_vertically,
                :angle_anchor_x, :angle_anchor_y, :blendmode_enum

  def primitive_marker
    :sprite
  end
end

# Create type with ALL solid properties AND primitive_marker
class Solid
  attr_accessor :x, :y, :w, :h, :r, :g, :b, :a

  def primitive_marker
    :solid
  end
end
