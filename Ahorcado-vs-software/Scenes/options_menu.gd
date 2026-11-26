
extends MarginContainer

@export var master_slider: HSlider
@export var master_percent: Label
@export var music_slider: HSlider
@export var music_percent: Label
@export var effects_slider: HSlider
@export var effects_percent: Label


func _ready() -> void:
	master_slider.value_changed.connect(on_master_value_changed)
	master_slider.drag_ended.connect(on_master_drag_ended)
	
	music_slider.value_changed.connect(on_music_value_changed)
	music_slider.drag_ended.connect(on_music_drag_ended)
	
	effects_slider.value_changed.connect(on_effects_value_changed)
	effects_slider.drag_ended.connect(on_effects_drag_ended)
	
	load_volume_settings()

func on_master_value_changed(value: float) -> void:
	master_percent.text = str(int(value)) + "%"
	GameData.preview_volume("volume_master", value / 100.0)

func on_master_drag_ended(_value: bool) -> void:
	GameData.change_volume("volume_master", master_slider.value / 100.0)

func on_music_value_changed(value: float) -> void:
	music_percent.text = str(int(value)) + "%"
	GameData.preview_volume("volume_music", value / 100.0)

func on_music_drag_ended(_value: bool) -> void:
	GameData.change_volume("volume_music", music_slider.value / 100.0)

func on_effects_value_changed(value: float) -> void:
	effects_percent.text = str(int(value)) + "%"
	GameData.preview_volume("volume_effects", value / 100.0)

func on_effects_drag_ended(_value: bool) -> void:
	GameData.change_volume("volume_effects", effects_slider.value / 100.0)

func load_volume_settings() -> void:
	master_slider.value = GameData.get_volume("volume_master") * 100
	music_slider.value = GameData.get_volume("volume_music") * 100
	effects_slider.value = GameData.get_volume("volume_effects") * 100
	
	master_percent.text = str(int(master_slider.value)) + "%"
	music_percent.text = str(int(music_slider.value)) + "%"
	effects_percent.text = str(int(effects_slider.value)) + "%"
