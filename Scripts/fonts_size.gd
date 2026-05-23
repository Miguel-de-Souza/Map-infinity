extends SpinBox

@export var texts: Control

func _on_value_changed(_value: float) -> void:
	texts.add_theme_font_size_override("font_size", int(_value))
	Global.alteraction()

func _on_mouse_entered() -> void:
	Global.yes_focus = true

func _on_mouse_exited() -> void:
	Global.yes_focus = false
