class_name Fish
extends Node2D


#class_name Fish
func update_sprite(texture):
	$FishSprite.texture = texture


func update_name(fish_name):
	$Label.text = fish_name
	$Label.scale = Vector2(0.4, 0.4)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.
