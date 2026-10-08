extends Node

var roster: Array[PlayerProfile] = []

func _ready() -> void:
	var power_hitter := PlayerProfile.new()
	power_hitter.id = "maya"
	power_hitter.name = "Maya"
	power_hitter.jersey_color = Color("ffcc66")
	power_hitter.accent_color = Color("2d6cdf")
	power_hitter.home_run_style = "bat_spin"
	power_hitter.on_base_style = "arms_up"
	power_hitter.slide_style = "scoot_left"
	power_hitter.special_hit_style = "burst_jump"

	var contact_hitter := PlayerProfile.new()
	contact_hitter.id = "nina"
	contact_hitter.name = "Nina"
	contact_hitter.jersey_color = Color("70e4ff")
	contact_hitter.accent_color = Color("ff6b6b")
	contact_hitter.home_run_style = "jump_pose"
	contact_hitter.on_base_style = "dance_tap"
	contact_hitter.slide_style = "scoot_right"
	contact_hitter.special_hit_style = "spin_wave"

	var flashy_runner := PlayerProfile.new()
	flashy_runner.id = "zoe"
	flashy_runner.name = "Zoe"
	flashy_runner.jersey_color = Color("b794f4")
	flashy_runner.accent_color = Color("f7b267")
	flashy_runner.home_run_style = "jump_pose"
	flashy_runner.on_base_style = "dance_tap"
	flashy_runner.slide_style = "scoot_left"
	flashy_runner.special_hit_style = "burst_jump"

	roster = [power_hitter, contact_hitter, flashy_runner]

func get_player_by_id(player_id: String) -> PlayerProfile:
	for player in roster:
		if player.id == player_id:
			return player
	return roster[0] if roster.size() > 0 else null
