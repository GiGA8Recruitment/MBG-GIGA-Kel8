extends Label

var label_tween: Tween

# Tambahkan return agar bisa di-await di main.gd
func show_result(is_win: bool):
	self.modulate.a = 0.0
	self.scale = Vector2(0.5, 0.5)
	self.pivot_offset = size / 2
	
	if is_win:
		text = "ROUND WIN"
		add_theme_color_override("font_color", Color.GREEN_YELLOW)
	else:
		text = "ROUND LOSE"
		add_theme_color_override("font_color", Color.ORANGE_RED)
	
	if label_tween:
		label_tween.kill()
	
	label_tween = create_tween().set_parallel(true)
	label_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	label_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Tunggu sampai tween selesai sebelum lanjut
	await label_tween.finished
	
	await get_tree().create_timer(1.0).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_out.finished
	text = ""
