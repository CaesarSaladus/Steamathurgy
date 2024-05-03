extends StaticBody3D
# Called when the node enters the scene tree for the first time.
@onready var animated_Sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var player_Camera : Camera3D = $Player_Camera
@onready var player_Parent = get_parent()

func _ready():
	pass	
func _process(delta):
	pass
	
func _on_player_mouse_position_changed(cursor_Pos: Vector3):
	if cursor_Pos != null:
		var direction = cursor_Pos - global_position

		var angle = direction.x/direction.y
		angle = atan(angle)
		var rotation_degrees = rad_to_deg(angle)

		rotation = Vector3(0, 0, rotation_degrees)
		if rotation_degrees > 0 and rotation_degrees >180:
			animated_Sprite.flip_h = true
		elif rotation_degrees > 0 and rotation_degrees < 180:
			animated_Sprite.flip_h = false
		
		print(rotation)
		print("Cursor: X", cursor_Pos.x, "Y ", cursor_Pos.y, "Z ", cursor_Pos.z)
		print("Player: X ", global_position.x, "Y ", global_position.y, "Z ", global_position.z)
