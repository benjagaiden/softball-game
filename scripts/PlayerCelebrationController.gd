extends Node2D

var profile: PlayerProfile
var sprite: Sprite2D
var particles: CPUParticles2D

func _ready() -> void:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.texture = _make_placeholder_texture()
		add_child(sprite)
	if particles == null:
		particles = CPUParticles2D.new()
		particles.amount = 18
		particles.lifetime = 0.6
		particles.spread = 60.0
		particles.initial_velocity_min = 40.0
		particles.initial_velocity_max = 90.0
		particles.gravity = Vector2(0, 120)
		particles.linear_accel_min = 0.0
		particles.linear_accel_max = 8.0
		particles.radial_accel_min = 0.0
		particles.radial_accel_max = 8.0
		particles.emitting = false
		add_child(particles)

func set_profile(new_profile: PlayerProfile) -> void:
	profile = new_profile
	if sprite != null and profile != null:
		sprite.modulate = profile.jersey_color
		particles.color = profile.accent_color
		particles.modulate = profile.accent_color

func trigger_home_run() -> void:
	match profile.home_run_style:
		"bat_spin":
			_play_bat_spin()
		"jump_pose":
			_play_jump_pose()
		_:
			_play_default_home_run()

func trigger_on_base() -> void:
	match profile.on_base_style:
		"arms_up":
			_play_arms_up()
		"dance_tap":
			_play_dance_tap()
		_:
			_play_default_on_base()

func trigger_slide() -> void:
	match profile.slide_style:
		"scoot_left":
			_play_slide_left()
		"scoot_right":
			_play_slide_right()
		_:
			_play_default_slide()

func trigger_special_hit() -> void:
	match profile.special_hit_style:
		"burst_jump":
			_play_burst_jump()
		"spin_wave":
			_play_spin_wave()
		_:
			_play_default_special_hit()

func _play_bat_spin() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 360.0, 0.7)
	tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.15)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)
	particles.emitting = true
	var reset := create_tween()
	reset.tween_callback(func() -> void:
		particles.emitting = false
	).set_delay(0.28)

func _play_jump_pose() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 26.0, 0.18)
	tween.tween_property(self, "position:y", position.y, 0.2)
	if sprite != null:
		sprite.modulate = Color(1.2, 1.2, 1.2, 1.0)

func _play_arms_up() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)

func _play_dance_tap() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x + 8.0, 0.1)
	tween.tween_property(self, "position:x", position.x - 8.0, 0.1)
	tween.tween_property(self, "position:x", position.x, 0.12)

func _play_slide_left() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x - 26.0, 0.18)
	tween.tween_property(self, "position:x", position.x, 0.24)

func _play_slide_right() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x + 26.0, 0.18)
	tween.tween_property(self, "position:x", position.x, 0.24)

func _play_burst_jump() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 36.0, 0.12)
	tween.tween_property(self, "position:y", position.y, 0.18)
	tween.parallel().tween_property(self, "scale", Vector2(1.22, 1.22), 0.15)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)
	particles.emitting = true
	var reset := create_tween()
	reset.tween_callback(func() -> void:
		particles.emitting = false
	).set_delay(0.28)

func _play_spin_wave() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", 180.0, 0.22)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.18)
	tween.tween_property(self, "scale", Vector2(1.14, 1.14), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)
	particles.emitting = true

func _play_default_home_run() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)

func _play_default_on_base() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)

func _play_default_slide() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", position.x - 18.0, 0.12)
	tween.tween_property(self, "position:x", position.x, 0.22)

func _play_default_special_hit() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.24, 1.24), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	particles.emitting = true

func _make_placeholder_texture() -> Texture2D:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 1.0))
	var texture := ImageTexture.create_from_image(image)
	return texture
