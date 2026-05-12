@tool
extends CardLayout

@onready var template_image = %Template
@onready var nama_label = %Nama
@onready var art_image = %Image
@onready var harga_label = %Harga

@onready var border = %Border

@onready var karbo_label = %Karbohidrat
@onready var protein_label = %Protein
@onready var lemak_label = %Lemak
@onready var gula_label = %Gula
@onready var vitamin_label = %Vitamin

func _update_display() -> void:
	var data = card_resource as FoodCardResource
	if not data:
		return
	template_image.texture = data.card_image
	nama_label.text = data.card_name
	harga_label.text = str(data.harga)
	karbo_label.text = str(data.karbohidrat)
	protein_label.text = str(data.protein)
	lemak_label.text = str(data.lemak)
	gula_label.text = str(data.gula)
	vitamin_label.text = str(data.vitamin)
	
func _focus_in() -> void:
	card_instance.tween_scale(Vector2(1.2,1.2), 0.2)
	#border.visible = true

func _focus_out() -> void:
	card_instance.tween_scale(Vector2(1,1), 0.2)
	#border.visible = false
	
