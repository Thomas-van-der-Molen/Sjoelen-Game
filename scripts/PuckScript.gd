extends RigidBody3D

var crossedEndzone = false
var targetPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	#apply_central_impulse(Vector3(rng.randf_range(-10,10),0,rng.randf_range(15,20)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !crossedEndzone and targetPosition:
		apply_central_force(targetPosition)
