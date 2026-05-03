@tool
extends CardLayout

@onready var title: Label = %Label
@onready var image: TextureRect = %TextureRect

func _update_display() -> void:
	var data = card_resource as FoodCardResource
	if not data:
		return
	title.text = data.card_name
	image.texture = data.card_image
	
