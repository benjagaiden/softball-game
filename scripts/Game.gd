extends Node2D

const PITCHES := ["fastball", "riseball", "curveball", "dropball", "screwball"]

var commentary: Node
var field: Node2D
var ball: Node2D
var pitcher: Node2D
var batter: Node2D
var hud: CanvasLayer
var status_label: Label
var pitch_label: Label
var score_label: Label
var count_label: Label
var comment_label: Label
var inning_label: Label
var swing_meter: ProgressBar
var bases_label: Label

var inning := 1
var max_innings := 3
var outs := 0
var balls := 0
var strikes := 0
var bases := [false, false, false]  # [first, second, third]
var score := [0, 0]
var team_name := "RIVERVALE"
var opponent_name := "PINE GROVE"
var current_pitch := "fastball"
var swing_window_active := false
var swing_meter_value := 0.0
var swing_timer := 0.0
var game_over := false
var inning_bottom := false

func _ready() -> void:
	_build_field()
	_build_hud()
	commentary = preload("res://scripts/CommentaryManager.gd").new()
	add_child(commentary)
	_set_commentary("Parents in the bleachers: 'This is the fun part!' ")
	_update_hud()
	_start_pitch_cycle()

func _set_commentary(text: String) -> void:
	if comment_label != null:
		comment_label.text = text

func _build_field() -> void:
	field = Node2D.new()
	add_child(field)

	var grass = ColorRect.new()
	grass.color = Color("2a9d5a")
	grass.position = Vector2.ZERO
	grass.size = Vector2(1280, 720)
	add_child(grass)

	var infield = ColorRect.new()
	infield.color = Color("f0d6a5")
	infield.position = Vector2(440, 150)
	infield.size = Vector2(400, 400)
	add_child(infield)

	var mound = ColorRect.new()
	mound.color = Color("d9c5b2")
	mound.position = Vector2(630, 250)
	mound.size = Vector2(40, 160)
	add_child(mound)

	var plate = ColorRect.new()
	plate.color = Color("f5f1e6")
	plate.position = Vector2(640, 400)
	plate.size = Vector2(16, 16)
	add_child(plate)

	var base_positions := [
		Vector2(640, 150),
		Vector2(1040, 360),
		Vector2(640, 550)
	]

	for i in range(3):
		var base = ColorRect.new()
		base.color = Color("f7f7f7")
		base.position = base_positions[i]
		base.size = Vector2(36, 36)
		add_child(base)

	var pitcher_marker = ColorRect.new()
	pitcher_marker.color = Color("409bd5")
	pitcher_marker.position = Vector2(640, 300)
	pitcher_marker.size = Vector2(12, 12)
	add_child(pitcher_marker)

	pitcher = Node2D.new()
	pitcher.position = Vector2(640, 300)
	add_child(pitcher)

	var pitch_sprite = ColorRect.new()
	pitch_sprite.color = Color("3d7af6")
	pitch_sprite.position = Vector2(-20, -20)
	pitch_sprite.size = Vector2(40, 40)
	pitcher.add_child(pitch_sprite)

	batter = Node2D.new()
	batter.position = Vector2(900, 420)
	add_child(batter)

	var batter_sprite = ColorRect.new()
	batter_sprite.color = Color("c26dff")
	batter_sprite.position = Vector2(-22, -22)
	batter_sprite.size = Vector2(44, 44)
	batter.add_child(batter_sprite)

	ball = Node2D.new()
	ball.position = Vector2(640, 300)
	add_child(ball)

	var ball_sprite = ColorRect.new()
	ball_sprite.color = Color("ffd43b")
	ball_sprite.position = Vector2(-8, -8)
	ball_sprite.size = Vector2(16, 16)
	ball.add_child(ball_sprite)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	var panel = ColorRect.new()
	panel.color = Color(0, 0, 0, 0.38)
	panel.position = Vector2(20, 20)
	panel.size = Vector2(1240, 120)
	hud.add_child(panel)

	inning_label = Label.new()
	inning_label.text = "TOP 1ST"
	inning_label.position = Vector2(40, 30)
	inning_label.add_theme_font_size_override("font_size", 28)
	inning_label.add_theme_color_override("font_color", Color("f5f7ff"))
	hud.add_child(inning_label)

	score_label = Label.new()
	score_label.position = Vector2(40, 70)
	score_label.add_theme_font_size_override("font_size", 26)
	score_label.add_theme_color_override("font_color", Color("ffe66d"))
	hud.add_child(score_label)

	count_label = Label.new()
	count_label.position = Vector2(430, 36)
	count_label.add_theme_font_size_override("font_size", 22)
	count_label.add_theme_color_override("font_color", Color("dfe9ff"))
	hud.add_child(count_label)

	pitch_label = Label.new()
	pitch_label.position = Vector2(430, 80)
	pitch_label.add_theme_font_size_override("font_size", 22)
	pitch_label.add_theme_color_override("font_color", Color("7ae582"))
	hud.add_child(pitch_label)

	bases_label = Label.new()
	bases_label.position = Vector2(750, 36)
	bases_label.add_theme_font_size_override("font_size", 18)
	bases_label.add_theme_color_override("font_color", Color("ffb3ba"))
	hud.add_child(bases_label)

	status_label = Label.new()
	status_label.position = Vector2(900, 34)
	status_label.add_theme_font_size_override("font_size", 22)
	status_label.add_theme_color_override("font_color", Color("f8d7a5"))
	hud.add_child(status_label)

	comment_label = Label.new()
	comment_label.position = Vector2(900, 78)
	comment_label.add_theme_font_size_override("font_size", 18)
	comment_label.add_theme_color_override("font_color", Color("fefefe"))
	comment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	comment_label.custom_minimum_size = Vector2(320, 40)
	hud.add_child(comment_label)

	swing_meter = ProgressBar.new()
	swing_meter.position = Vector2(30, 650)
	swing_meter.size = Vector2(1220, 24)
	swing_meter.min_value = 0.0
	swing_meter.max_value = 1.0
	swing_meter.value = 0.0
	swing_meter.show_percentage = false
	hud.add_child(swing_meter)

func _update_hud() -> void:
	inning_label.text = "TOP %d" % inning if not inning_bottom else "BOT %d" % inning
	score_label.text = "%s %d  -  %s %d" % [team_name, score[0], opponent_name, score[1]]
	count_label.text = "BALLS %d  STRIKES %d  OUTS %d" % [balls, strikes, outs]

	var bases_str := ""
	if bases[0]:
		bases_str += "1B "
	if bases[1]:
		bases_str += "2B "
	if bases[2]:
		bases_str += "3B"
	bases_label.text = "Bases: " + (bases_str if bases_str != "" else "empty")

func _start_pitch_cycle() -> void:
	current_pitch = PITCHES[randi() % PITCHES.size()]
	pitch_label.text = "Pitch: %s" % current_pitch.to_upper()
	swing_window_active = true
	swing_meter.value = 0.0
	swing_timer = 0.0
	status_label.text = "Timing window open"
	commentary.emit("The pitcher winds up on the %s." % current_pitch, "teammate")

func _process(delta: float) -> void:
	if game_over:
		return

	if swing_window_active:
		swing_timer += delta
		swing_meter_value = sin(swing_timer * 6.0) * 0.5 + 0.5
		swing_meter.value = swing_meter_value
		if swing_timer > 2.5:
			swing_window_active = false
			_resolve_pitch_result(false)

	if Input.is_action_just_pressed("toggle_swing"):
		_handle_swing()
	if Input.is_action_just_pressed("next_pitch"):
		_start_pitch_cycle()

func _handle_swing() -> void:
	if not swing_window_active:
		_resolve_pitch_result(false)
		return

	var timing_score: float = absf(swing_meter_value - 0.5)
	var contact_quality := 1.0 - timing_score / 0.5
	if contact_quality > 0.0:
		_resolve_hit(_choose_hit_result(contact_quality))
	else:
		_resolve_pitch_result(false)

func _choose_hit_result(contact_quality: float) -> String:
	var roll := randf()
	var quality := clamp(contact_quality, 0.0, 1.0)

	if quality > 0.85:
		if roll < 0.4:
			return "home_run"
		elif roll < 0.7:
			return "triple"
		return "double"
	elif quality > 0.65:
		if roll < 0.25:
			return "home_run"
		elif roll < 0.55:
			return "triple"
		elif roll < 0.8:
			return "double"
		return "single"
	elif quality > 0.45:
		if roll < 0.2:
			return "double"
		elif roll < 0.5:
			return "single"
		elif roll < 0.75:
			return "ground_ball"
		return "fly_ball"
	else:
		if roll < 0.35:
			return "single"
		elif roll < 0.65:
			return "ground_ball"
		return "fly_ball"

func _resolve_pitch_result(made_contact: bool) -> void:
	swing_window_active = false

	if made_contact:
		_resolve_hit(_choose_hit_result(0.5))
		return

	strikes += 1
	if strikes >= 3:
		outs += 1
		strikes = 0
		balls = 0
		status_label.text = "Strikeout!"
		_set_commentary("A parent in the bleachers says, 'Good hustle, kiddo!' ")
		commentary.emit("The dugout groans but keeps smiling.", "teammate")
	else:
		status_label.text = "Missed it!"
		_set_commentary("The bench chants, 'Keep it moving!' ")

	_update_hud()

	if outs >= 3:
		_advance_inning()
	else:
		_start_pitch_cycle()

func _resolve_hit(hit_type: String) -> void:
	swing_window_active = false
	var hit_strength := 1
	var result_text := ""

	match hit_type:
		"single":
			hit_strength = 1
			result_text = "SINGLE! Runner on first!"
		"double":
			hit_strength = 2
			result_text = "DOUBLE! Ball in the gap!"
		"triple":
			hit_strength = 3
			result_text = "TRIPLE! She's flying around!"
		"home_run":
			hit_strength = 4
			result_text = "HOME RUN! The bleachers erupt!"
		"fly_ball":
			result_text = "Fly ball! Caught for an out."
			outs += 1
			status_label.text = result_text
			_set_commentary("A parent sighs, 'That's baseball.' ")
			_update_hud()
			if outs >= 3:
				_advance_inning()
			else:
				_start_pitch_cycle()
			return
		"ground_ball":
			result_text = "Ground ball! Out at first."
			outs += 1
			status_label.text = result_text
			_set_commentary("A parent says, 'Next time, next time.' ")
			_update_hud()
			if outs >= 3:
				_advance_inning()
			else:
				_start_pitch_cycle()
			return
		_:
			hit_strength = 1
			result_text = "Hit!"

	status_label.text = result_text
	_advance_runners(hit_strength)
	_set_commentary("Teammates are screaming, 'That's a real hit!' ")
	commentary.emit("A parent in the bleachers laughs, 'You can hear this whole town cheering!'", "parent")
	_update_hud()
	_start_pitch_cycle()

func _advance_runners(hit_strength: int) -> void:
	var runs_scored := 0
	var next_bases := [false, false, false]

	if hit_strength >= 4:
		runs_scored += 1 + int(bases[0]) + int(bases[1]) + int(bases[2])
		bases = [false, false, false]
	else:
		for idx in range(2, -1, -1):
			if bases[idx]:
				var destination := idx + hit_strength
				if destination >= 3:
					runs_scored += 1
				else:
					next_bases[destination] = true

		if hit_strength == 1:
			next_bases[0] = true
		elif hit_strength == 2:
			next_bases[1] = true
		elif hit_strength == 3:
			next_bases[2] = true

		bases = next_bases

	score[0] += runs_scored
	if runs_scored > 0:
		commentary.emit("The score updates and the dugout is roaring.", "crowd")
		_set_commentary("Someone in the stands yells, 'There it is! That's why we came!' ")

func _advance_inning() -> void:
	inning_bottom = not inning_bottom

	if inning_bottom:
		inning_label.text = "BOT %d" % inning
		status_label.text = "Bottom half starting"
	else:
		inning += 1
		inning_label.text = "TOP %d" % inning
		status_label.text = "Top half starting"

	if inning > max_innings:
		game_over = true
		status_label.text = "Game over!"
		_set_commentary("Final score: %s %d - %s %d" % [team_name, score[0], opponent_name, score[1]])
		commentary.emit("Parents are already talking about the next warm-up.", "parent")
		return

	outs = 0
	balls = 0
	strikes = 0
	bases = [false, false, false]
	_update_hud()
	_start_pitch_cycle()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_swing"):
		_handle_swing()
