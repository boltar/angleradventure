extends CharacterBody2D

signal water_entered

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
var is_pressed = false

@onready var joystick = $Camera2D/Joystick
@onready var fish_scene = preload("res://scenes/fish.tscn")
@onready var inv_button = $Camera2D/InventoryButton
@onready var cast_button = $Camera2D/CastButton
@onready var sell_all_button = $Chest/SellButton


func _on_inventory_button_pressed(is_showing):
	$Chest.visible = is_showing

	#if is_showing == false:
	#clear_all_fish()


func _ready():
	inv_button.inventory_button_pressed.connect(_on_inventory_button_pressed)
	cast_button.cast_button_pressed.connect(_on_cast_button_pressed)
	cast_button.cast_button_released.connect(_on_cast_button_released)
	cast_button.cast_button_holding.connect(_on_cast_button_holding)
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
	if Input.is_key_label_pressed(KEY_I):
		$Chest.visible = true

	if Input.is_key_label_pressed(KEY_ESCAPE):
		$Chest.visible = false
		#clear_all_fish()

	if Input.is_key_label_pressed(KEY_C):
		if is_pressed == false:
			$Camera2D/CastButton/Button.button_pressed = true
			$Camera2D/CastButton/Button.button_down.emit()
			is_pressed = true

	else:
		if is_pressed:
			is_pressed = false
			$Camera2D/CastButton/Button.button_pressed = false
			$Camera2D/CastButton/Button.button_up.emit()


func _draw():
	pass


func _physics_process(_delta):
	velocity.x = Input.get_axis("ui_left", "ui_right") * WALK_SPEED
	velocity.y = Input.get_axis("ui_up", "ui_down") * WALK_SPEED

	if joystick.is_pressing():
		var direction = joystick.pos_vector
		if direction:
			velocity = direction * WALK_SPEED
		else:
			velocity = Vector2(0, 0)

	if velocity.x > 0:
		$Sprite2D.flip_h = false
	elif velocity.x < 0:
		$Sprite2D.flip_h = true
	move_and_slide()


func _on_water_entered():
	print("water entered")


func _on_cast_button_pressed():
	print_debug("cast button pressed")


func _on_cast_button_holding(distance):
	$DistanceLabel.set_val(distance)


func _on_cast_button_released(distance):
	print_debug("cast button released: ", distance)

	num_caught += 1
	if num_caught > MAX_FISH:
		return
	$Chest.set_val(num_caught)
	$FishingAnimation.start_drawing(distance, $Sprite2D.flip_h)
	var i = rng.randi_range(0, 15)
	print(fish_names[i])
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
	print_debug("_on_sell_all_button_pressed")
