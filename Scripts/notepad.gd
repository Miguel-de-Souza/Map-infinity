extends TextEdit


func _on_text_changed() -> void:
	Global.alteraction()


func _on_focus_entered() -> void:
	Global.not_atalho = true


func _on_focus_exited() -> void:
	Global.not_atalho = false
