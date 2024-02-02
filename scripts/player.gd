extends CharacterBody2D

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

func _init():
	for i in range(16):
		var fish_png = "res://assets/fish/fish%03d.png" % i
		print(fish_png)
		sprites.append(load(fish_png))
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		num_caught += 1
		if (num_caught > 15):
			return
		var i = rng.randi_range(0,15)
		print(fish_names[i])
		var my_sprite = Sprite2D.new()
		my_sprite.texture = sprites[i] 
		my_sprite.scale = Vector2(1,1)
		my_sprite.offset = Vector2(-20,16*(num_caught+1))
		add_child(my_sprite)
		
func _physics_process(delta):
	velocity.x = Input.get_axis("ui_left", "ui_right") * WALK_SPEED * WALK_SPEED_MULTIPLIER
	velocity.y = Input.get_axis("ui_up", "ui_down") * WALK_SPEED * WALK_SPEED_MULTIPLIER
	move_and_slide()
