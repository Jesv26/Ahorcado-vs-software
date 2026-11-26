extends TextureProgressBar

var current_max_time: float = 25.0
var timer_active: bool  = false
var timer: float

var auto_start_active: bool = true
var auto_starting_timer: float = 3
var auto_start_timer: float

func _ready() -> void:
	Global.picked_letter.connect(_on_picked_letter)
	Global.round_start.connect(_on_round_start)
	Global.round_over.connect(_on_round_over)
	reset_timer(current_max_time, 0.0)
	start_timer()

func _process(delta: float) -> void:
	if timer_active:
		self.value = timer
		$TimerAnimationPlayer.speed_scale = remap(timer,0,current_max_time,2.5,0.5)
		timer -= delta
		if timer / current_max_time <= 0.25:
			self_modulate = Color.RED
		else:
			self_modulate = Color.WHITE
		if timer <= 0:
			timer_active = false
			$TimerAnimationPlayer.play("time_out")
			Global.time_up.emit()
			await $TimerAnimationPlayer.animation_finished
			reset_timer(current_max_time, delta)

func start_timer() -> void:
	timer_active = true
	$TimerAnimationPlayer.play("active")

func reset_timer(time: float, delta: float) -> void:
	$TimerAnimationPlayer.stop()
	self_modulate = Color.WHITE
	current_max_time = time
	timer = time
	self.max_value = time
	self.value = time
	
	if auto_start_active:
		if auto_start_timer <= auto_starting_timer:
			auto_start_timer = 0
			start_timer()
		else:
			auto_start_timer += delta
		

func _on_picked_letter(_answer: String) -> void:
	reset_timer(current_max_time, 0.0)

func _on_round_start() -> void:
	auto_start_active = true
	
	reset_timer(current_max_time, 0.0)

func _on_round_over() -> void:
	auto_start_active = false
	timer_active = false
	reset_timer(current_max_time, 0.0)
