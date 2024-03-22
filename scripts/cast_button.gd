extends Node2D

signal cast_button_pressed
signal cast_button_released(distance)
signal cast_button_holding(distance)

const MAX_DISTANCE = 500

var distance = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Button.is_pressed():
		distance += delta * 100
		if distance > MAX_DISTANCE:
			distance = MAX_DISTANCE
		cast_button_holding.emit(distance)
	else:
		distance = 0


func _on_button_button_up():
	print_debug("on button released")
	cast_button_released.emit(distance)
	distance = 0


func _on_button_button_down():
	print_debug("on button pressed")
	cast_button_pressed.emit()
