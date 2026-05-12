@tool
class_name FoodCardResource extends CardResource

@export var card_name:String =""
@export_enum("Karbo", "Protein", "Sayur", "Pelengkap", "Powerup") var category: String
@export var card_image: Texture2D
@export var art_image: Texture2D = null

enum Kategori {KARBOHIDRAT, PROTEIN, VITAMIN, PELENGKAP}
enum Rarity {COMMON, UNCOMMON, RARE, SPECIAL, LEGEND, MYTHIC}

@export var kategori: Kategori
@export var rarity: Rarity
@export var harga:int
@export var karbohidrat:int
@export var protein:int
@export var lemak:int
@export var gula:int
@export var vitamin:int	
