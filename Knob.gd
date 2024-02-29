extends Sprite2D

@onready var parent = $".."

var posVector: Vector2

var pressing = false
@export var maxLength = 150
@export var deadzone = 5

func _ready():
	maxLength *= parent.scale.x*4

func _process(delta):
	if pressing:
		if get_global_mouse_position().distance_to(parent.global_position) <= maxLength:
			global_position = get_global_mouse_position()
		else:
			var angle = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle)*maxLength
			global_position.y = parent.global_position.y + sin(angle)*maxLength
		calculate_vector()
		
	else:
		global_position = lerp(global_position, parent.global_position, delta*50)	
		parent.posVector = Vector2(0,0)

func calculate_vector():
	var xdiff = global_position.x - parent.global_position.x
	var ydiff = global_position.y - parent.global_position.y
	if abs(xdiff) >= deadzone:
		parent.posVector.x = xdiff/maxLength
	if abs(ydiff) >= deadzone:
		parent.posVector.y = ydiff/maxLength
		

func _on_button_button_down():
	pressing = true
	
func _on_button_button_up():
	pressing = false
