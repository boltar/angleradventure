extends Node2D

enum EnumCastState { INIT, HOLDING, FLYING, SETTLING, DONE }
var time = 0
var _distance = 0

@onready var bobber = $Bobber
@onready var line: Line2D
@onready var p1_init_pos = $p1.position
@onready var p2_init_pos = $p2.position
@onready var cast_state: EnumCastState = EnumCastState.INIT
@onready var fish_scene = preload("res://scenes/fish.tscn")

#var fish

func _ready():
	print_debug(p2_init_pos)
	pass

#func destroy_fish_scene():
	#for child in get_children():
		#if child is Fish:
			#child.queue_free()

func handle_line_released():
	print_debug("line released")


# h_flip = false --> RIGHT
#          true  --> LEFT
func start_drawing(distance, h_flip):

	#fish = fish_scene.instantiate()
	#fish.update_sprite(fish_type)
	#fish.update_name(fish_name)

	$Bobber.visible = true
	if cast_state == EnumCastState.FLYING or cast_state == EnumCastState.SETTLING:
		return

	cast_state = EnumCastState.FLYING

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
	if cast_state != EnumCastState.FLYING and cast_state != EnumCastState.SETTLING:
		return

	var points = [$p0.position]
	var num_slices = 10

	#print_debug("distance : ", _distance)

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
			#print_debug($p1.position)
		else:
			print_debug("at DONE")
			time = 0
			_distance = 0

			#fish.scale *= 1.5
			#fish.position = $p2.position
			var bobber_landed_pos = $p2.position
			$p1.position = p1_init_pos
			$p2.position = p2_init_pos
			cast_state = EnumCastState.DONE
			$Bobber.visible = false
			Events.bobber_landed.emit(to_global(bobber_landed_pos))
			#add_child(fish)
		return

	if cast_state == EnumCastState.FLYING:
		bobber.position = bezier(time)
		time += delta

		line.add_point(bobber.position)

		if time >= 1:
			time = 1
			cast_state = EnumCastState.SETTLING
