extends Label

func set_val(val):
	text = str(int(val)) + " meters"


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("cast_button_holding", _on_cast_button_holding)

func _on_cast_button_holding(val):
	set_val(val)
