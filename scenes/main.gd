extends Node

@onready var food_deck: CardDeck
@onready var player_hand 		= %PlayerHand
@onready var food_deck_manager 	= %FoodCardDeckManager
@onready var card_slots: Array 	= [
	%CardSlotContainer/CardSlot,
	%CardSlotContainer/CardSlot2, 
	%CardSlotContainer/CardSlot3,
	%CardSlotContainer/CardSlot4, 
	%CardSlotContainer/CardSlot5, 
	%CardSlotContainer/CardSlot6, 
	%CardSlotContainer/CardSlot7, 
	%CardSlotContainer/CardSlot8
]
@onready var buff_slots: Array		= [
	%BuffSlotContainer/CardSlot,
	%BuffSlotContainer/CardSlot2,
	%BuffSlotContainer/CardSlot3,
	%BuffSlotContainer/CardSlot4
]

@onready var draw_pile 		= %DrawPile
@onready var discard_pile 	= %DiscardPile
@onready var trash_slot 	= %TrashSlot

@onready var detail_panel 	= %CardDetailPanel
@onready var stat_panel 	= %StatsSummaryPanel
@onready var target_panel	= %TargetPanel

@onready var play_button	= %PlayButton
@onready var shop_button	= %ShopButton

@onready var money_label	= %MoneyLabel
@onready var skor_label		= %SkorLabel
@onready var health_label	= %HealthLabel

@onready var shop_panel 	= %ShopPanel

# TARGET

@onready var TARGET_KARBO: int 		= 10
@onready var TARGET_PROTEIN: int 	= 10
@onready var TARGET_VITAMIN: int 	= 10
@onready var MAX_LEMAK: int 		= 10
@onready var MAX_GULA: int 			= 10

# CURRENT GIZI

var CURRENT_KARBO: int = 0
var CURRENT_PROTEIN: int = 0
var CURRENT_VITAMIN: int = 0
var CURRENT_LEMAK: int = 0
var CURRENT_GULA: int = 0
var CURRENT_HARGA: int = 0

# CURRENT PLAYER STATS

var CURRENT_MONEY: int = 100
var CURRENT_SCORE: int = 0
var CURRENT_LIVES: int = 3
var CURRENT_DIFFICULTY: int = 1
var NEXT_SCORE = 1000

func _ready() -> void:
	play_button.disabled = true
	player_hand.card_added.connect(_on_card_added)
	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	trash_slot.card_dropped_on.connect(_on_card_dropped_on_trash_slot)
	
	for slot in card_slots:
		slot.card_dropped_on.connect(_on_card_dropped)
		slot.abandon_on_empty_space = true
		slot.card_abandoned.connect(_on_card_back_to_hand)
		
	food_deck_manager.starting_pile = draw_pile
	food_deck_manager.shuffle_on_setup = true
	food_deck_manager.setup()
		
	draw_starting_hand()
	print_money()
	print_score()
	print_lives()
	display_target()
	
func evaluate_meal():
	var success = true
	var failed_reasons = []

	if CURRENT_KARBO < TARGET_KARBO:
		success = false
		failed_reasons.append("Karbo kurang")

	if CURRENT_PROTEIN < TARGET_PROTEIN:
		success = false
		failed_reasons.append("Protein kurang")

	if CURRENT_VITAMIN < TARGET_VITAMIN:
		success = false
		failed_reasons.append("Vitamin kurang")

	if CURRENT_GULA > MAX_GULA:
		success = false
		failed_reasons.append("Gula terlalu tinggi")

	if CURRENT_LEMAK > MAX_LEMAK:
		success = false
		failed_reasons.append("Lemak terlalu tinggi")

	if success:
		round_success()
	else:
		round_failed(failed_reasons)
		
func round_success():
	print("ROUND BERHASIL")

	var reward_money = 20 + (CURRENT_DIFFICULTY * 5)
	var reward_score = 100 * CURRENT_DIFFICULTY

	CURRENT_MONEY += reward_money
	CURRENT_SCORE += reward_score

	print_money()
	print_score()
	print_lives()

	add_difficulty()
	next_round()
	display_target()
	
func round_failed(reasons: Array):
	CURRENT_LIVES -= 1

	print("ROUND GAGAL")
	print("Alasan gagal:")

	for reason in reasons:
		print("- ", reason)

	print("Sisa nyawa: ", CURRENT_LIVES)
	
	print_lives()
	print_money()
	print_score()

	if CURRENT_LIVES <= 0:
		game_over()
	else:
		next_round()
		
func next_round():
	clear_board()
	draw_card()

func clear_board():
	for slot in card_slots:

		if slot.is_empty():
			continue

		var card = slot.get_card()
		card.move_to(discard_pile)
		
func game_over():
	print("GAME OVER")
	print("Final Score: ", CURRENT_SCORE)
	
func display_target():
	target_panel.get_node("TargetContainer/Karbohidrat").text = "Karbohidrat: " + str(TARGET_KARBO)
	target_panel.get_node("TargetContainer/Protein").text = "Protein: " + str(TARGET_PROTEIN)
	target_panel.get_node("TargetContainer/Vitamin").text = "Vitamin: " + str(TARGET_VITAMIN)
	target_panel.get_node("TargetContainer/Lemak").text = "Lemak: " + str(MAX_LEMAK)
	target_panel.get_node("TargetContainer/Gula").text = "Gula: " + str(MAX_GULA)


	
func _on_card_dropped_on_trash_slot(card: Card):
	discard_card(card)
	return_money(card)
	print_money()
	
func return_money(card: Card):
	var data = card.card_data as FoodCardResource
	CURRENT_MONEY += (data.harga / 2)

func draw_starting_hand():
	await draw_pile.deal_to(player_hand, 10, 0.4, 0.1)
	print(draw_pile.cards)
	
func _on_shop_pressed():
	if shop_panel.visible:
		close_shop()
		return
	open_shop()
	
func open_shop():
	shop_panel.show()

func close_shop():
	shop_panel.hide()
	
func draw_card() -> void:
	if draw_pile.is_empty():
		print("no card in draw pile")
		await discard_pile.move_all_to(draw_pile, 0)
		draw_pile.shuffle()
	await draw_pile.deal_to(player_hand, 1, 0.3)
	
func print_money():
	money_label.text = "Uang: " + str(CURRENT_MONEY)
	
func print_score():
	skor_label.text = "Skor: " + str(CURRENT_SCORE)
	
func print_lives():
	health_label.text = "Health: " + str(CURRENT_LIVES)
	
func discard_card(card: Card):
	card.move_to(discard_pile)
	
#func _on_play_pressed():
	#draw_card()
	
func _on_play_pressed():

	_sum_stats()

	evaluate_meal()
	
func subtract_money(amount: int):
	if CURRENT_MONEY < amount:
		return
	CURRENT_MONEY -= amount
	
func _on_card_dropped(card: Card):
	_sum_stats()
	play_button.disabled = false

func _on_card_back_to_hand(card: Card):
	card.move_to(player_hand)
	_sum_stats()

func add_difficulty():
	if CURRENT_SCORE >= NEXT_SCORE:
		CURRENT_DIFFICULTY += 1
		NEXT_SCORE += 1000

func _on_card_added(card: Card, _index: int):
	card.is_front_face = true
	card.card_clicked.connect(_show_details)
	card.drag_started.connect(_show_details)
	
func _sum_stats():
	CURRENT_HARGA = 0
	CURRENT_KARBO = 0
	CURRENT_PROTEIN = 0
	CURRENT_VITAMIN = 0
	CURRENT_GULA = 0
	CURRENT_LEMAK = 0
	
	var daftar_powerup = []
	var daftar_makanan = []

	for slot in card_slots:
		if slot.is_empty(): 
			continue

		var data = slot.get_card_at(0).card_data as FoodCardResource
		if data.kategori == FoodCardResource.Kategori.POWERUP:
			daftar_powerup.append(data)
		else:
			daftar_makanan.append(data.card_name.to_lower())
			CURRENT_HARGA 		+= data.harga
			CURRENT_KARBO 		+= data.karbohidrat
			CURRENT_PROTEIN 	+= data.protein
			CURRENT_VITAMIN 	+= data.vitamin
			CURRENT_GULA 		+= data.gula
			CURRENT_LEMAK 		+= data.lemak
	
	daftar_powerup.sort_custom(func(a, b): return a.power_up < b.power_up)

	for powerup in daftar_powerup:
		match powerup.power_up:
			FoodCardResource.Powerup.DOUBLE_COINS:
				CURRENT_MONEY *= 2
			FoodCardResource.Powerup.CLEAN_SUGAR:
				CURRENT_GULA = 0
			FoodCardResource.Powerup.CLEAN_FAT:
				CURRENT_LEMAK = 0
			FoodCardResource.Powerup.SUPPLEMENT:
				CURRENT_VITAMIN = int(CURRENT_VITAMIN * 1.5)
			FoodCardResource.Powerup.REHEAT:
				CURRENT_MONEY = int(CURRENT_MONEY * 1.5)
				CURRENT_KARBO += 20
			FoodCardResource.Powerup.DOUBLE_CARBS:
				CURRENT_KARBO *= 2
			FoodCardResource.Powerup.OVERCOOK:
				CURRENT_GULA = 0
				CURRENT_LEMAK = 0
				CURRENT_KARBO = int(CURRENT_KARBO * 0.75)
				CURRENT_PROTEIN = int(CURRENT_PROTEIN * 0.75)
				CURRENT_VITAMIN = int(CURRENT_VITAMIN * 0.75)
			FoodCardResource.Powerup.SEAFOOD_BOOST:
				if "seafood" in daftar_makanan:
					CURRENT_PROTEIN = int(CURRENT_PROTEIN * 1.2)
			FoodCardResource.Powerup.KETO_DIET:
				if CURRENT_KARBO >= 20:
					CURRENT_PROTEIN *= 2
			FoodCardResource.Powerup.PERFECT_BALANCE:
				if CURRENT_GULA == 0 and CURRENT_LEMAK == 0:
					CURRENT_KARBO += 20
					CURRENT_PROTEIN += 20
					CURRENT_VITAMIN += 20
					CURRENT_MONEY *= 2

	stat_panel.get_node("StatsSummaryContainer/Harga").text = "Harga: " + str(CURRENT_HARGA)
	stat_panel.get_node("StatsSummaryContainer/Karbohidrat").text = "Karbo: " + str(CURRENT_KARBO)
	stat_panel.get_node("StatsSummaryContainer/Protein").text = "Protein: " + str(CURRENT_PROTEIN)
	stat_panel.get_node("StatsSummaryContainer/Vitamin").text = "Vitamin: " + str(CURRENT_VITAMIN)
	stat_panel.get_node("StatsSummaryContainer/Gula").text = "Gula: " + str(CURRENT_GULA)
	stat_panel.get_node("StatsSummaryContainer/Lemak").text = "Lemak: " + str(CURRENT_LEMAK)


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

#func _process(delta: float) -> void:
	#pass
