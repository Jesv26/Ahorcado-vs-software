
extends Node

signal question_changed(question: Dictionary, number: int, total: int)
signal difficulty_changed(difficulty: int)
signal game_completed

enum Dificultad { FACIL, INTERMEDIO, DIFICIL}

const QUESTIONS_PER_DIFFICULTY = 5
const QUESTION_FILES = {
	Dificultad.FACIL: "res://questions/facil.json",
	Dificultad.INTERMEDIO: "res://questions/intermedio.json",
	Dificultad.DIFICIL: "res://questions/dificil.json"
}

var current_difficulty: int = -1
var question_pool: Array = []
var question_index: int = 0

func start_game() -> void:
	current_difficulty = -1
	question_pool.clear()
	question_index = 0
	load_next_difficulty()

func load_next_difficulty() -> void:
	current_difficulty += 1
	
	while current_difficulty <= Dificultad.DIFICIL:
		# Toma y mezcla las preguntas para la partida
		var available_questions = load_questions(current_difficulty)
		available_questions.shuffle()
		var selected_count = min(QUESTIONS_PER_DIFFICULTY,available_questions.size())
		question_pool = available_questions.slice(0, selected_count)
		question_index = 0
		
		if not question_pool.is_empty():
			difficulty_changed.emit(current_difficulty)
			show_current_question()
			return
		
		current_difficulty += 1
	
	game_completed.emit()

func load_questions(difficulty: int) -> Array:
	if not QUESTION_FILES.has(difficulty):
		push_error("Difficulty file not found.")
		return []
	
	var path = QUESTION_FILES[difficulty]
	
	if not FileAccess.file_exists(path):
		push_error("Question file does not exist: " + path)
		return []
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("Could not open question file: " + path)
		return []
	
	var contents = file.get_as_text()
	file.close()
	var json = JSON.new()
	var result = json.parse(contents)
	
	if result != OK:
		push_error("Invalid JSON: " + path)
		return []
	
	if not json.data is Array:
		push_error("Question file must contain an Array.")
		return []
	
	var valid_questions = []
	
	for question in json.data:
		
		if not question is Dictionary:
			continue
		
		if not question.has("id"):
			continue
		
		if not question.has("pregunta"):
			continue
		
		if not question.has("respuesta"):
			continue
		
		valid_questions.append(question)
	
	return valid_questions

func show_current_question() -> void:
	if question_index >= question_pool.size():
		load_next_difficulty()
		return
	
	var question = question_pool[question_index]
	
	question_changed.emit( question, question_index + 1, question_pool.size())

func get_current_question() -> Dictionary:
	if question_pool.is_empty():
		return {}
	
	if question_index >= question_pool.size():
		return {}
	
	return question_pool[question_index]

func check_answer(answer: String) -> bool:
	var question = get_current_question()
	
	if question.is_empty():
		return false
	
	return str(question["respuesta"]).to_lower() == answer.strip_edges().to_lower()

func resolve_current_question() -> void:
	if get_current_question().is_empty():
		return
	
	question_index += 1
	
	if question_index >= question_pool.size():
		load_next_difficulty()
	else:
		show_current_question()
