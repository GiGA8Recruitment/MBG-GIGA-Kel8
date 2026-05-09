extends Node

@onready var player_hand = $CardHand
@onready var detail_panel = $UI/CardDetailPanel
@onready var food_deck: CardDeck
@onready var food_deck_manager = $FoodCardDeckManager
@onready var card_slots: Array = [$GridContainer/CardSlot, $GridContainer/CardSlot2, $GridContainer/CardSlot3, $GridContainer/CardSlot4, $GridContainer/CardSlot5, $GridContainer/CardSlot6]
@onready var stat_panel = $UI/StatsSummaryPanel

func _ready() -> void:
	food_deck = food_deck_manager.deck
	player_hand.card_added.connect(_on_card_added)
	for slot in card_slots:
		slot.card_dropped_on.connect(_on_card_dropped)
		slot.card_rejected.connect(_on_card_rejected)
		slot.slot_swapped.connect(_on_card_swapped)
	spawn_from_deck(food_deck)

func _on_card_dropped(card: Card):
	var harga = 0
	var karbohidrat = 0
	var protein = 0
	var vitamin = 0
	var lemak = 0
	var gula = 0
	for slot in card_slots:
		if slot.is_empty():
			continue
		harga += slot.get_card_at(0).card_data.harga
		karbohidrat += slot.get_card_at(0).card_data.karbohidrat
		protein += slot.get_card_at(0).card_data.protein
		vitamin += slot.get_card_at(0).card_data.vitamin
		gula += slot.get_card_at(0).card_data.gula
		lemak += slot.get_card_at(0).card_data.lemak
		#print(slot.get_card_at(0).card_data.harga)
	print("-------------------------------")
	print("total harga: " + str(harga))
	print("total karbo: " + str(karbohidrat))
	print("total protein: " + str(protein))
	print("total vitamin: " + str(vitamin))
	print("total gula: " + str(gula))
	print("total lemak: " + str(lemak))
	
func _on_card_rejected(card: Card, reason: String):
	print("rejected good")
	
func _on_card_swapped(old_card: Card, new_card: Card):
	print("swapped good")

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
	
	
