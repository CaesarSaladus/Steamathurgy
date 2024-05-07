extends Node3D

@export var StartingWeapon : PackedScene
var hand : Marker3D
var EquippedWeapon : Node3D

func _ready():
	hand = get_parent().find_child("PlayerHand")
	if StartingWeapon:
		equip_weapon(StartingWeapon)

func equip_weapon(weapon_to_equip):
	if EquippedWeapon:
		print("Deleting current weapon")
		EquippedWeapon.queue_free()
	else:
		print("No weapon equipped")
		EquippedWeapon = weapon_to_equip.instantiate()
		hand.add_child(EquippedWeapon)
		

func _process(delta):
	pass

func shoot():
	if EquippedWeapon:
		EquippedWeapon.shoot()
