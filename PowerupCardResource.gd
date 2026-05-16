@tool
class_name PowerupCardResource extends BaseCardResource

enum EffectType {
	NONE,
	#coins final x2
	DOUBLE_COINS, 
	# sugar = 0 
	CLEAN_SUGAR,
	# lemak = 0 
	CLEAN_FAT, 
	# vitamin +50%
	SUPPLEMENT, 
	# coins *150% karbo + 20
	REHEAT,
	# karbohidrat 2x
	DOUBLE_CARBS,
	# lemak 0 dan gula 0 tapi stat lain 75% 
	OVERCOOK,
	# klo ada seafood boost proteinnya 20%
	SEAFOOD_BOOST,
	# Karb minim 20, Protein x2.
	KETO_DIET,
	# if lemak n gula = 0, all stat+20 coinsx2
	PERFECT_BALANCE,
	}

@export var effect_value: int
@export var effect_type: EffectType
