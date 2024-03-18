extends Node2D

signal fishing_animation_finished
enum EnumCastState { INIT, HOLDING, FLYING, SETTLING, DONE }
var time = 0
var _distance = 0

@onready var sprite = $Sprite
@onready var line: Line2D
@onready var p1_init_pos = $p1.position
@onready var p2_init_pos = $p2.position
@onready var cast_state: EnumCastState = EnumCastState.INIT


func clear_line():
	for child in get_children():
		if child is Line2D:
			child.queue_free()


func handle_line_released():
	print_debug("line released")


func start_drawing(distance):
	print_debug("at start_drawing")
	cast_state = EnumCastState.FLYING

	line = Line2D.new()
	line.width = 1
	add_child(line)
	_distance = distance
	$p1.position.y = -_distance / 2
	$p1.position.x += _distance / 2
	$p2.position.x += _distance


func bezier(t):
	var q0 = $p0.position.lerp($p1.position, t)
	var q1 = $p1.position.lerp($p2.position, t)
	var r = q0.lerp(q1, t)
	return r


func _draw():
	if cast_state != EnumCastState.FLYING and cast_state != EnumCastState.SETTLING:
		return

	var points = [$p0.position]
	var num_slices = 10

	print_debug("distance : ", _distance)

	for n in range(num_slices):
		points.append(bezier(float(n + 1) / num_slices))

	for n in range(num_slices):
		draw_line(points[n], points[n + 1], Color.WHITE, 1.0)


func _physics_process(delta):
	if cast_state != EnumCastState.FLYING and cast_state != EnumCastState.SETTLING:
		return

	if cast_state == EnumCastState.SETTLING:
		for child in get_children():
			if child is Line2D:
				child.queue_free()

		queue_redraw()
		if $p1.position.y < 0:
			$p1.position += Vector2(0, 100 * delta)
			print_debug($p1.position)
		else:
			print_debug("at DONE")
			time = 0
			_distance = 0
			$p1.position = p1_init_pos
			$p2.position = p2_init_pos
			cast_state = EnumCastState.DONE
		return

	if cast_state == EnumCastState.FLYING:
		sprite.position = bezier(time)
		time += delta

		line.add_point(sprite.position)

		if time >= 1:
			time = 1
			cast_state = EnumCastState.SETTLING
