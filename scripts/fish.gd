extends Node2D
class_name Fish
#class_name Fish
func update_sprite(texture):
	$FishSprite.texture = texture

func update_name(name):
	$Label.text = name
	$Label.scale = Vector2(0.25, 0.25)
#func set_position(pos):
	#$FishSprite.position = pos
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass