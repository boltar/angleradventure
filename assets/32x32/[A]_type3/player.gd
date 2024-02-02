extends CharacterBody2D

const GRAVITY = 200.0
const WALK_SPEED = 200


func read_input(delta):
	velocity.y += delta * GRAVITY
	
	if Input.is_action_pressed("ui_up"):
		velocity.y = -WALK_SPEED
		#direction = Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		velocity.y = WALK_SPEED
		#direction = Vector2(0, 1)
	if Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
		#direction = Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		velocity.x = WALK_SPEED
		#direction = Vector2(1, 0)

	#velocity = velocity * WALK_SPEED
		
#	velocity = velocity.normalized()
	move_and_slide()
		
func _physics_process(delta):
	read_input(delta)
