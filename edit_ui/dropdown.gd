extends OptionButton


@export var value_connect: String
enum UseableEnums {
	TYPES,
	COMPANION_TYPES,
	COLORS,
	MOVE_CATEGORY
}
var useable_enums: Dictionary = {
	UseableEnums.TYPES: AmorosData.AmorosType,
	UseableEnums.COMPANION_TYPES: AmorosData.AmorosCompanionType,
	UseableEnums.COLORS: Creator.ColorSet,
	UseableEnums.MOVE_CATEGORY: AmorosData.AmorosMoveCategory,
}

@export var dropdowntype: UseableEnums


func _ready() -> void:
	var used_enum = useable_enums[dropdowntype]
	for key in used_enum.keys():
		add_item(key, used_enum[key])


func _on_item_selected(index: int) -> void:
	get_tree().current_scene.set(value_connect, index)
