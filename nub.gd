extends RigidBody3D

signal success
signal fail
signal dead

@onready var globals = $"/root/Globals"

@onready var frag1_scene = preload("res://nub_fragment_1.tscn")
@onready var frag2_scene = preload("res://nub_fragment_2.tscn")
@onready var frag3_scene = preload("res://nub_fragment_3.tscn")
@onready var frag4_scene = preload("res://nub_fragment_4.tscn")

@onready var body1_scene = preload("res://nub_deadbody_1.tscn")
@onready var body2_scene = preload("res://nub_deadbody_2.tscn")

func _ready():
	$Skull.fail.connect(_on_fail)
	$Head.success.connect(_on_success)

	randomize()

func _process(delta: float):
	if position.dot(position) > globals.max_pos_sq:
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

func _on_success(clickpos: Vector3):
	var frag1
	var frag2
	
	if to_local(clickpos).x > 0.0:
		frag1 = frag1_scene.instantiate()
		frag2 = frag2_scene.instantiate()
	else:
		frag1 = frag3_scene.instantiate()
		frag2 = frag4_scene.instantiate()
	
	success.emit()
	

	set_fragments_movement(frag1.mass, frag2.mass, frag1, frag2)
	
	self.get_parent().add_child(frag1)
	self.get_parent().add_child(frag2)

	queue_free()

func _on_fail(clickpos: Vector3):
	dead.emit()

	var body1 = body1_scene.instantiate()
	var body2 = body2_scene.instantiate()

	set_fragments_movement(body1.mass, body2.mass, body1, body2)

	self.get_parent().add_child(body1)
	self.get_parent().add_child(body2)

	queue_free()
