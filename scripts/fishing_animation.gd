extends Node2D

var time = 0
var _distance = 0

@onready var bobber = $Bobber
@onready var line: Line2D
@onready var p1_init_pos = $p1.position
@onready var p2_init_pos = $p2.position
@onready var fish_scene = preload("res://scenes/fish.tscn")


func _ready():
	print_debug(p2_init_pos)


func handle_line_released():
	print_debug("line released")


# h_flip = false --> RIGHT
#          true  --> LEFT
func start_drawing(distance, h_flip):
	$Bobber.visible = true
	if Globals.CastState == Enums.CastState.FLYING or Globals.CastState == Enums.CastState.SETTLING:
		return

	Globals.CastState = Enums.CastState.FLYING

	line = Line2D.new()
	line.width = 1
	add_child(line)
	_distance = distance
	var cast_direction = 1
	if h_flip:
		cast_direction = -1

	$p1.position.y = -_distance / 2
	$p1.position.x += cast_direction * _distance / 2
	$p2.position.x += cast_direction * _distance


func bezier(t):
	var q0 = $p0.position.lerp($p1.position, t)
	var q1 = $p1.position.lerp($p2.position, t)
	var r = q0.lerp(q1, t)
	return r


func _draw():
	if (
		Globals.CastState != Enums.CastState.FLYING
		and Globals.CastState != Enums.CastState.SETTLING
	):
		return

	var points = [$p0.position]
	var num_slices = 10

	for n in range(num_slices):
		points.append(bezier(float(n + 1) / num_slices))

	for n in range(num_slices):
		draw_line(points[n], points[n + 1], Color.WHITE, 1.0)


func _physics_process(delta):
	if (
		Globals.CastState != Enums.CastState.FLYING
		and Globals.CastState != Enums.CastState.SETTLING
	):
		return

	if Globals.CastState == Enums.CastState.SETTLING:
		for child in get_children():
			if child is Line2D:
				child.queue_free()

		queue_redraw()
		if $p1.position.y < 0:
			$p1.position += Vector2(0, 100 * delta)
		else:
			print_debug("at DONE")
			time = 0
			_distance = 0

			var bobber_landed_pos = $p2.position
			$p1.position = p1_init_pos
			$p2.position = p2_init_pos
			Globals.CastState = Enums.CastState.DONE
			$Bobber.visible = false
			Events.bobber_landed.emit(to_global(bobber_landed_pos))
		return

	if Globals.CastState == Enums.CastState.FLYING:
		bobber.position = bezier(time)
		time += delta

		line.add_point(bobber.position)

		if time >= 1:
			time = 1
			Globals.CastState = Enums.CastState.SETTLING
