extends CharacterBody3D

@export var animation_frame : int = 0
@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var frame = 0
@onready var animation_tree : AnimationTree = $AnimationTree
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation_tree.active = true
	
func _process(delta):
	update_animation()
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		print("Velocity x: ", velocity.x, " Velocity z: ", velocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if velocity.x 	< 0:
		$Sprite3D.flip_h = true
	elif velocity.x > 0:
		$Sprite3D.flip_h = false
	move_and_slide()
	
func update_animation():
	if velocity != Vector3.ZERO:
		$Sprite3D.play("Player_Walk")
			
			
			
		
