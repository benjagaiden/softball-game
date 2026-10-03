extends Node2D

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
var pitch_timer := 0.0
var game_over := false
var inning_bottom := false

func _ready() -> void:
    _build_field()
    _build_hud()
    commentary = preload("res://scripts/CommentaryManager.gd").new()
    add_child(commentary)
    _start_pitch_cycle()
    commentary.emit("Crowd starts chanting: 'Go Team! Go Team!'", "crowd")

func _build_field() -> void:
    field = Node2D.new()
    add_child(field)

    var grass = ColorRect.new()
    grass.color = Color("2a9d5a")
    grass.position = Vector2(0, 0)
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

    for i in range(3):
        var base = ColorRect.new()
        base.color = Color("f7f7f7")
        var base_pos = [Vector2(640, 150), Vector2(1040, 360), Vector2(640, 550)]
        base.position = base_pos[i]
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
    score_label.text = "%s 0  -  %s 0" % [team_name, opponent_name]
    score_label.position = Vector2(40, 70)
    score_label.add_theme_font_size_override("font_size", 26)
    score_label.add_theme_color_override("font_color", Color("ffe66d"))
    hud.add_child(score_label)

    count_label = Label.new()
    count_label.text = "BALLS 0  STRIKES 0  OUTS 0"
    count_label.position = Vector2(430, 36)
    count_label.add_theme_font_size_override("font_size", 22)
    count_label.add_theme_color_override("font_color", Color("dfe9ff"))
    hud.add_child(count_label)

    pitch_label = Label.new()
    pitch_label.text = "Pitch: FASTBALL"
    pitch_label.position = Vector2(430, 80)
    pitch_label.add_theme_font_size_override("font_size", 22)
    pitch_label.add_theme_color_override("font_color", Color("7ae582"))
    hud.add_child(pitch_label)

    status_label = Label.new()
    status_label.text = "Play in progress"
    status_label.position = Vector2(900, 34)
    status_label.add_theme_font_size_override("font_size", 22)
    status_label.add_theme_color_override("font_color", Color("f8d7a5"))
    hud.add_child(status_label)

    comment_label = Label.new()
    comment_label.text = "Parents in the bleachers: 'You can do it, sweetie!'"
    comment_label.position = Vector2(900, 78)
    comment_label.add_theme_font_size_override("font_size", 18)
    comment_label.add_theme_color_override("font_color", Color("fefefe"))
    comment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    comment_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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

func _start_pitch_cycle() -> void:
    current_pitch = ["fastball", "riseball", "curveball", "dropball", "screwball"][randi() % 5]
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
        swing_meter_value = sin(swing_timer * 10.0) * 0.5 + 0.5
        swing_meter.value = swing_meter_value
        if swing_timer > 1.8:
            swing_window_active = false
            _resolve_pitch_result(false)
            status_label.text = "Swing missed"

    if Input.is_action_just_pressed("toggle_swing"):
        _handle_swing()
    if Input.is_action_just_pressed("next_pitch"):
        _start_pitch_cycle()

func _handle_swing() -> void:
    if not swing_window_active:
        _resolve_pitch_result(false)
        return

    var swing_quality = abs(swing_meter_value - 0.5)
    if swing_quality < 0.28:
        _resolve_pitch_result(true)
    else:
        _resolve_pitch_result(false)

func _resolve_pitch_result(hit: bool) -> void:
    swing_window_active = false
    if hit:
        balls = 0
        strikes = 0
        status_label.text = "CRACK! A line drive!"
        commentary.emit("Teammates yell, 'Nice swing!'", "teammate")
        commentary.emit("A parent in the bleachers says, 'That ball has a little bit of mustard on it!'", "parent")
        _advance_runner()
    else:
        strikes += 1
        if strikes >= 3:
            outs += 1
            strikes = 0
            balls = 0
            status_label.text = "Strikeout!"
            commentary.emit("The dugout groans, but a parent says, 'Good hustle, kiddo!'")
        else:
            status_label.text = "Foul tip / miss"
            commentary.emit("The bench chants, 'Keep it moving!'", "teammate")
        count_label.text = "BALLS %d  STRIKES %d  OUTS %d" % [balls, strikes, outs]

    if outs >= 3:
        _advance_inning()
    else:
        _start_pitch_cycle()

func _advance_runner() -> void:
    score[0] += 1
    score_label.text = "%s %d  -  %s %d" % [team_name, score[0], opponent_name, score[1]]
    commentary.emit("Runner scores and the stands erupt!", "crowd")
    _start_pitch_cycle()

func _advance_inning() -> void:
    inning_bottom = not inning_bottom
    if inning_bottom:
        inning_label.text = "BOT %d" % inning
    else:
        inning += 1
        inning_label.text = "TOP %d" % inning
        if inning > max_innings:
            game_over = true
            status_label.text = "Game over!"
            comment_label.text = "Final score: %s %d - %s %d" % [team_name, score[0], opponent_name, score[1]]
            commentary.emit("Parents are already talking about the next warm-up!", "parent")
            return

    outs = 0
    balls = 0
    strikes = 0
    count_label.text = "BALLS %d  STRIKES %d  OUTS %d" % [balls, strikes, outs]
    status_label.text = "New half inning"
    commentary.emit("The bench laughs, 'We got this next half!'", "teammate")
    _start_pitch_cycle()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_swing"):
        _handle_swing()
