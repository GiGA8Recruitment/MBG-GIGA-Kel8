extends Node

@onready var player_hand = $CardHand
@onready var detail_panel = $UI/CardDetailPanel
@onready var food_deck: CardDeck
@onready var food_deck_manager = $FoodCardDeckManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	food_deck = food_deck_manager.deck
	detail_panel.hide()
	player_hand.card_added.connect(_on_card_added)
	spawn_from_deck(food_deck)

func spawn_from_deck(deck: CardDeck):
	if not deck:
		push_error("Data belum di-assign!")
	
	for card_resource in deck.get_cards():
		if player_hand.is_full():
			print("Hand sudah penuh!")
			return
		
		var new_card = Card.new(card_resource)
		add_child(new_card)
		new_card.move_to(player_hand)
	
func _on_card_added(card: Card, _index: int):
	card.card_clicked.connect(_show_details)
	card.drag_started.connect(_show_details)
		
func _show_details(card: Card):
	var data = card.card_data as FoodCardResource
	
	if data:
		detail_panel.get_node("CardDetailContainer/Nama").text = "Nama: " + data.card_name
		detail_panel.get_node("CardDetailContainer/Harga").text = "Harga: " + str(data.harga)	
		detail_panel.get_node("CardDetailContainer/Karbohidrat").text = "Karbo: " + str(data.karbohidrat)
		detail_panel.get_node("CardDetailContainer/Protein").text = "Protein: " + str(data.protein)
		detail_panel.get_node("CardDetailContainer/Vitamin").text = "Vitamin: " + str(data.vitamin)
		detail_panel.get_node("CardDetailContainer/Lemak").text = "Lemak: " + str(data.lemak)
		detail_panel.get_node("CardDetailContainer/Gula").text = "Gula: " + str(data.gula)
		detail_panel.show()

#func _process(delta: float) -> void:
	#pass
	
	
