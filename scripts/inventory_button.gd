extends Node2D
signal inventory_button_pressed

var is_showing = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed():
	is_showing = !is_showing
	inventory_button_pressed.emit(is_showing)
