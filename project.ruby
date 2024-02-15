require 'ruby2d'

set title: "Chicken invaders", width: 576, height: 600

Image.new('space.jfif', width: 576, height: 1024)

$mesh = 30
mainTheme = Music.new('main_theme.wav')
@fireSound = Sound.new('laser-gun-sound.wav')
@chickenSound = Sound.new('chicken_sound.wav')
@explosion = Sound.new('explosion.wav')ll
$prob = 5
mainTheme.volume = 30
@fireSound.volume = 50
@chickenSound.volume = 40
$fire_speed = 7
$row = 3
$col = 8
$scoure = 0
$highScoure = 0
$egg_speed = 5
@bullets = []
@chickens = Array.new($row) { [] }
@eggs = []
@egg_drop_timer = 0
@egg_drop_interval = 60
$avalible = true

def dropEgg(chicken)
  egg = Sprite.new(
    'egg.png', x: chicken.x, y: chicken.y, width: 30, height: 30
  )
  @eggs << egg
end

def eggDrop
  @egg_drop_timer += 1
  @chickens.each do |row|
    row.each do |chicken|
      dropEgg(chicken) if chicken && rand(100) < $prob && @egg_drop_timer % @egg_drop_interval == 0
    end
  end
end

def createRocket
  @rocket = Sprite.new(
  'spaceship.png', x: 270, y: 500, width: 50, height: 50
)
end

def getHighScore
  $highScoure = File.read("score.txt").to_i
  puts $highScoure
  Text.new(
    $highScoure.to_s + " high score",
    x: 30, y: 500,
    size: 20,
    color: 'white',
  )
end

def checkHitRocket
  @eggs.each do |egg|
    egg_x_range = (egg.x - $mesh)..(egg.x + $mesh)
    egg_y_range = (egg.y - $mesh)..(egg.y + $mesh)

    hit = egg_x_range.include?(@rocket.x) && egg_y_range.include?(@rocket.y)

    if hit
      @explosion.play
      $avalible = false
      @rocket.remove
    end
  end

end

def saveHighScore
  if $scoure > $highScoure
    out_file = File.new("score.txt", "w")
    out_file.puts($scoure)
    out_file.close
  end
end

def fire(x, y)
  bullet = Sprite.new(
    'fire.png', x: x, y: y, width: 50, height: 50, rotate: 90
  )
  @bullets << bullet
  @fireSound.play
end

def hitChicken
  @bullets.each do |bullet|
    @chickens.each do |row|
      row.reject! do |chicken|
        next unless chicken

        bullet_x_range = (bullet.x - $mesh)..(bullet.x + $mesh)
        bullet_y_range = (bullet.y - $mesh)..(bullet.y + $mesh)

        hit = bullet_x_range.include?(chicken.x) && bullet_y_range.include?(chicken.y)

        if hit
          $scoure += 1
          @chickenSound.play
          puts "Hit"
          @bullets.delete(bullet)
          bullet.remove
          chicken.remove
        end
      end
    end
  end
end

def createChickens
  $spacingX = 70
  $spacingY = 50
  $cSpaceY = 20

  $row.times do |i|
    $cSpaceX = 20
    $col.times do
      chicken = Sprite.new(
        'chicken.webp', x: $cSpaceX, y: $cSpaceY, width: 50, height: 50
      )
      @chickens[i] << chicken
      $cSpaceX += $spacingX
    end
    $cSpaceY += $spacingY
  end
end

@rocket = Sprite.new(
  'spaceship.png', x: 270, y: 500, width: 50, height: 50
)

createChickens
getHighScore

mainTheme.loop = true
mainTheme.play
@x_speed = 0
@y_speed = 0
$speed = 7

on :key_down do |event|
  case event.key
  when 'j'
    @x_speed = -$speed
    # @y_speed = 0
  when 'l'
    @x_speed = $speed
    # @y_speed = 0
  when 'i'
    # @x_speed = 0
    @y_speed = -$speed
  when 'k'
    # @x_speed = 0
    @y_speed = $speed
  when 'space'
    fire(@rocket.x, @rocket.y)
  when 'r'
    $prob +=0.5
    createChickens
  when '0'
    $row += 1
  when 's'
    saveHighScore
  when 'x'
    saveHighScore
    close
  when 'h'
    if !$avalible
      createRocket
      $avalible = true
    end
  end
end

on :key_up do |event|
  case event.key
  when 'j', 'l'
    @x_speed = 0
  when 'i', 'k'
    @y_speed = 0
  end
end

update do
  hitChicken

  @bullets.each do |bullet|
    bullet.y -= $fire_speed
    if bullet.y < 0
      @bullets.delete(bullet)
      bullet.remove
    end
  end

  @eggs.each do |egg|
    egg.y += $egg_speed
    if egg.y > 600
      @eggs.delete(egg)
      egg.remove
    end
  end

  if (0..530).include?(@rocket.x)
    @rocket.x += @x_speed
  elsif @rocket.x < 0
    @rocket.x = 0
  else
    @rocket.x = 530
  end

  if (200..500).include?(@rocket.y)
    @rocket.y += @y_speed
  elsif @rocket.y < 200
    @rocket.y = 200
  else
    @rocket.y = 500
  end

  @current&.remove

  @current = Text.new(
    $scoure.to_s + " current score",
    x: 400, y: 500,
    size: 20,
    color: 'white',
  )
  eggDrop
  checkHitRocket  # Call the method to check if an egg hits the rocket
end

show
