extends Button
@export var letter: String

func _ready() -> void:
	self.text = letter
	pressed.connect(on_character_pressed)
	Global.reset_letters.connect(_on_reset_letters)

func on_character_pressed() -> void:
	Global.picked_letter.emit(letter)
	disabled = true

func _on_reset_letters() -> void:
	disabled = false
