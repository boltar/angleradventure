extends Node2D


@onready var p_0 = $p0.position
@onready var p_1 = $p1.position
@onready var p_2 = $p2.position
@onready var sprite = $Sprite
@onready var line : Line2D
@onready var p1_init_pos = p_1

	
var time = 0
var line_started = false
var line_done = false
func clear_line():
	for child in get_children():
		if child is Line2D:
			child.queue_free()

func draw_me():
	print("draw_me called")
	if line_started:
		#clear_line()
		return
		
	line = Line2D.new()
	line.width = 1
	add_child(line)
	line_started = true
		
func bezier(t):
	var q0 = p_0.lerp(p_1, t)
	var q1 = p_1.lerp(p_2, t)
	var r = q0.lerp(q1, t)
	return r

func draw_curve():
	queue_redraw()
			
func _draw():
	if line_started == false:
		return
	#if line_done:
		#return
		
	var points = [p_0]
	var num_slices = 10
	
	for n in range(num_slices):
		points.append(bezier(float(n+1)/num_slices))
		print(points[n])
	
	for n in range(num_slices):
		draw_line(points[n], points[n+1], Color.WHITE, 1.0)
		
	
func _physics_process(delta):
	if line_started == false:
		return
		
		#remove_child(line)
	if line_done:
		for child in get_children():
			if child is Line2D:
				child.queue_free()
	
		draw_curve()
		if p_1.y < 0:
			$p1.position += Vector2(0, 100 * delta)
			p_1 = $p1.position
		else:
			line_done = false
			line_started = false
			time = 0
			$p1.position = p1_init_pos
			p_1 = $p1.position
		return
		
	sprite.position = bezier(time)
	time += delta
	if line_started:
		line.add_point(sprite.position)
		
	if time >= 1:
		time = 1
		line_done = true
	
		
