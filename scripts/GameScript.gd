extends Node3D

var testpuck = preload("res://scenes/puck.tscn")
@onready var instancePoint = $PuckInstancePoint
@onready var cam = $pivot/Camera3D
@onready var endZone = $endZone
@onready var pointsLabel = $pivot/Camera3D/Control/Score
@onready var playerPucksLabel = $pivot/Camera3D/Control/playerPucksLabel

var activePuck
var pucksN1 = 0
var pucksN2 = 0
var pucksN3 = 0
var pucksN4 = 0
var nextSeries = 0
var playerScore = 0.0 
var playerPucks = 20
var pucksThisTurn = playerPucks
var playerTurns = 3
var tossedPucks = []

func _ready():
	playerPucksLabel.text = str(pucksThisTurn)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var newPuck = testpuck.instantiate()
		newPuck.position = instancePoint.position
		add_child(newPuck)
	
	if playerTurns == 0 or playerPucks == 0:
		var file = FileAccess.open("user://save_game.dat",FileAccess.WRITE)
		file.store_double(playerScore)
		file.close()
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		
	if Input.is_action_just_pressed("left_click") and pucksThisTurn > 0:
		createNewPuck()
		tossedPucks.append(activePuck)
		
		pucksThisTurn -= 1
		playerPucksLabel.text = str(pucksThisTurn)
		
		var mousePos = get_viewport().get_mouse_position()
		var space_state = get_world_3d().direct_space_state
		var origin = cam.project_ray_origin(mousePos)
		var end = origin + cam.project_ray_normal(mousePos) * 1000
		var query = PhysicsRayQueryParameters3D.create(origin,end)
		var result = space_state.intersect_ray(query)
		var newPosition = instancePoint.position
		if result:
			newPosition = result["position"]
			newPosition.y = instancePoint.position.y
			var diff = newPosition - activePuck.position
			activePuck.targetPosition = diff
			
	if pucksThisTurn == 0:
		
		#wait until the most recent puck stops moving
		#also needs to have left the end zone
		#because the initial velocity is zero, but ending the turn then would be incorrect
		if abs(activePuck.linear_velocity) < Vector3(.01,.01,.01) and activePuck.crossedEndzone:
			#reset the number of available pucks
			pucksThisTurn = tossedPucks.size()
			playerPucksLabel.text = str(pucksThisTurn)
			#remove the unscored pucks from the board
			for puck in tossedPucks:
				#tossedPucks.erase(puck)
				puck.queue_free()
			#reset the array
			tossedPucks = []
			#decrement the number of turns
			playerTurns -= 1
			#print("The player has ended this turn")
			
	


func _on_end_zone_body_entered(body):
	body.crossedEndzone = true
	
	
func createNewPuck():
	activePuck = testpuck.instantiate()
	activePuck.position = instancePoint.position
	add_child(activePuck)
	

func scorePoints(body, points):
	#body.queue_free()
	tossedPucks.erase(body)#The puck was scored, so remove it from the list of active pucks

	body.linear_velocity = Vector3.ZERO
	body.freeze = true
	
	playerScore += points
	playerPucks -= 1
	if pucksN1 > nextSeries and pucksN2 > nextSeries and pucksN3 > nextSeries and pucksN4 > nextSeries:
		playerScore += 10
		nextSeries += 1
	
	#must be the last thing to happen in the function
	pointsLabel.text = str(playerScore)
	
func _on_one_points_body_entered(body):
	body.position = $"1PointsStackPoint".position + Vector3(0, .28 * pucksN1, 0)
	pucksN1+=1
	scorePoints(body, 1)
	


func _on_two_points_body_entered(body):
	body.position = $"2PointsStackPoint".position + Vector3(0, .28 * pucksN2, 0)
	pucksN2+=1
	scorePoints(body, 2)
	
	

func _on_three_points_body_entered(body):
	body.position = $"3PointsStackPoint".position + Vector3(0, .28 * pucksN3, 0)
	pucksN3+=1
	scorePoints(body, 3)
	
	


func _on_four_points_body_entered(body):
	body.position = $"4PointsStackPoint".position + Vector3(0, .28 * pucksN4, 0)
	pucksN4+=1
	scorePoints(body, 4)
	
