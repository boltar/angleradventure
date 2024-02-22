extends Node2D


@onready var p_0 = $p0.position
@onready var p_1 = $p1.position
@onready var p_2 = $p2.position
@onready var sprite = $Sprite
@onready var line : Line2D

	
var time = 0
var line_started = false
var line_done = false
func draw_me():
	if line_started == false:
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
		
	if line_done:
		remove_child(line)
		draw_curve()
		if p_1.y < 0:
			$p1.position += Vector2(0, 100 * delta)
			p_1 = $p1.position
		
		return
		
	sprite.position = bezier(time)
	time += delta
	if line_started:
		line.add_point(sprite.position)
		
	if time >= 1:
		time = 1
		line_done = true
	
	
	
	#if line_done:
	#p_1 += Vector2(0, 10)
	
		
