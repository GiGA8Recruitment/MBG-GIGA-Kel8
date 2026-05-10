@tool
extends CardSlot


@export var allowed_category: FoodCardResource.Kategori

func _check_conditions(card: Card) -> bool:
	var data = card.card_data as FoodCardResource
	if not data:
		return false
	return data.kategori == allowed_category
