class_name StatCalculator

static func calculate(card_slots: Array) -> MealStats:

	var stats = MealStats.new()

	var daftar_powerup = []
	var daftar_makanan = []

	for slot in card_slots:
		if slot.is_empty():
			continue
		var data = slot.get_card_at(0).card_data as FoodCardResource
		if data.kategori == FoodCardResource.Kategori.POWERUP:
			daftar_powerup.append(data)
		else:
			daftar_makanan.append(data.card_name.to_lower())
			stats.harga += data.harga
			stats.karbo += data.karbohidrat
			stats.protein += data.protein
			stats.vitamin += data.vitamin
			stats.gula += data.gula
			stats.lemak += data.lemak

	_apply_powerups(stats, daftar_powerup, daftar_makanan)
	return stats

static func _apply_powerups(
	stats: MealStats,
	powerups: Array,
	foods: Array
):
	var daftar_seafood = ["bandeng", "dori asam manis", "lele goreng"]

	powerups.sort_custom(func(a, b): return a.power_up < b.power_up)
	for powerup in powerups:
		match powerup.power_up:
			FoodCardResource.Powerup.DOUBLE_COINS:
				stats.coins *= 2
			FoodCardResource.Powerup.CLEAN_SUGAR:
				stats.gula = 0
			FoodCardResource.Powerup.CLEAN_FAT:
				stats.lemak = 0
			FoodCardResource.Powerup.SUPPLEMENT:
				stats.vitamin = int(stats.vitamin * 1.5)
			FoodCardResource.Powerup.REHEAT:
				stats.coins = int(stats.coins * 1.5)
				stats.karbo += 20
			FoodCardResource.Powerup.DOUBLE_CARBS:
				stats.karbo *= 2
			FoodCardResource.Powerup.OVERCOOK:
				stats.gula = 0
				stats.lemak = 0
				stats.karbo = int(stats.karbo * 0.75)
				stats.protein = int(stats.protein * 0.75)
				stats.vitamin = int(stats.vitamin * 0.75)
			FoodCardResource.Powerup.SEAFOOD_BOOST:
				for makanan in foods:
					if makanan in daftar_seafood:
						stats.protein = int(stats.protein * 1.75)
						break
			FoodCardResource.Powerup.KETO_DIET:
				if stats.karbo >= 20:
					stats.protein *= 2
			FoodCardResource.Powerup.PERFECT_BALANCE:
				if stats.gula == 0 and stats.lemak == 0:
					stats.karbo += 20
					stats.protein += 20
					stats.vitamin += 20
					stats.coins *= 2
