extends Node3D
@onready var animator = $AnimationPlayer
@onready var prevScoreLabel = $pivot/Camera3D/Control/VBoxContainer/previousScore
@onready var highScoreLabel = $pivot/Camera3D/Control/VBoxContainer/highScore
var intro = 1
var intros = ["intro", "intro2", "intro3"]

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("intro")#deferred function call
	
	var prevScore = 0.0
	var highScore = 0.0
	#update the labels to reflect the player's previous score and high score
	if FileAccess.file_exists("user://save_game.dat"):
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		prevScore = file.get_double()
		file.close()
	prevScoreLabel.text = "Previous Score: " + str(prevScore)
	
	#This code is so bad
	if FileAccess.file_exists("user://save_game1.dat"):
		var file = FileAccess.open("user://save_game1.dat", FileAccess.READ_WRITE)
		var hscore = file.get_double()
		if prevScore > hscore:
			highScore = prevScore
			file.seek(0)
			file.store_double(prevScore)
		else:
			highScore = hscore
			file.seek(0)
			file.store_double(hscore)
		file.close()
	else:
		var file = FileAccess.open("user://save_game1.dat", FileAccess.WRITE)
		file.store_double(0)
		file.close()
	highScoreLabel.text = "High Score: " + str(highScore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	animator.play(intros[intro])
	intro  = (intro+1) % intros.size()
	pass # Replace with function body.


func _on_button_pressed():
	#start the game
	get_tree().change_scene_to_file("res://scenes/mainGame.tscn")
	pass # Replace with function body.
