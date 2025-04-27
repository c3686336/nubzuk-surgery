extends Node3D

@onready var nub_scene = preload("res://nub.tscn")

var timer
var timer_thres
var timer_paused_at

var timer_thres_mean

const timer_thres_default = 30

const timer_thres_std = 30
const timer_thres_min = 50
const timer_thres_max = 2000
const timer_thres_demo = 100

const timer_score_influence = 1.0/30.0

const success_score = 70
const fail_score = 1
const dead_score = 30

const nub_position_x = -30
const nub_position_y_std = 5
const nub_position_z_std = 4
const nub_position_z_min = -10
const nub_position_z_max = 15
const nub_vel_x_mean = 10
const nub_vel_x_std = 3
const nub_vel_y_std = 7
const nub_avel_mean = 5
const nub_avel_std = 10

var score

var demo_mode

func clampv(minimum, maximum, v):
	return min(maximum, max(minimum, v))

func reset_timer() -> void:
	timer = Time.get_ticks_msec()
	timer_thres = clampi(randfn(timer_thres_mean, timer_thres_std), timer_thres_min, timer_thres_max)

func pause_timer() -> void:
	timer_paused_at = Time.get_ticks_msec()

func resume_timer() -> void:
	timer_thres += Time.get_ticks_msec() - timer_paused_at

func _on_start_game() -> void:
	initialize()
	
	timer_thres_mean = timer_thres_default
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
	timer_thres_mean = timer_thres_demo
	reset_timer()
	demo_mode = true
	score = 0
	$Score.set_score(0)
	$Score.hide()
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
		reset_timer()
		if demo_mode:
			timer_thres = timer_thres_demo

		nub.position = Vector3(
			nub_position_x,
			randfn(0, nub_position_y_std),
			clampf(randfn(0, nub_position_z_std), nub_position_z_min, nub_position_z_max))
		nub.linear_velocity = Vector3(randfn(nub_vel_x_mean, nub_vel_x_std), abs(randfn(0, nub_vel_y_std)), 0)

		nub.angular_velocity.z = randfn(nub_avel_mean, nub_avel_std)

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
			print(result)
			var poor_nub = result["collider"]
			if poor_nub.is_in_group("Sliceable"):
				poor_nub.on_slice(result["position"])
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _update_score(ds: int):
	if !demo_mode:
		score += ds
		timer_thres_mean = timer_thres_default - score*timer_score_influence
		$Score.set_score(score)
		
func _on_success():
	_update_score(+success_score)

func _on_fail():
	_update_score(-fail_score)

func _on_dead():
	_update_score(-dead_score)
