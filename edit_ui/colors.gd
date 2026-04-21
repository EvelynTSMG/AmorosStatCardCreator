extends ColorPickerButton


@export var value_connect: String


func _on_color_changed(colorpicked: Color) -> void:
	get_tree().current_scene.set(value_connect, colorpicked)
