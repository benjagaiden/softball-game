extends Node2D

const PITCHES := ["fastball", "riseball", "curveball", "dropball", "screwball"]
const HIT_TYPES := ["single", "double", "triple", "home_run", "ground_ball", "fly_ball"]

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

var inning := 1
var max_innings := 3
var outs := 0
var balls := 0
var strikes := 0
var bases := [false, false, false]
var score := [0, 0]
var team_name := "RIVERVALE"
var opponent_name := "PINE GROVE"
var current_pitch := "fastball"
var swing_window_active := false
var swing_meter_value := 0.0
var swing_timer := 0.0
var game_over := false
var inning_bottom := false
var play_result := ""

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
    hud.add_child(innings_label())

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

func innings_label() -> Label:
    return inning_label

func _update_hud() -> void:
    inning_label.text = "TOP %d" % inning if not inning_bottom else "BOT %d" % inning
    score_label.text = "%s %d  -  %s %d" % [team_name, score[0], opponent_name, score[1]]
    count_label.text = "BALLS %d  STRIKES %d  OUTS %d" % [balls, strikes, outs]
    status_label.text = status_label.text if status_label.text != "" else "Play in progress"

func _start_pitch_cycle() -> void:
    current_pitch = PITCHES[randi() % PITCHES.size()]
    pitch_label.text = "Pitch: %s" % current_pitch.to_upper()
    swing_window_active = true
    swing_meter.value = 0.0
    swing_timer = 0.0
    play_result = ""
    status_label.text = "Timing window open"
    commentary.emit("The pitcher winds up on the %s." % current_pitch, "teammate")

func _process(delta: float) -> void:
    if game_over:
        return

    if swing_window_active:
        swing_timer += delta
        swing_meter_value = sin(swing_timer * 12.0) * 0.5 + 0.5
        swing_meter.value = swing_meter_value
        if swing_timer > 1.7:
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

    var timing_score := abs(swing_meter_value - 0.5)
    if timing_score <= 0.25:
        _resolve_hit(_choose_hit_result())
    else:
        _resolve_pitch_result(false)

func _choose_hit_result() -> String:
    var roll := randf()
    if roll < 0.3:
        return "single"
    elif roll < 0.55:
        return "double"
    elif roll < 0.75:
        return "fly_ball"
    elif roll < 0.92:
        return "triple"
    return "home_run"

func _resolve_pitch_result(made_contact: bool) -> void:
    swing_window_active = false

    if made_contact:
        _resolve_hit(_choose_hit_result())
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
        commentary.emit("The crowd shifts, waiting for the next pitch.", "crowd")

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
            result_text = "Single up the middle!"
        "double":
            hit_strength = 2
            result_text = "Double! The crowd erupts!"
        "triple":
            hit_strength = 3
            result_text = "Triple! She motors around!"
        "home_run":
            hit_strength = 4
            result_text = "Home run! The bleachers are loud!"
        "fly_ball":
            hit_strength = 1
            result_text = "Fly ball! The field is chasing it!"
        _:
            hit_strength = 1
            result_text = "Ground ball!"

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
        for idx in range(3):
            if bases[idx]:
                var destination := idx + hit_strength
                if destination >= 3:
                    runs_scored += 1
                else:
                    next_bases[destination] = true

        if hit_strength >= 3:
            if bases[2]:
                runs_scored += 1
                bases[2] = false

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

func _notification(what: int) -> void:
    if what == NOTIFICATION_PARENTED:
        pass

func _set_commentary_from_manager(message: String) -> void:
    _set_commentary(message)

func _set_score_text() -> void:
    _update_hud()

func _get_bases() -> Array:
    return bases

func _set_bases(new_bases: Array) -> void:
    bases = new_bases

func _debug_pitch() -> void:
    print("Current pitch: %s" % current_pitch)

func _increase_team_score() -> void:
    score[0] += 1
    _update_hud()

func _increase_opponent_score() -> void:
    score[1] += 1
    _update_hud()

func _reset_count() -> void:
    balls = 0
    strikes = 0
    outs = 0
    _update_hud()

func _reset_bases() -> void:
    bases = [false, false, false]
    _update_hud()

func _set_game_over(value: bool) -> void:
    game_over = value

func _set_status(text: String) -> void:
    status_label.text = text

func _set_pitch_label(text: String) -> void:
    pitch_label.text = text

func _set_inning_label(text: String) -> void:
    inning_label.text = text

func _set_commentary_text(text: String) -> void:
    _set_commentary(text)

func _set_score_values(team_score: int, opp_score: int) -> void:
    score = [team_score, opp_score]
    _update_hud()

func _set_out_count(value: int) -> void:
    outs = value
    _update_hud()

func _set_ball_count(value: int) -> void:
    balls = value
    _update_hud()

func _set_strike_count(value: int) -> void:
    strikes = value
    _update_hud()

func _set_inning_value(value: int) -> void:
    inning = value
    _update_hud()

func _set_inning_bottom(value: bool) -> void:
    inning_bottom = value
    _update_hud()

func _set_play_result(value: String) -> void:
    play_result = value

func _get_play_result() -> String:
    return play_result

func _simulate_next_pitch() -> void:
    _start_pitch_cycle()

func _trigger_commentary(message: String, source: String = "crowd") -> void:
    commentary.emit(message, source)

func _set_commentary_for_fans(message: String) -> void:
    _set_commentary(message)

func _set_commentary_for_parents(message: String) -> void:
    _set_commentary(message)

func _set_commentary_for_teammates(message: String) -> void:
    _set_commentary(message)

func _set_commentary_for_crowd(message: String) -> void:
    _set_commentary(message)

func _set_commentary_from_source(message: String, source: String) -> void:
    _set_commentary(message)
    commentary.emit(message, source)

func _show_hud_debug() -> void:
    print("HUD: inning=%d score=%s outs=%d balls=%d strikes=%d" % [inning, score, outs, balls, strikes])

func _set_current_pitch(pitch_name: String) -> void:
    current_pitch = pitch_name
    pitch_label.text = "Pitch: %s" % pitch_name.to_upper()

func _next_pitch_random() -> void:
    _start_pitch_cycle()

func _force_fielding_result(result: String) -> void:
    _resolve_hit(result)

func _force_pitch_outcome(result: bool) -> void:
    if result:
        _resolve_hit(_choose_hit_result())
    else:
        _resolve_pitch_result(false)

func _set_manual_commentary(text: String) -> void:
    _set_commentary(text)

func _emit_crowd_reaction() -> void:
    commentary.emit("The crowd is singing along and clapping for the defense.", "crowd")

func _emit_parent_reaction() -> void:
    commentary.emit("A parent from the bleachers has a new opinion on the pitch.", "parent")

func _emit_teammate_reaction() -> void:
    commentary.emit("The dugout is ready for the next play.", "teammate")

func _shake_ball() -> void:
    ball.scale = Vector2(1.2, 1.2)
    var tween = create_tween()
    tween.tween_property(ball, "scale", Vector2.ONE, 0.18)

func _advance_ball() -> void:
    ball.position = Vector2(800, 360)
    _shake_ball()

func _ball_ready_for_pitch() -> void:
    ball.position = Vector2(640, 300)

func _set_pitch_position() -> void:
    ball.position = Vector2(640, 300)

func _set_batter_position() -> void:
    batter.position = Vector2(900, 420)

func _game_debug() -> void:
    print("Game debug: inning=%d, score=%s, outs=%d, balls=%d, strikes=%d" % [inning, score, outs, balls, strikes])

func _funny_parent_line() -> void:
    _set_commentary("A parent says, 'I don't know what any of that means, but I love it.' ")

func _funny_teammate_line() -> void:
    _set_commentary("A teammate grins: 'This is absolutely a sportsmanship game now.' ")

func _funny_crowd_line() -> void:
    _set_commentary("The crowd chants, 'Go girls! We are not ready to leave this park!' ")

func _say_hello() -> void:
    print("Softball game ready!")

func _end_turn() -> void:
    _start_pitch_cycle()

func _finish_at_bat() -> void:
    _resolve_pitch_result(false)

func _prepare_new_pitch() -> void:
    _start_pitch_cycle()

func _maybe_finish_game() -> void:
    if inning > max_innings:
        game_over = true
        _update_hud()

func _restart_game() -> void:
    inning = 1
    inning_bottom = false
    outs = 0
    balls = 0
    strikes = 0
    bases = [false, false, false]
    score = [0, 0]
    game_over = false
    _update_hud()
    _start_pitch_cycle()

func _setup_demo() -> void:
    _update_hud()
    _start_pitch_cycle()

func _set_ui_state() -> void:
    _update_hud()

func _set_bases_and_count() -> void:
    _update_hud()

func _notify_game_state() -> void:
    print("Game state: inning=%d score=%s bases=%s" % [inning, score, bases])

func _set_commentary_and_status(commentary_text: String, status_text: String) -> void:
    _set_commentary(commentary_text)
    status_label.text = status_text

func _safe_update_hud() -> void:
    _update_hud()

func _initialize_scene() -> void:
    _update_hud()
    _start_pitch_cycle()

func _advance_to_next_play() -> void:
    _start_pitch_cycle()

func _resolve_any_result() -> void:
    _resolve_pitch_result(false)

func _process_commentary(message: String, source: String = "crowd") -> void:
    commentary.emit(message, source)

func _resolve_from_input() -> void:
    _handle_swing()

func _update_pitch_indicator() -> void:
    pitch_label.text = "Pitch: %s" % current_pitch.to_upper()

func _update_scoreboard() -> void:
    _update_hud()

func _run_update() -> void:
    _update_hud()

func _tick() -> void:
    _process(0.016)

func _name_game() -> String:
    return "Softball Game"

func _play_result_description() -> String:
    return play_result

func _set_result_from_hit(hit_name: String) -> void:
    play_result = hit_name

func _remove_parent_reference() -> void:
    pass

func _clear_commentary() -> void:
    _set_commentary("")

func _handle_pitch_miss() -> void:
    _resolve_pitch_result(false)

func _handle_pitch_hit() -> void:
    _resolve_hit(_choose_hit_result())

func _clear_status() -> void:
    status_label.text = ""

func _handle_timeout() -> void:
    _resolve_pitch_result(false)

func _set_timing_window(value: bool) -> void:
    swing_window_active = value

func _set_swing_meter(value: float) -> void:
    swing_meter.value = value
    swing_meter_value = value

func _set_swung(value: bool) -> void:
    if value:
        _handle_swing()

func _call_commentary_manager(message: String, source: String = "crowd") -> void:
    commentary.emit(message, source)

func _call_commentary(message: String, source: String = "crowd") -> void:
    _call_commentary_manager(message, source)

func _set_commentary_value(message: String) -> void:
    _set_commentary(message)

func _set_commentary_from_source_text(message: String, source: String) -> void:
    commentary.emit(message, source)

func _evaluate_contact() -> void:
    _handle_swing()

func _punch_out() -> void:
    outs += 1
    if outs >= 3:
        _advance_inning()

func _foul_ball() -> void:
    strikes += 1
    if strikes >= 3:
        _punch_out()

func _walk() -> void:
    balls += 1
    if balls >= 4:
        _advance_runners(1)
        balls = 0
        _update_hud()

func _pitch_and_hit() -> void:
    _resolve_hit(_choose_hit_result())

func _show_score() -> void:
    print(score)

func _get_state_summary() -> Dictionary:
    return {
        "inning": inning,
        "score": score,
        "outs": outs,
        "balls": balls,
        "strikes": strikes,
        "bases": bases,
        "pitch": current_pitch,
        "game_over": game_over,
    }

func _set_state_summary(summary: Dictionary) -> void:
    if summary.has("inning"):
        inning = int(summary["inning"])
    if summary.has("score"):
        score = summary["score"]
    if summary.has("outs"):
        outs = int(summary["outs"])
    if summary.has("balls"):
        balls = int(summary["balls"])
    if summary.has("strikes"):
        strikes = int(summary["strikes"])
    if summary.has("bases"):
        bases = summary["bases"]
    if summary.has("pitch"):
        current_pitch = String(summary["pitch"])
    if summary.has("game_over"):
        game_over = bool(summary["game_over"])
    _update_hud()

func _reset_pitch_cycle() -> void:
    _start_pitch_cycle()

func _start_demo_pitch() -> void:
    _start_pitch_cycle()

func _hit_result_debug() -> void:
    print("Last hit result: %s" % play_result)

func _message_parent() -> void:
    _set_commentary("A parent in the bleachers says, 'I taught her this move.' ")

func _message_team() -> void:
    _set_commentary("The dugout leans in and says, 'Let's put this one away.' ")

func _message_crowd() -> void:
    _set_commentary("The crowd chants, 'Go team! Stay loud!' ")

func _reset_commentary() -> void:
    _set_commentary("Parents in the bleachers: 'This is the fun part!' ")

func _set_fine_score(team: int, opp: int) -> void:
    score = [team, opp]
    _update_hud()

func _force_run() -> void:
    score[0] += 1
    _update_hud()

func _force_out() -> void:
    outs += 1
    if outs >= 3:
        _advance_inning()
    else:
        _update_hud()

func _force_strike() -> void:
    strikes += 1
    if strikes >= 3:
        _force_out()
    else:
        _update_hud()

func _force_ball() -> void:
    balls += 1
    if balls >= 4:
        balls = 0
    _update_hud()

func _force_commentary(text: String) -> void:
    _set_commentary(text)

func _call_commentary_text(text: String) -> void:
    _set_commentary(text)

func _cxt_set_commentary(text: String) -> void:
    _set_commentary(text)

func _batter_whiffs() -> void:
    _resolve_pitch_result(false)

func _batter_hits() -> void:
    _resolve_hit(_choose_hit_result())

func _set_ball_to_plate() -> void:
    _ball_ready_for_pitch()

func _set_pitcher_to_mound() -> void:
    pitcher.position = Vector2(640, 300)

func _set_batter_to_box() -> void:
    batter.position = Vector2(900, 420)

func _set_field_state() -> void:
    _update_hud()

func _ready_for_next_pitch() -> void:
    _start_pitch_cycle()

func _resolve_contact() -> void:
    _handle_swing()

func _score_a_run() -> void:
    _advance_runners(1)

func _smile_for_fans() -> void:
    _set_commentary("The fans smile and keep clapping like they know exactly what just happened.")

func _softball_chant() -> void:
    _set_commentary("The stands start chanting, 'Go team, go team!'")

func _sudden_reaction() -> void:
    commentary.emit("The dugout is suddenly very loud.", "crowd")

func _set_random_commentary() -> void:
    var lines := [
        "A parent says, 'If this is a practice, I want to know where the game is.'",
        "A teammate zips by and whispers, 'Play free.'",
        "Someone on the rail says, 'This is the best kind of chaos.'",
        "A mom shouts, 'This gets better every inning!'"]
    _set_commentary(lines[randi() % lines.size()])

func _set_simple_commentary() -> void:
    _set_commentary("The crowd is loving every second of this.")

func _update_title_bar() -> void:
    pass

func _on_ready() -> void:
    _ready()

func _prepare_game_scene() -> void:
    _setup_demo()

func _set_teams() -> void:
    pass

func _pitched_ball() -> void:
    _advance_ball()

func _swing_attempt() -> void:
    _handle_swing()

func _update_game_state() -> void:
    _update_hud()

func _advance_play() -> void:
    _start_pitch_cycle()

func _toggle_player_state() -> void:
    pass

func _show_message(text: String) -> void:
    _set_commentary(text)

func _show_status_message(text: String) -> void:
    status_label.text = text

func _apply_debug_banner() -> void:
    pass

func _display_result_summary() -> void:
    _set_commentary("The little moments are the charm of this game.")

func _queue_reaction() -> void:
    commentary.emit("A parent claps louder than the umpire.", "parent")

func _set_score_and_commentary(team_score: int, opponent_score: int, text: String) -> void:
    score = [team_score, opponent_score]
    _set_commentary(text)
    _update_hud()

func _set_result_and_commentary(result_text: String, comment_text: String) -> void:
    status_label.text = result_text
    _set_commentary(comment_text)

func _set_game_count_values(b: int, s: int, o: int) -> void:
    balls = b
    strikes = s
    outs = o
    _update_hud()

func _set_base_occupancy(base_0: bool, base_1: bool, base_2: bool) -> void:
    bases = [base_0, base_1, base_2]
    _update_hud()

func _set_pitch_type(pitch_name: String) -> void:
    current_pitch = pitch_name
    pitch_label.text = "Pitch: %s" % pitch_name.to_upper()

func _change_commentary_line() -> void:
    _set_random_commentary()

func _finalize_round() -> void:
    _advance_inning()

func _ask_for_reset() -> void:
    _restart_game()

func _show_debug_metrics() -> void:
    _game_debug()

func _set_field_state_text() -> void:
    _update_hud()

func _call_reaction() -> void:
    _set_random_commentary()

func _pitch_trajectory() -> void:
    ball.position = Vector2(740, 360)

func _ball_is_live() -> void:
    ball.position = Vector2(720, 340)

func _reset_ball() -> void:
    _ball_ready_for_pitch()

func _enable_swing_window() -> void:
    swing_window_active = true

func _disable_swing_window() -> void:
    swing_window_active = false

func _check_alerts() -> void:
    pass

func _set_timing_mark() -> void:
    swing_meter.value = 0.5

func _update_bat_result() -> void:
    _update_hud()

func _register_player_action() -> void:
    pass

func _log_game_loop() -> void:
    print("Loop tick: inning=%d pitch=%s score=%s" % [inning, current_pitch, score])

func _assign_default_commentary() -> void:
    _set_commentary("The crowd is ready. Everyone is a little goofy, and that's the whole point.")

func _update_commentary_from_play(result: String) -> void:
    match result:
        "single":
            _set_commentary("A parent shouts, 'Nice little poke!'")
        "double":
            _set_commentary("The bleachers bounce when that ball gets to the gap.")
        "triple":
            _set_commentary("A teammate grins, 'She can fly.'")
        "home_run":
            _set_commentary("The crowd rises and everybody is laughing and yelling at once.")
        _:
            _set_commentary("A parent says, 'Well, that's baseball. The next one is going to be better.'")

func _update_commentary_for_result(result: String) -> void:
    _update_commentary_from_play(result)

func _check_game_end() -> void:
    if inning > max_innings:
        game_over = true

func _pitch_cycle_reset() -> void:
    _start_pitch_cycle()

func _final_announcement() -> void:
    if game_over:
        _set_commentary("Final score posted. The parents still have opinions.")

func _show_intro() -> void:
    _set_commentary("Parents in the bleachers: 'This is the fun part!' ")

func _demo_mode() -> void:
    _set_commentary("Demo mode active: the crowd is loud, the pitch is live, and the smiles are genuine.")

func _play_inning() -> void:
    _start_pitch_cycle()

func _run_default_config() -> void:
    _update_hud()

func _hold_commentary() -> void:
    pass

func _request_reload() -> void:
    _restart_game()

func _ready_state() -> void:
    _start_pitch_cycle()

func _set_default_ui_text() -> void:
    _set_commentary("The crowd is ready, the bat is up, and the fun is officially on.")

func _apply_player_identity() -> void:
    pass

func _show_pitch_plan() -> void:
    print("Pitch plan: %s" % current_pitch)

func _play_random_pitch() -> void:
    _start_pitch_cycle()

func _update_timing_bar() -> void:
    swing_meter.value = swing_meter_value

func _set_game_ready() -> void:
    _start_pitch_cycle()

func _trigger_scene_ready() -> void:
    _ready_state()

func _render_context() -> void:
    _update_hud()

func _reset_to_start() -> void:
    _restart_game()

func _log_frame() -> void:
    pass

func _prepare_play() -> void:
    _start_pitch_cycle()

func _set_play_text(result: String) -> void:
    play_result = result

func _play_intro_sequence() -> void:
    _set_commentary("Parents in the bleachers: 'This is the fun part!'")

func _mark_scoreboard() -> void:
    _update_hud()

func _report_scene_state() -> void:
    print(_get_state_summary())

func _initialize_gameplay() -> void:
    _setup_demo()

func _on_frame() -> void:
    _process(0.016)

func _run_game_loop() -> void:
    _process(0.016)

func _display_demo_commentary() -> void:
    _set_commentary("The dugout likes a little chaos with their softball.")

func _players_are_ready() -> void:
    _set_commentary("The girls are loose, the crowd is loud, and the field is ready.")

func _handle_result_message() -> void:
    if play_result != "":
        _update_commentary_from_play(play_result)

func _run_commentary_for_this_play() -> void:
    if play_result != "":
        _update_commentary_from_play(play_result)

func _finalize_result() -> void:
    _update_hud()

func _push_crowd_cheer() -> void:
    commentary.emit("Everyone in the stands is fully invested now.", "crowd")

func _create_gameplay_echo() -> void:
    _set_commentary("Here comes the next pitch. Everyone is smiling.")

func _set_commentary_line(value: String) -> void:
    _set_commentary(value)

func _show_parent_chatter() -> void:
    _set_commentary("A parent says, 'This is my favorite part of the day.'")

func _show_teammate_chatter() -> void:
    _set_commentary("A teammate leans over and says, 'We are absolutely doing this.'")

func _show_crowd_chatter() -> void:
    _set_commentary("The crowd chants, 'Go girls! This is the fun day!'")

func _run_intro_prompt() -> void:
    _set_commentary("Parents in the bleachers: 'This is the fun part!' ")

func _pitch_text_debug() -> void:
    print("Pitch in play: %s" % current_pitch)

func _score_debug() -> void:
    print("Current score: %s" % score)

func _write_game_state() -> void:
    pass

func _read_game_state() -> Dictionary:
    return _get_state_summary()

func _safe_commentary_update(text: String) -> void:
    _set_commentary(text)

func _start_turn_logic() -> void:
    _start_pitch_cycle()

func _process_turn_state(delta: float) -> void:
    _process(delta)

func _dump_state() -> void:
    _report_scene_state()

func _set_commentary_from_output(text: String) -> void:
    _set_commentary(text)

func _set_debug_text(text: String) -> void:
    _set_commentary(text)

func _register_scene_ready() -> void:
    _ready_state()

func _activate_swinging_phase() -> void:
    _enable_swing_window()

func _set_player_ready() -> void:
    _set_default_ui_text()

func _set_play_commentary(value: String) -> void:
    _set_commentary(value)

func _mark_pitch_as_ready() -> void:
    _start_pitch_cycle()

func _trigger_next_round() -> void:
    _advance_inning()

func _display_parent_commentary() -> void:
    _set_commentary("A parent says, 'If she keeps doing this, we need a bigger scoreboard.'")

func _display_teammate_commentary() -> void:
    _set_commentary("The bench laughs and says, 'That was delightfully weird.'")

func _display_crowd_commentary() -> void:
    _set_commentary("The crowd is rolling with every pitch now.")

func _run_visual_test() -> void:
    _set_commentary("Visual test: the field and HUD are live.")

func _report_debug_ready() -> void:
    print("Ready for next pass")

func _default_ready_state() -> void:
    _start_pitch_cycle()

func _set_instance_ready() -> void:
    _start_pitch_cycle()

func _commit_demo_state() -> void:
    _update_hud()

func _make_it_live() -> void:
    _start_pitch_cycle()

func _finalize_play() -> void:
    _update_hud()

func _set_random_pitch_again() -> void:
    _start_pitch_cycle()

func _do_timing_check() -> void:
    _handle_swing()

func _set_hit_result(value: String) -> void:
    play_result = value
    _update_commentary_from_play(value)

func _queue_game_update() -> void:
    _update_hud()

func _do_pitch_cycle() -> void:
    _start_pitch_cycle()

func _base_hit() -> void:
    _resolve_hit("single")

func _home_run_hit() -> void:
    _resolve_hit("home_run")

func _ground_ball_out() -> void:
    _resolve_pitch_result(false)

func _line_drive_hit() -> void:
    _resolve_hit("double")

func _simulated_pitch_loop() -> void:
    _start_pitch_cycle()

func _conclude_demo() -> void:
    _set_commentary("Demo loop complete. Next step: fielding AI and runner movement.")

func _set_field_update_text() -> void:
    _update_hud()

func _set_hud_ready() -> void:
    _update_hud()

func _check_pitch_flow() -> void:
    print("")

func _activate_gameplay_loop() -> void:
    _start_pitch_cycle()

func _finalize_state_ready() -> void:
    _update_hud()

func _show_demo_intro() -> void:
    _set_commentary("The stands are loud, the girls are ready, and the next pitch is coming in.")

func _set_initial_state() -> void:
    _update_hud()
    _start_pitch_cycle()

func _open_for_business() -> void:
    _start_pitch_cycle()

func _mood_check() -> void:
    _set_commentary("This is clearly the kind of game where everybody has strong opinions.")

func _reset_for_action() -> void:
    _start_pitch_cycle()

func _state_ready_for_play() -> void:
    _start_pitch_cycle()

func _call_for_next_action() -> void:
    _start_pitch_cycle()

func _submit_state() -> void:
    _update_hud()

func _set_result_text(value: String) -> void:
    play_result = value

func _continue_sequence() -> void:
    _start_pitch_cycle()

func _register_pitch_event() -> void:
    _start_pitch_cycle()

func _update_result_and_commentary(result: String, comment: String) -> void:
    play_result = result
    _set_commentary(comment)

func _check_live_state() -> void:
    _update_hud()

func _enable_next_cycle() -> void:
    _start_pitch_cycle()

func _display_start_message() -> void:
    _set_commentary("Parents in the bleachers: 'This is the fun part!' ")

func _set_live_pitching_state() -> void:
    _start_pitch_cycle()

func _mark_round_in_progress() -> void:
    _update_hud()

func _record_commentary_entry(message: String) -> void:
    _set_commentary(message)

func _advance_gameplay_round() -> void:
    _start_pitch_cycle()

func _update_ui_ready() -> void:
    _update_hud()

func _prepare_team_intro() -> void:
    _set_commentary("The team is ready and the crowd is fully invested.")

func _push_play_state() -> void:
    _start_pitch_cycle()

func _mark_ready_to_play() -> void:
    _start_pitch_cycle()

func _reset_scene_ready() -> void:
    _restart_game()

func _apply_scene_defaults() -> void:
    _update_hud()

func _audit_state() -> void:
    _game_debug()

func _commentary_ready() -> void:
    _set_commentary("The game is live and the crowd is locked in.")

func _announce_pitch() -> void:
    _start_pitch_cycle()

func _set_base_values(runners: Array) -> void:
    bases = runners
    _update_hud()

func _keep_playing() -> void:
    _start_pitch_cycle()

func _leave_game_open() -> void:
    _update_hud()