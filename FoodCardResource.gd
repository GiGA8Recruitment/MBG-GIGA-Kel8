@tool
class_name FoodCardResource extends CardResource

@export var card_name:String =""
@export_enum("Karbo", "Protein", "Sayur", "Pelengkap", "Powerup") var category: String
@export var card_image: Texture2D

@export var harga:int
@export var karbohidrat:int
@export var protein:int
@export var lemak:int
@export var gula:int
@export var vitamin:int
