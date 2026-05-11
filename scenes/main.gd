extends Node

@onready var food_deck: CardDeck
@onready var player_hand 		= %CardHand
@onready var food_deck_manager 	= %FoodCardDeckManager
@onready var card_slots: Array 	= [%CardSlotContainer/CardSlot,%CardSlotContainer/CardSlot2, %CardSlotContainer/CardSlot3,%CardSlotContainer/CardSlot4, %CardSlotContainer/CardSlot5, %CardSlotContainer/CardSlot6]

@onready var draw_pile = %DrawPile
@onready var discard_pile = %DiscardPile

@onready var detail_panel 		= %CardDetailPanel
@onready var stat_panel 		= %StatsSummaryPanel

@onready var play_button		= %PlayButton
@onready var deal_button		= %DealButton

@onready var money_label		= %MoneyLabel

func _ready() -> void:
	play_button.disabled = true		
	food_deck = food_deck_manager.deck
	player_hand.card_added.connect(_on_card_added)
	play_button.pressed.connect(_on_play_pressed)
	for slot in card_slots:
		slot.card_dropped_on.connect(_on_card_dropped)
		
	food_deck_manager.starting_pile = draw_pile
	food_deck_manager.setup()
	draw_starting_hand()
	#spawn_from_deck(food_deck)
	
func draw_starting_hand():
	await draw_pile.deal_to(player_hand, 3, 0.4, 0.1)
	print(draw_pile.cards)
	
func draw_card() -> void:
	if draw_pile.is_empty():
		print("no card in draw pile")
		await discard_pile.move_all_to(draw_pile, 0)
		draw_pile.shuffle()
	await draw_pile.deal_to(player_hand, 1, 0.3)
	
func discard_card():
	pass
	
func _on_play_pressed():
	#print("pressed")
	draw_card()
	

func _on_card_dropped(card: Card):
	_sum_stats()
	play_button.disabled = false


func _on_card_added(card: Card, _index: int):
	card.card_clicked.connect(_show_details)
	card.drag_started.connect(_show_details)
	
func _sum_stats():
	var harga = 0
	var karbohidrat = 0
	var protein = 0
	var vitamin = 0
	var lemak = 0
	var gula = 0
	
	for slot in card_slots:
		if slot.is_empty(): 
			continue
		harga 		+= slot.get_card_at(0).card_data.harga
		karbohidrat += slot.get_card_at(0).card_data.karbohidrat
		protein 	+= slot.get_card_at(0).card_data.protein
		vitamin 	+= slot.get_card_at(0).card_data.vitamin
		gula 		+= slot.get_card_at(0).card_data.gula
		lemak 		+= slot.get_card_at(0).card_data.lemak
	
	stat_panel.get_node("StatsSummaryContainer/Harga").text = "Harga: " + str(harga)
	stat_panel.get_node("StatsSummaryContainer/Karbohidrat").text = "Karbo: " + str(karbohidrat)
	stat_panel.get_node("StatsSummaryContainer/Protein").text = "Protein: " + str(protein)
	stat_panel.get_node("StatsSummaryContainer/Vitamin").text = "Vitamin: " + str(vitamin)
	stat_panel.get_node("StatsSummaryContainer/Gula").text = "Gula: " + str(gula)
	stat_panel.get_node("StatsSummaryContainer/Lemak").text = "Lemak: " + str(lemak)

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

func _show_details(card: Card):
	var data = card.card_data as FoodCardResource
	if data:
		detail_panel.get_node("CardDetailContainer/Nama").text = "Nama: " + data.card_name
		detail_panel.get_node("CardDetailContainer/Kategori").text = "Kategori: " + str(data.kategori)
		detail_panel.get_node("CardDetailContainer/Harga").text = "Harga: " + str(data.harga)	
		detail_panel.get_node("CardDetailContainer/Karbohidrat").text = "Karbo: " + str(data.karbohidrat)
		detail_panel.get_node("CardDetailContainer/Protein").text = "Protein: " + str(data.protein)
		detail_panel.get_node("CardDetailContainer/Vitamin").text = "Vitamin: " + str(data.vitamin)
		detail_panel.get_node("CardDetailContainer/Lemak").text = "Lemak: " + str(data.lemak)
		detail_panel.get_node("CardDetailContainer/Gula").text = "Gula: " + str(data.gula)
		detail_panel.show()
		
		var a = str(data.kategori)
		print(a)

#func _process(delta: float) -> void:
	#pass
