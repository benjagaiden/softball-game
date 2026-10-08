extends Node2D

var profile: PlayerProfile
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D

func set_profile(new_profile: PlayerProfile) -> void:
	profile = new_profile
	sprite.modulate = profile.jersey_color

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

func _play_bat_spin() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 360.0, 0.7)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)
	particles.emitting = true

func _play_jump_pose() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 26, 0.18)
	tween.tween_property(self, "position:y", position.y, 0.2)
	sprite.modulate = Color(1.2, 1.2, 1.2, 1)

func _play_arms_up() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)

func _play_dance_tap() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 8, 0.1)
	tween.tween_property(self, "position:x", position.x - 8, 0.1)
	tween.tween_property(self, "position:x", position.x, 0.12)

func _play_slide_left() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 26, 0.18)
	tween.tween_property(self, "position:x", position.x, 0.24)

func _play_default_home_run() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)

func _play_default_on_base() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)

func _play_default_slide() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 18, 0.12)
	tween.tween_property(self, "position:x", position.x, 0.22)