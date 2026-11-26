extends Control

func _ready() -> void:
	$MainSelect.visible = true
	$OptionsMenu.visible = false

func _on_button_play_pressed() -> void:
	$AnimationPlayer.play("screen_fade")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_button_options_pressed() -> void:
	$MainSelect.visible = false
	$OptionsMenu.visible = true

func _on_button_back_pressed() -> void:
	$MainSelect.visible = true
	$OptionsMenu.visible = false

func _on_button_exit_pressed() -> void:
	$AnimationPlayer.play("screen_fade")
	await $AnimationPlayer.animation_finished
	get_tree().quit()
