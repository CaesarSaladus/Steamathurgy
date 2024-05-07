extends StaticBody3D
# Called when the node enters the scene tree for the first time.

@export var Bullet : PackedScene
@onready var rof_timer = $Timer
var can_shoot = true
@export var muzzle_speed = 30
@export var millis_between_shots = 0.1

func _ready():
	rof_timer.wait_time = millis_between_shots
	pass
	
	
func _process(delta):
	pass
	
	
func shoot():
	if can_shoot:
		var new_bullet = Bullet.instantiate()
		new_bullet.global_transform = $AnimatedSprite3D/Gun_Barrel.global_transform
		new_bullet.speed = muzzle_speed
		var scene_root = get_tree().get_root().get_children()[0]
		scene_root.add_child(new_bullet)
		can_shoot = false
		rof_timer.start()
	


func _on_timer_timeout():
	print("Can shoot again")
	can_shoot = true
