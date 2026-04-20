extends Button


@export var value_connect : String


func _on_toggled(toggled_on: bool) -> void:
	get_tree().current_scene.set(value_connect, toggled_on)
