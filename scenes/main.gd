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

@onready var draw_pile 		= %DrawPile
@onready var discard_pile 	= %DiscardPile
@onready var trash_slot 	= %TrashSlot
@onready var ompreng 		= %Ompreng

@onready var detail_panel 	= %CardDetailPanel
@onready var stat_panel 	= %StatsSummaryPanel
@onready var target_panel	= %TargetPanel

@onready var play_button	= %PlayButton
@onready var shop_button	= %ShopButton

@onready var money_label	= %MoneyLabel
@onready var skor_label		= %SkorLabel
@onready var health_label	= %HealthLabel

@onready var shop_panel 	= %ShopPanel

@onready var game_over_panel = %GameOverPanel
@onready var try_again_button = %TryAgainButton
@onready var exit_button = %ExitButton

# TARGET

@onready var TARGET_KARBO 	= 10
@onready var TARGET_PROTEIN = 10
@onready var TARGET_VITAMIN = 10
@onready var MAX_LEMAK	 	= 50
@onready var MAX_GULA 		= 50

# CURRENT GIZI

var current_stats := MealStats.new()

# STATE

enum GameState {
	SHOP,
	PREPARE,
	EVALUATE,
	GAME_OVER
}

# CONST

const STARTING_HAND_SIZE = 8
const DRAW_SIZE = 5

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

	shop_panel.shop_closed.connect(next_round)
	shop_panel.card_bought.connect(_on_card_bought_from_shop)
	shop_panel.shop_updated.connect(print_money)

	try_again_button.pressed.connect(_on_try_again_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_card_added(card: Card, _index: int):
	card.is_front_face = true
	card.card_clicked.connect(show_details)
	card.drag_started.connect(show_details)
	
func _on_card_back_to_hand(card: Card):
	card.move_to(player_hand)
	current_stats = StatCalculator.calculate(card_slots)
	stat_panel.display(current_stats)
	
#func _on_card_dropped(card: Card):
	#_sum_stats()
	#play_button.disabled = false
	
func _on_card_dropped(card: Card):
	detail_panel.hide()
	current_stats = StatCalculator.calculate(card_slots)
	stat_panel.display(current_stats)
	play_button.disabled = false

#func _on_card_back_to_hand(card: Card):
	#card.move_to(player_hand)
	#_sum_stats()
	
func _on_card_dropped_on_trash_slot(card: Card):
	detail_panel.hide()
	var data = card.card_data as FoodCardResource
	if data:
		# Hitung refund 50% dari harga kartu
		var refund = int(data.harga * 0.5)
		RoundManager.current_money += refund
		
		# Hapus kartu secara permanen
		card.queue_free()
		
		print_money()
		print("Kartu dijual: +" + str(refund))
	
func _on_shop_pressed():
	if shop_panel.visible:
		close_shop()
		return
	open_shop()
	
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
	
#func evaluate_meal():
	#var success = true
	#var failed_reasons = []
#
	#if CURRENT_KARBO < TARGET_KARBO:
		#success = false
		#failed_reasons.append("Karbo kurang")
#
	#if CURRENT_PROTEIN < TARGET_PROTEIN:
		#success = false
		#failed_reasons.append("Protein kurang")
#
	#if CURRENT_VITAMIN < TARGET_VITAMIN:
		#success = false
		#failed_reasons.append("Vitamin kurang")
#
	#if CURRENT_GULA > MAX_GULA:
		#success = false
		#failed_reasons.append("Gula terlalu tinggi")
#
	#if CURRENT_LEMAK > MAX_LEMAK:
		#success = false
		#failed_reasons.append("Lemak terlalu tinggi")
#
	#if success:
		#round_success()
	#else:
		#round_failed(failed_reasons)
		#
func round_success():
	var old_difficulty = RoundManager.current_difficulty
	RoundManager.round_success()
	
	if RoundManager.current_difficulty > old_difficulty:
		adjust_target()

	print_money()
	print_score()
	print_lives()
	display_target()

	clear_board()
	open_shop()
	
func round_failed(reasons: Array):
	RoundManager.round_failed(reasons)
	
	print_lives()
	print_money()
	print_score()
	clear_board()

	if RoundManager.is_game_over():
		game_over() # Panel Game Over muncul dan tombol interaksi mati
	else:
		open_shop()
		
func next_round():
	ompreng.show()
	clear_board()
	# draw_card(5)

func clear_board():
	for slot in card_slots:

		if slot.is_empty():
			continue

		var card = slot.get_card()
		card.move_to(discard_pile)
	
func display_target():
	target_panel.get_node("TargetContainer/Karbohidrat").text = "Karbohidrat: " + str(TARGET_KARBO)
	target_panel.get_node("TargetContainer/Protein").text = "Protein: " + str(TARGET_PROTEIN)
	target_panel.get_node("TargetContainer/Vitamin").text = "Vitamin: " + str(TARGET_VITAMIN)
	target_panel.get_node("TargetContainer/Lemak").text = "Lemak: " + str(MAX_LEMAK)
	target_panel.get_node("TargetContainer/Gula").text = "Gula: " + str(MAX_GULA)


	

	
func return_money(card: Card):
	var data = card.card_data as FoodCardResource
	RoundManager.current_money += int(data.harga / 2)

func draw_starting_hand():
	await draw_pile.deal_to(player_hand, STARTING_HAND_SIZE, 0.4, 0.1)
	print(draw_pile.cards)
	

	
func open_shop():
	shop_panel.show()
	shop_panel.player_hand_ref = player_hand
	shop_panel.open_shop(food_deck_manager.deck)
	ompreng.hide()

func _on_card_bought_from_shop(card: Card):
	card.move_to(player_hand)
	print_money()

func close_shop():
	shop_panel.hide()
	ompreng.show()
	
func draw_card(amount) -> void:
	if draw_pile.is_empty():
		print("no card in draw pile")
		await discard_pile.move_all_to(draw_pile, 0)
		draw_pile.shuffle()
	await draw_pile.deal_to(player_hand, amount, 0.3)
	
# PRINT N DISPLAY	

func print_money():
	money_label.text = "Uang: " + str(RoundManager.current_money)
	
func print_score():
	skor_label.text = "Skor: " + str(RoundManager.current_score)
	
func print_lives():
	health_label.text = "Health: " + str(RoundManager.current_lives)
	
func discard_card(card: Card):
	card.move_to(discard_pile)
	
#func _on_play_pressed():
	#draw_card()
	
#func _on_play_pressed():
	#_sum_stats()
	#evaluate_meal()
	

	
func subtract_money(amount: int):
	if RoundManager.current_money < amount:
		return
	RoundManager.current_money -= amount

func increase_difficulty():
	if RoundManager.current_score >= RoundManager.next_diff_score:
		RoundManager.current_difficulty += 1
		RoundManager.next_diff_score += 1000
	adjust_target()
		
func adjust_target():
	TARGET_KARBO += 5 * RoundManager.current_difficulty
	TARGET_PROTEIN += 5 * RoundManager.current_difficulty
	TARGET_VITAMIN += 5 * RoundManager.current_difficulty
	MAX_GULA += 5 * RoundManager.current_difficulty
	MAX_LEMAK += 5 * RoundManager.current_difficulty


	
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
		detail_panel.show()
		
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

#func _process(delta: float) -> void:
	#pass

func game_over():
	game_over_panel.show()
	print("GAME OVER")
	print("Final Score: ", RoundManager.current_score)
	
	play_button.disabled = true
	shop_button.disabled = true

func _on_try_again_pressed():
	RoundManager.current_score = 0
	RoundManager.current_money = 100
	RoundManager.current_lives = 3
	RoundManager.current_difficulty = 1

	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()
