require 'ruby2d'

# Set up window
set title: 'Simple Game',
    width: 800,
    height: 600,
    background: 'black'

# Player circle
player = Circle.new(
  x: 400,
  y: 300,
  radius: 20,
  sectors: 32,
  color: 'white'
)

# Aim line
aim_distance = 50
aim_width = 5
aim_line = Line.new(
  x1: player.x,
  y1: player.y + aim_width / 2,
  x2: player.x + aim_distance,
  y2: player.y + aim_width / 2,
  width: aim_width,
  color: 'red',
  z: 1
)

# Projectiles array
projectiles = []

# Enemies array
enemies = []

# Money
$money = 0

# Health
$max_health = 100
$current_health = $max_health

# Health bar
health_bar = Rectangle.new(
  x: 10,
  y: 10,
  width: 200,
  height: 20,
  color: 'red',
  z: 2
)

# Overhealth bar
overhealth_bar = Rectangle.new(
  x: health_bar.x + health_bar.width,
  y: health_bar.y,
  width: 0,
  height: 20,
  color: 'yellow',
  z: 2
)

# Health text
health_text = Text.new("#{$current_health} / #{$max_health}", x: 220, y: 10, size: 20, color: 'white', z: 3)

# Money text
money_text = Text.new("Money: #{$money}", x: 10, y: 40, size: 20, color: 'white', z: 3)

# Game over text
$game_over_text = Text.new("Game Over", x: 250, y: 250, size: 30, color: 'white', opacity: 0, z: 4)


# toggle_game_over(). Describes the function to toggle the game over screen and restart the game.
# Parameters:
# - health_bar: Rectangle representing the health bar.
# - overhealth_bar: Rectangle representing the overhealth bar.
# - projectiles: Array containing projectile objects.
# - enemies: Array containing enemy objects.
# - visible: Boolean indicating whether the game over screen should be visible.
# Returns: None.
def toggle_game_over(health_bar, overhealth_bar, projectiles, enemies, visible)
  alpha = visible ? 1 : 0
  $game_over_text.color = [1.0, 1.0, 1.0, alpha]

  if alpha > 0
    # Reset game state
    $current_health = $max_health
    $money = 0
    health_bar.width = 200
    overhealth_bar.width = 0

    # Remove existing projectiles, enemies, and overhealth bar
    projectiles.each { |proj| proj[:circle].remove }
    projectiles.clear
    enemies.each { |enemy| enemy[:circle].remove }
    enemies.clear
  end
end



# move_towards_player(). Describes the function to move an enemy towards the player.
# Parameters:
# - enemy: Hash representing the enemy object.
# - player: Circle representing the player.
# Returns: None.
def move_towards_player(enemy, player)
  target_x = player.x + rand(100) - 50
  target_y = player.y + rand(100) - 50

  angle = Math.atan2(target_y - enemy[:circle].y, target_x - enemy[:circle].x)
  enemy[:velocity_x] = 2 * Math.cos(angle)
  enemy[:velocity_y] = 2 * Math.sin(angle)
end

# shoot_projectile(). Describes the function to shoot a projectile from the player.
# Parameters:
# - player: Circle representing the player.
# - aim_width: Width of the aiming line.
# - projectiles: Array containing projectile objects.
# Returns: None.
def shoot_projectile(player, aim_width, projectiles)
  angle = Math.atan2(Window.mouse_y - player.y, Window.mouse_x - player.x)

  projectile = {
    circle: Circle.new(
      x: player.x,
      y: player.y + aim_width / 2,
      radius: 5,
      sectors: 12,
      color: 'blue',
      z: 1
    ),
    velocity_x: 5 * Math.cos(angle),
    velocity_y: 5 * Math.sin(angle),
    damage: 10  # Damage dealt by bullets
  }

  projectiles << projectile
end

# spawn_enemy(). Describes the function to spawn an enemy.
# Parameters:
# - enemies: Array containing enemy objects.
# - player: Circle representing the player.
# Returns: None.
def spawn_enemy(enemies, player)
  return if enemies.length >= 5  # Limit the number of enemies

  new_enemy = {
    circle: Circle.new(
      x: 0,
      y: 0,
      radius: 20,
      sectors: 12,
      color: 'red',
      z: 1
    ),
    velocity_x: 0,
    velocity_y: 0,
    health: 25  # Health of enemies
  }

  # Check if the new enemy is too close to the player
  distance_to_player = distance(new_enemy[:circle].x, new_enemy[:circle].y, player.x, player.y)
  return if distance_to_player < 100

  # Check if the new enemy is too close to existing enemies
  too_close = enemies.any? do |existing_enemy|
    distance(new_enemy[:circle].x, new_enemy[:circle].y, existing_enemy[:circle].x, existing_enemy[:circle].y) < 2 * new_enemy[:circle].radius
  end

  return if too_close

  new_enemy[:circle].x = player.x + rand(200) - 100
  new_enemy[:circle].y = player.y + rand(200) - 100

  enemies << new_enemy
end


# destroy_projectile(). Describes the function to destroy a projectile.
# Parameters:
# - projectile: Hash representing the projectile object.
# - projectiles: Array containing projectile objects.
# Returns: None.
def destroy_projectile(projectile, projectiles)
  projectile[:circle].remove
  projectiles.delete(projectile)
end

# destroy_enemy(). Describes the function to destroy an enemy.
# Parameters:
# - enemy: Hash representing the enemy object.
# - enemies: Array containing enemy objects.
# Returns: None.
def destroy_enemy(enemy, enemies)  # Add `enemies` as an argument
  enemy[:circle].remove
  enemies.delete(enemy)  # Remove enemy from the array
end  


# update_score(). Describes the function to update the score.
# Parameters:
# - points: Integer representing the points to be added to the score.
# Returns: None.
def update_score(points)
  $money += points
end

# distance(). Describes the function to calculate the distance between two points.
# Parameters:
# - x1, y1: Coordinates of the first point.
# - x2, y2: Coordinates of the second point.
# Returns: Float representing the distance between the two points.
def distance(x1, y1, x2, y2)
  Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
end

# Mouse event for aiming
on :mouse do |event|
  aim_line.x2 = player.x + aim_distance * Math.cos(Math.atan2(event.y - player.y, event.x - player.x))
  aim_line.y2 = player.y + aim_width / 2 + aim_distance * Math.sin(Math.atan2(event.y - player.y, event.x - player.x))
end

# Keyboard events for movement and shooting
on :key_held do |event|
  case event.key
  when 'w'
    player.y -= 5
  when 'a'
    player.x -= 5
  when 's'
    player.y += 5
  when 'd'
    player.x += 5
  end

  aim_line.x1 = player.x
  aim_line.y1 = player.y + aim_width / 2
end

on :key_down do |event|
  case event.key
  when 'space'
    shoot_projectile(player, aim_width, projectiles)
  end
end

# Update loop
frame_count = 0  # Initialize frame count
enemy_spawn_interval = 60  # Spawn enemies every 5 seconds (60 frames per second)
max_enemies = 5
bullet_cooldown = 30  # Cooldown in frames (0.5 seconds assuming 60 frames per second)

last_shot_frame = 0  # Track the frame when the last shot occurred

update do
  frame_count += 1

  # Decrease enemy spawn interval every 600 frames
  if frame_count % 600 == 0 && enemy_spawn_interval > 60
    enemy_spawn_interval -= 5
  end

  # Spawn enemies every 5 seconds after being killed, with a max limit
  if frame_count % enemy_spawn_interval == 0 && enemies.length < max_enemies
    spawn_enemy(enemies, player)
  end

  # Check if health is zero or below
  if $current_health <= 0
    toggle_game_over(health_bar, overhealth_bar, projectiles, enemies, true)
  else
    toggle_game_over(health_bar, overhealth_bar, projectiles, enemies, false)
  end

  # Update projectiles
  projectiles.each do |proj|
    proj[:circle].x += proj[:velocity_x]
    proj[:circle].y += proj[:velocity_y]

    # Check collision with enemies
    enemies.each do |enemy|
      if distance(proj[:circle].x, proj[:circle].y, enemy[:circle].x, enemy[:circle].y) < proj[:circle].radius + enemy[:circle].radius
        destroy_enemy(enemy,enemies)
        update_score(10)
        $current_health += 1 if $current_health < $max_health # Heal 1 health when enemy is hit
        destroy_projectile(proj, projectiles) # Destroy the projectile after hitting an enemy
      end
    end
  end



  # Update enemies
  enemies.each do |enemy|
    move_towards_player(enemy, player)

    # Check collision with player
    if distance(player.x, player.y, enemy[:circle].x, enemy[:circle].y) < player.radius + enemy[:circle].radius
      destroy_enemy(enemy, enemies)
      if $money >= 20
        update_score(-20)
      else
        update_score(-$money)
      end
      $current_health -= 10
    end

    # Remove off-screen enemies
    if enemy[:circle].y > Window.height || enemy[:circle].x > Window.width
      destroy_enemy(enemy, enemies)
      update_score(5)
    end
  end



  # Remove off-screen projectiles
  projectiles.reject! { |proj| proj[:circle].x > Window.width || proj[:circle].y > Window.height }

  # Update health bar and overhealth bar
  health_bar.width = ($current_health / $max_health.to_f) * 200
  overhealth_bar.width = [([$current_health - $max_health, 0].max / $max_health.to_f) * 200, 0].max


  # Update health text
  health_text.text = "#{$current_health} / #{$max_health}"

  # Update money text
  money_text.text = "Money: #{$money}"
end

# Show the window
show
