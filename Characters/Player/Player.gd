extends CharacterBody3D

@export var speed = 10
@export var camera_rotation_speed = 250

var move_direction = Vector3()

@export var jump_height : float = 1
@export var jump_time_to_peak : float = 0.5
@export var jump_time_to_descent : float = 0.4
@onready var jump_velocity : float = (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
@onready var just_jumped : bool = false
@onready var walking_toggled : bool = true
@onready var crouch_toggled : bool = false

@onready var Animated_Sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var camera = $CameraRig/Camera3D
@onready var camera_rig = $CameraRig
@onready var cursor= $Cursor


func _ready():
	camera_rig.set_as_top_level(true)
	cursor.set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



func _physics_process(delta):
	camera_follows_player()
	rotate_camera(delta)
	look_at_cursor()
	movement(delta)
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(3)
	move_and_slide()
	update_animations(velocity)


func camera_follows_player():
	var player_pos = global_transform.origin
	camera_rig.global_transform.origin = player_pos


func rotate_camera(delta):
	if Input.is_action_pressed("Camera_Rotate_CW"):
		camera_rig.rotate_y(deg_to_rad(-camera_rotation_speed * delta)) 
	if Input.is_action_pressed("Camera_Rotate_CCW"):
		camera_rig.rotate_y(deg_to_rad(camera_rotation_speed * delta)) 


func look_at_cursor():
	# Create a horizontal plane, and find a point where the ray intersects with it
	var player_pos = global_transform.origin
	var dropPlane  = Plane(Vector3(0, 1, 0), player_pos.y)
	# Project a ray from camera, from where the mouse cursor is in 2D viewport
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = dropPlane.intersects_ray(from,to)
	
	# Set the position of cursor visualizer
	cursor.global_transform.origin = cursor_pos + Vector3(0,1,0)
	
	# Make player look at the cursor
	#look_at(cursor_pos, Vector3.UP)


func movement(delta):
	
	if not is_on_floor():
		velocity.y += get_gravity() * delta
	if is_on_floor():
		if Input.is_action_just_pressed("Player_Jump"):
			just_jumped = true
			jump()
		if Input.is_action_just_pressed("Player_Crouch"):
			crouch_toggled = true
		elif Input.is_action_just_released("Player_Crouch"):
			crouch_toggled = false
		if Input.is_action_just_pressed("Player_Sprint"):
			walking_toggled = false
			crouch_toggled = false
		elif Input.is_action_just_released("Player_Sprint"):
			walking_toggled = true
	
	
	var input_dir = Input.get_vector("Player_Move_Left", "Player_Move_Right", "Player_Move_Up", "Player_Move_Down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if direction:		
		if walking_toggled:
			velocity.x = direction.x * (speed * 0.5)
			velocity.z = direction.z * (speed * 0.5)
		elif not walking_toggled:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			if crouch_toggled:
				velocity.x = direction.x * (speed * 0.25)
				velocity.z = direction.z * (speed * 0.25) 
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	velocity = velocity.rotated(Vector3.UP, $CameraRig.rotation.y)
	if velocity.x < 0:
		Animated_Sprite.flip_h = true
	elif velocity.x > 0:
		Animated_Sprite.flip_h = false
		
	
	
func get_gravity() -> float:
	return jump_gravity if velocity.y > 0  else fall_gravity
	
func check_falling() -> bool:
	if !is_on_floor() and velocity.y < 0:
		return true
	else:
		return false

func jump():
	velocity.y = jump_velocity
		
func update_animations(velocity):
	if velocity.x != 0 and is_on_floor() and walking_toggled and !crouch_toggled or velocity.z != 0 and is_on_floor() and walking_toggled and !crouch_toggled:
		Animated_Sprite.play("Player_Walk")
		
	elif velocity.x != 0 and is_on_floor() and !walking_toggled and !crouch_toggled or velocity.z != 0 and is_on_floor() and !walking_toggled and !crouch_toggled:
		Animated_Sprite.play("Player_Run")
		
	elif velocity.y > 0:
		Animated_Sprite.play("Player_Jump_Rise")
		
	elif check_falling() == true:
		Animated_Sprite.play("Player_Fall")
		
	elif is_on_floor() == true and just_jumped == true:
		Animated_Sprite.play("Player_Land")
		
	elif velocity.x != 0 and crouch_toggled or velocity.z != 0 and crouch_toggled:
		Animated_Sprite.play("Player_Crouch_Walk")
		
	elif crouch_toggled:
		Animated_Sprite.play("Player_Crouch")
		
	else:
		Animated_Sprite.play("Player_Idle")
		
func _on_animated_sprite_3d_animation_finished():
	if Animated_Sprite.animation == "Player_Land":
		just_jumped = false
