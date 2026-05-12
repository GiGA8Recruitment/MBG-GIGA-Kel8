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
	
func _focus_in() -> void:
	card_instance.tween_scale(Vector2(1.2,1.2), 0.2)
	#print(card_instance.get_screen_position())
	#card_instance.tween_position(Vector2(0.0, 1.1), 0.3)

func _focus_out() -> void:
	card_instance.tween_scale(Vector2(1,1), 0.2)
	#card_instance.tween_position(Vector2(0,0), 0.3)
