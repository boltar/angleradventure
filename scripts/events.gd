extends Node

signal inventory_button_pressed()
signal cast_button_pressed
signal cast_button_released(distance)
signal cast_button_holding(distance)
signal joystick_pressed(pos_vector)
signal fish_caught(fish_type)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass