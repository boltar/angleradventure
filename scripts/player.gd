extends CharacterBody2D

signal water_entered

const GRAVITY = 200.0
const WALK_SPEED = 200
const WALK_SPEED_MULTIPLIER = 4
var rng = RandomNumberGenerator.new()
var fish_names = ["Atlantic Bass",
"Clownfish", 
"Dab",
"Sea Spider",
"Blue Gill",
"Guppy",
"Freshwater Snail",
"Axolotl",
"High Fin Banded Shark",
"Golden Tench",
"Moss Ball",
"Plastic Bag",
"Junonia",
"Sand Dollar",
"Starfish",
"Bobber",
]

#var full_spritesheet = load("res://assets/fish/fish.png")
#var texture_size = full_spritesheet.get_size()
#var sprite_size = Vector2(16, 16)  # Adjust for your sprite size
#var num_columns = int(texture_size.x / sprite_size.x)
#var num_rows = int(texture_size.y / sprite_size.y)
var sprites = []
var fish_inventory = []
var num_caught = 0
const MAX_FISH = 18
const MAX_FISH_TYPE = 16
var line_end = Vector2(1, 0)

func _init():
	for i in range(MAX_FISH_TYPE):
		var fish_png = "res://assets/fish/fish%03d.png" % i
		print(fish_png)
		sprites.append(load(fish_png))

func get_fish_inv_coordinate(num_caught):
	const HORIZ_LIMIT = 6
	const VERT_LIMIT = 3
	
	var x = (num_caught - 1) % HORIZ_LIMIT
	var y = (num_caught - 1) / HORIZ_LIMIT
	if (y > VERT_LIMIT):
		y = VERT_LIMIT-1;
	return Vector2(x, y)
	
func _process(delta):
	if Input.is_key_label_pressed(KEY_I):
		$Chest.visible = true
		
	if Input.is_key_label_pressed(KEY_ESCAPE):
		$Chest.visible = false
		
		for child in $Chest.get_children():
			child.queue_free()
	
	if Input.is_action_just_pressed("ui_accept"):
		if (num_caught > MAX_FISH):
			return
		num_caught += 1
		#$Chest.set_val(num_caught)
		$FishingAnimation.draw_me()
		var i = rng.randi_range(0,15)
		print(fish_names[i])
		var my_sprite = Sprite2D.new()
		my_sprite.texture = sprites[i] 
		my_sprite.scale = Vector2(1,1)
		#my_sprite.offset = Vector2(-20,16*(num_caught+1))
		var v = get_fish_inv_coordinate(num_caught)
		v *= 32
		$Chest.add_child(my_sprite)
		my_sprite.position = v + Vector2(-85,-125)
		
		line_end.x += 10
		queue_redraw()
		

func _draw():
	draw_line(Vector2(0,0), line_end, Color.WHITE, 1.0)
	
func _physics_process(delta):
	velocity.x = Input.get_axis("ui_left", "ui_right") * WALK_SPEED * WALK_SPEED_MULTIPLIER
	velocity.y = Input.get_axis("ui_up", "ui_down") * WALK_SPEED * WALK_SPEED_MULTIPLIER
	move_and_slide()


func _on_water_entered():
	print("water entered")
	pass # Replace with function body.
