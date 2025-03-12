extends Control

func show_menu():
	visible = true
	get_tree().paused = true

func _on_HomeBtn_pressed():
	visible = false
	get_tree().paused =false
	get_tree().change_scene("res://Menu.tscn")

func _on_QuitBtn_pressed():
	get_tree().quit()
