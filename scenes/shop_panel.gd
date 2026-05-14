extends Panel

signal shop_closed
signal shop_refreshed

@onready var close_button = %CloseButton
@onready var refresh_button = %RefreshButton
@onready var shop_card_hand = %ShopHand
@onready var card_detail_panel = %CardDetailPanel

var current_shop_cards = []

func _ready() -> void:
	hide()
		
func _on_refresh_button_pressed() -> void:
	shop_refreshed.emit()

func _on_close_button_pressed() -> void:
	hide()
	shop_closed.emit()
