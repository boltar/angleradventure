extends Label

func set_val(val):
	text = str(int(val)) + " meters"


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("updated_distance_label", _on_updated_distance_label)

func _on_updated_distance_label(val):
	set_val(val)
