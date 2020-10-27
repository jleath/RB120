class Firework
  attr_reader :x_pos, :y_pos, :height

  MIN_HEIGHT = 3
  MAX_HEIGHT = 5
  SPRITES = ['.', '.', '.', '.', '.', '*', '%', '*', '%', '.']
  ANIMATION_FRAMES = SPRITES.size

  def initialize(x_pos)
    @x_pos = x_pos
    @y_pos = MAX_HEIGHT - 1
    @height = rand(MIN_HEIGHT..MAX_HEIGHT)
    @frame = MAX_HEIGHT - @height
    @active = true
  end

  def sprite
    SPRITES[@frame]
  end

  def update
    update_height
    update_frame
    update_active_status
  end

  def active?
    @active
  end

  private

  def update_height
    @y_pos -= 1 if @y_pos > (MAX_HEIGHT - @height)
  end

  def update_frame
    @frame += 1
  end

  def update_active_status
    @active = false if @frame == ANIMATION_FRAMES
  end
end

class FireworksAnimation
  WIDTH = 21
  REFRESH = 0.1
  FRAMES = 40
  GEN_CHANCE = 65

  def self.display(message)
    fireworks = []
    FRAMES.times do
      fireworks << Firework.new(rand(WIDTH)) if rand(100) > GEN_CHANCE
      puts generate_image(fireworks)
      puts(message)
      sleep(REFRESH)
      system('clear') || system('cls')
    end
  end

  def self.generate_image(fireworks)
    image = blank_image(WIDTH, Firework::MAX_HEIGHT)
    fireworks = fireworks.select(&:active?)
    fireworks.each do |firework|
      image[firework.y_pos][firework.x_pos] = firework.sprite
      firework.update
    end
    image
  end

  def self.blank_image(width, height)
    (0...height).map { ' ' * width }
  end
end