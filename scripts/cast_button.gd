extends Button

#signal cast_button_pressed
#signal cast_button_released(distance)
#signal cast_button_holding(distance)

const MAX_DISTANCE = 500

var distance = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_pressed():
		distance += delta * 100
		if distance > MAX_DISTANCE:
			distance = MAX_DISTANCE
		Events.cast_button_holding.emit(distance)
	else:
		distance = 0


func _on_button_up():
	#print_debug("on button released")
	Events.cast_button_released.emit(distance)
	distance = 0


func _on_button_down():
	#print_debug("on button pressed")
	Events.cast_button_pressed.emit()
