extends TextEdit


func _on_text_changed() -> void:
	Global.alteraction()


func _on_focus_entered() -> void:
	print("Help")
