# game_over_panel.gd
extends Control

@onready var title_label   = %TitleLabel
@onready var sub_label     = %SubLabel
@onready var skor_label    = %ScoreLabel
@onready var ronde_label   = %RondeLabel
@onready var diff_label    = %DiffLabel
@onready var restart_btn   = %RestartButton
@onready var exit_btn      = %ExitButton

signal restart_pressed
signal exit_pressed

func _ready() -> void:
	restart_btn.pressed.connect(func(): restart_pressed.emit())
	exit_btn.pressed.connect(func(): exit_pressed.emit())
	hide()

func show_game_over(score: int, round_num: int, difficulty: int) -> void:
	skor_label.text  = str(score)
	ronde_label.text = str(round_num)
	diff_label.text  = str(difficulty)

	# Animasi muncul
	modulate.a = 0.0
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
