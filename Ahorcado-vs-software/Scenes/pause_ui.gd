extends Control

@onready var panel_pause: PanelContainer = $PanelPause
@onready var pause_menu: MarginContainer = $PanelPause/PauseMenu
@onready var options_menu: MarginContainer = $PanelPause/OptionsMenu
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func _ready() -> void:
	panel_pause.visible = false
	pause_menu.visible = true
	options_menu.visible = false

func _on_pause_button_pressed() -> void:
	panel_pause.visible = true

func _on_button_continue_pressed() -> void:
	panel_pause.visible = false

func _on_button_options_pressed() -> void:
	pause_menu.visible = false
	options_menu.visible = true

func _on_button_exit_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")

func _on_button_back_pressed() -> void:
	pause_menu.visible = true
	options_menu.visible = false
