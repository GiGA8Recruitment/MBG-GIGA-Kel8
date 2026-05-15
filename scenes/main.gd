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
@onready var buff_slots: Array	= [
	%BuffSlotContainer/CardSlot,
	%BuffSlotContainer/CardSlot2,
	%BuffSlotContainer/CardSlot3,
	%BuffSlotContainer/CardSlot4
]

@onready var buff_container = %BuffSlotContainer
@onready var button_container = %ButtonContainer

@onready var draw_pile 		= %DrawPile
@onready var discard_pile 	= %DiscardPile
@onready var trash_slot 	= %TrashSlot

@onready var detail_panel 	= %CardDetailPanel
@onready var stat_panel 	= %StatsSummaryPanel
@onready var target_panel	= %TargetPanel
@onready var shop_panel 	= %ShopPanel

@onready var ompreng		= %Ompreng

@onready var play_button	= %PlayButton
@onready var shop_button	= %ShopButton

#region SHOP
@onready var close_shop_button = %CloseButton
@onready var refresh_shop_button = %RefreshButton
@onready var shop_hand = %ShopHand
@onready var shop_card_detail_panel = %ShopCardDetailPanel
@onready var shop_money_label = %ShopMoneyLabel
@onready var buy_button = %BuyButton
var selected_shop_card = null
#endregion

@onready var money_label	= %MoneyLabel
@onready var skor_label		= %SkorLabel
@onready var health_label	= %HealthLabel
@onready var diff_label 	= %DiffLabel


# TARGET

@onready var TARGET_KARBO 	= 20
@onready var TARGET_PROTEIN = 15
@onready var TARGET_VITAMIN = 10
@onready var MAX_LEMAK	 	= 25
@onready var MAX_GULA 		= 25

# CURRENT GIZI

var current_stats := MealStats.new()

# CURRENT PLAYER STATS

var CURRENT_MONEY: int 		= 300
var CURRENT_SCORE: int 		= 0
var CURRENT_LIVES: int 		= 3
var CURRENT_DIFFICULTY: int = 1
var NEXT_DIFF_SCORE: int 	= 1000
var NEXT_BUFF_SCORE: int	= 5000

# STATE

enum GameState {
	SHOP,
	PREPARE,
	GAME_OVER
}

var CURRENT_GAMESTATE = GameState.SHOP

#region CONST

const STARTING_HAND_SIZE = 0
const REFRESH_COST = 5
const SHOP_DRAW_SIZE = 6

#endregion

func _ready() -> void:
	food_deck_manager.starting_pile = draw_pile
	food_deck_manager.shuffle_on_setup = true
	food_deck_manager.setup()	
	play_button.disabled = true
	player_hand.card_added.connect(_on_card_added)
	shop_hand.card_added.connect(_on_shop_card_added)
	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	trash_slot.card_dropped_on.connect(_on_card_dropped_on_trash_slot)
	close_shop_button.pressed.connect(_on_close_shop_presesd)
	refresh_shop_button.pressed.connect(_on_refresh_shop_pressed)
	buy_button.pressed.connect(_on_buy_pressed)

	open_shop()

	
	for slot in card_slots:
		slot.card_dropped_on.connect(_on_card_dropped)
		slot.abandon_on_empty_space = true
		slot.card_abandoned.connect(_on_card_back_to_hand)
		
	draw_card(STARTING_HAND_SIZE)
	print_player_stats()
	generate_target()
	display_target()

func _on_buy_pressed():
	if selected_shop_card == null:
		return
	var data = selected_shop_card.card_data as FoodCardResource
	if CURRENT_MONEY < data.harga:
		print("Uang tdk cukup")
		return
	if player_hand.is_full():
		print("player hand full, tdk dapat membeli")
		return
		
	substract_money(data.harga)
	print_money()
	update_refresh_button()
	
	selected_shop_card.move_to(player_hand)
	print("transaksi sukses")
	selected_shop_card = null

func _on_close_shop_presesd():
	if shop_panel.visible:
		shop_panel.hide()
		_set_ui_disabled(false)
		CURRENT_GAMESTATE = GameState.PREPARE

func _on_refresh_shop_pressed():
	refresh_shop()

func _on_card_added(card: Card, _index: int):
	card.is_front_face = true
	card.card_clicked.connect(show_details)
	card.drag_started.connect(show_details)
	
func _on_shop_card_added(card: Card, _index: int):
	card.is_front_face = true
	card.card_clicked.connect(show_shop_details)
	card.card_clicked.connect(add_card_to_selected)
	card.drag_started.connect(show_shop_details)
	
func _on_card_back_to_hand(card: Card):
	card.move_to(player_hand)
	current_stats = StatCalculator.calculate(card_slots)
	stat_panel.display(current_stats)
	update_play_button()

#func _on_card_back_to_hand(card: Card):
	#card.move_to(player_hand)
	#_sum_stats()
	
#func _on_card_dropped(card: Card):
	#_sum_stats()
	#play_button.disabled = false
	
func _on_card_dropped(card: Card):
	current_stats = StatCalculator.calculate(card_slots)
	stat_panel.display(current_stats)
	update_play_button()

func _on_card_dropped_on_trash_slot(card: Card):
	#if CURRENT_MONEY < 5:
		#print("uang tdk cukup")
		#return
	#substract_money(5)
	discard_card(card)
	#draw_card(1)
	return_money(card)
	print_money()
	
func _on_shop_pressed():
	if shop_panel.visible:
		shop_panel.hide()
		return
	shop_panel.show()
	
func _on_play_pressed():
	current_stats = StatCalculator.calculate(card_slots)
	apply_buffs(current_stats)
	stat_panel.display(current_stats)
	var result = MealEvaluator.evaluate(
		current_stats,
		TARGET_KARBO,
		TARGET_PROTEIN,
		TARGET_VITAMIN,
		MAX_GULA,
		MAX_LEMAK
	)
	if result.success:
		round_success()
	else:
		round_failed(result.reasons)
	update_play_button()

	
#func evaluate_meal():
	#var success = true
	#var failed_reasons = []
#
	#if current_stats.karbo < TARGET_KARBO:
		#success = false
		#failed_reasons.append("Karbo kurang")
#
	#if current_stats.protein < TARGET_PROTEIN:
		#success = false
		#failed_reasons.append("Protein kurang")
#
	#if current_stats.vitamin < TARGET_VITAMIN:
		#success = false
		#failed_reasons.append("Vitamin kurang")
#
	#if current_stats.gula > MAX_GULA:
		#success = false
		#failed_reasons.append("Gula terlalu tinggi")
#
	#if current_stats.lemak > MAX_LEMAK:
		#success = false
		#failed_reasons.append("Lemak terlalu tinggi")
#
	#if success:
		#round_success()
	#else:
		#round_failed(failed_reasons)
		
func round_success():
	print("ROUND BERHASIL")
	var reward_money = 20 + (CURRENT_DIFFICULTY * 5)
	var reward_score = 100 * CURRENT_DIFFICULTY
	CURRENT_MONEY += reward_money
	CURRENT_SCORE += reward_score
	print_player_stats()
	increase_difficulty()
	next_round()
	
func round_failed(reasons: Array):
	CURRENT_LIVES -= 1
	print("ROUND GAGAL")
	print("Alasan gagal:")
	for reason in reasons:
		print("- ", reason)
	print("Sisa nyawa: ", CURRENT_LIVES)
	print_player_stats()

	if CURRENT_LIVES <= 0:
		game_over()
	else:
		next_round()
		
func next_round():
	CURRENT_GAMESTATE = GameState.SHOP
	open_shop()
	generate_target()
	display_target()
	clear_board()
	#draw_card(5)

func clear_board():
	for slot in card_slots:

		if slot.is_empty():
			continue

		var card = slot.get_card()
		card.move_to(discard_pile)
		
func game_over():
	play_button.disabled = true
	print("GAME OVER")
	print("Final Score: ", CURRENT_SCORE)
	CURRENT_GAMESTATE = GameState.GAME_OVER
	
func display_target():
	target_panel.get_node("TargetContainer/Karbohidrat").text = "Karbohidrat: " + str(TARGET_KARBO)
	target_panel.get_node("TargetContainer/Protein").text = "Protein: " + str(TARGET_PROTEIN)
	target_panel.get_node("TargetContainer/Vitamin").text = "Vitamin: " + str(TARGET_VITAMIN)
	target_panel.get_node("TargetContainer/Lemak").text = "Lemak: " + str(MAX_LEMAK)
	target_panel.get_node("TargetContainer/Gula").text = "Gula: " + str(MAX_GULA)

	
func return_money(card: Card):
	var data = card.card_data as FoodCardResource
	CURRENT_MONEY += int(data.harga / 2)

func draw_card(amount, from_pile: CardPile=draw_pile, to_hand: CardHand=player_hand) -> void:
	if from_pile.is_empty() || from_pile.cards.size() < amount:
		print("no card in draw pile, reshuflling from discard pile..")
		await discard_pile.move_all_to(from_pile, 0)
		print("reshuflling done")
		draw_pile.shuffle()
	await from_pile.deal_to(to_hand, amount, 0.4, 0.1)
	
# PRINT N DISPLAY	

func print_money():
	money_label.text = "Uang: " + str(CURRENT_MONEY)
	shop_money_label.text = "Uang: " + str(CURRENT_MONEY)
	
func print_score():
	skor_label.text = "Skor: " + str(CURRENT_SCORE)
	
func print_lives():
	health_label.text = "Health: " + str(CURRENT_LIVES)
	
func print_diff():
	diff_label.text = "Diff: " + str(CURRENT_DIFFICULTY)
	
func print_player_stats():
	print_money()
	print_lives()
	print_score()
	print_diff()
	
func discard_card(card: Card):
	await card.move_to(discard_pile, 1)
	
#func _on_play_pressed():
	#_sum_stats()
	#evaluate_meal()

func substract_money(amount: int):
	if CURRENT_MONEY < amount:
		return
	CURRENT_MONEY -= amount
	
func increase_difficulty():
	if CURRENT_SCORE >= NEXT_DIFF_SCORE:
		CURRENT_DIFFICULTY += 1
		NEXT_DIFF_SCORE += 1000
	generate_target()
			
#func adjust_target():
	#TARGET_KARBO += 5 * CURRENT_DIFFICULTY
	#TARGET_PROTEIN += 5 * CURRENT_DIFFICULTY
	#TARGET_VITAMIN += 5 * CURRENT_DIFFICULTY
	#MAX_GULA += 5 * CURRENT_DIFFICULTY
	#MAX_LEMAK += 5 * CURRENT_DIFFICULTY
	
func generate_target():
	TARGET_KARBO = randi_range(10, 20) + (CURRENT_DIFFICULTY * 5)
	TARGET_PROTEIN = randi_range(10, 20) + (CURRENT_DIFFICULTY * 5)
	TARGET_VITAMIN = randi_range(5, 15) + (CURRENT_DIFFICULTY * 5)

	MAX_GULA = max(20, 30 - CURRENT_DIFFICULTY)
	MAX_LEMAK = max(20, 30 - CURRENT_DIFFICULTY)
	
#func _sum_stats():
	#CURRENT_HARGA = 0
	#CURRENT_KARBO = 0
	#CURRENT_PROTEIN = 0
	#CURRENT_VITAMIN = 0
	#CURRENT_GULA = 0
	#CURRENT_LEMAK = 0
	#
	#var daftar_powerup = []
	#var daftar_makanan = []
#
	#for slot in card_slots:
		#if slot.is_empty(): 
			#continue
#
		#var data = slot.get_card_at(0).card_data as FoodCardResource
		#if data.kategori == FoodCardResource.Kategori.POWERUP:
			#daftar_powerup.append(data)
		#else:
			#daftar_makanan.append(data.card_name.to_lower())
			#CURRENT_HARGA 		+= data.harga
			#CURRENT_KARBO 		+= data.karbohidrat
			#CURRENT_PROTEIN 	+= data.protein
			#CURRENT_VITAMIN 	+= data.vitamin
			#CURRENT_GULA 		+= data.gula
			#CURRENT_LEMAK 		+= data.lemak
	#
	#daftar_powerup.sort_custom(func(a, b): return a.power_up < b.power_up)
#
	#for powerup in daftar_powerup:
		#match powerup.power_up:
			#FoodCardResource.Powerup.DOUBLE_COINS:
				#CURRENT_MONEY *= 2
			#FoodCardResource.Powerup.CLEAN_SUGAR:
				#CURRENT_GULA = 0
			#FoodCardResource.Powerup.CLEAN_FAT:
				#CURRENT_LEMAK = 0
			#FoodCardResource.Powerup.SUPPLEMENT:
				#CURRENT_VITAMIN = int(CURRENT_VITAMIN * 1.5)
			#FoodCardResource.Powerup.REHEAT:
				#CURRENT_MONEY = int(CURRENT_MONEY * 1.5)
				#CURRENT_KARBO += 20
			#FoodCardResource.Powerup.DOUBLE_CARBS:
				#CURRENT_KARBO *= 2
			#FoodCardResource.Powerup.OVERCOOK:
				#CURRENT_GULA = 0
				#CURRENT_LEMAK = 0
				#CURRENT_KARBO = int(CURRENT_KARBO * 0.75)
				#CURRENT_PROTEIN = int(CURRENT_PROTEIN * 0.75)
				#CURRENT_VITAMIN = int(CURRENT_VITAMIN * 0.75)
			#FoodCardResource.Powerup.SEAFOOD_BOOST:
				#if "seafood" in daftar_makanan:
					#CURRENT_PROTEIN = int(CURRENT_PROTEIN * 1.2)
			#FoodCardResource.Powerup.KETO_DIET:
				#if CURRENT_KARBO >= 20:
					#CURRENT_PROTEIN *= 2
			#FoodCardResource.Powerup.PERFECT_BALANCE:
				#if CURRENT_GULA == 0 and CURRENT_LEMAK == 0:
					#CURRENT_KARBO += 20
					#CURRENT_PROTEIN += 20
					#CURRENT_VITAMIN += 20
					#CURRENT_MONEY *= 2
#
	#stat_panel.get_node("StatsSummaryContainer/Harga").text = "Harga: " + str(CURRENT_HARGA)
	#stat_panel.get_node("StatsSummaryContainer/Karbohidrat").text = "Karbo: " + str(CURRENT_KARBO)
	#stat_panel.get_node("StatsSummaryContainer/Protein").text = "Protein: " + str(CURRENT_PROTEIN)
	#stat_panel.get_node("StatsSummaryContainer/Vitamin").text = "Vitamin: " + str(CURRENT_VITAMIN)
	#stat_panel.get_node("StatsSummaryContainer/Gula").text = "Gula: " + str(CURRENT_GULA)
	#stat_panel.get_node("StatsSummaryContainer/Lemak").text = "Lemak: " + str(CURRENT_LEMAK)


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

func show_details(card: Card):
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
		
func show_shop_details(card: Card):
	var data = card.card_data as FoodCardResource
	if data:
		shop_card_detail_panel.get_node("CardDetailContainer/Nama").text = "Nama: " + data.card_name
		shop_card_detail_panel.get_node("CardDetailContainer/Kategori").text = "Kategori: " + str(data.kategori)
		shop_card_detail_panel.get_node("CardDetailContainer/Harga").text = "Harga: " + str(data.harga)	
		shop_card_detail_panel.get_node("CardDetailContainer/Karbohidrat").text = "Karbo: " + str(data.karbohidrat)
		shop_card_detail_panel.get_node("CardDetailContainer/Protein").text = "Protein: " + str(data.protein)
		shop_card_detail_panel.get_node("CardDetailContainer/Vitamin").text = "Vitamin: " + str(data.vitamin)
		shop_card_detail_panel.get_node("CardDetailContainer/Lemak").text = "Lemak: " + str(data.lemak)
		shop_card_detail_panel.get_node("CardDetailContainer/Gula").text = "Gula: " + str(data.gula)
		
func get_active_buffs() -> Array:
	var buffs = []
	for slot in buff_slots:
		if slot.is_empty():
			continue
		var data = slot.get_card_at(0).card_data as FoodCardResource
		buffs.append(data)
	return buffs
	
func apply_buffs(stats: MealStats):
	var buffs = get_active_buffs()
	for buff in buffs:
		match buff.power_up:
			FoodCardResource.Powerup.DOUBLE_CARBS:
				stats.karbohidrat *= 2
			FoodCardResource.Powerup.CLEAN_SUGAR:
				stats.gula = 0
				
func _set_ui_disabled(enabled: bool) -> void:
	stat_panel.visible = !enabled
	target_panel.visible = !enabled
	ompreng.visible = !enabled
	button_container.visible = !enabled
	detail_panel.visible = !enabled
	discard_pile.visible = !enabled
	draw_pile.visible = !enabled
	trash_slot.visible = !enabled
	buff_container.visible = !enabled
	for slot in card_slots:
		if enabled: slot.lock()
		else: slot.unlock()
	for slot in buff_slots:
		if enabled: slot.lock()
		else: slot.unlock()
	if enabled: trash_slot.lock()
	else: trash_slot.unlock()
		
func clear_shop():
	for card in shop_hand.cards:
		card.move_to(discard_pile)
		
func refresh_shop():
	if CURRENT_MONEY < 5:
		print("duit abis")
		return
	clear_shop()
	substract_money(REFRESH_COST)
	print_money()
	update_refresh_button()
	draw_card(SHOP_DRAW_SIZE, draw_pile, shop_hand)
	
func update_play_button():
	var has_card = false
	for slot in card_slots:
		if !slot.is_empty():
			has_card = true
			break
	play_button.disabled = !has_card
	
func update_refresh_button():
	var has_enough_money = false
	if CURRENT_MONEY >= 5:
		has_enough_money = true
	refresh_shop_button.disabled = !has_enough_money
	
func add_card_to_selected(card: Card):
	selected_shop_card = card
	
func open_shop():
		shop_panel.show()
		clear_shop()
		draw_card(SHOP_DRAW_SIZE, draw_pile, shop_hand)
		_set_ui_disabled(true)
		print_money()
	

#func _process(delta: float) -> void:
	#pass
