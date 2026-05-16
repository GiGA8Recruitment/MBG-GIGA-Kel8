@tool
class_name BaseCardResource extends CardResource

enum Rarity {COMMON, RARE, SPECIAL}

@export var card_name:String =""
@export var card_image: Texture2D
@export var harga: int
@export var rarity: Rarity
