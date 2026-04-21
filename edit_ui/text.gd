extends LineEdit


@export var value_connect: String
@export var is_numeric: bool

func _on_text_changed(new:String) -> void:
	if is_numeric:
		if !text:
			get_tree().current_scene.set(value_connect, 0)
		elif text.is_valid_int():
			get_tree().current_scene.set(value_connect, int(new))
		return
	get_tree().current_scene.set(value_connect, new)
