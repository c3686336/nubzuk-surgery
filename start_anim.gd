extends MeshInstance3D
const closest = 13.5
const amplitude = 3.0
const freq = 0.001

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec()

	# rotation.y = -90.0 + time*0.001
	position.z = amplitude*sin(time*freq*2*PI) + closest - amplitude
