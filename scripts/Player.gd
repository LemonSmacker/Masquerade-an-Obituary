extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5.0
const SENSITIVITY = 0.003

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0
var respawn_coords = Vector3(0, 0, 0)



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var jumpSound = $jumpsound
@onready var stepSound = $stepsound


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$RayCast3D.force_raycast_update()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		stepSound.stop()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumpSound.play()
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 8.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 8.0)
			stepSound.play()
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.5)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.5)
		
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	
	move_and_slide()
	
	
	if position.y < -5:
		position = respawn_coords
	
	
	if $RayCast3D.is_colliding():
		var collider = $RayCast3D.get_collider()
		if collider.name == "CSGBox3D13":
			respawn_coords = Vector3(-14.51, 15.122, 6.105)
			print("Yippee")
		if collider.name == "CSGBox3D25":
			respawn_coords = Vector3(-50.52, 10.328, 13.04)
			print("Yippee")
	


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


