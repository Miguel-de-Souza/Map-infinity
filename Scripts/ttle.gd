extends LineEdit

func _on_text_changed(_new_text: String) -> void:
	Global.alteraction()

func _on_focus_entered() -> void:
	Global.not_atalho = true

func _on_focus_exited() -> void:
	Global.not_atalho = false
