extends Panel

signal shop_closed
signal card_bought(card: Card) 
signal shop_updated 

@onready var close_button = %CloseButton
@onready var refresh_button = %RefreshButton
@onready var shop_card_hand = %ShopHand

var player_hand_ref
var shop_deck: CardDeck
const REFRESH_COST = 5

func _ready() -> void:
	hide()
	close_button.pressed.connect(_on_close_button_pressed)
	refresh_button.pressed.connect(_on_refresh_button_pressed)

func open_shop(deck: CardDeck):
	show()
	shop_deck = deck
	
	roll_shop()

func roll_shop():
	var cards_to_clear = shop_card_hand.get_cards()
	for card in cards_to_clear:
		shop_card_hand.remove_child(card)
		card.queue_free()

	await get_tree().process_frame
		
	if not shop_deck:
		return
		
	var all_cards = shop_deck.get_cards()
	for i in range(6): 
		var random_data = all_cards.pick_random()
		var new_card = Card.new(random_data)
		
		add_child(new_card) 
		new_card.is_front_face = true 
		new_card.move_to(shop_card_hand)		
		new_card.undraggable = true 
		new_card.gui_input.connect(_on_shop_card_gui_input.bind(new_card))

func _on_shop_card_gui_input(event: InputEvent, card: Card):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		if player_hand_ref and player_hand_ref.get_cards().size() >= 10:
			print("Slot tidak cukup!")
			return

		var data = card.card_data as FoodCardResource
		if RoundManager.current_money >= data.harga:
			RoundManager.current_money -= data.harga
			card.gui_input.disconnect(_on_shop_card_gui_input)
			
			card.undraggable = false 
			
			card_bought.emit(card)
			shop_updated.emit()
		else:
			print("Uang tidak cukup!")
			
func _on_refresh_button_pressed() -> void:
	if RoundManager.current_money >= REFRESH_COST:
		RoundManager.current_money -= REFRESH_COST
		roll_shop()
		shop_updated.emit()

func _on_close_button_pressed() -> void:
	hide()
	shop_closed.emit()
