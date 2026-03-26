extends Node

var font_size_default := 16
var font_size_title_default := 16
var var_check_ajust:= false
var changed := false
var stop_unsave := false
var selected_nodes := 0

func alteraction():
	if not Global.changed:
		Global.changed = true
		

func sem_alteraction():
	if Global.changed:
		Global.changed = false
		Global.stop_unsave = false
