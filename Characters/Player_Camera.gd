extends Camera3D

@export var mouse_Position_3D : float
signal mouse_Position_Changed(mouse_Postion)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_Global_Mouse_Position()
	
func get_Global_Mouse_Position():
	var mouse_Position_2D = get_viewport().get_mouse_position()
	var mouse_Position_3D : Vector3
	mouse_Position_3D = project_position(mouse_Position_2D, position.z)
	emit_signal("mouse_Position_Changed", mouse_Position_3D)
	print("Mouse Position X: ", mouse_Position_3D.x, " Y: ", mouse_Position_3D.y, " Z: ", mouse_Position_3D.z)
