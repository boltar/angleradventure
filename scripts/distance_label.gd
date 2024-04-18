extends Node2D


func set_val(val):
	$Label.text = str(int(val)) + " meters"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.
