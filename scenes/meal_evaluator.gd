class_name MealEvaluator

static func evaluate(
	stats: MealStats,
	target_karbo: int,
	target_protein: int,
	target_vitamin: int,
	max_gula: int,
	max_lemak: int
) -> Dictionary:

	var success = true
	var reasons = []

	if stats.karbo < target_karbo:
		success = false
		reasons.append("Karbo kurang")

	if stats.protein < target_protein:
		success = false
		reasons.append("Protein kurang")

	if stats.vitamin < target_vitamin:
		success = false
		reasons.append("Vitamin kurang")

	if stats.gula > max_gula:
		success = false
		reasons.append("Gula terlalu tinggi")

	if stats.lemak > max_lemak:
		success = false
		reasons.append("Lemak terlalu tinggi")

	return {
		"success": success,
		"reasons": reasons
	}
