extends CharacterBody2D

const GRAVITY = 200.0
const WALK_SPEED = 800
const MAX_FISH = 18
const MAX_FISH_TYPE = 16

var rng = RandomNumberGenerator.new()
var fish_names = [
	"Atlantic Bass",
	"Clownfish",
	"Flounder",
	"Sea Spider",
	"Blue Gill",
	"Guppy",
	"Snail",
	"Axolotl",
	"Shark",
	"Golden Tench",
	"Moss Ball",
	"Plastic Bag",
	"Junonia",
	"Sand Dollar",
	"Starfish",
	"Bobber",
]

var sprites = []
var fish_inventory = []
var num_caught = 0

@onready var fish_scene = preload("res://scenes/fish.tscn")
@onready var sell_all_button = $Chest/SellButton

func _on_inventory_button_pressed():
	$Chest.visible = !$Chest.visible

func _ready():

	Events.connect("inventory_button_pressed", _on_inventory_button_pressed)
	Events.connect("cast_button_released", _on_cast_button_released)
	Events.connect("cast_button_pressed", _on_cast_button_pressed)
	Events.connect("joystick_pressed", _on_joystick_pressed)

	$Chest.sell_all_pressed.connect(_on_sell_all_button_pressed)

	for i in range(MAX_FISH_TYPE):
		var fish_png = "res://assets/fish/fish%03d.png" % i
		print(fish_png)
		sprites.append(load(fish_png))


func get_fish_inv_coordinate(fish_count):
	const HORIZ_LIMIT = 6
	const VERT_LIMIT = 3

	var x = (fish_count - 1) % HORIZ_LIMIT
	var y = (fish_count - 1) / HORIZ_LIMIT
	if y > VERT_LIMIT:
		y = VERT_LIMIT - 1
	return Vector2(x, y)


func clear_all_fish():
	var num_sold = num_caught
	for child in $Chest.get_children():
		if child is Fish:
			child.queue_free()
	num_caught = 0
	$Chest.set_val(0)
	return num_sold


func _process(_delta):
	if Input.is_key_label_pressed(KEY_ESCAPE):
		$Chest.visible = false

func _draw():
	pass

func _physics_process(_delta):

	if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
		velocity.x = Input.get_axis("ui_left", "ui_right") * WALK_SPEED
	else:
		velocity.x = 0
	if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
		velocity.y = Input.get_axis("ui_up", "ui_down") * WALK_SPEED
	else:
		velocity.y = 0

	$Sprite2D.flip_h = velocity.x < 0
	move_and_slide()


func _on_joystick_pressed(pos_vector):
	print("_on_joystick_pressed")
	if pos_vector:
		velocity = pos_vector * WALK_SPEED
	else:
		velocity = Vector2(0,0)
	$Sprite2D.flip_h = velocity.x < 0

	$Chest.visible = false
	move_and_slide()

func _on_cast_button_pressed():
	print_debug("cast button pressed")

func _on_cast_button_released(distance):
	print_debug("cast button released: ", distance)

	num_caught += 1
	if num_caught > MAX_FISH:
		return
	$Chest.set_val(num_caught)
	var i = rng.randi_range(0, 15)
	print(fish_names[i])
	$FishingAnimation.start_drawing(distance, $Sprite2D.flip_h, sprites[i], fish_names[i])
	var fish = fish_scene.instantiate()

	fish.update_sprite(sprites[i])
	fish.update_name(fish_names[i])
	var v = get_fish_inv_coordinate(num_caught)
	v *= 32
	$Chest.add_child(fish)
	fish.set_position(v + Vector2(-85, -125))

	queue_redraw()

func _on_sell_all_button_pressed():
	var num_sold = clear_all_fish()
	$Chest.add_cash(num_sold * 10.0)
