extends Node3D

@onready var nub_scene = preload("res://nub.tscn")

var timer
var timer_thres
var timer_paused_at

var timer_thres_default = 1000
var timer_thres_mean = timer_thres_default
var timer_thres_std = 30
var timer_thres_demo = 100

var score = 0

var demo_mode = true 

func reset_timer() -> void:
	timer = Time.get_ticks_msec()
	timer_thres = randfn(timer_thres_mean, timer_thres_std)

func pause_timer() -> void:
	timer_paused_at = Time.get_ticks_msec()

func resume_timer() -> void:
	timer_thres += Time.get_ticks_msec() - timer_paused_at

func _on_start_game() -> void:
	initialize()
	
	reset_timer()

	demo_mode = false

	$PauseMenuContainer.hide()
	$StartMenuContainer.hide()
	$Score.show()

func _on_unpause_game() -> void:
	if demo_mode:
		return
	
	resume_timer()
	get_tree().paused = false
	$PauseMenuContainer.hide()

func _on_pause_game() -> void:
	if demo_mode:
		return

	pause_timer()
	$PauseMenuContainer.show()
	get_tree().paused = true

func _on_new_game() -> void:
	initialize()

func initialize() -> void:
	get_tree().paused = false
	reset_timer()
	timer_thres = timer_thres_demo
	demo_mode = true
	score = 0
	$Score.set_score(0)
	$StartMenuContainer.show()
	$PauseMenuContainer.hide()

	for child in get_children():
		if child.is_in_group("Trash"):
			child.queue_free()

func _ready() -> void:
	randomize()
	initialize()

func _process(delta: float):
	if Time.get_ticks_msec() - timer > timer_thres:
		var nub = nub_scene.instantiate()
		timer = Time.get_ticks_msec()
		var rand = randfn(timer_thres_mean, timer_thres_std)
		if demo_mode:
			timer_thres = timer_thres_demo
		else:
			timer_thres = max(min(2000, rand), 3)

		nub.position = Vector3(-30, randfn(0, 5), randfn(0, 4))
		nub.linear_velocity = Vector3(randfn(25, 3), abs(randfn(0, 7)), 0)

		nub.angular_velocity.z = randfn(5, 10)

		nub.success.connect(_on_success)
		nub.fail.connect(_on_fail)
		nub.dead.connect(_on_dead)
		
		add_child(nub)

func _input(event):
	pass

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos)*30
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result = space_state.intersect_ray(query)

	
	if result:
		if result["collider"].is_in_group("Nub_skull"):
			Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		if Input.is_action_just_pressed("click") && !demo_mode && result:
			var poor_nub = result["collider"]
			if poor_nub.is_in_group("Sliceable"):
				poor_nub.on_slice()
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _update_score(ds: int):
	if !demo_mode:
		score += ds
		timer_thres_mean = timer_thres_default - score/10.0
		$Score.set_score(score)
		
func _on_success():
	_update_score(+15)

func _on_fail():
	_update_score(-5)

func _on_dead():
	_update_score(-13)
