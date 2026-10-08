extends Resource
class_name PlayerProfile

@export var id: String = "player_01"
@export var name: String = "Maya"
@export var jersey_color: Color = Color("ffcc66")
@export var accent_color: Color = Color("2d6cdf")

@export var home_run_style: String = "bat_spin"
@export var on_base_style: String = "arms_up"
@export var slide_style: String = "scoot_left"
@export var power_hit_style: String = "triple_bounce"
@export var special_hit_style: String = "burst_jump"

@export var cheer_bonus: float = 12.0
@export var celebration_scale: float = 1.0
