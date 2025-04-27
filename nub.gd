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

func get_random_vector_of_direction(direction):
	return direction*abs(randfn(1, 3))

func set_fragments_movement(relmas1, relmas2, frag1, frag2):
	var relvel = to_global(get_random_vector_of_direction(Vector3(1.0, 0.0, 0.0)))
	
	frag1.linear_velocity = self.linear_velocity - relvel*(relmas1+relmas2)/relmas1
	frag2.linear_velocity = self.linear_velocity + relvel*(relmas1+relmas2)/relmas2

	frag1.angular_velocity = self.angular_velocity*(relmas1+relmas2)/relmas1
	frag2.angular_velocity = self.angular_velocity*(relmas1+relmas2)/relmas2

	frag1.position = position
	frag1.rotation = rotation
	frag2.position = position
	frag2.rotation = rotation

func _on_success():
	success.emit()
	
	var frag1 = frag1_scene.instantiate()
	var frag2 = frag2_scene.instantiate()

	set_fragments_movement(2, 1, frag1, frag2)
	
	self.get_parent().add_child(frag1)
	self.get_parent().add_child(frag2)

	queue_free()

func _on_fail():
	dead.emit()

	var body1 = body1_scene.instantiate()
	var body2 = body2_scene.instantiate()

	set_fragments_movement(1, 1, body1, body2)

	self.get_parent().add_child(body1)
	self.get_parent().add_child(body2)

	queue_free()
