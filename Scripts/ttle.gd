extends LineEdit


func _on_text_changed(_new_text: String) -> void:
	Global.alteraction()
