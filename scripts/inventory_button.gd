extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed():
	Events.inventory_button_pressed.emit()
