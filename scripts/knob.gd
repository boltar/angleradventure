extends Sprite2D

@export var max_length = 150
@export var deadzone = 5
var pos_vector: Vector2
var pressing = false

@onready var parent = $".."


func _ready():
	max_length *= parent.scale.x


func _process(delta):
	if pressing:
		if get_global_mouse_position().distance_to(parent.global_position) <= max_length:
			global_position = get_global_mouse_position()
		else:
			var angle = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle) * max_length
			global_position.y = parent.global_position.y + sin(angle) * max_length
		calculate_vector()
		Events.joystick_pressed.emit(parent.pos_vector)
	else:
		global_position = lerp(global_position, parent.global_position, delta * 50)
		var zero_v = Vector2(0,0)
		if parent.pos_vector != zero_v:
			parent.pos_vector = Vector2(0, 0)
			Events.joystick_pressed.emit(parent.pos_vector)

func calculate_vector():
	var xdiff = global_position.x - parent.global_position.x
	var ydiff = global_position.y - parent.global_position.y
	if abs(xdiff) >= deadzone:
		parent.pos_vector.x = xdiff / max_length
	if abs(ydiff) >= deadzone:
		parent.pos_vector.y = ydiff / max_length


func _on_button_button_down():
	pressing = true


func _on_button_button_up():
	pressing = false
