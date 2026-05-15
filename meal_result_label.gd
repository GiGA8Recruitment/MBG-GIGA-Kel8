# meal_result_label.gd
class_name MealResultLabel extends Label

func _ready() -> void:
	hide()
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment   = VERTICAL_ALIGNMENT_CENTER

# Animasi teks muncul dengan tween
func tween_text(new_text: String, duration: float = 0.4) -> void:
	if new_text.is_empty():
		await _tween_fade(0.0, duration)
		text = ""
		return

	text = new_text
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	show()

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, duration)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), duration) \
		 .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

func _tween_fade(target_alpha: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, duration)
	await tween.finished

# Generate teks hasil berdasarkan evaluasi
func build_result_text(
	success: bool,
	stats: MealStats,
	reward_money: int,
	reward_score: int,
	reasons: Array
) -> String:
	var lines: Array[String] = []

	if success:
		lines.append("MENU SEHAT!")
		lines.append("")
		lines.append("+%d Uang   +%d Skor" % [reward_money, reward_score])

		# Bonus flavor text berdasarkan komposisi
		if stats.gula == 0:
			lines.append("Tanpa Gula!")
		if stats.lemak == 0:
			lines.append("Bebas Lemak!")
		if stats.protein >= 40:
			lines.append("Tinggi Protein!")
		if stats.karbohidrat >= 60:
			lines.append("Penuh Energi!")
	else:
		lines.append("MENU GAGAL!")
		lines.append("")
		for reason in reasons:
			lines.append("✗ " + reason)

	return "\n".join(lines)
