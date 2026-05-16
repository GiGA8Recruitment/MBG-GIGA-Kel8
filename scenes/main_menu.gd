extends Node

const GAME_SCENE = "res://scenes/main.tscn"


@onready var start_button = %PlayButton
@onready var exit_button = %ExitButton
@onready var logo = %GameLogo

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	animate_logo()
	
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_exit_pressed() -> void:
	get_tree().quit()
	


func animate_logo():
	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		logo,
		"position:y",
		logo.position.y - 10,
		1.5
	)

	tween.tween_property(
		logo,
		"position:y",
		logo.position.y,
		1.5
	)
