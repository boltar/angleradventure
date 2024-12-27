extends CharacterBody2D

const GRAVITY = 200.0
const WALK_SPEED = 800
const MAX_FISH = 18
const HORIZ_LIMIT = 6  # for displaying inventory
const VERT_LIMIT = 3  # for displaying inventory

const MAX_FISH_TYPE = 144
const TILE_SIZE = Vector2i(32, 32)

@export var casting_sound: AudioStream
@export var chest_open_sound: AudioStream
@export var chest_close_sound: AudioStream
@export var fish_caught_sound: AudioStream
@export var bobber_landed_sound: AudioStream
@export var sell_sound: AudioStream

var rng = RandomNumberGenerator.new()
var fish_names = []
var scientific_names = []
var sprites = []
var fish_inventory = []
var num_caught = 0
#var Globals.is_casting = false

@onready var fish_scene = preload("res://scenes/fish.tscn")
@onready var sell_all_button = $Chest/SellButton
@onready var fish_sprite_sheet: Texture2D = preload("res://assets/fish/fishes.png")
@onready var cols: int = fish_sprite_sheet.get_width() / TILE_SIZE.x
@onready var rows: int = fish_sprite_sheet.get_height() / TILE_SIZE.y
@onready var inventory_button = get_node("/root/Main/UI/FishingActions/InventoryButton")


func read_fish_names():
	var csv_file_path = "res://scripts/fish_names.txt"

	var fish_data = read_csv(csv_file_path)
	if fish_data:
		for row in fish_data:
			if row.size() >= 3:  # Ensure the row has at least 3 elements
				scientific_names.append(row[1])
				fish_names.append(row[2])

		print("Scientific Names:", scientific_names)
		print("English Names:", fish_names)
	else:
		print("Failed to load CSV file.")


func read_csv(file_path: String) -> Array:
	var result = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line()
			var row = line.split(",")  # Split by comma
			result.append(row)
		file.close()
	else:
		print("Could not read csv")
	return result


func _on_inventory_button_pressed():
	destroy_fish_scene_after_catching()
	if !Globals.is_casting():
		open_chest()


func _ready():
	Events.connect("inventory_button_pressed", _on_inventory_button_pressed)
	Events.connect("cast_button_released", _on_cast_button_released)
	Events.connect("cast_button_pressed", _on_cast_button_pressed)
	Events.connect("joystick_pressed", _on_joystick_pressed)
	Events.connect("bobber_landed", _on_bobber_landed)
	Events.connect("cast_button_holding", _on_cast_button_holding)

	$Chest.sell_all_pressed.connect(_on_sell_all_button_pressed)

	read_fish_names()
	for i in range(cols * rows):  # Total number of tiles
		create_tile_sprite(i)


func get_tile_region(tile_index: int) -> Rect2i:
	var col = tile_index % cols
	var row = tile_index / cols
	return Rect2i(Vector2i(col * TILE_SIZE.x, row * TILE_SIZE.y), TILE_SIZE)


func create_tile_sprite(tile_index: int):
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = fish_sprite_sheet
	atlas_texture.region = get_tile_region(tile_index)
	sprites.append(atlas_texture)


func get_fish_inv_coordinate(fish_count):
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
	inventory_button.text = "Inventory"
	return num_sold


func is_direction_pressed():
	return (
		Input.is_action_pressed("ui_left")
		|| Input.is_action_pressed("ui_right")
		|| Input.is_action_pressed("ui_down")
		|| Input.is_action_pressed("ui_up")
	)


func _process(_delta):
	if Input.is_key_label_pressed(KEY_ESCAPE) || is_direction_pressed():
		clean_up_screen()


func _draw():
	pass


func _physics_process(_delta):
	if !Globals.is_casting():
		if Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
			velocity.x = Input.get_axis("ui_left", "ui_right") * WALK_SPEED
			$Sprite2D.flip_h = velocity.x < 0
		else:
			velocity.x = 0
		if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
			velocity.y = Input.get_axis("ui_up", "ui_down") * WALK_SPEED
		else:
			velocity.y = 0

	move_and_slide()


func process_new_fish_caught(new_pos):
	if num_caught + 1 > MAX_FISH:
		return
	num_caught += 1

	$Chest.set_val(num_caught)
	var i = rng.randi_range(0, MAX_FISH_TYPE - 1)
	Audio.play_sound(fish_caught_sound)
	var fish = fish_scene.instantiate()

	fish.update_sprite(sprites[i])
	fish.update_name(fish_names[i])
	var v = get_fish_inv_coordinate(num_caught)
	var temp_x = v.x
	var temp_y = v.y
	v *= 32
	v.x += temp_x * 22
	v.y += temp_y * 20
	$Chest.add_child(fish)
	fish.set_position(v + Vector2(-85, -125))

	var display_fish = fish_scene.instantiate()
	display_fish.update_sprite(sprites[i])
	display_fish.update_name(fish_names[i])
	display_fish.position = to_local(new_pos)

	add_child(display_fish)
	inventory_button.text = "Inventory (" + str(num_caught) + ")"


func _on_bobber_landed(pos_vector):
	#Globals.is_casting = false
	if Tiles.is_water(pos_vector):
		process_new_fish_caught(pos_vector)


func clean_up_screen():
	destroy_fish_scene_after_catching()
	close_chest()


func destroy_fish_scene_after_catching():
	for child in get_children():
		if child is Fish:
			child.queue_free()


func close_chest():
	if $Chest.visible:
		Audio.play_sound(chest_close_sound)
	$Chest.visible = false


func open_chest():
	if !$Chest.visible:
		Audio.play_sound(chest_open_sound)
	$Chest.visible = true


func _on_joystick_pressed(pos_vector):
	if pos_vector:
		velocity = pos_vector * WALK_SPEED
		$Sprite2D.flip_h = velocity.x < 0
	else:
		velocity = Vector2(0, 0)

	clean_up_screen()
	move_and_slide()


func _on_cast_button_pressed():
	if Globals.is_casting():
		return
	clean_up_screen()
	#Globals.is_casting = true
	if num_caught + 1 > MAX_FISH:
		return


func _on_cast_button_holding(distance):
	if Globals.is_casting():
		return
	if num_caught > MAX_FISH:
		return
	Events.updated_distance_label.emit(distance)


func _on_cast_button_released(distance):
	if Globals.is_casting():
		return

	clean_up_screen()
	$FishingAnimation.start_drawing(distance, $Sprite2D.flip_h)
	queue_redraw()
	Audio.play_sound(casting_sound)


func _on_sell_all_button_pressed():
	var num_sold = clear_all_fish()
	$Chest.add_cash(num_sold * 10.0)
	Audio.play_sound(sell_sound)
