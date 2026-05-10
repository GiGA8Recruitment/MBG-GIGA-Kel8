@tool
class_name FoodCardResource extends CardResource

@export var card_name:String =""
@export var card_image: Texture2D

enum Kategori {KARBOHIDRAT, PROTEIN, VITAMIN, PELENGKAP}

@export var kategori: Kategori
@export var harga:int
@export var karbohidrat:int
@export var protein:int
@export var lemak:int
@export var gula:int
@export var vitamin:int
