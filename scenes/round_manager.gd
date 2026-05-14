extends Node
class_name RoundManager

var current_score := 0
var current_money := 100
var current_lives := 3
var current_difficulty := 1

var next_diff_score := 1000

func round_success():
	print("ROUND BERHASIL")

	var reward_money = 20 + (current_difficulty * 5)
	var reward_score = 100 * current_difficulty

	current_money += reward_money
	current_score += reward_score

	_add_difficulty()


func round_failed(reasons: Array):
	current_lives -= 1

	print("ROUND GAGAL")

	for reason in reasons:
		print("- ", reason)


func is_game_over() -> bool:
	return current_lives <= 0


func _add_difficulty():
	if current_score >= next_diff_score:
		current_difficulty += 1
		next_diff_score += 1000
