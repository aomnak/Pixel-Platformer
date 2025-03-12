extends Control

var is_paused = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused


func _on_ResumeBtn_pressed():
	print("resumeBtn")
	self.is_paused = false


func _on_RestartBtn_pressed():
	print("restartBtn")
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_QuitBtn_pressed():
	print("quitBtn")
	get_tree().quit()
