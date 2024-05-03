extends CharacterBody3D

@onready var Animated_Sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var player_Camera : Camera3D = $Player_Camera
const SPEED = 5.0

@export var jump_height : float = 1
@export var jump_time_to_peak : float = 0.5
@export var jump_time_to_descent : float = 0.4
@onready var jump_velocity : float = (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
@onready var just_jumped : bool = false
@onready var walking_toggled : bool = true
@onready var crouch_toggled : bool = false
signal mouse_Position_Changed(mouse_Postion)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += get_gravity() * delta
		
	if Input.is_action_just_pressed("Player_Jump") and is_on_floor():
		just_jumped = true
		jump()
		
	if Input.is_action_just_pressed("Player_Crouch") and is_on_floor():
		crouch_toggled = true
		
	if Input.is_action_just_released("Player_Crouch") and is_on_floor():
		crouch_toggled = false
		
	if Input.is_action_just_pressed("Player_Sprint") and is_on_floor():
		walking_toggled = false
		crouch_toggled = false
		
	if Input.is_action_just_released("Player_Sprint") and is_on_floor():
		walking_toggled = true
		
	var input_dir = Input.get_vector("Player_Move_Left", "Player_Move_Right", "Player_Move_Up", "Player_Move_Down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
			
		if walking_toggled:
			velocity.x = direction.x * (SPEED * 1/2)
			velocity.z = direction.z * (SPEED * 1/2)
		elif !walking_toggled:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if crouch_toggled:
				velocity.x = direction.x * (SPEED * 1/4)
				velocity.z = direction.z * (SPEED * 1/4) 
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if velocity.x < 0:
		Animated_Sprite.flip_h = true
	elif velocity.x > 0:
		Animated_Sprite.flip_h = false
	move_and_slide()
	update_animations(velocity)
	look_at_mouse()

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
		
func look_at_mouse():
	var player_pos = global_transform.origin
	var dropPlane = Plane(Vector3(0, 0, 1), player_pos)
	var ray_length = 1000
	var mouse_Pos = get_viewport().get_mouse_position()
	var from = player_Camera.project_ray_origin(mouse_Pos)
	var to = from + player_Camera.project_ray_normal(mouse_Pos) * ray_length
	var cursor_Pos = dropPlane.intersects_ray(from, to)
	emit_signal("mouse_Position_Changed", cursor_Pos)
