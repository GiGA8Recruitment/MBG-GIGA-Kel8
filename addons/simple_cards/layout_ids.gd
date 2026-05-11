# AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
# This file is regenerated when layouts are modified in the Card Layouts panel

class_name LayoutID

const CUSTOM_FOOD_LAYOUT: StringName = &"custom_food_layout"
const DEFAULT: StringName = &"default"
const DEFAULT_BACK: StringName = &"default_back"
const FOOD_LAYOUT: StringName = &"food_layout"
const STANDARD_BACK_LAYOUT: StringName = &"standard_back_layout"
const STANDARD_LAYOUT: StringName = &"standard_layout"


## Returns all available layout IDs
static func get_all() -> Array[StringName]:
	return [
		CUSTOM_FOOD_LAYOUT,
		DEFAULT,
		DEFAULT_BACK,
		FOOD_LAYOUT,
		STANDARD_BACK_LAYOUT,
		STANDARD_LAYOUT
	]


## Check if a layout ID is valid
static func is_valid(id: StringName) -> bool:
	return id in get_all()