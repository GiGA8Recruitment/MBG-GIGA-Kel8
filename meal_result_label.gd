extends Label

var label_tween: Tween

func show_result(is_win: bool) -> void:
	# Reset state awal
	self.modulate.a = 0.0
	self.scale = Vector2(0.5, 0.5) # Mulai dari kecil
	self.pivot_offset = size / 2   # Pastikan pivot di tengah agar scale bagus
	
	if is_win:
		text = "ROUND WIN"
		add_theme_color_override("font_color", Color.GREEN_YELLOW)
		add_theme_color_override("font_outline_color", Color.DARK_GREEN)
	else:
		text = "ROUND LOSE"
		add_theme_color_override("font_color", Color.ORANGE_RED)
		add_theme_color_override("font_outline_color", Color.DARK_RED)
	
	# Mulai Animasi
	if label_tween:
		label_tween.kill()
	
	label_tween = create_tween().set_parallel(true) # Jalankan animasi bersamaan
	
	# Animasi Muncul & Membesar (Pop in)
	label_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	label_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Tunggu sebentar di atas, lalu mengecil sedikit ke ukuran normal
	await get_tree().create_timer(0.4).timeout
	
	var settle_tween = create_tween()
	settle_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Tunggu 1 detik agar pemain bisa baca
	await get_tree().create_timer(1.2).timeout
	
	# Animasi Menghilang (Fade out)
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_out.finished
	text = "" # Kosongkan setelah selesai
