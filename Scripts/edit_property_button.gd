extends Button

@export var propert: Window

func _on_pressed() -> void:
	if propert.visible:
		propert.hide()
	
	else:
		propert.show()
