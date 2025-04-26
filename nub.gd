extends RigidBody3D

signal success
signal fail
signal dead

@onready var frag1_scene = preload("res://nub_fragment_1.tscn")
@onready var frag2_scene = preload("res://nub_fragment_2.tscn")

@onready var body1_scene = preload("res://nub_deadbody_1.tscn")
@onready var body2_scene = preload("res://nub_deadbody_2.tscn")

func _ready():
	$Skull.fail.connect(_on_fail)
	$Head.success.connect(_on_success)

	randomize()

func _process(delta: float):
	if position.y < -20.0:
		fail.emit()
		queue_free()

func get_random_vector():
	return Vector3(abs(randfn(0, 3)), randfn(0, 3), 0.0)

func _on_success():
	success.emit()
	
	var frag1 = frag1_scene.instantiate()
	var frag2 = frag2_scene.instantiate()

	frag1.linear_velocity = self.linear_velocity - get_random_vector()*1
	frag2.linear_velocity = self.linear_velocity + get_random_vector()*2

	frag1.position = position
	frag1.rotation = rotation
	frag2.position = position
	frag2.rotation = rotation
	
	self.get_parent().add_child(frag1)
	self.get_parent().add_child(frag2)

	queue_free()

func _on_fail():
	dead.emit()

	var body1 = body1_scene.instantiate()
	var body2 = body2_scene.instantiate()

	body1.linear_velocity = self.linear_velocity - get_random_vector()
	body2.linear_velocity = self.linear_velocity + get_random_vector()

	body1.position = position
	body1.rotation = rotation
	body2.position = position
	body2.rotation = rotation

	self.get_parent().add_child(body1)
	self.get_parent().add_child(body2)

	queue_free()
