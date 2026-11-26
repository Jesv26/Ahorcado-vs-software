extends Node2D

@onready var game_end_screen: PanelContainer = $GameUI/GameEndScreen
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var answer_preview: HBoxContainer = $GameUI/PlayerUI/MarginContainer/AnswerPreview/HBoxContainer

@onready var guess_input: LineEdit = $GameUI/PlayerUI/MarginContainer/LetterOptions/GuessBox/GuessInput
@onready var guess_button: Button = $GameUI/PlayerUI/MarginContainer/LetterOptions/GuessBox/GuessButton

@onready var continue_button: Button = $GameUI/ContinuePanel/PanelContainer/MarginContainer/VBoxContainer/ContinueButton
@onready var exit_button: Button = $GameUI/ContinuePanel/PanelContainer/MarginContainer/VBoxContainer/ExitButton

@export var character_slot: PackedScene
@export var level_label: Label
@export var question_space: Label

var lives: int = 5
var level: int = 0

var word_letters: Array[String] = []
var character_slots: Array[Label] = []
var revealed_letters: Array[bool] = []

var awaiting_next_question: bool = false

func _ready() -> void:
	lives = 5
	level = 0
	
	Global.picked_letter.connect(_on_picked_letter)
	Global.time_up.connect(_on_time_up)
	QuestionManager.game_completed.connect(_on_game_completed)
	
	exit_button.pressed.connect(_on_button_exit_pressed)
	
	QuestionManager.start_game()
	if not QuestionManager.get_current_question().is_empty():
		start_round()

func start_round() -> void:
	level += 1
	awaiting_next_question = false
	
	var difficulty_names = ["Fácil", "Intermedio", "Difícil"]
	var difficulty_name = difficulty_names[QuestionManager.current_difficulty]
	
	$GameUI/PlayerUI/MarginContainer/Label.text = "Nivel " + str(level) + " - " + difficulty_name
	$GameUI/ContinuePanel.visible = false
	guess_input.clear()
	guess_input.editable = true
	guess_button.disabled = false
	Global.reset_letters.emit()
	lives = 5
	get_question()
	Global.round_start.emit()

# Loads the current question and creates its character slots
func get_question() -> void:
	var question = QuestionManager.get_current_question()
	
	if question.is_empty():
		return
	
	question_space.text = str(question["pregunta"])
	var answer = str(question["respuesta"]).strip_edges().to_upper()
	word_letters.clear()
	character_slots.clear()
	revealed_letters.clear()
	
	# Remove previous character slots
	for child in answer_preview.get_children():
		child.queue_free()
	
	# Create one slot for each character
	for i in range(answer.length()):
		var character = answer.substr(i, 1)
		word_letters.append(character)
		var slot_instance = character_slot.instantiate()
		var slot_label: Label = slot_instance as Label
		# If the root isn't a Label, find the child Label
		if slot_label == null:
			slot_label = slot_instance.get_node_or_null("charcterslot") as Label
		
		if slot_label == null:
			push_error("CharacterSlot scene must contain a Label named charcterslot.")
			slot_instance.queue_free()
			continue
		
		answer_preview.add_child(slot_instance)
		character_slots.append(slot_label)
		# Spaces are revealed automatically
		if character == " ":
			slot_label.text = " "
			revealed_letters.append(true)
		else:
			slot_label.text = "_"
			revealed_letters.append(false)

func _on_picked_letter(answer: String) -> void:
	if awaiting_next_question:
		return
	
	if answer.strip_edges().is_empty():
		update_lives(-1)
		return
	
	animation_player.play("block")
	_reveal_character(answer)

# Reveals matching characters
func _reveal_character(answer: String) -> void:
	var selected = answer.strip_edges().to_upper()
	var full_word = "".join(word_letters)
	# Check if the player guessed the entire word
	if selected == full_word:
		for i in range(word_letters.size()):
			character_slots[i].text = word_letters[i]
			revealed_letters[i] = true
		
		_complete_question()
		return
	
	# Check if the player selected a single letter
	if selected.length() != 1:
		_wrong_answer()
		return
	
	var found = false
	
	for i in range(word_letters.size()):
		if word_letters[i] == selected:
			found = true
			
			if not revealed_letters[i]:
				character_slots[i].text = word_letters[i]
				revealed_letters[i] = true
	
	# Incorrect letter
	if not found:
		_wrong_answer()
		return
	
	# Check whether all characters have been revealed
	if _is_word_complete():
		_complete_question()

# Checks whether all letters have been revealed
func _is_word_complete() -> bool:
	for revealed in revealed_letters:
		if not revealed:
			return false
	return true

# Handles a wrong answer
func _wrong_answer() -> void:
	update_lives(-1)

# Called when the player completes the current word
func _complete_question() -> void:
	if awaiting_next_question:
		return
	
	Global.round_over.emit()
	awaiting_next_question = true
	guess_input.editable = false
	guess_button.disabled = true
	
	QuestionManager.resolve_current_question()
	
	# Check if another question is available
	if not QuestionManager.get_current_question().is_empty():
		$GameUI/ContinuePanel.visible = true
		#start_round()

func _on_game_completed() -> void:
	end_screen("¡Has completado todas las preguntas!")

func _on_time_up() -> void:
	if awaiting_next_question:
		return
	
	update_lives(-1)

func update_lives(value: int)-> void:
	lives += value
	if value < 0:
		$AnimationPlayer.play("wrong_shake")
	if lives <= 0:
		Global.round_over.emit()
		end_screen("Fin de la partida.")
		#Musica de game over
	$CharacterSprites.frame = clamp(5 - lives, 0, 5)

func end_screen(text: String) -> void:
	$GameUI/ContinuePanel.visible = false
	guess_input.editable = false
	guess_button.disabled = true
	$GameUI/GameEndScreen/Label.text = text
	game_end_screen.visible = true

func _on_guess_button_pressed() -> void:
	if awaiting_next_question:
		return
	
	var answer = guess_input.text.strip_edges()
	
	if answer.is_empty():
		return
	
	guess_input.clear()
	_reveal_character(answer)

func _on_button_restart_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().reload_current_scene()

func _on_continue_button_pressed() -> void:
	if not awaiting_next_question:
		return
	
	start_round()

func _on_button_exit_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")
